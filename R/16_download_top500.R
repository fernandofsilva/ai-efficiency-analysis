# 16_download_top500.R
# Baixa as listas semestrais do TOP500 (junho e novembro, 2013 em diante) em
# planilha, sem autenticação, para data/top500/, e agrega o número de
# sistemas e o desempenho Rmax por país e ano (média das duas listas do ano)
# em data/top500/top500_pais_ano.csv. Proxy de capital computacional para o
# segundo estágio.
# Uso: Rscript R/16_download_top500.R

source("R/00_setup.R")

pasta <- "data/top500"
dir.create(pasta, showWarnings = FALSE)
anos <- 2013:as.integer(format(Sys.Date(), "%Y"))
meses <- c("06", "11")

BaixarListaTop500 <- function(ano, mes) {
  # Devolve o caminho local da planilha (baixa se necessário) ou NA.
  # O site limita a taxa de requisições: pausa entre listas e até três
  # tentativas; se continuar falhando, baixar manualmente (download livre
  # na página de cada lista) e salvar em data/top500/ com o mesmo nome.
  arquivo <- file.path(pasta, sprintf("TOP500_%d%s.xlsx", ano, mes))
  if (file.exists(arquivo)) {
    return(arquivo)
  }
  url <- sprintf(
    "https://www.top500.org/lists/top500/%d/%s/download/TOP500_%d%s.xlsx/",
    ano, mes, ano, mes)
  for (tentativa in 1:3) {
    Sys.sleep(15 * tentativa)
    ok <- tryCatch({
      curl::curl_download(url, arquivo,
                          handle = curl::new_handle(timeout = 120,
                                                    useragent = "Mozilla/5.0"))
      TRUE
    }, error = function(e) FALSE)
    if (ok && file.size(arquivo) >= 20000) {
      return(arquivo)
    }
    if (file.exists(arquivo)) file.remove(arquivo)
  }
  return(NA_character_)
}

LerListaTop500 <- function(arquivo, ano, mes) {
  dados <- readxl::read_excel(arquivo)
  coluna_rmax <- grep("^Rmax", names(dados), value = TRUE)[1]
  saida <- data.frame(pais = dados$Country,
                      rmax = as.numeric(dados[[coluna_rmax]]),
                      ano = ano, lista = paste0(ano, mes),
                      stringsAsFactors = FALSE)
  return(saida)
}

listas <- list()
for (ano in anos) {
  for (mes in meses) {
    arquivo <- BaixarListaTop500(ano, mes)
    if (is.na(arquivo)) {
      Registrar("lista indisponível:", ano, mes)
      next
    }
    listas[[paste0(ano, mes)]] <- LerListaTop500(arquivo, ano, mes)
  }
}
todas <- do.call(rbind, listas)
todas$iso3c <- countrycode::countrycode(todas$pais, "country.name", "iso3c",
                                        warn = FALSE)
Registrar("listas lidas:", length(listas), "| sistemas:", nrow(todas),
          "| sem ISO3:", paste(unique(todas$pais[is.na(todas$iso3c)]),
                              collapse = "; "))

por_lista <- todas |>
  dplyr::filter(!is.na(iso3c)) |>
  dplyr::group_by(iso3c, ano, lista) |>
  dplyr::summarise(sistemas = dplyr::n(), rmax_tflops = sum(rmax, na.rm = TRUE),
                   .groups = "drop")
por_ano <- por_lista |>
  dplyr::group_by(iso3c, ano) |>
  dplyr::summarise(top500_sistemas = mean(sistemas),
                   top500_rmax_tflops = mean(rmax_tflops),
                   listas_no_ano = dplyr::n(), .groups = "drop")
utils::write.csv(por_ano, file.path(pasta, "top500_pais_ano.csv"),
                 row.names = FALSE)
Registrar("top500_pais_ano.csv:", nrow(por_ano), "linhas,",
          length(unique(por_ano$iso3c)), "países,", min(por_ano$ano), "-",
          max(por_ano$ano))
print(as.data.frame(por_ano[por_ano$iso3c %in% c("USA", "CHN", "BRA", "JPN") &
                              por_ano$ano %in% c(2016, 2021), ]))
