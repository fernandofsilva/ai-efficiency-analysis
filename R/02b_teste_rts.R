# 02b_teste_rts.R
# Teste de retornos de escala com bootstrap (Simar e Wilson, 2002)
# implementado sobre Benchmarking (DEA vetorizada). rDEA::rts.test não
# concluiu uma única réplica em mais de uma hora nesta base, por isso a
# implementação própria.
# H0: retornos constantes (ou não crescentes) contra H1: retornos variáveis.
# Estatística: razão das médias das distâncias de Shephard orientadas a
# produto, S = mean(D_H0) / mean(D_VRS), com D = 1 / F (Farrell, >= 1).
# Sob H0, S fica próximo de 1; valores pequenos favorecem VRS. O p-valor é a
# fração de réplicas com S* <= S observado, com pseudo-dados gerados sob H0
# pelo bootstrap homogêneo suavizado com reflexão (Simar e Wilson, 1998).
# Variáveis de ambiente: BASE_ARQUIVO, SUFIXO_SAIDA, INSUMOS, PRODUTOS,
# N_REP_RTS (padrão 1000).
# Uso: Rscript R/02b_teste_rts.R

source("R/00_setup.R")

arquivo_base <- Sys.getenv("BASE_ARQUIVO", "data/processed/base_atual.csv")
sufixo <- Sys.getenv("SUFIXO_SAIDA", "")
insumos <- strsplit(Sys.getenv("INSUMOS", "investimento,gerd"), ",")[[1]]
produtos <- strsplit(Sys.getenv("PRODUTOS", "publicacoes,patentes"), ",")[[1]]
n_rep_rts <- as.integer(Sys.getenv("N_REP_RTS", "1000"))

base <- utils::read.csv(arquivo_base, stringsAsFactors = FALSE)
completas <- stats::complete.cases(base[, c(insumos, produtos)])
amostra <- base[completas & base[[insumos[1]]] > 0, ]
x_m2 <- as.matrix(amostra[, insumos]) / 1e6
x_m1 <- x_m2[, 1, drop = FALSE]
y <- as.matrix(amostra[, produtos])
Registrar("amostra:", nrow(amostra), "obs.; réplicas:", n_rep_rts)

DistanciaShephard <- function(x, y, rts) {
  # Distância de Shephard orientada a produto (<= 1) = 1 / Farrell. O tempo
  # máximo por LP (lpSolveAPI) evita travamentos em problemas degenerados
  # dos pseudo-dados; LPs interrompidos devolvem NA.
  modelo <- Benchmarking::dea(x, y, RTS = rts, ORIENTATION = "out",
                              CONTROL = list(timeout = 10))
  return(1 / as.numeric(Benchmarking::eff(modelo)))
}

SortearSuavizado <- function(d) {
  # Bootstrap homogêneo suavizado com reflexão em 1 (Simar e Wilson, 1998):
  # reamostra as distâncias refletidas {d, 2 - d}, adiciona ruído gaussiano
  # com largura de banda de Silverman, corrige a variância e reflete de
  # volta para (0, 1].
  n <- length(d)
  refletido <- c(d, 2 - d)
  h <- 0.9 * min(stats::sd(refletido), stats::IQR(refletido) / 1.34) *
    (2 * n)^(-1 / 5)
  beta <- sample(refletido, n, replace = TRUE)
  beta_til <- beta + h * stats::rnorm(n)
  beta_corr <- mean(beta) + (beta_til - mean(beta)) /
    sqrt(1 + h^2 / stats::var(d))
  d_estrela <- ifelse(beta_corr > 1, 2 - beta_corr, beta_corr)
  d_estrela <- pmin(pmax(d_estrela, 1e-4), 1)
  return(d_estrela)
}

TesteRts <- function(x, modelo, h0) {
  # h0: "crs" (retornos constantes) ou "drs" (não crescentes, NIRS).
  inicio <- Sys.time()
  d_h0 <- DistanciaShephard(x, y, h0)
  d_vrs <- DistanciaShephard(x, y, "vrs")
  s_obs <- mean(d_h0, na.rm = TRUE) / mean(d_vrs, na.rm = TRUE)
  s_boot <- vapply(seq_len(n_rep_rts), function(b) {
    d_estrela <- SortearSuavizado(d_h0)
    # Pseudo-produtos sob H0: projeta na fronteira H0 e reposiciona com a
    # distância sorteada: y* = y * d_estrela / d_h0. LPs que falham
    # numericamente (raros) geram NA e a réplica é descartada.
    y_estrela <- y * (d_estrela / d_h0)
    mean(DistanciaShephard(x, y_estrela, h0), na.rm = TRUE) /
      mean(DistanciaShephard(x, y_estrela, "vrs"), na.rm = TRUE)
  }, numeric(1))
  validas <- is.finite(s_boot)
  s_boot <- s_boot[validas]
  p_valor <- mean(s_boot <= s_obs)
  saida <- data.frame(
    modelo = modelo, h0 = h0, n = nrow(x), B = n_rep_rts,
    replicas_validas = sum(validas),
    estatistica = s_obs, p_valor = p_valor, rejeita_h0_5pct = p_valor < 0.05,
    s_boot_q05 = unname(stats::quantile(s_boot, 0.05)),
    s_boot_mediana = stats::median(s_boot),
    minutos = as.numeric(difftime(Sys.time(), inicio, units = "mins")))
  Registrar(modelo, h0, "S =", round(s_obs, 4), "p =", round(p_valor, 4),
            "|", round(saida$minutos, 1), "min")
  return(saida)
}

resultados <- TesteRts(x_m2, "M2", "crs")
SalvarTabela(resultados, paste0("teste_rts", sufixo))
resultados <- rbind(resultados, TesteRts(x_m2, "M2", "drs"))
SalvarTabela(resultados, paste0("teste_rts", sufixo))
resultados <- rbind(resultados, TesteRts(x_m1, "M1", "crs"))
SalvarTabela(resultados, paste0("teste_rts", sufixo))
print(resultados)
Registrar("FIM teste de RTS")
