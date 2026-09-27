# 15_download_msti.R
# Baixa do OECD Data Explorer (API SDMX) os gastos em P&D por setor de
# execução do MSTI: HERD (ensino superior), GOVERD (governo) e GERD, como
# percentual do PIB, para todas as economias disponíveis (membros da OCDE e
# parceiros como Argentina, China, Romênia, Rússia, Singapura, África do Sul,
# Taiwan). Cache em data/msti/. O P&D público (HERD + GOVERD) entra como
# insumo alternativo ao GERD total (hipótese H2).
# Fonte: OECD.STI.STP, dataflow DSD_MSTI@DF_MSTI, medidas H, GV e G, unidade
# PT_B1GQ (% do PIB).
# Uso: Rscript R/15_download_msti.R

source("R/00_setup.R")

pasta <- "data/msti"
dir.create(pasta, showWarnings = FALSE)
arquivo <- file.path(pasta, "msti_pd_setor_pct_pib.csv")

BaixarMsti <- function(forcar = FALSE) {
  if (file.exists(arquivo) && !forcar) {
    return(utils::read.csv(arquivo, stringsAsFactors = FALSE))
  }
  # Chave: REF_AREA.FREQ.MEASURE.UNIT_MEASURE.PRICE_BASE.TRANSFORMATION
  url <- paste0(
    "https://sdmx.oecd.org/public/rest/data/OECD.STI.STP,DSD_MSTI@DF_MSTI,1.0/",
    ".A.H+GV+G.PT_B1GQ..?startPeriod=2010",
    "&dimensionAtObservation=AllDimensions&format=csvfilewithlabels")
  handle <- curl::new_handle(timeout = 300, useragent = "Mozilla/5.0 (R)")
  texto <- rawToChar(curl::curl_fetch_memory(url, handle = handle)$content)
  if (!grepl("^STRUCTURE", texto)) {
    stop("API SDMX (MSTI) não devolveu dados: ", substr(texto, 1, 200))
  }
  bruto <- utils::read.csv(text = texto, stringsAsFactors = FALSE,
                           check.names = FALSE)
  longo <- data.frame(iso3c = bruto$REF_AREA, pais = bruto[["Reference area"]],
                      ano = as.integer(bruto$TIME_PERIOD),
                      medida = bruto$MEASURE,
                      valor = as.numeric(bruto$OBS_VALUE),
                      stringsAsFactors = FALSE)
  largo <- longo |>
    dplyr::mutate(medida = dplyr::recode(medida, H = "herd_pct_pib",
                                         GV = "goverd_pct_pib",
                                         G = "gerd_msti_pct_pib")) |>
    tidyr::pivot_wider(names_from = medida, values_from = valor) |>
    dplyr::mutate(pd_publico_pct_pib = herd_pct_pib + goverd_pct_pib,
                  baixado_em = format(Sys.Date())) |>
    dplyr::arrange(iso3c, ano)
  utils::write.csv(largo, arquivo, row.names = FALSE)
  return(as.data.frame(largo))
}

BaixarEurostat <- function(geos = c("BG", "HR", "RS", "UA"),
                           arquivo_eu = file.path(pasta,
                                                  "eurostat_gerd_setor.csv"),
                           forcar = FALSE) {
  # Eurostat rd_e_gerdtot: GERD por setor de execução (% do PIB) para
  # membros e candidatos da UE ausentes do MSTI (Bulgária, Croácia, Sérvia;
  # Ucrânia sem dados). Devolve iso3c, ano, herd, goverd e soma.
  if (file.exists(arquivo_eu) && !forcar) {
    return(utils::read.csv(arquivo_eu, stringsAsFactors = FALSE))
  }
  url <- paste0(
    "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/",
    "rd_e_gerdtot?format=JSON&lang=EN&unit=PC_GDP&sectperf=HES&sectperf=GOV",
    paste0("&geo=", geos, collapse = ""))
  handle <- curl::new_handle(timeout = 120, useragent = "Mozilla/5.0 (R)")
  resposta <- curl::curl_fetch_memory(url, handle = handle)
  json <- jsonlite::fromJSON(rawToChar(resposta$content),
                             simplifyVector = FALSE)
  ids <- unlist(json$id)
  tamanhos <- unlist(json$size)
  categorias <- lapply(ids, function(d) {
    indice <- json$dimension[[d]]$category$index
    names(indice)[order(unlist(indice))]
  })
  linhas <- lapply(names(json$value), function(chave) {
    resto <- as.integer(chave)
    posicoes <- integer(length(tamanhos))
    for (k in rev(seq_along(tamanhos))) {
      posicoes[k] <- resto %% tamanhos[k]
      resto <- resto %/% tamanhos[k]
    }
    rotulos <- mapply(function(cat, pos) cat[pos + 1], categorias, posicoes)
    data.frame(geo = rotulos[ids == "geo"],
               setor = rotulos[ids == "sectperf"],
               ano = as.integer(rotulos[ids == "time"]),
               valor = as.numeric(json$value[[chave]]),
               stringsAsFactors = FALSE)
  })
  longo <- do.call(rbind, linhas)
  largo <- longo |>
    tidyr::pivot_wider(names_from = setor, values_from = valor) |>
    dplyr::transmute(iso3c = countrycode::countrycode(geo, "eurostat",
                                                      "iso3c"),
                     pais = countrycode::countrycode(geo, "eurostat",
                                                     "country.name"),
                     ano, herd_pct_pib = HES, goverd_pct_pib = GOV,
                     gerd_msti_pct_pib = NA_real_,
                     pd_publico_pct_pib = HES + GOV,
                     baixado_em = format(Sys.Date()), fonte = "Eurostat")
  utils::write.csv(largo, arquivo_eu, row.names = FALSE)
  return(as.data.frame(largo))
}

msti <- BaixarMsti()
msti$fonte <- "MSTI"
eurostat <- tryCatch(BaixarEurostat(), error = function(e) {
  Registrar("Eurostat indisponível:", conditionMessage(e))
  NULL
})
if (!is.null(eurostat)) {
  novos <- eurostat[!eurostat$iso3c %in% msti$iso3c, ]
  msti <- rbind(msti, novos[, names(msti)])
  Registrar("Eurostat: acrescentados", length(unique(novos$iso3c)), "países:",
            paste(unique(novos$iso3c), collapse = ", "))
  utils::write.csv(msti, arquivo, row.names = FALSE)
}
paises <- msti[nchar(msti$iso3c) == 3, ]
Registrar("MSTI:", nrow(paises), "linhas,", length(unique(paises$iso3c)),
          "economias,", min(paises$ano), "-", max(paises$ano),
          "| com HERD e GOVERD:", sum(!is.na(paises$pd_publico_pct_pib)))
painel <- utils::read.csv("data/processed/painel_ia.csv",
                          stringsAsFactors = FALSE)
no_painel <- unique(painel$iso3c)
cobertos <- unique(paises$iso3c[!is.na(paises$pd_publico_pct_pib)])
Registrar("países do painel cobertos:", sum(no_painel %in% cobertos), "de",
          length(no_painel), "| faltam:",
          paste(sort(setdiff(no_painel, cobertos)), collapse = ", "))
print(as.data.frame(paises[paises$iso3c %in% c("USA", "CHN", "ISR", "KOR") &
                             paises$ano == 2021, ]))
