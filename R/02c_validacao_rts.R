# 02c_validacao_rts.R
# Validação por simulação do teste de RTS (TesteRtsBootstrap): tamanho sob
# um processo gerador com retornos constantes e poder sob retornos
# decrescentes. Dois insumos, dois produtos, ineficiência half-normal.
# Variáveis de ambiente: N_SIM (padrão 30), N_DMU (40), N_REP (100).
# Uso: Rscript R/02c_validacao_rts.R

source("R/00_setup.R")

n_sim <- as.integer(Sys.getenv("N_SIM", "30"))
n_dmu <- as.integer(Sys.getenv("N_DMU", "40"))
n_rep <- as.integer(Sys.getenv("N_REP", "100"))

GerarAmostra <- function(n, escala) {
  # Fronteira Cobb-Douglas y_k = (x1^0.5 * x2^0.5)^escala * peso_k,
  # com produtos deslocados para dentro por exp(-u), u ~ half-normal.
  x <- matrix(stats::runif(2 * n, 1, 10), ncol = 2)
  nivel <- (x[, 1]^0.5 * x[, 2]^0.5)^escala
  u <- abs(stats::rnorm(n, 0, 0.3))
  y <- cbind(nivel * stats::runif(n, 0.6, 1.4),
             nivel * stats::runif(n, 0.6, 1.4)) * exp(-u)
  return(list(x = x, y = y))
}

Simular <- function(escala, rotulo) {
  p <- vapply(seq_len(n_sim), function(s) {
    set.seed(1000 + s)
    a <- GerarAmostra(n_dmu, escala)
    TesteRtsBootstrap(a$x, a$y, "crs", n_rep)$p_valor
  }, numeric(1))
  saida <- data.frame(dgp = rotulo, escala = escala, n_sim = n_sim,
                      n_dmu = n_dmu, B = n_rep,
                      rejeicao_5pct = mean(p < 0.05),
                      rejeicao_10pct = mean(p < 0.10),
                      p_mediano = stats::median(p))
  Registrar(rotulo, ": rejeição a 5% =", round(saida$rejeicao_5pct, 3))
  return(saida)
}

resultados <- rbind(Simular(1.0, "CRS verdadeiro (tamanho)"),
                    Simular(0.6, "DRS verdadeiro (poder)"),
                    Simular(0.8, "DRS moderado (poder)"))
SalvarTabela(resultados, "validacao_teste_rts")
print(resultados)
Registrar("FIM validação do teste de RTS")
