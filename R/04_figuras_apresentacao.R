# 04_figuras_apresentacao.R
# Fase A: figuras para a apresentação (a partir das tabelas de output/tables).
# Figuras: ranking com IC, decomposição de Malmquist, canais acadêmico x
# tecnológico, coeficientes do segundo estágio, eficiência por grupo de renda
# e ano, comparação de estimadores.
# Uso: Rscript R/04_figuras_apresentacao.R (após os scripts 02 e 03)

source("R/00_setup.R")

sufixo <- Sys.getenv("SUFIXO_SAIDA", "")

LerTabela <- function(nome) {
  return(utils::read.csv(file.path("output/tables",
                                   paste0(nome, sufixo, ".csv")),
                         stringsAsFactors = FALSE))
}

SalvarFigura <- function(grafico, nome, largura = 9, altura = 6) {
  ggplot2::ggsave(file.path("output/figures", paste0(nome, sufixo, ".png")),
                  grafico, width = largura, height = altura, dpi = 200,
                  bg = "white")
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
                subtitle = paste("Média", periodo, "dos escores anuais",
                                 "corrigidos (cheio) e originais (vazado);",
                                 "barras: IC 95% bootstrap da média anual;",
                                 "entre parênteses, anos por país")) +
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
if ("dependente" %in% names(seg)) seg <- seg[seg$dependente == "escore", ]
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
fig4 <- ggplot2::ggplot(seg, ggplot2::aes(x = coeficiente, y = termo_rotulo,
                                          colour = significativo_5pct)) +
  ggplot2::geom_vline(xintercept = 0, linetype = 2) +
  ggplot2::geom_errorbarh(ggplot2::aes(xmin = ic_inf, xmax = ic_sup),
                          height = 0.25) +
  ggplot2::geom_point(size = 2.5) +
  ggplot2::facet_wrap(~ modelo, scales = "free", ncol = 2) +
  ggplot2::scale_colour_manual(values = c(`TRUE` = "#d62728",
                                          `FALSE` = "grey50"),
                               name = "IC 95% exclui zero") +
  ggplot2::labs(x = paste("Coeficiente (dependente: eficiência corrigida",
                          "em (0,1]; positivo = mais eficiente)"),
                y = NULL,
                title = paste("Segundo estágio: truncada, escores fixos,",
                              "bootstrap por país (dependente em (0,1])")) +
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
Registrar("FIM figuras Fase A")
