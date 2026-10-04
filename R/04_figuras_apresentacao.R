# 04_figuras_apresentacao.R
# Fase A: figuras para a apresentação (a partir das tabelas de output/tables).
# Figuras: ranking com IC, decomposição de Malmquist, canais acadêmico x
# tecnológico, coeficientes do segundo estágio, eficiência por grupo de renda
# e ano, comparação de estimadores. Tabelas derivadas (comentários da
# apresentação de 28/09/2026): Malmquist por país com a leitura de cada
# componente (S06) e dispersão do escore por grupo de renda e ano, com
# comparação entre metades do período por bootstrap de países (S08).
# Tabelas lidas (com MD5), tabelas e figuras gravadas entram no manifesto
# de execução (RegistrarManifesto, no fim).
# Uso: Rscript R/04_figuras_apresentacao.R (após os scripts 02 e 03)

source("R/00_setup.R")

padronizacao <- ConfigurarPadronizacao()
sufixo <- paste0(Sys.getenv("SUFIXO_SAIDA", ""), padronizacao$sufixo)
# Nas execuções com padronização, cada figura traz a transformação usada.
nota_padronizacao <- if (padronizacao$metodo == "nenhuma") {
  NULL
} else {
  sprintf("Variáveis da fronteira padronizadas: min-max em [%s; 1]",
          format(padronizacao$epsilon, decimal.mark = ","))
}

LerTabela <- function(nome) {
  arquivo <- file.path("output/tables", paste0(nome, sufixo, ".csv"))
  RegistrarEntrada(arquivo)
  return(utils::read.csv(arquivo, stringsAsFactors = FALSE))
}

SalvarFigura <- function(grafico, nome, largura = 9, altura = 6) {
  if (!is.null(nota_padronizacao)) {
    grafico <- grafico + ggplot2::labs(caption = nota_padronizacao)
  }
  arquivo <- file.path("output/figures", paste0(nome, sufixo, ".png"))
  ggplot2::ggsave(arquivo, grafico, width = largura, height = altura,
                  dpi = 200, bg = "white")
  RegistrarSaida(arquivo)
  Registrar("figura gravada:", nome)
  return(invisible(NULL))
}

tema <- ggplot2::theme_minimal(base_size = 13) +
  ggplot2::theme(legend.position = "bottom",
                 panel.grid.minor = ggplot2::element_blank())
cores_renda <- c("Alta renda" = "#1f77b4", "Renda média-alta" = "#ff7f0e",
                 "Renda média-baixa" = "#2ca02c", "Renda média" = "#ff7f0e")

# 1. Ranking por país: média dos escores corrigidos (M2, VRS) com IC ---------
boot_m2 <- LerTabela("boot_ano_m2")
periodo <- paste(range(boot_m2$ano), collapse = "-")
# Ranking com IC 95% bootstrap da média anual (réplicas por ano), gerado no
# script 02; o rótulo inclui o número de anos de cada país.
ranking <- LerTabela("ranking_paises_boot")
ranking$rotulo <- paste0(ranking$pais, " (", ranking$n_anos, ")")
SalvarTabela(ranking, paste0("ranking_paises_m2", sufixo))
fig1 <- ggplot2::ggplot(
  ranking, ggplot2::aes(x = escore_bc, y = stats::reorder(rotulo, escore_bc),
                        colour = grupo_renda)) +
  ggplot2::geom_errorbarh(ggplot2::aes(xmin = ic_inf, xmax = ic_sup),
                          height = 0.3, alpha = 0.7) +
  ggplot2::geom_point(size = 2.5) +
  ggplot2::geom_point(ggplot2::aes(x = escore), shape = 1, size = 2.5,
                      colour = "grey40") +
  ggplot2::scale_colour_manual(values = cores_renda, name = NULL) +
  ggplot2::labs(x = "Eficiência técnica (VRS, orientação a produto)",
                y = NULL,
                title = paste("Ranking de eficiência na conversão de",
                              "investimento em IA e P&D"),
                subtitle = paste0("Média ", periodo, " dos escores anuais: ",
                                  "corrigido (cheio) e original (vazado)\n",
                                  "Barras: IC 95% (pseudo-valores de ",
                                  "Simar-Wilson); (n) = anos por país")) +
  tema
SalvarFigura(fig1, "fig1_ranking_m2", 9, 9)

# 2. Malmquist 2016-2019: decomposição por país -------------------------------
malm <- LerTabela("malmquist_m2")
periodo_malm <- paste(min(malm$ano) - 1, max(malm$ano), sep = "-")
malm_pais <- malm |>
  dplyr::group_by(pais, grupo_renda2) |>
  dplyr::summarise(`Mudança técnica` = MediaGeometrica(mudanca_tecnica),
                   `Mudança de eficiência` =
                     MediaGeometrica(mudanca_eficiencia),
                   malmquist = MediaGeometrica(malmquist), .groups = "drop") |>
  tidyr::pivot_longer(c(`Mudança técnica`, `Mudança de eficiência`),
                      names_to = "componente", values_to = "indice")
fig2 <- ggplot2::ggplot(
  malm_pais, ggplot2::aes(x = stats::reorder(pais, malmquist), y = indice,
                          fill = componente)) +
  ggplot2::geom_col(position = "dodge") +
  ggplot2::geom_hline(yintercept = 1, linetype = 2) +
  ggplot2::geom_point(ggplot2::aes(y = malmquist), colour = "black",
                      shape = 18, size = 3, show.legend = FALSE) +
  ggplot2::coord_flip() +
  ggplot2::scale_fill_manual(values = c("#9467bd", "#17becf"), name = NULL) +
  ggplot2::labs(x = NULL,
                y = paste0("Índice (média geométrica ", periodo_malm, ")"),
                title = "Índice de Malmquist e decomposição (CRS, produto)",
                subtitle = "Losango = índice de Malmquist; > 1 indica ganho") +
  tema
SalvarFigura(fig2, "fig2_malmquist_decomposicao", 9, 7)

# 2b. Malmquist por país: deslocamento da fronteira x catch-up (S06) --------
# Médias geométricas por país dos índices na convenção do script 02 (maior
# que 1 = melhora); a leitura usa faixas de 5% em torno de 1 para a mudança
# técnica (TC: a fronteira avança, fica estável ou recua) e para a mudança
# de eficiência (EC: o país se aproxima da fronteira, fica estável ou se
# afasta). "Na fronteira em todos os anos" exige escore CRS contemporâneo
# igual a 1 (tolerância 1e-6) em TODOS os anos do painel balanceado,
# inclusive o primeiro: só então todo o movimento do país é o da própria
# fronteira. EC = 1 em cada transição não basta (só indica eficiência
# constante, que pode ser 0,5 todo ano), e uma média geométrica de EC igual
# a 1 menos ainda (A02 de artigo/17). Os nomes distinguem os índices anuais
# (tabela malmquist_m2) das médias por país (sufixo _media_geom).
Faixa <- function(x, acima, estavel, abaixo) {
  return(ifelse(x > 1.05, acima, ifelse(x < 0.95, abaixo, estavel)))
}
tolerancia_fronteira <- 1e-6
posicao_crs <- LerTabela("malmquist_escores_crs") |>
  dplyr::arrange(pais, ano) |>
  dplyr::group_by(pais) |>
  dplyr::summarise(
    anos_com_escore = sum(!is.na(escore_crs)),
    escore_crs_inicial = dplyr::first(escore_crs),
    escore_crs_final = dplyr::last(escore_crs),
    escore_crs_minimo = min(escore_crs),
    sempre_na_fronteira = !anyNA(escore_crs) &&
      all(escore_crs >= 1 - tolerancia_fronteira),
    .groups = "drop")
malm_por_pais <- malm |>
  dplyr::group_by(pais, grupo_renda2) |>
  dplyr::summarise(
    pares_de_anos = dplyr::n(),
    malmquist_media_geom = MediaGeometrica(malmquist),
    mudanca_tecnica_media_geom = MediaGeometrica(mudanca_tecnica),
    mudanca_eficiencia_media_geom = MediaGeometrica(mudanca_eficiencia),
    .groups = "drop") |>
  dplyr::left_join(posicao_crs, by = "pais") |>
  dplyr::mutate(
    fronteira = Faixa(mudanca_tecnica_media_geom, "avança", "estável",
                      "recua"),
    eficiencia_relativa = Faixa(mudanca_eficiencia_media_geom, "catch-up",
                                "estável", "se afasta"),
    leitura = ifelse(sempre_na_fronteira,
                     paste("na fronteira em todos os anos: só",
                           "deslocamento da fronteira"),
                     paste0(eficiencia_relativa, "; fronteira ",
                            fronteira))) |>
  dplyr::arrange(dplyr::desc(malmquist_media_geom))
SalvarTabela(malm_por_pais, paste0("malmquist_por_pais", sufixo))

# 3. Canais: acadêmico x tecnológico -------------------------------------------
canais <- LerTabela("canais_ano_m2")
canais_pais <- canais |>
  dplyr::group_by(pais, grupo_renda) |>
  dplyr::summarise(publicacoes = mean(escore_pub), patentes = mean(escore_pat),
                   .groups = "drop")
rho <- LerTabela("spearman_canais")
fig3 <- ggplot2::ggplot(canais_pais,
                        ggplot2::aes(x = publicacoes, y = patentes,
                                     colour = grupo_renda, label = pais)) +
  ggplot2::geom_abline(slope = 1, intercept = 0, linetype = 3,
                       colour = "grey50") +
  ggplot2::geom_point(size = 3) +
  ggrepel::geom_text_repel(size = 3, show.legend = FALSE,
                           max.overlaps = 30) +
  ggplot2::scale_colour_manual(values = cores_renda, name = NULL) +
  ggplot2::coord_equal(xlim = c(0, 1.05), ylim = c(0, 1.05)) +
  ggplot2::labs(x = "Eficiência no canal acadêmico (publicações)",
                y = "Eficiência no canal tecnológico (patentes)",
                title = "Os dois canais de conversão divergem",
                subtitle = sprintf(
                  "Spearman entre canais (país-ano) = %.2f [%.2f; %.2f]",
                  rho$rho, rho$ic_inf, rho$ic_sup)) +
  tema
SalvarFigura(fig3, "fig3_canais", 8, 8)

# 4. Segundo estágio: coeficientes com IC do bootstrap agrupado --------------
seg <- LerTabela("segundo_estagio_truncada")
seg <- seg[!grepl("^ano_f|Intercept|sigma", seg$termo), ]
if ("dependente" %in% names(seg)) {
  seg <- seg[seg$dependente == "log_escore", ]
}
seg <- seg[!is.na(seg$coeficiente), ]
rotulos <- c(efetividade_governo = "Efetividade governamental",
             alta_tec_export = "Exportações de alta tecnologia (%)",
             log_comercio = "log(comércio/PIB)",
             market_cap = "Capitalização de mercado (% PIB)",
             credito_privado = "Crédito ao setor privado (% PIB)",
             log_pesquisadores = "log(pesquisadores por milhão)",
             npl = "Empréstimos inadimplentes (%)",
             log_pib_pc = "log(PIB per capita)",
             log_talento = "log(concentração de talento em IA)")
seg$termo_rotulo <- ifelse(seg$termo %in% names(rotulos),
                           rotulos[seg$termo], seg$termo)
# Cor pelo nível de evidência (S07): tons de azul para o sinal previsto
# (escuro = IC 95% exclui zero; médio = só o IC 90%; claro = sem
# significância, compatível com previsão nula ou coeficiente ≈ 0), vermelho
# para o sinal contrário (com ou sem significância: o IC mostra qual) e
# cinza para controles sem previsão. Tabelas antigas sem a
# classificação caem na legenda de significância a 5%.
niveis_fig4 <- c("Sinal previsto, IC 95% exclui zero",
                 "Sinal previsto, só IC 90% exclui zero",
                 "Sem significância (previsto, compatível ou ≈ 0)",
                 "Sinal contrário", "Controle (sem previsão)")
if ("nivel_evidencia" %in% names(seg)) {
  seg$evidencia <- factor(dplyr::case_when(
    is.na(seg$nivel_evidencia) ~ niveis_fig4[5],
    seg$nivel_evidencia == "significativo (5%)" ~ niveis_fig4[1],
    seg$nivel_evidencia == "bateu na trave (5-10%)" ~ niveis_fig4[2],
    seg$nivel_evidencia %in% c("só o sinal", "compatível",
                               "sem sinal (coeficiente ≈ 0)") ~
      niveis_fig4[3],
    TRUE ~ niveis_fig4[4]), levels = niveis_fig4)
} else {
  seg$evidencia <- factor(ifelse(seg$significativo_5pct, niveis_fig4[1],
                                 niveis_fig4[5]), levels = niveis_fig4)
}
cores_evidencia <- stats::setNames(
  c("#104281", "#3987e5", "#86b6ef", "#e34948", "#898781"), niveis_fig4)
fig4 <- ggplot2::ggplot(seg, ggplot2::aes(x = coeficiente, y = termo_rotulo,
                                          colour = evidencia)) +
  ggplot2::geom_vline(xintercept = 0, linetype = 2) +
  # show.legend = TRUE: desenha a chave também dos níveis sem coeficiente
  # nesta base, para a legenda ser a mesma em todas as figuras.
  ggplot2::geom_errorbarh(ggplot2::aes(xmin = ic_inf, xmax = ic_sup),
                          height = 0.25, show.legend = TRUE) +
  ggplot2::geom_point(size = 2.5, show.legend = TRUE) +
  ggplot2::facet_wrap(~ modelo, scales = "free", ncol = 2) +
  ggplot2::scale_colour_manual(values = cores_evidencia, name = NULL,
                               drop = FALSE) +
  ggplot2::guides(colour = ggplot2::guide_legend(ncol = 2)) +
  ggplot2::labs(x = paste("Coeficiente (dependente: log da eficiência",
                          "corrigida, truncada em 0; positivo = mais",
                          "eficiente)"),
                y = NULL,
                title = paste("Segundo estágio: truncada sobre log(escore),",
                              "escores fixos, bootstrap por país")) +
  tema + ggplot2::theme(strip.text = ggplot2::element_text(size = 9))
SalvarFigura(fig4, "fig4_segundo_estagio", 12, 9)

# 5. Eficiência por grupo de renda e ano ---------------------------------------
fig5 <- ggplot2::ggplot(boot_m2, ggplot2::aes(x = factor(ano), y = escore_bc,
                                              fill = grupo_renda)) +
  ggplot2::geom_boxplot(alpha = 0.7, outlier.size = 0.8) +
  ggplot2::scale_fill_manual(values = cores_renda, name = NULL) +
  ggplot2::labs(x = "Ano", y = "Eficiência corrigida de viés (VRS, M2)",
                title = paste("Distribuição da eficiência por grupo de",
                              "renda e ano")) +
  tema
SalvarFigura(fig5, "fig5_renda_ano", 10, 6)

# 5b. Dispersão do escore por grupo de renda e ano (S08) -------------------
# Escore corrigido de viés. As fronteiras são anuais (contemporâneas): o
# nível do escore não se compara entre anos, e a dispersão também não é
# automaticamente comparável, porque uma fronteira nova pode mudar os
# escores de forma não proporcional (A15 de artigo/17). As medidas
# descrevem a dispersão observada em cada referência anual: IQR é
# dispersão ABSOLUTA do escore (multiplicar todos os escores por c
# multiplica o IQR por c); CV (desvio-padrão / média) e IQR relativo (IQR
# / mediana) são relativas ao centro da distribuição e não mudam com essa
# multiplicação. Em cada grupo e ano, também quem fica nos extremos (quem
# "abre" a distribuição).
dispersao <- boot_m2 |>
  dplyr::group_by(grupo_renda, ano) |>
  dplyr::summarise(
    n = dplyr::n(), media = mean(escore_bc),
    mediana = stats::median(escore_bc),
    desvio_padrao = if (dplyr::n() > 1) stats::sd(escore_bc) else NA_real_,
    iqr = stats::IQR(escore_bc), minimo = min(escore_bc),
    pais_minimo = pais[which.min(escore_bc)], maximo = max(escore_bc),
    pais_maximo = pais[which.max(escore_bc)], .groups = "drop") |>
  dplyr::mutate(cv = desvio_padrao / media, iqr_relativo = iqr / mediana)
SalvarTabela(dispersao, paste0("dispersao_renda_ano", sufixo))
# Tendência da dispersão por grupo (anos com pelo menos 3 países; com menos
# de 4 anos assim o grupo fica de fora), com dois objetos distintos:
#   - inclinação do CV, do IQR e do IQR relativo no ano: MQO com um ponto
#     por ano (4 a 9 anos), só descrição de tendência (sem significância,
#     isso não prova estabilidade);
#   - alvo inferencial: diferença do desvio absoluto mediano em relação à
#     mediana de cada ano entre a segunda e a primeira metade do período.
#     Os mesmos países aparecem nas duas metades (A10 de artigo/17): o IC e
#     o p-valor vêm de reamostrar PAÍSES (trajetórias completas, todos os
#     anos juntos), recalculando em cada réplica as medianas anuais e os
#     desvios; os escores ficam fixos, então o resultado é condicional às
#     fronteiras anuais estimadas. Sensibilidade pareada: Wilcoxon de
#     postos sinalizados sobre o desvio médio de cada país em cada metade,
#     só com os países presentes nas duas.
n_boot_dispersao <- 2000
DesvioMedianoMetades <- function(d) {
  # Desvio absoluto em relação à mediana do ano; devolve as medianas desses
  # desvios na primeira e na segunda metade.
  d$desvio <- abs(d$escore_bc - stats::ave(d$escore_bc, d$ano,
                                           FUN = stats::median))
  return(c(primeira = stats::median(d$desvio[d$periodo == "primeira"]),
           segunda = stats::median(d$desvio[d$periodo == "segunda"])))
}
TendenciaDispersao <- function(g) {
  d <- boot_m2[boot_m2$grupo_renda == g, ]
  por_ano <- dispersao[dispersao$grupo_renda == g & dispersao$n >= 3, ]
  if (nrow(por_ano) < 4) return(NULL)
  d <- d[d$ano %in% por_ano$ano, ]
  corte <- stats::median(por_ano$ano)
  d$periodo <- ifelse(d$ano <= corte, "primeira", "segunda")
  Inclinacao <- function(coluna) {
    return(summary(stats::lm(stats::as.formula(paste(coluna, "~ ano")),
                             data = por_ano))$coefficients["ano", ])
  }
  cv <- Inclinacao("cv")
  iqr <- Inclinacao("iqr")
  iqr_rel <- Inclinacao("iqr_relativo")
  ponto <- DesvioMedianoMetades(d)
  paises <- unique(d$pais)
  set.seed(semente)
  reps <- replicate(n_boot_dispersao, {
    escolhidos <- sample(paises, replace = TRUE)
    db <- do.call(rbind, lapply(escolhidos, function(p) d[d$pais == p, ]))
    m <- DesvioMedianoMetades(db)
    unname(m["segunda"] - m["primeira"])
  })
  reps <- reps[is.finite(reps)]
  # Sensibilidade pareada: desvio médio por país em cada metade.
  d$desvio <- abs(d$escore_bc - stats::ave(d$escore_bc, d$ano,
                                           FUN = stats::median))
  por_pais <- d |>
    dplyr::group_by(pais, periodo) |>
    dplyr::summarise(desvio = mean(desvio), .groups = "drop") |>
    tidyr::pivot_wider(names_from = periodo, values_from = desvio) |>
    dplyr::filter(!is.na(primeira), !is.na(segunda))
  pareado <- stats::wilcox.test(por_pais$segunda, por_pais$primeira,
                                paired = TRUE, exact = FALSE)
  return(data.frame(
    grupo_renda = g, anos = nrow(por_ano), observacoes = nrow(d),
    n_paises = length(paises), paises_nas_duas_metades = nrow(por_pais),
    inclinacao_cv = cv[1], p_inclinacao_cv = cv[4],
    inclinacao_iqr = iqr[1], p_inclinacao_iqr = iqr[4],
    inclinacao_iqr_relativo = iqr_rel[1],
    p_inclinacao_iqr_relativo = iqr_rel[4],
    leitura_inclinacoes = "descritiva (MQO com um ponto por ano)",
    corte_periodo = corte,
    desvio_mediano_primeira = unname(ponto["primeira"]),
    desvio_mediano_segunda = unname(ponto["segunda"]),
    dif_desvio_mediano = unname(ponto["segunda"] - ponto["primeira"]),
    ic_inf_dif = unname(stats::quantile(reps, 0.025)),
    ic_sup_dif = unname(stats::quantile(reps, 0.975)),
    p_boot_paises = min(1, 2 * min(mean(reps <= 0), mean(reps >= 0))),
    replicas_validas = length(reps),
    p_wilcoxon_pareado_paises = pareado$p.value,
    inferencia = paste("bootstrap de países (trajetórias completas),",
                       "escores fixos; sensibilidade: Wilcoxon pareado",
                       "por país"),
    stringsAsFactors = FALSE, row.names = NULL))
}
tendencia <- do.call(rbind, lapply(sort(unique(boot_m2$grupo_renda)),
                                   TendenciaDispersao))
if (!is.null(tendencia)) {
  SalvarTabela(tendencia, paste0("dispersao_renda_tendencia", sufixo))
  print(tendencia)
}

# 6. Concordância entre estimadores --------------------------------------------
cor_est <- LerTabela("spearman_estimadores_m2")
cor_est$par <- paste(cor_est$a, "x", cor_est$b)
fig6 <- ggplot2::ggplot(cor_est, ggplot2::aes(x = rho,
                                              y = stats::reorder(par, rho))) +
  ggplot2::geom_errorbarh(ggplot2::aes(xmin = ic_inf, xmax = ic_sup),
                          height = 0.25) +
  ggplot2::geom_point(size = 3, colour = "#1f77b4") +
  ggplot2::geom_vline(xintercept = 0.7, linetype = 2, colour = "grey40") +
  ggplot2::labs(x = "Correlação de Spearman (IC 95% bootstrap)", y = NULL,
                title = "Robustez dos rankings entre estimadores (R1)") +
  tema
SalvarFigura(fig6, "fig6_estimadores", 9, 5)

# 7. Metafronteira: TGR por grupo ---------------------------------------------
meta <- LerTabela("metafronteira_renda_m2")
fig7 <- ggplot2::ggplot(meta, ggplot2::aes(x = grupo, y = tgr, fill = grupo)) +
  ggplot2::geom_boxplot(alpha = 0.7) +
  ggplot2::scale_fill_manual(values = cores_renda, guide = "none") +
  ggplot2::labs(x = NULL, y = "Razão de gap tecnológico (TGR)",
                title = paste0("Metafronteira por grupo de renda (pooled ",
                               periodo, ", M2)")) +
  tema
SalvarFigura(fig7, "fig7_metafronteira", 7, 5)
RegistrarManifesto("04_figuras_apresentacao.R", sufixo,
                   Sys.getenv("BASE_ARQUIVO", "data/processed/base_atual.csv"),
                   "ok", detalhe = "tabelas lidas em manifesto_entradas.csv")
Registrar("FIM figuras Fase A")
