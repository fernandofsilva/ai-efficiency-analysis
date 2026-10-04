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

ConfigurarPadronizacao <- function() {
  # Lê a padronização das variáveis da fronteira (insumos e produtos da DEA)
  # das variáveis de ambiente:
  #   PADRONIZACAO: "nenhuma" (padrão: unidades originais, insumos em
  #                 milhões de US$ e produtos em contagem) ou "minmax";
  #   EPSILON_PADRONIZACAO: piso da escala min-max, em (0, 1) (padrão 0,01).
  # A min-max leva cada variável a [epsilon, 1] com
  #   z = epsilon + (1 - epsilon) (x - mín) / (máx - mín),
  # no mesmo sentido para insumos e produtos (o insumo continua insumo). O
  # piso epsilon evita insumo zero (unidade eficiente por construção) e
  # produto zero. Os modelos radiais são invariantes à escala, mas não à
  # translação: a min-max equivale a somar a cada variável a constante
  # epsilon (máx - mín) / (1 - epsilon) - mín, e é, portanto, outra
  # especificação, e não a mesma DEA em outra escala.
  # Devolve lista com metodo, epsilon e o sufixo dos arquivos de saída
  # ("" sem padronização; "_minmax" com epsilon = 0,01; "_minmax_eps<e>"
  # com outro epsilon).
  metodo <- Sys.getenv("PADRONIZACAO", "nenhuma")
  if (!metodo %in% c("nenhuma", "minmax")) {
    stop("PADRONIZACAO deve ser 'nenhuma' ou 'minmax', não '", metodo, "'")
  }
  epsilon <- as.numeric(Sys.getenv("EPSILON_PADRONIZACAO", "0.01"))
  if (!is.finite(epsilon) || epsilon <= 0 || epsilon >= 1) {
    stop("EPSILON_PADRONIZACAO deve estar em (0, 1)")
  }
  sufixo <- if (metodo == "nenhuma") {
    ""
  } else if (isTRUE(all.equal(epsilon, 0.01))) {
    "_minmax"
  } else {
    paste0("_minmax_eps", format(epsilon))
  }
  return(list(metodo = metodo, epsilon = epsilon, sufixo = sufixo))
}

ParametrosPadronizacao <- function(base, colunas, config) {
  # Mínimo e máximo de cada variável da fronteira na amostra de referência:
  # observações com as colunas completas, todos os anos agrupados e
  # incluindo investimento zero. Com os mesmos parâmetros em todas as
  # análises de uma execução (fronteiras anuais, fronteira agrupada,
  # metafronteira, Malmquist e sensibilidades), a transformação é uma só.
  # Devolve NULL sem padronização.
  if (config$metodo == "nenhuma") {
    return(NULL)
  }
  referencia <- base[stats::complete.cases(base[, colunas]), colunas,
                     drop = FALSE]
  saida <- data.frame(
    coluna = colunas,
    minimo = vapply(referencia, min, numeric(1)),
    maximo = vapply(referencia, max, numeric(1)),
    metodo = config$metodo, epsilon = config$epsilon,
    n_referencia = nrow(referencia), stringsAsFactors = FALSE)
  rownames(saida) <- NULL
  if (any(saida$maximo <= saida$minimo)) {
    stop("variável sem amplitude na amostra de referência: ",
         paste(saida$coluna[saida$maximo <= saida$minimo], collapse = ", "))
  }
  return(saida)
}

MatrizFronteira <- function(dados, colunas, parametros, escala = 1) {
  # Matriz de insumos ou produtos usada nas fronteiras. Sem padronização
  # (parametros = NULL), devolve as colunas divididas por `escala` (1e6 nos
  # insumos: milhões de US$), exatamente como nas versões anteriores; com
  # padronização, aplica a min-max com os parâmetros da execução, e
  # `escala` é irrelevante (a min-max é invariante à escala).
  x <- as.matrix(dados[, colunas, drop = FALSE])
  if (is.null(parametros)) {
    if (escala != 1) x <- x / escala
    return(x)
  }
  for (j in seq_along(colunas)) {
    p <- parametros[parametros$coluna == colunas[j], ]
    if (nrow(p) != 1) {
      stop("sem parâmetros de padronização para ", colunas[j])
    }
    z <- p$epsilon + (1 - p$epsilon) * (x[, j] - p$minimo) /
      (p$maximo - p$minimo)
    if (any(z < p$epsilon - 1e-12 | z > 1 + 1e-12, na.rm = TRUE)) {
      stop(colunas[j], ": valores fora da amostra de referência da ",
           "padronização")
    }
    x[, j] <- z
  }
  return(x)
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
  # Réplicas (Farrell) por DMU, para agregações posteriores (ex.: média
  # por país ao longo dos anos com incerteza de bootstrap).
  attr(saida, "replicas") <- boot$boot
  return(saida)
}

SpearmanComIc <- function(a, b, n_boot = 2000, semente = 2026, grupo = NULL,
                          limiar = NULL) {
  # Correlação de Spearman com IC percentílico por bootstrap. Se `grupo`
  # (ex.: país) for informado, a reamostragem é por bloco (trajetórias
  # completas), respeitando a repetição de observações por unidade. Se
  # `limiar` for informado, devolve o p-valor unilateral bootstrap de
  # H0: rho >= limiar (fração de réplicas com rho >= limiar).
  set.seed(semente)
  completos <- stats::complete.cases(a, b)
  a <- a[completos]
  b <- b[completos]
  if (!is.null(grupo)) grupo <- grupo[completos]
  rho <- stats::cor(a, b, method = "spearman")
  replicas <- replicate(n_boot, {
    if (is.null(grupo)) {
      indice <- sample(length(a), replace = TRUE)
    } else {
      blocos <- sample(unique(grupo), replace = TRUE)
      indice <- unlist(lapply(blocos, function(g) which(grupo == g)))
    }
    stats::cor(a[indice], b[indice], method = "spearman")
  })
  replicas <- replicas[is.finite(replicas)]
  saida <- c(rho = rho,
             ic_inf = unname(stats::quantile(replicas, 0.025)),
             ic_sup = unname(stats::quantile(replicas, 0.975)),
             n = length(a),
             n_blocos = if (is.null(grupo)) {
               NA_real_
             } else {
               length(unique(grupo))
             })
  if (!is.null(limiar)) {
    saida <- c(saida, p_h0_rho_maior_igual_limiar = mean(replicas >= limiar))
  }
  return(saida)
}

RegistrarManifesto <- function(script, sufixo, base, status, detalhe = "",
                               arquivo = file.path("output/tables",
                                                   "manifesto_execucoes.csv")) {
  # Registra uma linha por execução (id, script, sufixo, base e seu hash
  # MD5, horário e status) e, em manifesto_saidas.csv, uma linha por tabela
  # gravada nesta execução com o MD5 do arquivo, para vincular cada saída à
  # configuração e à execução que a geraram.
  config <- ConfigurarPadronizacao()
  if (config$metodo != "nenhuma") {
    detalhe <- paste0(detalhe, if (nzchar(detalhe)) "; " else "",
                      "padronizacao=", config$metodo, " epsilon=",
                      config$epsilon)
  }
  horario <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  id_execucao <- paste0(sub("\\.R$", "", script), sufixo, "@",
                        format(Sys.time(), "%Y%m%d%H%M%S"))
  linha <- data.frame(
    id_execucao = id_execucao, horario = horario, script = script,
    sufixo = sufixo, base = base,
    md5_base = if (file.exists(base)) unname(tools::md5sum(base)) else NA,
    insumos = Sys.getenv("INSUMOS", "investimento,gerd"),
    produtos = Sys.getenv("PRODUTOS", "publicacoes,patentes"),
    status = status, detalhe = detalhe, stringsAsFactors = FALSE)
  utils::write.table(linha, arquivo, sep = ",", row.names = FALSE,
                     col.names = !file.exists(arquivo),
                     append = file.exists(arquivo))
  saidas <- .registro_saidas$arquivos
  if (length(saidas) > 0) {
    arquivo_saidas <- file.path(dirname(arquivo), "manifesto_saidas.csv")
    tab <- data.frame(id_execucao = id_execucao, horario = horario,
                      script = script, sufixo = sufixo, arquivo = saidas,
                      md5 = unname(tools::md5sum(saidas)), status = status,
                      stringsAsFactors = FALSE)
    utils::write.table(tab, arquivo_saidas, sep = ",", row.names = FALSE,
                       col.names = !file.exists(arquivo_saidas),
                       append = file.exists(arquivo_saidas))
    .registro_saidas$arquivos <- character(0)
  }
  return(invisible(linha))
}

DistanciaShephard <- function(x, y, rts, xref = NULL, yref = NULL) {
  # Distância de Shephard orientada a produto (<= 1) = 1 / Farrell, com
  # tempo máximo por LP; LPs interrompidos devolvem NA. Se xref/yref forem
  # dados, as unidades (x, y) são avaliadas contra essa tecnologia de
  # referência (usado no bootstrap: observações originais contra a
  # pseudofronteira, como em Simar e Wilson).
  modelo <- Benchmarking::dea(x, y, RTS = rts, ORIENTATION = "out",
                              XREF = xref, YREF = yref,
                              CONTROL = list(timeout = 10))
  return(1 / as.numeric(Benchmarking::eff(modelo)))
}

ArredondarEmUm <- function(x, tolerancia = 1e-5) {
  # Fixa em exatamente 1 os valores a menos de `tolerancia` de 1 (ruído
  # numérico da LP), como faz a implementação de referência do rDEA.
  x[abs(x - 1) < tolerancia] <- 1
  return(x)
}

SortearSuavizado <- function(d, h = stats::bw.nrd0(d)) {
  # Bootstrap homogêneo suavizado com reflexão em 1 (Simar e Wilson, 1998)
  # aplicado às distâncias de Shephard (<= 1), com as mesmas escolhas da
  # implementação de referência (rDEA::rts.test): largura de banda de
  # Silverman calculada na amostra original (bw.nrd0), sorteio da mistura
  # gaussiana, reflexão em 1 e correção de variância pela média e pela
  # variância da amostra original. Valores negativos (sorteios abaixo de
  # zero, fora do suporte) são levados a 1e-4: a pseudo-unidade resultante
  # fica no interior da tecnologia e não afeta a pseudofronteira.
  n <- length(d)
  beta_til <- sample(d, n, replace = TRUE) + h * stats::rnorm(n)
  beta_til <- ifelse(beta_til > 1, 2 - beta_til, beta_til)
  d_estrela <- mean(d) + (beta_til - mean(d)) / sqrt(1 + h^2 / stats::var(d))
  d_estrela <- ifelse(d_estrela > 1, 2 - d_estrela, d_estrela)
  d_estrela <- pmin(pmax(d_estrela, 1e-4), 1)
  return(d_estrela)
}

TesteRtsBootstrap <- function(x, y, h0 = "crs", n_rep = 1000) {
  # Teste de retornos de escala adaptado de Simar e Wilson (2002), com a
  # mesma construção da implementação de referência (rDEA::rts.test,
  # estatística 4.6): S = mean(D_H0) / mean(D_VRS); pseudo-produtos gerados
  # sob H0 pela projeção na fronteira H0 e reposicionamento com distância
  # sorteada; réplicas com qualquer LP falho são descartadas por inteiro.
  # O tamanho do teste NÃO é controlado em amostras finitas (validação em
  # R/02c_validacao_rts.R, também para a referência): os p-valores são
  # diagnósticos exploratórios, não decisões com erro tipo I de 5%.
  d_h0 <- ArredondarEmUm(DistanciaShephard(x, y, h0))
  d_vrs <- ArredondarEmUm(DistanciaShephard(x, y, "vrs"))
  ok <- is.finite(d_h0) & is.finite(d_vrs)
  s_obs <- mean(d_h0[ok]) / mean(d_vrs[ok])
  x_ok <- x[ok, , drop = FALSE]
  y_ok <- y[ok, , drop = FALSE]
  h <- stats::bw.nrd0(d_h0[ok])
  s_boot <- vapply(seq_len(n_rep), function(b) {
    d_estrela <- SortearSuavizado(d_h0[ok], h)
    # Pseudo-amostra sob H0 (projeção na fronteira H0 e reposicionamento);
    # as observações ORIGINAIS são avaliadas contra a pseudofronteira,
    # como no algoritmo de Simar e Wilson (1998, 2002).
    y_estrela <- y_ok * (d_estrela / d_h0[ok])
    d1 <- DistanciaShephard(x_ok, y_ok, h0, xref = x_ok, yref = y_estrela)
    d2 <- DistanciaShephard(x_ok, y_ok, "vrs", xref = x_ok, yref = y_estrela)
    if (any(!is.finite(d1)) || any(!is.finite(d2))) return(NA_real_)
    mean(d1) / mean(d2)
  }, numeric(1))
  validas <- is.finite(s_boot)
  s_boot <- s_boot[validas]
  # p-valor com a correção (k + 1) / (B + 1), como na referência.
  saida <- list(estatistica = s_obs,
                p_valor = (sum(s_boot <= s_obs) + 1) / (length(s_boot) + 1),
                replicas_validas = sum(validas), n = sum(ok),
                largura_banda = h,
                s_boot_q05 = unname(stats::quantile(s_boot, 0.05)),
                s_boot_mediana = stats::median(s_boot))
  return(saida)
}

AjustarTruncada <- function(formula, d, dependente = "log_escore") {
  # Regressão truncada (truncreg) em uma de três parametrizações, com
  # verificação explícita da convergência ANTES de devolver coeficientes:
  #   "log_escore":  dependente = log do escore corrigido, em (-Inf, 0),
  #                  truncada à direita em 0. É o modelo de Simar e Wilson
  #                  (2007) aplicado ao logaritmo da medida de Farrell
  #                  (transformação monótona), com suporte compatível com
  #                  o escore em (0, 1) e numericamente estável mesmo nos
  #                  canais com escores próximos de zero; coeficiente
  #                  positivo = MAIS eficiente (semi-elasticidade);
  #   "escore_1lim": dependente = escore em (0, 1], truncada só à direita
  #                  em 1 (suporte (-Inf, 1); especificação das versões
  #                  anteriores, mantida para comparação);
  #   "farrell":     dependente = Farrell corrigido (>= 1), truncada à
  #                  esquerda em 1 (escala original de Simar e Wilson,
  #                  2007); coeficiente positivo = MENOS eficiente; nos
  #                  canais com caudas pesadas o ajuste é degenerado.
  # A normal truncada em 0 E em 1 sobre o escore foi testada e descartada:
  # nos canais com escores acumulados perto de zero a verossimilhança não
  # tem máximo finito (gradiente não se anula em nenhum otimizador).
  # Devolve lista com coeficientes (nomeados, incluindo sigma), convergiu,
  # log-verossimilhança, norma máxima do gradiente e mensagem; ajustes sem
  # convergência devolvem convergiu = FALSE e coeficientes NA.
  x <- stats::model.matrix(formula, d)
  nomes <- c(colnames(x), "sigma")
  Falha <- function(msg) {
    return(list(coeficientes = stats::setNames(rep(NA_real_, length(nomes)),
                                               nomes),
                convergiu = FALSE, loglik = NA_real_, grad_max = NA_real_,
                mensagem = msg))
  }
  ponto <- switch(dependente, log_escore = 0, escore_1lim = 1, farrell = 1)
  direcao <- switch(dependente, log_escore = "right", escore_1lim = "right",
                    farrell = "left")
  y <- as.numeric(stats::model.response(stats::model.frame(formula, d)))
  fora <- if (direcao == "right") any(y >= ponto) else any(y <= ponto)
  if (fora) {
    return(Falha("dependente fora do suporte da truncada"))
  }
  ajuste <- NULL
  for (metodo in c("BFGS", "NR", "BHHH")) {
    candidato <- tryCatch(
      truncreg::truncreg(formula, data = d, point = ponto,
                         direction = direcao, method = metodo,
                         iterlim = 500),
      error = function(e) NULL)
    if (!is.null(candidato) &&
        grepl("success", candidato$est.stat$message, ignore.case = TRUE) &&
        all(is.finite(stats::coef(candidato)))) {
      ajuste <- candidato
      break
    }
  }
  if (is.null(ajuste)) {
    return(Falha("truncreg sem convergência (BFGS, NR, BHHH)"))
  }
  grad <- ajuste$gradient
  return(list(coeficientes = stats::coef(ajuste)[nomes], convergiu = TRUE,
              loglik = as.numeric(ajuste$logLik),
              grad_max = if (is.null(grad)) NA_real_ else max(abs(grad)),
              mensagem = paste(trimws(ajuste$est.stat$message), metodo)))
}

# Registro das saídas gravadas na sessão (consumido por RegistrarManifesto).
.registro_saidas <- new.env()
.registro_saidas$arquivos <- character(0)

SalvarTabela <- function(dados, nome, pasta = "output/tables") {
  # Grava uma tabela em CSV na pasta de saída e anota o arquivo no registro
  # da sessão, para que o manifesto vincule cada saída à execução.
  dir.create(pasta, showWarnings = FALSE, recursive = TRUE)
  arquivo <- file.path(pasta, paste0(nome, ".csv"))
  utils::write.csv(dados, arquivo, row.names = FALSE)
  .registro_saidas$arquivos <- unique(c(.registro_saidas$arquivos, arquivo))
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
