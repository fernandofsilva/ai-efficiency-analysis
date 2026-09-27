# 01_prep_dataset_atual.R
# Prepara o dataset original (data/AI_INVESTMENT.csv) para a Fase A:
# harmoniza grupos de renda, converte patentes por milhão em contagem com a
# população do World Bank, cria o GERD em US$, marca zeros e valores-piso do
# investimento e grava data/processed/base_atual.csv com descritivas.
# Uso: Rscript R/01_prep_dataset_atual.R

source("R/00_setup.R")

# Leitura ---------------------------------------------------------------------
bruto <- utils::read.csv("data/AI_INVESTMENT.csv", stringsAsFactors = FALSE)
Registrar("linhas lidas:", nrow(bruto), "| países:",
          length(unique(bruto$Country)))

base <- bruto |>
  dplyr::transmute(
    pais = Country,
    iso3c = countrycode::countrycode(Country, "country.name", "iso3c"),
    ano = as.integer(Year),
    regiao = GeogLoc,
    grupo_renda = HarmonizarRenda(IncomeLevel),
    investimento = AI.Investment,          # US$ constantes de 2021
    investimento_pib = AI_Investment_per_GDP,
    publicacoes = AI.Publications,          # contagem
    patentes_pm = AI.Patent.Applications,   # por milhão de habitantes
    pd_pct_pib = R.D_Percentage,
    pib = GDP.constant,                     # US$ constantes de 2015
    pib_pc = GDP.per.capita,
    credito_privado = Domestic_Credit,
    controle_corrupcao = Corruption_Estimate,
    efetividade_governo = Government_Effectiveness,
    alta_tec_export = High_Tech_Export_Percentage,
    market_cap = MarketCap,
    npl = Non.performing.Loans,
    zscore = Z_Score,
    comercio = Trade_Percentage,
    patentes_totais = Total_Patents)

stopifnot(!any(is.na(base$iso3c)), !any(is.na(base$grupo_renda)))

# População (World Bank, cache em data/wdi/) ----------------------------------
populacao <- LerWorldBank("SP.POP.TOTL", "populacao")
base <- dplyr::left_join(base, populacao, by = c("iso3c", "ano"))
stopifnot(!any(is.na(base$populacao)))

# Patentes: de "por milhão" para contagem --------------------------------------
base$patentes_bruto <- base$patentes_pm * base$populacao / 1e6
base$patentes <- round(base$patentes_bruto)
desvio_max <- max(abs(base$patentes_bruto - base$patentes))
Registrar("desvio máximo da contagem inteira de patentes:",
          round(desvio_max, 3))

# GERD em US$ constantes de 2015 (P&D % PIB x PIB) ----------------------------
base$gerd <- base$pd_pct_pib / 100 * base$pib

# Marcas de qualidade do insumo -----------------------------------------------
base$inv_zero <- base$investimento == 0
base$inv_piso <- base$investimento > 0 & base$investimento <= 2.5e6
Registrar("zeros de investimento:", sum(base$inv_zero),
          "| valores-piso (<= 2,5 M):", sum(base$inv_piso))

# Transformações úteis ---------------------------------------------------------
base$log_pib_pc <- log(base$pib_pc)
base$log_comercio <- log(base$comercio)
base$id <- paste(base$iso3c, base$ano, sep = "-")

base <- base |>
  dplyr::arrange(pais, ano) |>
  dplyr::relocate(id, pais, iso3c, ano, regiao, grupo_renda)

# Descritivas e cobertura -----------------------------------------------------
variaveis <- c("investimento", "gerd", "publicacoes", "patentes",
               "patentes_pm", "pd_pct_pib", "pib_pc", "populacao",
               "efetividade_governo", "controle_corrupcao", "alta_tec_export",
               "market_cap", "credito_privado", "npl", "zscore", "comercio")
descritiva <- do.call(rbind, lapply(variaveis, function(v) {
  x <- base[[v]]
  data.frame(variavel = v, n = sum(!is.na(x)), media = mean(x, na.rm = TRUE),
             dp = stats::sd(x, na.rm = TRUE), minimo = min(x, na.rm = TRUE),
             mediana = stats::median(x, na.rm = TRUE),
             maximo = max(x, na.rm = TRUE))
}))
SalvarTabela(descritiva, "descritiva_base_atual")

cobertura <- base |>
  dplyr::count(pais, grupo_renda, name = "n_anos") |>
  dplyr::arrange(dplyr::desc(n_anos))
SalvarTabela(cobertura, "cobertura_base_atual")

renda_por_ano <- base |>
  dplyr::count(ano, grupo_renda) |>
  tidyr::pivot_wider(names_from = grupo_renda, values_from = n,
                     values_fill = 0)
SalvarTabela(renda_por_ano, "renda_por_ano_base_atual")

# Correlações insumo-produto (isotonicidade) -----------------------------------
isotonia <- stats::cor(
  base[, c("investimento", "gerd", "publicacoes", "patentes")],
  method = "spearman")
SalvarTabela(as.data.frame(round(isotonia, 3)), "isotonicidade_base_atual")
print(round(isotonia, 2))

utils::write.csv(base, "data/processed/base_atual.csv", row.names = FALSE)
Registrar("gravado data/processed/base_atual.csv com", nrow(base), "linhas e",
          ncol(base), "colunas")
