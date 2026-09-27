# 05_comparacoes_amostra_comum.R
# Decompõe as diferenças entre variantes do painel em efeito de AMOSTRA
# (composição de país-ano) e efeito de ESPECIFICAÇÃO (insumo ou produto),
# reestimando a metafronteira por grupo de renda e o coeficiente de
# efetividade governamental do segundo estágio sempre no mesmo conjunto de
# identificadores. Também testa a diferença de coeficientes entre
# especificações com bootstrap pareado por país.
# Uso: Rscript R/05_comparacoes_amostra_comum.R (após as variantes do painel)

source("R/00_setup.R")

painel <- utils::read.csv("data/processed/painel_ia.csv",
                          stringsAsFactors = FALSE)
LerTabela <- function(nome) {
  return(utils::read.csv(file.path("output/tables", paste0(nome, ".csv")),
                         stringsAsFactors = FALSE))
}

TgrPorGrupo <- function(d, insumos, produtos) {
  # Metafronteira VRS agrupada e fronteiras de grupo (alta vs média renda).
  g <- ifelse(d$grupo_renda == "Alta renda", "Alta renda", "Renda média")
  x <- as.matrix(d[, insumos]) / 1e6
  y <- as.matrix(d[, produtos])
  meta <- CalcularDea(x, y, d$id, "vrs")$escore
  grupo <- numeric(nrow(d))
  for (categoria in unique(g)) {
    i <- g == categoria
    grupo[i] <- CalcularDea(x[i, , drop = FALSE], y[i, , drop = FALSE],
                            d$id[i], "vrs")$escore
  }
  tgr <- tapply(meta / grupo, g, mean)
  return(data.frame(tgr_alta = tgr[["Alta renda"]],
                    tgr_media = tgr[["Renda média"]],
                    n = nrow(d)))
}

variantes <- list(
  publico = list(sufixo = "_painel_publico",
                 insumos = c("investimento_l1", "pd_publico_l1"),
                 produtos = c("publicacoes", "patentes")),
  qualidade = list(sufixo = "_painel_qualidade",
                   insumos = c("investimento_l1", "gerd_l1"),
                   produtos = c("citacoes_ok", "patentes_concedidas_ok")),
  fonte = list(sufixo = "_painel_fonte",
               insumos = c("investimento_l1", "gerd_l1"),
               produtos = c("publicacoes", "patentes_inventor")),
  preqin = list(sufixo = "_painel_preqin",
                insumos = c("investimento_preqin_l1", "gerd_l1"),
                produtos = c("publicacoes", "patentes")))
base_ins <- c("investimento_l1", "gerd_l1")
base_prod <- c("publicacoes", "patentes")

# 1. Metafronteira: base na amostra original, base na amostra da variante,

      variante na amostra da variante --------------------------------------------
ids_base <- LerTabela("dea_ano_m2_painel")$id
linhas <- list(cbind(variante = "base", amostra = "original",
                     especificacao = "base",
                     TgrPorGrupo(painel[painel$id %in% ids_base, ],
                                 base_ins, base_prod)))
for (nome in names(variantes)) {
  v <- variantes[[nome]]
  ids_v <- LerTabela(paste0("dea_ano_m2", v$sufixo))$id
  d <- painel[painel$id %in% ids_v, ]
  colunas <- c(base_ins, base_prod, v$insumos, v$produtos)
  d <- d[stats::complete.cases(d[, colunas]), ]
  linhas[[length(linhas) + 1]] <- cbind(
    variante = nome, amostra = "da variante", especificacao = "base",
    TgrPorGrupo(d, base_ins, base_prod))
  linhas[[length(linhas) + 1]] <- cbind(
    variante = nome, amostra = "da variante", especificacao = "variante",
    TgrPorGrupo(d, v$insumos, v$produtos))
}
meta_comp <- do.call(rbind, linhas)
meta_comp$inversao <- meta_comp$tgr_media < meta_comp$tgr_alta
SalvarTabela(meta_comp, "comparacao_metafronteira_amostra_comum")
print(meta_comp)

# 2. Segundo estágio: efetividade governamental, base vs variante, na
#    amostra comum, com diferença de coeficientes por bootstrap pareado ----
AjustarEfetividade <- function(d, coluna_escore) {
  f <- stats::as.formula(paste(coluna_escore, "~ efetividade_governo +",
                               "alta_tec_export + log_comercio + market_cap +",
                               "credito_privado + ano_f"))
  m <- truncreg::truncreg(f, data = d, point = 1, direction = "right")
  return(unname(stats::coef(m)["efetividade_governo"]))
}
comp_coef <- list()
for (nome in names(variantes)) {
  v <- variantes[[nome]]
  b_base <- LerTabela("boot_ano_m2_painel")[, c("id", "escore_bc")]
  b_var <- LerTabela(paste0("boot_ano_m2", v$sufixo))[, c("id", "escore_bc")]
  names(b_var)[2] <- "escore_bc_variante"
  d <- painel |>
    dplyr::inner_join(b_base, by = "id") |>
    dplyr::inner_join(b_var, by = "id") |>
    dplyr::mutate(ano_f = factor(ano))
  d <- d[stats::complete.cases(d[, c("efetividade_governo", "alta_tec_export",
                                     "log_comercio", "market_cap",
                                     "credito_privado")]), ]
  if (nrow(d) < 40) next
  c_base <- AjustarEfetividade(d, "escore_bc")
  c_var <- AjustarEfetividade(d, "escore_bc_variante")
  paises <- unique(d$pais)
  set.seed(semente)
  difs <- replicate(300, {
    esc <- sample(paises, replace = TRUE)
    db <- do.call(rbind, lapply(esc, function(p) d[d$pais == p, ]))
    tryCatch(AjustarEfetividade(db, "escore_bc_variante") -
               AjustarEfetividade(db, "escore_bc"),
             error = function(e) NA_real_)
  })
  difs <- difs[is.finite(difs)]
  comp_coef[[nome]] <- data.frame(
    variante = nome, n_obs = nrow(d), n_paises = length(paises),
    coef_base = c_base, coef_variante = c_var, diferenca = c_var - c_base,
    dif_ic_inf = unname(stats::quantile(difs, 0.025)),
    dif_ic_sup = unname(stats::quantile(difs, 0.975)),
    replicas_validas = length(difs))
  Registrar(nome, ": efetividade base", round(c_base, 3), "variante",
            round(c_var, 3), "diferença IC [",
            round(stats::quantile(difs, 0.025), 3), ";",
            round(stats::quantile(difs, 0.975), 3), "]")
}
comp_coef <- do.call(rbind, comp_coef)
SalvarTabela(comp_coef, "comparacao_coeficiente_efetividade_amostra_comum")
print(comp_coef)
RegistrarManifesto("05_comparacoes_amostra_comum.R", "",
                   "data/processed/painel_ia.csv", "ok")
Registrar("FIM comparações em amostra comum")
