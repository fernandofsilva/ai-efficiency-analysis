# 05b_comparacao_padronizacao.R
# S01 (comentários da apresentação de 28/09/2026): compara as execuções em
# unidades originais com as execuções com as variáveis da fronteira
# padronizadas (min-max em [epsilon, 1]). A seleção de amostra usa sempre
# as unidades originais, de modo que amostra e conjunto de referência das
# fronteiras são os mesmos nas duas versões e toda diferença vem da
# transformação.
# Partes:
#   1. comparação dos resultados gravados pelos scripts 02, 02b e 03, por
#      execução (Fase A, painel e variantes): escores, retornos de escala,
#      ranking, supereficiência, canais, metafronteira, Malmquist, teste de
#      RTS, testes por renda e segundo estágio;
#   2. sensibilidade a epsilon e verificação numérica da invariância à
#      escala, com as DEA determinísticas (sem bootstrap) da Fase A e do
#      painel: unidades originais, escala pura (x / máx, sem translação) e
#      min-max com epsilon de 0,001 a 0,2.
# Uso: PADRONIZACAO=minmax Rscript R/05b_comparacao_padronizacao.R
#      (depois das execuções com e sem padronização)

source("R/00_setup.R")

padronizacao <- ConfigurarPadronizacao()
if (padronizacao$metodo == "nenhuma") {
  stop("rode com PADRONIZACAO=minmax: o script compara as duas versões")
}
sufixo_pad <- padronizacao$sufixo
epsilons <- c(0.001, 0.01, 0.05, 0.1, 0.2)

execucoes <- data.frame(
  sufixo = c("", "_painel", "_painel_qualidade", "_painel_fonte",
             "_painel_preqin", "_painel_publico"),
  rotulo = c("Fase A", "Painel", "Painel: qualidade",
             "Painel: patentes por inventor", "Painel: Preqin",
             "Painel: P&D público"),
  stringsAsFactors = FALSE)

LerTabelaSe <- function(nome) {
  arquivo <- file.path("output/tables", paste0(nome, ".csv"))
  if (!file.exists(arquivo)) {
    return(NULL)
  }
  return(utils::read.csv(arquivo, stringsAsFactors = FALSE))
}

LerPar <- function(nome, s) {
  # Tabela de uma execução nas duas versões; NULL se faltar alguma.
  original <- LerTabelaSe(paste0(nome, s))
  padronizada <- LerTabelaSe(paste0(nome, s, sufixo_pad))
  if (is.null(original) || is.null(padronizada)) {
    return(NULL)
  }
  return(list(o = original, p = padronizada))
}

Linha <- function(execucao, bloco, indicador, original = NA,
                  padronizada = NA, comparacao = NA, detalhe = "") {
  # Uma linha do resumo: valor em cada versão e, quando houver, uma medida
  # que compara as duas (correlação, concordância, sobreposição).
  return(data.frame(execucao = execucao, bloco = bloco,
                    indicador = indicador,
                    original = as.numeric(original),
                    padronizada = as.numeric(padronizada),
                    comparacao = as.numeric(comparacao),
                    detalhe = detalhe, stringsAsFactors = FALSE))
}

FormatarIc <- function(inf, sup) {
  return(sprintf("[%.3f; %.3f]", inf, sup))
}

CompararSegundoEstagio <- function(o, p) {
  # Junta as duas versões por modelo e termo e marca se o sinal, a
  # conclusão a 5% e o nível de evidência (quando houver) coincidem.
  sg <- dplyr::full_join(o, p, by = c("modelo", "termo"),
                         suffix = c("_original", "_padronizada"))
  sg$mesmo_sinal <- sign(sg$coeficiente_original) ==
    sign(sg$coeficiente_padronizada)
  sg$mesma_conclusao_5pct <- sg$significativo_5pct_original ==
    sg$significativo_5pct_padronizada
  if (all(c("nivel_evidencia_original", "nivel_evidencia_padronizada") %in%
          names(sg))) {
    sg$mesmo_nivel <- sg$nivel_evidencia_original ==
      sg$nivel_evidencia_padronizada
  }
  return(sg)
}

# 1. Comparação dos resultados gravados ---------------------------------------
resumo <- list()
ranking_comp <- list()
rts_comp <- list()
malm_comp <- list()
seg_comp <- list()
for (k in seq_len(nrow(execucoes))) {
  s <- execucoes$sufixo[k]
  ex <- execucoes$rotulo[k]
  dea <- LerPar("dea_ano_m2", s)
  if (is.null(dea)) {
    Registrar("sem as duas versões de dea_ano_m2", s, "- execução pulada")
    next
  }
  L <- list()

  # Escores anuais e retornos de escala (M2).
  colunas <- c("id", "escore_vrs", "escore_crs", "eficiencia_escala", "rts")
  d <- dplyr::inner_join(dea$o[, c("pais", "ano", colunas)],
                         dea$p[, colunas], by = "id",
                         suffix = c("_o", "_p"))
  if (nrow(d) != nrow(dea$o) || nrow(d) != nrow(dea$p)) {
    stop(ex, ": as amostras das duas versões diferem")
  }
  L[[length(L) + 1]] <- Linha(ex, "escores", "observações (país-ano)",
                              nrow(dea$o), nrow(dea$p))
  L[[length(L) + 1]] <- Linha(
    ex, "escores", "escore VRS médio", mean(d$escore_vrs_o),
    mean(d$escore_vrs_p),
    stats::cor(d$escore_vrs_o, d$escore_vrs_p, method = "spearman"),
    "comparação = Spearman país-ano entre versões")
  L[[length(L) + 1]] <- Linha(
    ex, "escores", "escore CRS médio", mean(d$escore_crs_o),
    mean(d$escore_crs_p),
    stats::cor(d$escore_crs_o, d$escore_crs_p, method = "spearman"),
    "comparação = Spearman país-ano entre versões")
  L[[length(L) + 1]] <- Linha(
    ex, "escores", "eficiência de escala média",
    mean(d$eficiencia_escala_o), mean(d$eficiencia_escala_p),
    stats::cor(d$eficiencia_escala_o, d$eficiencia_escala_p,
               method = "spearman"),
    "comparação = Spearman país-ano entre versões")
  L[[length(L) + 1]] <- Linha(ex, "escores", "eficientes VRS (%)",
                              100 * mean(d$escore_vrs_o > 0.999),
                              100 * mean(d$escore_vrs_p > 0.999))
  for (regime in c("CRS", "DRS", "IRS")) {
    L[[length(L) + 1]] <- Linha(ex, "retornos de escala",
                                paste("país-ano em", regime),
                                sum(d$rts_o == regime),
                                sum(d$rts_p == regime))
  }
  L[[length(L) + 1]] <- Linha(
    ex, "retornos de escala", "concordância da classificação (%)",
    comparacao = 100 * mean(d$rts_o == d$rts_p),
    detalhe = "mesma classe nas duas versões")
  rts <- LerPar("rts_por_pais_m2", s)
  if (!is.null(rts)) {
    rts_comp[[ex]] <- data.frame(
      execucao = ex,
      dplyr::inner_join(rts$o, rts$p, by = c("pais", "anos"),
                        suffix = c("_original", "_padronizada")))
  }

  # Ranking por país (escore corrigido, pseudo-valores de Simar-Wilson).
  rk <- LerPar("ranking_paises_boot", s)
  if (!is.null(rk)) {
    r <- dplyr::inner_join(
      rk$o[, c("pais", "grupo_renda", "n_anos", "escore_bc", "ic_inf",
               "ic_sup", "posto")],
      rk$p[, c("pais", "escore_bc", "ic_inf", "ic_sup", "posto")],
      by = "pais", suffix = c("_original", "_padronizada"))
    r$dif_posto <- r$posto_padronizada - r$posto_original
    r <- r[order(r$posto_padronizada), ]
    ranking_comp[[ex]] <- data.frame(execucao = ex, r)
    rho <- SpearmanComIc(r$escore_bc_original, r$escore_bc_padronizada,
                         n_boot = 1000)
    L[[length(L) + 1]] <- Linha(
      ex, "ranking", "Spearman entre rankings (países)",
      comparacao = rho["rho"],
      detalhe = paste("IC 95%", FormatarIc(rho["ic_inf"], rho["ic_sup"]),
                      "| países:", nrow(r)))
    Topo <- function(posto, n = 5) r$pais[order(posto)][seq_len(n)]
    Base <- function(posto, n = 5) r$pais[order(-posto)][seq_len(n)]
    L[[length(L) + 1]] <- Linha(
      ex, "ranking", "países em comum no topo 5",
      comparacao = length(intersect(Topo(r$posto_original),
                                    Topo(r$posto_padronizada))),
      detalhe = paste("topo padronizada:",
                      paste(Topo(r$posto_padronizada), collapse = ", ")))
    L[[length(L) + 1]] <- Linha(
      ex, "ranking", "países em comum na base 5",
      comparacao = length(intersect(Base(r$posto_original),
                                    Base(r$posto_padronizada))),
      detalhe = paste("base padronizada:",
                      paste(Base(r$posto_padronizada), collapse = ", ")))
    maior <- r[which.max(abs(r$dif_posto)), ]
    L[[length(L) + 1]] <- Linha(
      ex, "ranking", "mudança média de posto (valor absoluto)",
      comparacao = mean(abs(r$dif_posto)),
      detalhe = sprintf("maior: %s (%+.0f)", maior$pais, maior$dif_posto))
    L[[length(L) + 1]] <- Linha(
      ex, "ranking", "largura média do IC 95% do escore",
      mean(r$ic_sup_original - r$ic_inf_original),
      mean(r$ic_sup_padronizada - r$ic_inf_padronizada))
  }

  # Supereficiência na fronteira agrupada (M2, VRS).
  sup <- LerPar("supereficiencia_m2_pooled", s)
  if (!is.null(sup)) {
    L[[length(L) + 1]] <- Linha(
      ex, "supereficiência", "unidades supereficientes",
      sum(sup$o$supereficiente), sum(sup$p$supereficiente))
    L[[length(L) + 1]] <- Linha(
      ex, "supereficiência", "supereficientes no piso de investimento",
      sum(sup$o$supereficiente & sup$o$inv_piso),
      sum(sup$p$supereficiente & sup$p$inv_piso))
  }

  # Canais (H3a).
  can <- LerPar("spearman_canais", s)
  if (!is.null(can)) {
    L[[length(L) + 1]] <- Linha(
      ex, "canais (H3a)", "Spearman entre canais", can$o$rho, can$p$rho,
      detalhe = paste("IC original", FormatarIc(can$o$ic_inf, can$o$ic_sup),
                      "| IC padronizada",
                      FormatarIc(can$p$ic_inf, can$p$ic_sup)))
    L[[length(L) + 1]] <- Linha(
      ex, "canais (H3a)", "p unilateral de rho >= 0,5",
      can$o$p_h0_rho_maior_igual_limiar, can$p$p_h0_rho_maior_igual_limiar)
  }

  # Metafronteira (H3b).
  met <- LerPar("metafronteira_resumo", s)
  if (!is.null(met)) {
    for (g in c("Alta renda", "Renda média")) {
      L[[length(L) + 1]] <- Linha(
        ex, "metafronteira (H3b)", paste("TGR médio,", g),
        met$o$tgr_media[met$o$grupo == g], met$p$tgr_media[met$p$grupo == g])
    }
    L[[length(L) + 1]] <- Linha(
      ex, "metafronteira (H3b)",
      "diferença de TGR médio (renda média - alta)",
      met$o$dif_tgr_media[1], met$p$dif_tgr_media[1],
      detalhe = paste("IC original",
                      FormatarIc(met$o$dif_ic_inf[1], met$o$dif_ic_sup[1]),
                      "| IC padronizada",
                      FormatarIc(met$p$dif_ic_inf[1], met$p$dif_ic_sup[1])))
    L[[length(L) + 1]] <- Linha(
      ex, "metafronteira (H3b)", "p Mann-Whitney unilateral (país-ano)",
      met$o$p_mann_whitney_unilateral[1], met$p$p_mann_whitney_unilateral[1])
  }

  # Malmquist (H4).
  mal <- LerPar("malmquist_resumo", s)
  if (!is.null(mal)) {
    todos_o <- mal$o[mal$o$grupo_renda2 == "Todos", ]
    todos_p <- mal$p[mal$p$grupo_renda2 == "Todos", ]
    for (col in c("malmquist", "mudanca_tecnica", "mudanca_eficiencia")) {
      L[[length(L) + 1]] <- Linha(ex, "Malmquist (H4)",
                                  paste(col, "(média geométrica, todos)"),
                                  todos_o[[col]], todos_p[[col]])
    }
    media_o <- mal$o[mal$o$grupo_renda2 == "Renda média", ]
    media_p <- mal$p[mal$p$grupo_renda2 == "Renda média", ]
    if (nrow(media_o) == 1 && nrow(media_p) == 1) {
      L[[length(L) + 1]] <- Linha(
        ex, "Malmquist (H4)", "mudança de eficiência, renda média (H4b)",
        media_o$mudanca_eficiencia, media_p$mudanca_eficiencia,
        detalhe = paste(
          "IC original", FormatarIc(media_o$mudanca_eficiencia_ic_inf,
                                    media_o$mudanca_eficiencia_ic_sup),
          "| IC padronizada", FormatarIc(media_p$mudanca_eficiencia_ic_inf,
                                         media_p$mudanca_eficiencia_ic_sup)))
    }
    L[[length(L) + 1]] <- Linha(
      ex, "Malmquist (H4)", "parcela de TC (rateio simétrico, H4a)",
      todos_o$parcela_tc_rateio_simetrico,
      todos_p$parcela_tc_rateio_simetrico)
  }
  beta <- LerPar("malmquist_beta_convergencia", s)
  if (!is.null(beta)) {
    bo <- beta$o[beta$o$termo != "(Intercept)", ]
    bp <- beta$p[beta$p$termo != "(Intercept)", ]
    L[[length(L) + 1]] <- Linha(
      ex, "Malmquist (H4)", "beta-convergência (inclinação)",
      bo$coeficiente, bp$coeficiente,
      detalhe = sprintf("p original %.3f | p padronizada %.3f",
                        bo$p_valor, bp$p_valor))
  }
  mp <- LerPar("malmquist_m2", s)
  if (!is.null(mp)) {
    PorPais <- function(m) {
      return(m |>
               dplyr::group_by(pais, grupo_renda2) |>
               dplyr::summarise(
                 malmquist = MediaGeometrica(malmquist),
                 mudanca_tecnica = MediaGeometrica(mudanca_tecnica),
                 mudanca_eficiencia = MediaGeometrica(mudanca_eficiencia),
                 .groups = "drop"))
    }
    malm_comp[[ex]] <- data.frame(
      execucao = ex,
      dplyr::inner_join(PorPais(mp$o), PorPais(mp$p),
                        by = c("pais", "grupo_renda2"),
                        suffix = c("_original", "_padronizada")))
  }

  # Teste de retornos de escala (H1).
  tr <- LerPar("teste_rts", s)
  if (!is.null(tr)) {
    for (i in seq_len(nrow(tr$o))) {
      j <- which(tr$p$modelo == tr$o$modelo[i] & tr$p$h0 == tr$o$h0[i])
      if (length(j) != 1) next
      L[[length(L) + 1]] <- Linha(
        ex, "teste de RTS (H1)",
        paste0("p-valor, ", tr$o$modelo[i], ", H0 = ", tr$o$h0[i]),
        tr$o$p_valor[i], tr$p$p_valor[j],
        detalhe = sprintf("S original %.3f | S padronizada %.3f",
                          tr$o$estatistica[i], tr$p$estatistica[j]))
    }
  }

  # Testes por grupo de renda (escores corrigidos: modelo conjunto e
  # canais; os documentos citam o canal de patentes).
  tg <- LerPar("testes_grupo_renda", s)
  if (!is.null(tg)) {
    for (escore in tg$o$escore) {
      to <- tg$o[tg$o$escore == escore, ]
      tp <- tg$p[tg$p$escore == escore, ]
      if (nrow(tp) != 1) next
      L[[length(L) + 1]] <- Linha(
        ex, "grupos de renda",
        paste0("p Kruskal-Wallis, 3 grupos (país-ano), ", escore),
        to$p_kruskal_3grupos_pais_ano, tp$p_kruskal_3grupos_pais_ano)
      L[[length(L) + 1]] <- Linha(
        ex, "grupos de renda",
        paste0("p Kruskal-Wallis, 3 grupos (médias por país), ", escore),
        to$p_kruskal_3grupos_medias_pais, tp$p_kruskal_3grupos_medias_pais)
    }
  }

  # Concordância entre estimadores (R1).
  est <- LerPar("spearman_estimadores_m2", s)
  if (!is.null(est)) {
    for (i in seq_len(nrow(est$o))) {
      j <- which(est$p$a == est$o$a[i] & est$p$b == est$o$b[i])
      if (length(j) != 1) next
      L[[length(L) + 1]] <- Linha(
        ex, "estimadores (R1)",
        paste("Spearman", est$o$a[i], "x", est$o$b[i]),
        est$o$rho[i], est$p$rho[j])
    }
  }
  resumo[[ex]] <- do.call(rbind, L)

  # Segundo estágio (truncada sobre log do escore) e algoritmo 2.
  seg <- LerPar("segundo_estagio_truncada", s)
  if (!is.null(seg)) {
    Filtrar <- function(t) {
      # Inclui p-valor e nível de evidência (S07) quando a tabela os tem.
      colunas <- intersect(c("modelo", "termo", "coeficiente", "ic_inf",
                             "ic_sup", "p_boot", "significativo_5pct",
                             "nivel_evidencia", "n_obs",
                             "replicas_convergentes"), names(t))
      t <- t[t$dependente == "log_escore" &
               !grepl("^ano_f|Intercept|sigma", t$termo), colunas]
      return(t)
    }
    sg <- CompararSegundoEstagio(Filtrar(seg$o), Filtrar(seg$p))
    seg_comp[[ex]] <- data.frame(execucao = ex, sg)
    if ("mesmo_nivel" %in% names(sg)) {
      com_expectativa <- !is.na(sg$nivel_evidencia_original)
      resumo[[ex]] <- rbind(resumo[[ex]], Linha(
        ex, "segundo estágio",
        "termos com expectativa: mesmo nível de evidência (%)",
        comparacao = 100 * mean(sg$mesmo_nivel[com_expectativa],
                                na.rm = TRUE),
        detalhe = paste(sum(com_expectativa), "termos")))
    }
  }
  # H5 com as outras dimensões do WGI (S07).
  wgi <- LerPar("segundo_estagio_wgi", s)
  if (!is.null(wgi)) {
    dimensoes <- c("qualidade_regulatoria", "estado_direito",
                   "controle_corrupcao", "indice_wgi")
    FiltrarWgi <- function(t) {
      colunas <- intersect(c("modelo", "termo", "coeficiente", "ic_inf",
                             "ic_sup", "p_boot", "significativo_5pct",
                             "nivel_evidencia", "n_obs"), names(t))
      return(t[t$termo %in% dimensoes, colunas])
    }
    sg <- CompararSegundoEstagio(FiltrarWgi(wgi$o), FiltrarWgi(wgi$p))
    seg_comp[[paste(ex, "wgi")]] <- data.frame(execucao = ex, sg)
  }
  sw <- LerPar("segundo_estagio_simar_wilson_m2", s)
  if (!is.null(sw)) {
    so <- sw$o[!grepl("^ano_f|Intercept", sw$o$termo), ]
    sp <- sw$p[!grepl("^ano_f|Intercept", sw$p$termo), ]
    sg <- dplyr::full_join(
      so[, c("termo", "coeficiente", "ic_inf", "ic_sup")],
      sp[, c("termo", "coeficiente", "ic_inf", "ic_sup")],
      by = "termo", suffix = c("_original", "_padronizada"))
    sg$modelo <- "Simar-Wilson alg. 2 (Farrell; positivo = menos eficiente)"
    seg_comp[[paste(ex, "sw")]] <- data.frame(execucao = ex, sg)
  }
}
# Comparações entre variantes do painel em amostra e fronteira comuns
# (script 05), nas duas versões.
L <- list()
ex <- "Painel: variantes em amostra comum (R/05)"
coef <- LerPar("comparacao_coeficiente_efetividade_amostra_comum", "")
if (!is.null(coef)) {
  for (v in coef$o$variante) {
    co <- coef$o[coef$o$variante == v, ]
    cp <- coef$p[coef$p$variante == v, ]
    if (nrow(cp) != 1) next
    L[[length(L) + 1]] <- Linha(
      ex, "segundo estágio",
      paste0("diferença do coeficiente de efetividade (", v, " - base)"),
      co$diferenca, cp$diferenca,
      detalhe = paste("IC original", FormatarIc(co$dif_ic_inf, co$dif_ic_sup),
                      "| IC padronizada",
                      FormatarIc(cp$dif_ic_inf, cp$dif_ic_sup)))
  }
}
pais_comum <- LerPar("comparacao_escores_pais_amostra_comum", "")
if (!is.null(pais_comum)) {
  for (v in unique(pais_comum$o$variante)) {
    Rho <- function(t) {
      t <- t[t$variante == v, ]
      return(stats::cor(t$base_comum, t$variante_comum, method = "spearman"))
    }
    L[[length(L) + 1]] <- Linha(
      ex, "ranking",
      paste0("Spearman base x variante em amostra comum (", v, ")"),
      Rho(pais_comum$o), Rho(pais_comum$p))
  }
}
meta_comum <- LerPar("comparacao_metafronteira_amostra_comum", "")
if (!is.null(meta_comum)) {
  for (i in seq_len(nrow(meta_comum$o))) {
    mo <- meta_comum$o[i, ]
    mp <- meta_comum$p[meta_comum$p$variante == mo$variante &
                         meta_comum$p$amostra == mo$amostra &
                         meta_comum$p$especificacao == mo$especificacao, ]
    if (nrow(mp) != 1) next
    L[[length(L) + 1]] <- Linha(
      ex, "metafronteira",
      paste0("TGR renda média - alta (", mo$variante, ", amostra ",
             mo$amostra, ", especificação ", mo$especificacao, ")"),
      mo$tgr_media - mo$tgr_alta, mp$tgr_media - mp$tgr_alta)
  }
}
if (length(L) > 0) {
  resumo[[ex]] <- do.call(rbind, L)
}
resumo <- do.call(rbind, resumo)
rownames(resumo) <- NULL
SalvarTabela(resumo, paste0("comparacao_padronizacao_resumo", sufixo_pad))
SalvarTabela(do.call(rbind, ranking_comp),
             paste0("comparacao_padronizacao_ranking", sufixo_pad))
SalvarTabela(do.call(rbind, rts_comp),
             paste0("comparacao_padronizacao_rts_pais", sufixo_pad))
SalvarTabela(do.call(rbind, malm_comp),
             paste0("comparacao_padronizacao_malmquist_pais", sufixo_pad))
seg_comp <- dplyr::bind_rows(seg_comp)
SalvarTabela(seg_comp,
             paste0("comparacao_padronizacao_segundo_estagio", sufixo_pad))
print(resumo[resumo$execucao %in% c("Fase A", "Painel"),
             c("execucao", "indicador", "original", "padronizada",
               "comparacao")])

# Figura: ranking por país nas duas versões (Fase A e painel). Halteres:
# vazado cinza = unidades originais (como o escore de referência da fig1),
# cheio azul = padronizada; países ordenados pela versão padronizada.
FiguraRanking <- function(r, rotulo, nome) {
  ordem <- r$pais[order(r$escore_bc_padronizada)]
  rotulos_y <- stats::setNames(paste0(r$pais, " (", r$n_anos, ")"), r$pais)
  versoes <- c("Unidades originais", "Min-max")
  longo <- data.frame(
    pais = factor(rep(r$pais, 2), levels = ordem),
    versao = factor(rep(versoes, each = nrow(r)), levels = versoes),
    escore = c(r$escore_bc_original, r$escore_bc_padronizada))
  r$pais <- factor(r$pais, levels = ordem)
  rho <- stats::cor(r$escore_bc_original, r$escore_bc_padronizada,
                    method = "spearman")
  figura <- ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = r, ggplot2::aes(x = escore_bc_original,
                             xend = escore_bc_padronizada, y = pais,
                             yend = pais),
      colour = "#c3c2b7", linewidth = 0.6) +
    ggplot2::geom_point(
      data = longo, ggplot2::aes(x = escore, y = pais, colour = versao,
                                 shape = versao),
      size = 2.6, stroke = 1) +
    ggplot2::scale_colour_manual(
      values = c("Unidades originais" = "#6b6a65", "Min-max" = "#2a78d6"),
      name = NULL) +
    ggplot2::scale_shape_manual(
      values = c("Unidades originais" = 1, "Min-max" = 16), name = NULL) +
    ggplot2::scale_y_discrete(labels = rotulos_y) +
    ggplot2::scale_x_continuous(limits = c(0, 1),
                                breaks = seq(0, 1, 0.2)) +
    ggplot2::labs(
      x = paste("Eficiência corrigida de viés (VRS, orientação a produto;",
                "média dos anos)"),
      y = NULL,
      title = paste("Ranking com e sem padronização min-max -", rotulo),
      subtitle = sprintf(paste0(
        "Min-max em [%s; 1]; Spearman entre os rankings = %s; ",
        "(n) = anos por país"),
        format(padronizacao$epsilon, decimal.mark = ","),
        format(round(rho, 2), decimal.mark = ","))) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(legend.position = "bottom",
                   panel.grid.minor = ggplot2::element_blank(),
                   panel.grid.major.y = ggplot2::element_blank())
  ggplot2::ggsave(file.path("output/figures", paste0(nome, ".png")), figura,
                  width = 8.5, height = 9.5, dpi = 200, bg = "white")
  Registrar("figura gravada:", nome)
  return(invisible(NULL))
}
for (k in which(execucoes$rotulo %in% c("Fase A", "Painel"))) {
  ex <- execucoes$rotulo[k]
  if (!is.null(ranking_comp[[ex]])) {
    FiguraRanking(ranking_comp[[ex]], ex,
                  paste0("fig11_ranking_padronizacao", execucoes$sufixo[k],
                         sufixo_pad))
  }
}

# 2. Sensibilidade a epsilon e invariância à escala -------------------------
# Para cada transformação, as DEA anuais (M2: CRS, VRS e NIRS), os canais
# (VRS por canal) e o Malmquist (CRS, painel balanceado) são refeitos com a
# MESMA amostra e comparados com as unidades originais. A escala pura
# (cada variável dividida pelo seu máximo) não translada os dados: os
# escores devem coincidir com os originais até a tolerância do solver, o
# que separa o efeito numérico da escala do efeito da translação embutida
# na min-max.
SensibilidadeEpsilon <- function(rotulo, arquivo, insumos, produtos,
                                 janela) {
  base <- utils::read.csv(arquivo, stringsAsFactors = FALSE)
  colunas <- c(insumos, produtos)
  completas <- stats::complete.cases(base[, colunas])
  referencia <- base[completas, ]
  amostra <- base[completas & base[[insumos[1]]] > 0, ]
  anos <- sort(unique(amostra$ano))
  maximos <- vapply(referencia[, colunas], max, numeric(1))
  transformacoes <- list(
    list(nome = "unidades originais", epsilon = NA, parametros = NULL,
         escala_pura = FALSE),
    list(nome = "escala pura (x / máx)", epsilon = NA, parametros = NULL,
         escala_pura = TRUE))
  for (e in epsilons) {
    config <- list(metodo = "minmax", epsilon = e)
    transformacoes[[length(transformacoes) + 1]] <- list(
      nome = "min-max", epsilon = e,
      parametros = ParametrosPadronizacao(referencia, colunas, config),
      escala_pura = FALSE)
  }
  Matriz <- function(tr, d, cols, escala) {
    if (tr$escala_pura) {
      return(sweep(as.matrix(d[, cols, drop = FALSE]), 2, maximos[cols],
                   "/"))
    }
    return(MatrizFronteira(d, cols, tr$parametros, escala))
  }
  Rodar <- function(tr) {
    anual <- do.call(rbind, lapply(anos, function(a) {
      d <- amostra[amostra$ano == a, ]
      x <- Matriz(tr, d, insumos, 1e6)
      y <- Matriz(tr, d, produtos, 1)
      crs <- CalcularDea(x, y, d$id, "crs")
      vrs <- CalcularDea(x, y, d$id, "vrs")
      nirs <- CalcularDea(x, y, d$id, "drs")
      escore_canal <- lapply(produtos, function(p) {
        dc <- d[d[[p]] > 0, ]
        v <- CalcularDea(Matriz(tr, dc, insumos, 1e6), Matriz(tr, dc, p, 1),
                         dc$id, "vrs")
        return(v$escore[match(d$id, dc$id)])
      })
      data.frame(id = d$id, pais = d$pais, ano = a,
                 escore_vrs = vrs$escore, escore_crs = crs$escore,
                 rts = ClassificarRts(crs$farrell, vrs$farrell,
                                      nirs$farrell),
                 escore_pub = escore_canal[[1]],
                 escore_pat = escore_canal[[2]], stringsAsFactors = FALSE)
    }))
    presentes <- names(which(table(
      amostra$pais[amostra$ano %in% janela]) == length(janela)))
    painel <- amostra[amostra$pais %in% presentes & amostra$ano %in% janela, ]
    painel <- painel[order(painel$pais, painel$ano), ]
    malm <- Benchmarking::malmquist(Matriz(tr, painel, insumos, 1e6),
                                    Matriz(tr, painel, produtos, 1),
                                    ID = painel$pais, TIME = painel$ano,
                                    RTS = "crs", ORIENTATION = "out")
    return(list(anual = anual, malm = as.numeric(malm$m),
                tc = as.numeric(malm$tc), ec = as.numeric(malm$ec)))
  }
  resultados <- lapply(transformacoes, Rodar)
  ref <- resultados[[1]]
  MediaPais <- function(an) tapply(an$escore_vrs, an$pais, mean)
  ranking_ref <- MediaPais(ref$anual)
  linhas <- lapply(seq_along(transformacoes), function(i) {
    tr <- transformacoes[[i]]
    an <- resultados[[i]]$anual
    rk <- MediaPais(an)[names(ranking_ref)]
    # Só a base do ranking: o topo da DEA VRS determinística é formado por
    # empates em 1 (o conjunto de unidades eficientes sob VRS não muda com
    # a translação), e comparar o topo 5 seria comparar a ordem alfabética.
    Fundo <- function(v, n = 5) names(sort(v))[seq_len(n)]
    canais_ok <- stats::complete.cases(an$escore_pub, an$escore_pat)
    malm <- resultados[[i]]
    data.frame(
      base = rotulo, transformacao = tr$nome, epsilon = tr$epsilon,
      n_obs = nrow(an),
      max_dif_vrs = max(abs(an$escore_vrs - ref$anual$escore_vrs)),
      max_dif_crs = max(abs(an$escore_crs - ref$anual$escore_crs)),
      spearman_vrs_pais_ano = stats::cor(an$escore_vrs, ref$anual$escore_vrs,
                                         method = "spearman"),
      spearman_crs_pais_ano = stats::cor(an$escore_crs, ref$anual$escore_crs,
                                         method = "spearman"),
      spearman_ranking_vrs = stats::cor(rk, ranking_ref,
                                        method = "spearman"),
      base5_em_comum = length(intersect(Fundo(rk), Fundo(ranking_ref))),
      escore_vrs_medio = mean(an$escore_vrs),
      escore_crs_medio = mean(an$escore_crs),
      eficientes_vrs_pct = 100 * mean(an$escore_vrs > 0.999),
      crs_pct = 100 * mean(an$rts == "CRS"),
      drs_pct = 100 * mean(an$rts == "DRS"),
      irs_pct = 100 * mean(an$rts == "IRS"),
      concordancia_rts_pct = 100 * mean(an$rts == ref$anual$rts),
      rho_canais = stats::cor(an$escore_pub[canais_ok],
                              an$escore_pat[canais_ok],
                              method = "spearman"),
      malmquist = MediaGeometrica(malm$malm),
      mudanca_tecnica = MediaGeometrica(malm$tc),
      mudanca_eficiencia = MediaGeometrica(malm$ec),
      max_dif_malmquist = max(abs(malm$malm - ref$malm), na.rm = TRUE),
      base5 = paste(Fundo(rk), collapse = ", "),
      stringsAsFactors = FALSE)
  })
  return(do.call(rbind, linhas))
}
Registrar("sensibilidade a epsilon e invariância à escala...")
sensibilidade <- rbind(
  SensibilidadeEpsilon("Fase A", "data/processed/base_atual.csv",
                       c("investimento", "gerd"),
                       c("publicacoes", "patentes"), 2016:2019),
  SensibilidadeEpsilon("Painel", "data/processed/painel_ia.csv",
                       c("investimento_l1", "gerd_l1"),
                       c("publicacoes", "patentes"), 2017:2021))
SalvarTabela(sensibilidade, "sensibilidade_padronizacao_epsilon")
print(sensibilidade[, c("base", "transformacao", "epsilon", "max_dif_vrs",
                        "spearman_vrs_pais_ano", "spearman_ranking_vrs",
                        "crs_pct", "drs_pct", "rho_canais",
                        "mudanca_tecnica")])
RegistrarManifesto("05b_comparacao_padronizacao.R", sufixo_pad,
                   "data/processed/base_atual.csv",
                   "ok", detalhe = "e data/processed/painel_ia.csv")
Registrar("FIM comparação com e sem padronização")
