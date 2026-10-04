# 05_comparacoes_amostra_comum.R
# Decompõe as diferenças entre variantes do painel em efeito de AMOSTRA
# (composição de país-ano) e efeito de ESPECIFICAÇÃO (insumo ou produto).
# Duas exigências, ambas verificadas aqui:
#   1. a amostra comum é a INTERSEÇÃO das amostras admissíveis nas duas
#      especificações (observação presente nas duas DEA, com investimento
#      positivo no insumo do modelo base), e não apenas a amostra da
#      variante: a Preqin, por exemplo, admite três país-ano com
#      investimento CSET igual a zero, que o modelo base exclui;
#   2. as fronteiras e os escores das duas especificações são REESTIMADOS
#      na amostra comum (DEA anual VRS + bootstrap de Simar-Wilson), de modo
#      que a variável dependente do segundo estágio reflita o mesmo conjunto
#      de referência; só então as regressões são ajustadas nas mesmas
#      observações com contexto completo e a diferença de coeficientes é
#      testada por bootstrap pareado por país.
# Também decompõe, país a país, a mudança do escore médio em três passos
# (base na amostra original; base na amostra comum; variante na amostra
# comum), o que separa composição da fronteira e especificação.
# Com PADRONIZACAO=minmax, lê e grava as tabelas com sufixo "_minmax" e
# reestima as fronteiras com a padronização de cada especificação (mesmos
# parâmetros do script 02 de cada variante).
# Uso: Rscript R/05_comparacoes_amostra_comum.R (após as variantes do painel)

source("R/00_setup.R")

n_rep_boot <- 1000    # réplicas do bootstrap DEA por ano (como no script 02)
n_boot_coef <- 300    # réplicas do bootstrap pareado da diferença

painel <- utils::read.csv("data/processed/painel_ia.csv",
                          stringsAsFactors = FALSE)
padronizacao <- ConfigurarPadronizacao()
sufixo_pad <- padronizacao$sufixo
LerTabela <- function(nome) {
  return(utils::read.csv(file.path("output/tables",
                                   paste0(nome, sufixo_pad, ".csv")),
                         stringsAsFactors = FALSE))
}
Salvar <- function(dados, nome) {
  return(SalvarTabela(dados, paste0(nome, sufixo_pad)))
}
Parametros <- function(insumos, produtos) {
  # Parâmetros da padronização de uma especificação, na mesma amostra de
  # referência do script 02 (observações completas do painel nas colunas
  # da especificação); NULL sem padronização.
  colunas <- c(insumos, produtos)
  return(ParametrosPadronizacao(
    painel[stats::complete.cases(painel[, colunas]), ], colunas,
    padronizacao))
}

TgrPorGrupo <- function(d, insumos, produtos) {
  # Metafronteira VRS agrupada e fronteiras de grupo (alta vs média renda).
  g <- ifelse(d$grupo_renda == "Alta renda", "Alta renda", "Renda média")
  parametros <- Parametros(insumos, produtos)
  x <- MatrizFronteira(d, insumos, parametros, 1e6)
  y <- MatrizFronteira(d, produtos, parametros)
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

EscoresCorrigidosPorAno <- function(d, insumos, produtos) {
  # DEA VRS anual com bootstrap de Simar-Wilson na amostra `d`; devolve
  # id e escore corrigido (mesma construção do script 02).
  set.seed(semente)
  parametros <- Parametros(insumos, produtos)
  saida <- lapply(sort(unique(d$ano)), function(a) {
    da <- d[d$ano == a, ]
    boot <- BootstrapDea(MatrizFronteira(da, insumos, parametros, 1e6),
                         MatrizFronteira(da, produtos, parametros), da$id,
                         "vrs", n_rep = n_rep_boot)
    return(boot[, c("id", "escore", "escore_bc")])
  })
  return(do.call(rbind, saida))
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
ids_base <- LerTabela("dea_ano_m2_painel")$id
boot_base_original <- LerTabela("boot_ano_m2_painel")[, c("id", "escore_bc")]

AmostraComum <- function(v) {
  # Interseção das amostras DEA da base e da variante, com casos completos
  # nas colunas das duas especificações.
  ids_v <- LerTabela(paste0("dea_ano_m2", v$sufixo))$id
  comuns <- intersect(ids_base, ids_v)
  d <- painel[painel$id %in% comuns, ]
  colunas <- unique(c(base_ins, base_prod, v$insumos, v$produtos))
  d <- d[stats::complete.cases(d[, colunas]), ]
  d <- d[d[[base_ins[1]]] > 0 & d[[v$insumos[1]]] > 0, ]
  attr(d, "so_na_variante") <- setdiff(ids_v, ids_base)
  return(d)
}

# 1. Metafronteira: base na amostra original, base na amostra comum,
#    variante na amostra comum -------------------------------------------------
linhas <- list(cbind(variante = "base", amostra = "original",
                     especificacao = "base",
                     TgrPorGrupo(painel[painel$id %in% ids_base, ],
                                 base_ins, base_prod)))
for (nome in names(variantes)) {
  v <- variantes[[nome]]
  d <- AmostraComum(v)
  Registrar(nome, ": amostra comum", nrow(d), "obs.; só na variante:",
            length(attr(d, "so_na_variante")),
            paste(attr(d, "so_na_variante"), collapse = " "))
  linhas[[length(linhas) + 1]] <- cbind(
    variante = nome, amostra = "comum", especificacao = "base",
    TgrPorGrupo(d, base_ins, base_prod))
  linhas[[length(linhas) + 1]] <- cbind(
    variante = nome, amostra = "comum", especificacao = "variante",
    TgrPorGrupo(d, v$insumos, v$produtos))
}
meta_comp <- do.call(rbind, linhas)
meta_comp$inversao <- meta_comp$tgr_media < meta_comp$tgr_alta
Salvar(meta_comp, "comparacao_metafronteira_amostra_comum")
print(meta_comp)

# 2. Escores reestimados na amostra comum, decomposição por país e segundo
#    estágio com fronteira comum ----------------------------------------------
AjustarEfetividade <- function(d, coluna_log_escore) {
  # Coeficiente da efetividade governamental na truncada sobre log(escore);
  # NA se o ajuste não convergir (AjustarTruncada verifica a convergência).
  f <- stats::as.formula(paste(coluna_log_escore, "~ efetividade_governo +",
                               "alta_tec_export + log_comercio + market_cap +",
                               "credito_privado + ano_f"))
  r <- AjustarTruncada(f, d, "log_escore")
  if (!r$convergiu) return(NA_real_)
  return(unname(r$coeficientes["efetividade_governo"]))
}
comp_coef <- list()
comp_pais <- list()
for (nome in names(variantes)) {
  v <- variantes[[nome]]
  d <- AmostraComum(v)
  Registrar(nome, ": reestimando fronteiras e bootstrap na amostra comum...")
  esc_base <- EscoresCorrigidosPorAno(d, base_ins, base_prod)
  names(esc_base)[2:3] <- c("escore_base", "escore_bc_base")
  esc_var <- EscoresCorrigidosPorAno(d, v$insumos, v$produtos)
  names(esc_var)[2:3] <- c("escore_variante", "escore_bc_variante")
  escores <- d[, c("id", "pais", "ano", "grupo_renda")] |>
    dplyr::inner_join(esc_base, by = "id") |>
    dplyr::inner_join(esc_var, by = "id") |>
    dplyr::left_join(dplyr::rename(boot_base_original,
                                   escore_bc_base_original = escore_bc),
                     by = "id")
  Salvar(escores, paste0("escores_amostra_comum", v$sufixo))
  # Decomposição por país: base (amostra original) -> base (amostra comum)
  # -> variante (amostra comum), médias dos escores corrigidos.
  por_pais <- escores |>
    dplyr::group_by(pais, grupo_renda) |>
    dplyr::summarise(n_anos = dplyr::n(),
                     base_original = mean(escore_bc_base_original),
                     base_comum = mean(escore_bc_base),
                     variante_comum = mean(escore_bc_variante),
                     .groups = "drop") |>
    dplyr::mutate(variante = nome,
                  efeito_amostra = base_comum - base_original,
                  efeito_especificacao = variante_comum - base_comum)
  comp_pais[[nome]] <- as.data.frame(por_pais)
  rho <- SpearmanComIc(por_pais$base_comum, por_pais$variante_comum,
                       n_boot = 1000)
  Registrar(nome, ": Spearman entre rankings (amostra e fronteira comuns)",
            round(rho["rho"], 3))
  # Segundo estágio nas mesmas observações com contexto completo.
  dd <- painel |>
    dplyr::inner_join(escores[, c("id", "escore_bc_base",
                                  "escore_bc_variante")], by = "id") |>
    dplyr::mutate(ano_f = factor(ano),
                  log_escore_base = log(escore_bc_base),
                  log_escore_variante = log(escore_bc_variante))
  dd <- dd[stats::complete.cases(dd[, c("efetividade_governo",
                                        "alta_tec_export", "log_comercio",
                                        "market_cap", "credito_privado")]), ]
  if (nrow(dd) < 40) next
  c_base <- AjustarEfetividade(dd, "log_escore_base")
  c_var <- AjustarEfetividade(dd, "log_escore_variante")
  paises <- unique(dd$pais)
  set.seed(semente)
  difs <- replicate(n_boot_coef, {
    esc <- sample(paises, replace = TRUE)
    db <- do.call(rbind, lapply(esc, function(p) dd[dd$pais == p, ]))
    AjustarEfetividade(db, "log_escore_variante") -
      AjustarEfetividade(db, "log_escore_base")
  })
  validas <- is.finite(difs)
  difs <- difs[validas]
  comp_coef[[nome]] <- data.frame(
    variante = nome, n_obs = nrow(dd), n_paises = length(paises),
    coef_base = c_base, coef_variante = c_var, diferenca = c_var - c_base,
    dif_ic_inf = unname(stats::quantile(difs, 0.025)),
    dif_ic_sup = unname(stats::quantile(difs, 0.975)),
    replicas_tentadas = n_boot_coef, replicas_convergentes = sum(validas),
    dependente = "log_escore",
    fronteira = "reestimada na amostra comum (DEA anual VRS + bootstrap)")
  Registrar(nome, ": efetividade base", round(c_base, 3), "variante",
            round(c_var, 3), "diferença IC [",
            round(stats::quantile(difs, 0.025), 3), ";",
            round(stats::quantile(difs, 0.975), 3), "] réplicas",
            sum(validas))
}
comp_coef <- do.call(rbind, comp_coef)
Salvar(comp_coef, "comparacao_coeficiente_efetividade_amostra_comum")
print(comp_coef)
comp_pais <- do.call(rbind, comp_pais)
Salvar(comp_pais, "comparacao_escores_pais_amostra_comum")
destaque <- comp_pais[comp_pais$pais %in% c("Israel", "Ireland", "China",
                                            "United States", "India"), ]
print(destaque[order(destaque$variante, destaque$pais),
               c("variante", "pais", "n_anos", "base_original", "base_comum",
                 "variante_comum")])
RegistrarManifesto("05_comparacoes_amostra_comum.R", sufixo_pad,
                   "data/processed/painel_ia.csv", "ok")
Registrar("FIM comparações em amostra comum")
