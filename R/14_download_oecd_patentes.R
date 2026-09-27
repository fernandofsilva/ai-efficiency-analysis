# 14_download_oecd_patentes.R
# Baixa do OECD Data Explorer (API SDMX, sem autenticação) as famílias de
# patentes relacionadas a IA por país de residência do inventor: contagem
# fracionária, data de prioridade, famílias IP5 e triádicas, 2010 em diante.
# Fonte: OECD.STI.PIE, dataflow DSD_PATENTS@DF_PATENTS_OECDSPECIFIC,
# tecnologia "AI" (Technologies related to artificial intelligence), unidade
# PATN_FM (famílias). Cache em data/oecd-ai/.
# Uso: Rscript R/14_download_oecd_patentes.R

source("R/00_setup.R")

BaixarPatentesOecd <- function(autoridade, arquivo, inicio = 2010,
                               forcar = FALSE) {
  # autoridade: "9P50_3" (famílias IP5) ou "9P50_2" (famílias triádicas).
  # Chave SDMX (11 dimensões): PATENT_AUTHORITIES.FREQ.MEASURE.UNIT_MEASURE.
  # DATE_TYPE.REF_AREA.PARTNER_AREA.AGENT_ROLE.COOPERATION_TYPE.WIPO.
  # OECD_TECHNOLOGY_PATENT; REF_AREA vazio = todos os países.
  if (file.exists(arquivo) && !forcar) {
    return(utils::read.csv(arquivo, stringsAsFactors = FALSE))
  }
  chave <- sprintf("%s.A.PF.PATN_FM.PRIORITY.._Z.INVENTOR._Z._Z.AI",
                   autoridade)
  url <- paste0(
    "https://sdmx.oecd.org/public/rest/data/",
    "OECD.STI.PIE,DSD_PATENTS@DF_PATENTS_OECDSPECIFIC,1.0/", chave,
    "?startPeriod=", inicio,
    "&dimensionAtObservation=AllDimensions&format=csvfilewithlabels")
  handle <- curl::new_handle(timeout = 300, useragent = "Mozilla/5.0 (R)")
  texto <- rawToChar(curl::curl_fetch_memory(url, handle = handle)$content)
  if (!grepl("^STRUCTURE", texto)) {
    stop("API SDMX da OCDE não devolveu dados: ", substr(texto, 1, 200))
  }
  bruto <- utils::read.csv(text = texto, stringsAsFactors = FALSE,
                           check.names = FALSE)
  saida <- data.frame(
    iso3c = bruto$REF_AREA,
    pais = bruto[["Reference area"]],
    ano = as.integer(bruto$TIME_PERIOD),
    familias = as.numeric(bruto$OBS_VALUE),
    autoridade = autoridade,
    baixado_em = format(Sys.Date()),
    stringsAsFactors = FALSE)
  saida <- saida[order(saida$iso3c, saida$ano), ]
  utils::write.csv(saida, arquivo, row.names = FALSE)
  return(saida)
}

dir.create("data/oecd-ai", showWarnings = FALSE)
ip5 <- BaixarPatentesOecd("9P50_3", "data/oecd-ai/patentes_ia_ip5_inventor.csv")
triadicas <- BaixarPatentesOecd(
  "9P50_2", "data/oecd-ai/patentes_ia_triadicas_inventor.csv")

for (nome in c("ip5", "triadicas")) {
  dados <- get(nome)
  paises <- dados[nchar(dados$iso3c) == 3, ]
  total_ano <- tapply(paises$familias, paises$ano, sum)
  Registrar(nome, ":", nrow(paises), "linhas,",
            length(unique(paises$iso3c)), "países,", min(paises$ano), "-",
            max(paises$ano), "| total mundial por ano:",
            paste(names(total_ano), round(total_ano), sep = "=",
                  collapse = " "))
}
Registrar("FIM download de patentes OCDE")
