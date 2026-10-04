# 07_tabelas_manuscrito.R
# Tabelas descritivas do manuscrito (artigo/20) a partir do painel
# reconstruído: estatísticas da amostra da DEA (país-ano usados no modelo
# conjunto, 2017-2021) e medianas por ano dos insumos e produtos. Escores,
# testes e regressões vêm das tabelas dos scripts 02 a 06; aqui só se
# descreve a amostra, no mesmo formato de descritiva_base_atual.csv.
# Uso: Rscript R/07_tabelas_manuscrito.R (depois da cadeia do painel, que
# grava dea_ano_m2_painel.csv)

source("R/00_setup.R")

arquivo_base <- "data/processed/painel_ia.csv"
arquivo_amostra <- "output/tables/dea_ano_m2_painel.csv"

painel <- utils::read.csv(arquivo_base, stringsAsFactors = FALSE)
RegistrarEntrada(arquivo_amostra)
amostra_dea <- utils::read.csv(arquivo_amostra, stringsAsFactors = FALSE)
amostra <- painel[painel$id %in% amostra_dea$id, ]
if (nrow(amostra) != nrow(amostra_dea)) {
  stop("a amostra da DEA não foi encontrada inteira no painel")
}

# Insumos em milhões (investimento) e bilhões (GERD) de US$; produtos em
# contagem; contexto nas unidades do World Bank.
amostra$investimento_l1_mi <- amostra$investimento_l1 / 1e6
amostra$gerd_l1_bi <- amostra$gerd_l1 / 1e9

variaveis <- c(
  investimento_l1_mi =
    "investimento privado em IA em t-1 (milhões de US$ de 2021)",
  gerd_l1_bi = "GERD em t-1 (bilhões de US$ de 2015)",
  publicacoes = "artigos de IA",
  patentes = "famílias de patentes de IA (país de prioridade)",
  efetividade_governo = "WGI: efetividade governamental",
  qualidade_regulatoria = "WGI: qualidade regulatória",
  estado_direito = "WGI: estado de direito",
  controle_corrupcao = "WGI: controle da corrupção",
  pesquisadores_pm = "pesquisadores em P&D por milhão de habitantes",
  alta_tec_export = "exportações de alta tecnologia (% das manufaturadas)",
  comercio = "comércio (% do PIB)",
  credito_privado = "crédito doméstico ao setor privado (% do PIB)",
  market_cap = "capitalização de mercado (% do PIB)",
  npl = "empréstimos inadimplentes (% do total)",
  pib_pc = "PIB per capita (US$ de 2015)")

Descrever <- function(x) {
  # Estatísticas de uma variável, ignorando faltantes (n = casos válidos).
  x <- x[!is.na(x)]
  return(c(n = length(x), media = mean(x), dp = stats::sd(x),
           minimo = min(x), mediana = stats::median(x), maximo = max(x)))
}

descritiva <- data.frame(
  variavel = names(variaveis),
  descricao = unname(variaveis),
  t(vapply(names(variaveis), function(v) Descrever(amostra[[v]]),
           numeric(6))),
  row.names = NULL, stringsAsFactors = FALSE)
SalvarTabela(descritiva, "manuscrito_descritiva_painel")

# Medianas por ano: o insumo cresce muito mais depressa que os produtos, o
# que pesa na posição de cada país em relação à fronteira (artigo/01, RQ1).
medianas_ano <- do.call(rbind, lapply(sort(unique(amostra$ano)), function(a) {
  d <- amostra[amostra$ano == a, ]
  return(data.frame(
    ano = a, n = nrow(d),
    investimento_l1_mi = stats::median(d$investimento_l1_mi),
    gerd_l1_bi = stats::median(d$gerd_l1_bi),
    publicacoes = stats::median(d$publicacoes),
    patentes = stats::median(d$patentes)))
}))
SalvarTabela(medianas_ano, "manuscrito_medianas_ano_painel")

Registrar("Descritiva do painel:", nrow(amostra), "país-ano,",
          length(unique(amostra$iso3c)), "países")
RegistrarManifesto("07_tabelas_manuscrito.R", "_painel", arquivo_base, "ok",
                   detalhe = "amostra da DEA lida em manifesto_entradas.csv")
Registrar("FIM tabelas do manuscrito")
