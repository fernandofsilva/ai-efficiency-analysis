# 02c_validacao_rts.R
# Validação por simulação do teste de RTS (TesteRtsBootstrap) e da
# implementação de referência (rDEA::rts.test, estatística 4.6, banda de
# Silverman): frequência de rejeição sob um processo gerador com retornos
# constantes (tamanho) e sob retornos decrescentes (poder), em cenários com
# o tamanho das amostras usadas (40 DMUs e 191 país-ano; dois insumos e um
# insumo, como nos modelos M2 e M1). Dois produtos; ineficiência
# half-normal. A validação mede o tamanho no cenário simulado; ela não o
# transfere aos dados reais (observações repetidas por país, escalas
# distintas).
# Variáveis de ambiente: N_SIM (padrão 100), N_REP (100).
# Uso: Rscript R/02c_validacao_rts.R

source("R/00_setup.R")

n_sim <- as.integer(Sys.getenv("N_SIM", "100"))
n_rep <- as.integer(Sys.getenv("N_REP", "100"))

GerarAmostra <- function(n, escala, m = 2) {
  # Fronteira Cobb-Douglas y_k = (prod x_j^(1/m))^escala * peso_k, com
  # produtos deslocados para dentro por exp(-u), u ~ half-normal.
  x <- matrix(stats::runif(m * n, 1, 10), ncol = m)
  nivel <- exp(rowMeans(log(x)))^escala
  u <- abs(stats::rnorm(n, 0, 0.3))
  y <- cbind(nivel * stats::runif(n, 0.6, 1.4),
             nivel * stats::runif(n, 0.6, 1.4)) * exp(-u)
  return(list(x = x, y = y))
}

PValorProprio <- function(a) {
  return(TesteRtsBootstrap(a$x, a$y, "crs", n_rep)$p_valor)
}
PValorReferencia <- function(a) {
  r <- tryCatch(
    rDEA::rts.test(X = a$x, Y = a$y, model = "output", H0 = "constant",
                   bw = "silverman", B = n_rep, alpha = 0.05),
    error = function(e) NULL)
  return(if (is.null(r)) NA_real_ else r$pvalue)
}

Simular <- function(rotulo, escala, n_dmu, m, implementacao, PValor) {
  p <- vapply(seq_len(n_sim), function(s) {
    set.seed(1000 + s)
    PValor(GerarAmostra(n_dmu, escala, m))
  }, numeric(1))
  p <- p[is.finite(p)]
  # IC binomial exato (Clopper-Pearson) da frequência de rejeição a 5%.
  ic <- stats::binom.test(sum(p < 0.05), length(p))$conf.int
  saida <- data.frame(dgp = rotulo, implementacao = implementacao,
                      escala = escala, n_sim = length(p), n_dmu = n_dmu,
                      n_insumos = m, B = n_rep,
                      rejeicao_5pct = mean(p < 0.05),
                      rejeicao_5pct_ic_inf = ic[1],
                      rejeicao_5pct_ic_sup = ic[2],
                      rejeicao_10pct = mean(p < 0.10),
                      p_mediano = stats::median(p))
  Registrar(implementacao, "|", rotulo, "| n =", n_dmu, "| m =", m,
            ": rejeição a 5% =", round(saida$rejeicao_5pct, 3))
  return(saida)
}

cenarios <- list(
  list("CRS verdadeiro (tamanho)", 1.0, 40, 2),
  list("CRS verdadeiro (tamanho)", 1.0, 191, 2),
  list("CRS verdadeiro (tamanho)", 1.0, 191, 1),
  list("DRS verdadeiro (poder)", 0.6, 40, 2),
  list("DRS moderado (poder)", 0.8, 191, 2))
resultados <- do.call(rbind, lapply(cenarios, function(c) {
  rbind(Simular(c[[1]], c[[2]], c[[3]], c[[4]], "propria (Benchmarking)",
                PValorProprio),
        Simular(c[[1]], c[[2]], c[[3]], c[[4]], "referencia (rDEA::rts.test)",
                PValorReferencia))
}))
SalvarTabela(resultados, "validacao_teste_rts")
print(resultados)
RegistrarManifesto("02c_validacao_rts.R", "", "(simulacao)", "ok")
Registrar("FIM validação do teste de RTS")
