# 11_import_cset.R
# Fase B: importa os arquivos anuais do CSET (data/cat/), filtra o campo
# "All", aplica as flags de completude, mapeia países para ISO3, deflaciona o
# investimento para US$ constantes de 2021 (CPI dos EUA) e grava
# data/processed/cset_long.csv (uma linha por país-ano).
# Uso: Rscript R/11_import_cset.R

source("R/00_setup.R")

LerCset <- function(arquivo, coluna_valor, nome) {
  # Lê um arquivo anual do CSET e devolve país, ano, valor e flag completo.
  dados <- utils::read.csv(file.path("data/cat", arquivo),
                           stringsAsFactors = FALSE)
  dados <- dados[dados$field == "All", ]
  saida <- data.frame(pais_cset = dados$country, ano = as.integer(dados$year),
                      valor = as.numeric(dados[[coluna_valor]]),
                      stringsAsFactors = FALSE)
  if ("complete" %in% names(dados)) {
    saida$completo <- dados$complete %in% c("True", "TRUE", TRUE)
  } else {
    saida$completo <- NA
  }
  names(saida)[3:4] <- c(nome, paste0(nome, "_completo"))
  return(saida)
}

artigos <- LerCset("publications_yearly_articles.csv", "num_articles",
                   "artigos")
citacoes <- LerCset("publications_yearly_citations.csv", "num_citations",
                    "citacoes")
pedidos <- LerCset("patents_yearly_applications.csv",
                   "num_patent_applications", "patentes_pedidos")
concedidas <- LerCset("patents_yearly_granted.csv", "num_patent_granted",
                      "patentes_concedidas")
inv_est <- LerCset("companies_yearly_estimated.csv", "estimated_investment",
                   "inv_estimado_mi")
inv_div <- LerCset("companies_yearly_disclosed.csv", "disclosed_investment",
                   "inv_divulgado_mi")

cset <- artigos |>
  dplyr::full_join(citacoes[, 1:3], by = c("pais_cset", "ano")) |>
  dplyr::full_join(pedidos, by = c("pais_cset", "ano")) |>
  dplyr::full_join(concedidas, by = c("pais_cset", "ano")) |>
  dplyr::full_join(inv_est, by = c("pais_cset", "ano")) |>
  dplyr::full_join(inv_div, by = c("pais_cset", "ano"))

# ISO3 -----------------------------------------------------------------------
cset$iso3c <- countrycode::countrycode(cset$pais_cset, "country.name", "iso3c",
                                       warn = FALSE)
sem_iso <- unique(cset$pais_cset[is.na(cset$iso3c)])
if (length(sem_iso) > 0) {
  Registrar("sem ISO3 (descartados):", paste(sem_iso, collapse = "; "))
}
cset <- cset[!is.na(cset$iso3c), ]

# Regras de completude: métricas incompletas viram NA (mantendo o bruto) -----
cset$publicacoes <- ifelse(cset$artigos_completo %in% TRUE, cset$artigos, NA)
cset$patentes <- ifelse(cset$patentes_pedidos_completo %in% TRUE,
                        cset$patentes_pedidos, NA)
cset$patentes_concedidas_ok <- ifelse(
  cset$patentes_concedidas_completo %in% TRUE, cset$patentes_concedidas, NA)
# Citações não têm flag: janela de citação curta nos anos recentes; usamos
# apenas até 2020 nas análises ajustadas por qualidade.
cset$citacoes_ok <- ifelse(cset$ano <= 2020, cset$citacoes, NA)

# Índia: série de pedidos de patente quebrada a partir de 2019 --------------
quebra_india <- cset$iso3c == "IND" & cset$ano >= 2019
cset$patentes_suspeitas <- quebra_india
cset$patentes[quebra_india] <- NA
cset$patentes_concedidas_ok[quebra_india] <- NA

# Deflação do investimento: milhões de US$ nominais -> US$ constantes 2021 ---
cpi <- BaixarWorldBank("FP.CPI.TOTL")
cpi_eua <- cpi[cpi$iso3c == "USA", c("ano", "valor")]
names(cpi_eua)[2] <- "cpi_eua"
cpi_2021 <- cpi_eua$cpi_eua[cpi_eua$ano == 2021]
cset <- dplyr::left_join(cset, cpi_eua, by = "ano")
# Anos sem CPI ainda publicado (2025-2026) usam o último disponível.
ultimo_cpi <- cpi_eua$cpi_eua[which.max(cpi_eua$ano)]
cset$cpi_eua[is.na(cset$cpi_eua)] <- ultimo_cpi
cset$fator_2021 <- cpi_2021 / cset$cpi_eua
cset$investimento <- ifelse(cset$inv_estimado_mi_completo %in% TRUE,
                            cset$inv_estimado_mi * 1e6 * cset$fator_2021, NA)
cset$investimento_divulgado <- ifelse(cset$inv_divulgado_mi_completo %in% TRUE,
                                      cset$inv_divulgado_mi * 1e6 *
                                        cset$fator_2021, NA)

cset <- cset |>
  dplyr::arrange(iso3c, ano) |>
  dplyr::relocate(iso3c, pais_cset, ano)
utils::write.csv(cset, "data/processed/cset_long.csv", row.names = FALSE)
Registrar("gravado data/processed/cset_long.csv:", nrow(cset), "linhas,",
          length(unique(cset$iso3c)), "países,", min(cset$ano), "-",
          max(cset$ano))

# Reconciliação com o dataset original (US$ 2021) ----------------------------
checagem <- cset[cset$iso3c %in% c("ARG", "LUX", "CHN") &
                   cset$ano %in% c(2018, 2021),
                 c("iso3c", "ano", "publicacoes", "patentes", "inv_estimado_mi",
                   "fator_2021", "investimento")]
print(checagem)
