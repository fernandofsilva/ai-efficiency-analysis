# funcoes.R
# Funções auxiliares compartilhadas pelos scripts do projeto.
# Projeto: eficiência dos países na conversão de investimento em IA em
# publicações e patentes (Introdução à Análise de Eficiência em R).
# Estilo: Google R Style Guide (funções em BigCamelCase, return() explícito,
# funções externas qualificadas com ::, indentação de 2 espaços).

Registrar <- function(...) {
  # Imprime uma mensagem de log com carimbo de hora.
  cat(format(Sys.time(), "%H:%M:%S"), ..., "\n")
  return(invisible(NULL))
}

BaixarWorldBank <- function(codigo, fonte = NULL, inicio = 2010, fim = 2024,
                            pasta = "data/wdi", forcar = FALSE,
                            timeout = 300) {
  # Baixa um indicador do World Bank (API v2) com cache em CSV.
  #
  # Args:
  #   codigo: código do indicador (ex.: "SP.POP.TOTL").
  #   fonte: id da fonte na API (NULL = padrão; 3 = WGI).
  #   inicio, fim: intervalo de anos.
  #   pasta: pasta de cache (arquivo <codigo>.csv).
  #   forcar: TRUE para baixar de novo mesmo com cache.
  #   timeout: tempo máximo da requisição em segundos.
  #
  # Returns:
  #   data.frame com iso3c, pais, ano, valor e codigo.
  dir.create(pasta, showWarnings = FALSE, recursive = TRUE)
  arquivo <- file.path(pasta, paste0(codigo, ".csv"))
  if (file.exists(arquivo) && !forcar) {
    return(utils::read.csv(arquivo, stringsAsFactors = FALSE))
  }
  sufixo_fonte <- if (is.null(fonte)) "" else paste0("&source=", fonte)
  url <- sprintf(
    paste0("https://api.worldbank.org/v2/en/country/all/indicator/%s",
           "?format=json&date=%d:%d&per_page=20000%s"),
    codigo, inicio, fim, sufixo_fonte)
  agente <- "Mozilla/5.0 (R; projeto-eficiencia-ia)"
  handle <- curl::new_handle(timeout = timeout, useragent = agente)
  resposta <- curl::curl_fetch_memory(url, handle = handle)
  texto <- rawToChar(resposta$content)
  json <- jsonlite::fromJSON(texto, simplifyVector = TRUE)
  if (length(json) < 2 || is.null(json[[2]])) {
    stop("API do World Bank sem dados para ", codigo, ": ",
         substr(texto, 1, 200))
  }
  dados <- json[[2]]
  saida <- data.frame(
    iso3c = dados$countryiso3code,
    pais = dados$country$value,
    ano = as.integer(dados$date),
    valor = as.numeric(dados$value),
    codigo = codigo,
    stringsAsFactors = FALSE)
  saida <- saida[saida$iso3c != "", ]
  utils::write.csv(saida, arquivo, row.names = FALSE)
  return(saida)
}

LerWorldBank <- function(codigo, nome_valor, pasta = "data/wdi") {
  # Lê um indicador do cache (baixando se necessário) em formato largo
  # mínimo: iso3c, ano, <nome_valor>.
  dados <- BaixarWorldBank(codigo, pasta = pasta)
  saida <- dados[, c("iso3c", "ano", "valor")]
  names(saida)[3] <- nome_valor
  return(saida)
}

HarmonizarRenda <- function(x) {
  # Unifica as grafias de IncomeLevel do dataset original em três níveis.
  x <- tolower(gsub("[_ ]+", " ", x))
  saida <- dplyr::case_when(
    grepl("^high", x) ~ "Alta renda",
    grepl("upper", x) ~ "Renda média-alta",
    grepl("lower", x) ~ "Renda média-baixa",
    TRUE ~ NA_character_)
  return(saida)
}

ParaEscala01 <- function(farrell) {
  # Converte a medida de Farrell orientada a produto (F >= 1) para (0, 1].
  return(1 / farrell)
}

ClassificarRts <- function(f_crs, f_vrs, f_nirs, tolerancia = 1e-6) {
  # Classifica a região de retornos de escala de cada DMU (orientação a
  # produto) pela regra de Färe, Grosskopf e Lovell:
  # F_crs == F_vrs -> CRS; F_nirs == F_crs -> IRS; caso contrário DRS.
  saida <- ifelse(abs(f_crs - f_vrs) < tolerancia, "CRS",
                  ifelse(abs(f_nirs - f_crs) < tolerancia, "IRS", "DRS"))
  return(saida)
}

CalcularDea <- function(x, y, id, rts = "vrs") {
  # Roda DEA orientada a produto (Benchmarking) e devolve tabela arrumada.
  #
  # Args:
  #   x, y: matrizes de insumos (n x m) e produtos (n x s).
  #   id: identificador das DMUs.
  #   rts: "crs", "vrs", "drs" (= NIRS) ou "irs".
  x <- as.matrix(x)
  y <- as.matrix(y)
  modelo <- Benchmarking::dea(x, y, RTS = rts, ORIENTATION = "out",
                              SLACK = TRUE)
  farrell <- as.numeric(Benchmarking::eff(modelo))
  saida <- data.frame(
    id = id,
    farrell = farrell,
    escore = ParaEscala01(farrell),
    folga_insumos = rowSums(as.matrix(modelo$sx)),
    folga_produtos = rowSums(as.matrix(modelo$sy)),
    stringsAsFactors = FALSE)
  return(saida)
}

BootstrapDea <- function(x, y, id, rts = "vrs", n_rep = 2000, alpha = 0.05) {
  # Bootstrap homogêneo de Simar e Wilson (1998) via Benchmarking::dea.boot.
  # Devolve escore original, corrigido de viés e IC, na escala (0, 1].
  x <- as.matrix(x)
  y <- as.matrix(y)
  boot <- Benchmarking::dea.boot(x, y, NREP = n_rep, RTS = rts,
                                 ORIENTATION = "out", alpha = alpha)
  saida <- data.frame(
    id = id,
    farrell = as.numeric(boot$eff),
    farrell_bc = as.numeric(boot$eff.bc),
    escore = ParaEscala01(as.numeric(boot$eff)),
    escore_bc = ParaEscala01(as.numeric(boot$eff.bc)),
    # O limite superior de F corresponde ao limite inferior do escore.
    ic_inf = ParaEscala01(as.numeric(boot$conf.int[, 2])),
    ic_sup = ParaEscala01(as.numeric(boot$conf.int[, 1])),
    vies = as.numeric(boot$bias),
    stringsAsFactors = FALSE)
  return(saida)
}

SpearmanComIc <- function(a, b, n_boot = 2000, semente = 2026) {
  # Correlação de Spearman com IC percentílico por bootstrap.
  set.seed(semente)
  completos <- stats::complete.cases(a, b)
  a <- a[completos]
  b <- b[completos]
  rho <- stats::cor(a, b, method = "spearman")
  replicas <- replicate(n_boot, {
    indice <- sample(length(a), replace = TRUE)
    stats::cor(a[indice], b[indice], method = "spearman")
  })
  saida <- c(rho = rho,
             ic_inf = unname(stats::quantile(replicas, 0.025)),
             ic_sup = unname(stats::quantile(replicas, 0.975)),
             n = length(a))
  return(saida)
}

SalvarTabela <- function(dados, nome, pasta = "output/tables") {
  # Grava uma tabela em CSV na pasta de saída.
  dir.create(pasta, showWarnings = FALSE, recursive = TRUE)
  utils::write.csv(dados, file.path(pasta, paste0(nome, ".csv")),
                   row.names = FALSE)
  return(invisible(dados))
}

MediaGeometrica <- function(x) {
  # Média geométrica ignorando NA (usada nos índices de Malmquist).
  x <- x[!is.na(x) & x > 0]
  return(exp(mean(log(x))))
}

BaixarPaisesWorldBank <- function(pasta = "data/wdi", forcar = FALSE) {
  # Baixa a lista de economias do World Bank com região e grupo de renda
  # (classificação vigente), com cache em data/wdi/paises_world_bank.csv.
  arquivo <- file.path(pasta, "paises_world_bank.csv")
  if (file.exists(arquivo) && !forcar) {
    return(utils::read.csv(arquivo, stringsAsFactors = FALSE))
  }
  url <- "https://api.worldbank.org/v2/country?format=json&per_page=400"
  handle <- curl::new_handle(timeout = 300, useragent = "Mozilla/5.0 (R)")
  texto <- rawToChar(curl::curl_fetch_memory(url, handle = handle)$content)
  dados <- jsonlite::fromJSON(texto, simplifyVector = TRUE)[[2]]
  saida <- data.frame(iso3c = dados$id, pais_wb = dados$name,
                      regiao_wb = dados$region$value,
                      renda_wb = dados$incomeLevel$value,
                      stringsAsFactors = FALSE)
  saida <- saida[saida$regiao_wb != "Aggregates", ]
  utils::write.csv(saida, arquivo, row.names = FALSE)
  return(saida)
}

InterpolarPorPais <- function(dados, coluna, id = "iso3c", tempo = "ano") {
  # Interpola linearmente valores faltantes de `coluna` dentro de cada país
  # (extremos repetidos), marcando as células imputadas em <coluna>_imputado.
  nova <- paste0(coluna, "_imputado")
  dados[[nova]] <- is.na(dados[[coluna]])
  for (p in unique(dados[[id]])) {
    idx <- which(dados[[id]] == p)
    x <- dados[[tempo]][idx]
    y <- dados[[coluna]][idx]
    ok <- !is.na(y)
    if (sum(ok) >= 2 && any(!ok)) {
      dados[[coluna]][idx] <- stats::approx(x[ok], y[ok], xout = x,
                                            rule = 2)$y
    }
  }
  return(dados)
}
