# 02b_teste_rts.R
# Teste de retornos de escala com bootstrap, adaptado de Simar e Wilson
# (2002) e implementado sobre Benchmarking (ver TesteRtsBootstrap em
# R/funcoes.R). Não é a implementação de rDEA::rts.test, que não concluiu em
# mais de uma hora nesta base; a validação por simulação está em
# R/02c_validacao_rts.R. H0: retornos constantes ("crs") ou não crescentes
# ("drs" = NIRS) contra H1: retornos variáveis.
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
Registrar("amostra agrupada:", nrow(amostra), "obs.; réplicas:", n_rep_rts)

RodarTeste <- function(x, modelo, h0) {
  inicio <- Sys.time()
  r <- TesteRtsBootstrap(x, y, h0, n_rep_rts)
  saida <- data.frame(modelo = modelo, h0 = h0, n = r$n, B = n_rep_rts,
                      replicas_validas = r$replicas_validas,
                      estatistica = r$estatistica, p_valor = r$p_valor,
                      rejeita_h0_5pct = r$p_valor < 0.05,
                      s_boot_q05 = r$s_boot_q05,
                      s_boot_mediana = r$s_boot_mediana,
                      fronteira = "agrupada (todas as observações)",
                      minutos = as.numeric(difftime(Sys.time(), inicio,
                                                    units = "mins")))
  Registrar(modelo, h0, "S =", round(r$estatistica, 4), "p =",
            round(r$p_valor, 4), "| réplicas válidas", r$replicas_validas)
  return(saida)
}

resultados <- RodarTeste(x_m2, "M2", "crs")
resultados <- rbind(resultados, RodarTeste(x_m2, "M2", "drs"))
resultados <- rbind(resultados, RodarTeste(x_m1, "M1", "crs"))
SalvarTabela(resultados, paste0("teste_rts", sufixo))
print(resultados)
RegistrarManifesto("02b_teste_rts.R", sufixo, arquivo_base, "ok")
Registrar("FIM teste de RTS")
