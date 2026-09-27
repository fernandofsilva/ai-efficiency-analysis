# 12_import_fontes_alternativas.R
# Fase B: importa as fontes alternativas baixadas manualmente — dados
# públicos do AI Index 2025 (data/ai_index/) e exportação do OECD.AI
# (data/oecd-ai/) — e produz:
#   data/processed/ai_index_pais_ano.csv    painel de talento em IA;
#   data/processed/ai_index_transversal.csv investimento e empresas
#                                           acumulados (Quid), habilidades;
#   data/processed/oecd_ai_publicacoes.csv  parcela mundial de publicações;
#   checagens cruzadas com o CSET em output/tables e output/figures.
# Uso: Rscript R/12_import_fontes_alternativas.R (após R/11)

source("R/00_setup.R")

pasta_ai_index <- "data/ai_index"
pasta_oecd <- "data/oecd-ai"

LerAiIndex <- function(capitulo, figura) {
  # Lê um CSV de dados do AI Index (arquivos têm BOM UTF-8).
  arquivo <- file.path(pasta_ai_index, capitulo, "Data",
                       paste0("fig_", figura, ".csv"))
  dados <- utils::read.csv(arquivo, check.names = FALSE,
                           stringsAsFactors = FALSE,
                           fileEncoding = "UTF-8-BOM")
  return(dados)
}

PercentualParaNumero <- function(x) {
  # Converte "0.26%" em 0.26; vazios viram NA.
  x <- gsub("%", "", trimws(as.character(x)))
  x[x == ""] <- NA
  return(as.numeric(x))
}

IsoDe <- function(nomes) {
  # Mapeia nomes do AI Index (com asteriscos de nota) para ISO3.
  limpos <- trimws(gsub("\\*", "", nomes))
  return(countrycode::countrycode(limpos, "country.name", "iso3c",
                                  warn = FALSE))
}

AnoDeData <- function(x) {
  # Datas no formato m/d/aa (ex.: "1/1/19").
  return(as.integer(format(as.Date(x, format = "%m/%d/%y"), "%Y")))
}

economia <- "4. Economy"

# 1. Painel de talento em IA (LinkedIn via AI Index) -------------------------
talento <- LerAiIndex(economia, "4.2.19")
names(talento) <- c("ano", "pais", "genero", "valor")
talento$valor <- PercentualParaNumero(talento$valor)
talento <- talento |>
  dplyr::mutate(iso3c = IsoDe(pais), ano = as.integer(ano)) |>
  dplyr::filter(!is.na(iso3c)) |>
  dplyr::group_by(iso3c, ano) |>
  dplyr::summarise(
    talento_ia_pct = mean(valor, na.rm = TRUE),   # média simples F/M
    talento_ia_fem_pct = valor[genero == "Female"][1],
    talento_ia_masc_pct = valor[genero == "Male"][1],
    .groups = "drop")

contratacao <- LerAiIndex(economia, "4.2.14")
names(contratacao) <- c("data", "pais", "valor")
contratacao <- contratacao |>
  dplyr::mutate(iso3c = IsoDe(pais), ano = AnoDeData(data),
                valor = PercentualParaNumero(valor)) |>
  dplyr::filter(!is.na(iso3c), !is.na(valor)) |>
  dplyr::group_by(iso3c, ano) |>
  dplyr::summarise(contratacao_ia_rel_pct = mean(valor),
                   meses_contratacao = dplyr::n(), .groups = "drop")

migracao <- LerAiIndex(economia, "4.2.23")
names(migracao) <- c("data", "pais", "valor")
migracao <- migracao |>
  dplyr::mutate(iso3c = IsoDe(pais), ano = AnoDeData(data),
                valor = as.numeric(valor)) |>
  dplyr::filter(!is.na(iso3c), !is.na(valor)) |>
  dplyr::group_by(iso3c, ano) |>
  dplyr::summarise(migracao_talento_10k = mean(valor), .groups = "drop")

vagas <- rbind(LerAiIndex(economia, "4.2.1"), LerAiIndex(economia, "4.2.2"))
names(vagas) <- c("ano", "valor", "pais")
vagas <- vagas |>
  dplyr::mutate(iso3c = IsoDe(pais), ano = as.integer(ano),
                valor = PercentualParaNumero(valor)) |>
  dplyr::filter(!is.na(iso3c), !is.na(valor)) |>
  dplyr::group_by(iso3c, ano) |>
  dplyr::summarise(vagas_ia_pct = mean(valor), .groups = "drop")

painel_ai_index <- talento |>
  dplyr::full_join(contratacao, by = c("iso3c", "ano")) |>
  dplyr::full_join(migracao, by = c("iso3c", "ano")) |>
  dplyr::full_join(vagas, by = c("iso3c", "ano")) |>
  dplyr::arrange(iso3c, ano)
stopifnot(!any(duplicated(painel_ai_index[, c("iso3c", "ano")])))
utils::write.csv(painel_ai_index, "data/processed/ai_index_pais_ano.csv",
                 row.names = FALSE)
Registrar("ai_index_pais_ano.csv:", nrow(painel_ai_index), "linhas,",
          length(unique(painel_ai_index$iso3c)), "países,",
          min(painel_ai_index$ano), "-", max(painel_ai_index$ano))

# 2. Cortes transversais (Quid via AI Index) ---------------------------------
inv_acum <- LerAiIndex(economia, "4.3.9")
names(inv_acum) <- c("pais", "investimento_quid_acum_bi")
emp_acum <- LerAiIndex(economia, "4.3.13")
names(emp_acum) <- c("pais", "empresas_quid_acum")
habilidades <- LerAiIndex(economia, "4.2.15")
names(habilidades) <- c("pais", "penetracao_habilidades_ia")
talento_2024 <- LerAiIndex(economia, "4.2.17")
names(talento_2024) <- c("pais", "talento_ia_2024_pct")
talento_2024$talento_ia_2024_pct <- PercentualParaNumero(
  talento_2024$talento_ia_2024_pct)
transversal <- inv_acum |>
  dplyr::full_join(emp_acum, by = "pais") |>
  dplyr::full_join(habilidades, by = "pais") |>
  dplyr::full_join(talento_2024, by = "pais") |>
  dplyr::mutate(iso3c = IsoDe(pais)) |>
  dplyr::filter(!is.na(iso3c)) |>
  dplyr::distinct(iso3c, .keep_all = TRUE) |>
  dplyr::relocate(iso3c)
utils::write.csv(transversal, "data/processed/ai_index_transversal.csv",
                 row.names = FALSE)
Registrar("ai_index_transversal.csv:", nrow(transversal), "países")

# 3. OECD.AI: parcela mundial de publicações de IA (OpenAlex) ---------------
oecd <- utils::read.csv(file.path(pasta_oecd, "data.csv"), check.names = FALSE,
                        stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
oecd <- data.frame(iso3c = oecd[["Country/territory"]],
                   ano = as.integer(oecd$year),
                   share_pub_oecd = as.numeric(oecd$publications),
                   stringsAsFactors = FALSE)
oecd <- oecd[oecd$iso3c != "EU27", ]
utils::write.csv(oecd, "data/processed/oecd_ai_publicacoes.csv",
                 row.names = FALSE)
Registrar("oecd_ai_publicacoes.csv:", nrow(oecd), "linhas,",
          length(unique(oecd$iso3c)), "economias")

# 3b. OECD Data Explorer: famílias de patentes de IA por país do inventor
# (baixadas por R/14; contagem fracionária, IP5 e triádicas) ------------------
arquivo_pat <- "data/oecd-ai/patentes_ia_ip5_inventor.csv"
arquivo_tri <- "data/oecd-ai/patentes_ia_triadicas_inventor.csv"
oecd_pat <- NULL
if (file.exists(arquivo_pat)) {
  ip5 <- utils::read.csv(arquivo_pat, stringsAsFactors = FALSE)
  ip5 <- ip5[nchar(ip5$iso3c) == 3, c("iso3c", "ano", "familias")]
  names(ip5)[3] <- "patentes_inventor"
  oecd_pat <- ip5
  if (file.exists(arquivo_tri)) {
    tri <- utils::read.csv(arquivo_tri, stringsAsFactors = FALSE)
    tri <- tri[nchar(tri$iso3c) == 3, c("iso3c", "ano", "familias")]
    names(tri)[3] <- "patentes_triadicas"
    oecd_pat <- dplyr::full_join(oecd_pat, tri, by = c("iso3c", "ano"))
  }
  # Defasagem de publicação: o último ano disponível é incompleto.
  ultimo_ano <- max(oecd_pat$ano)
  oecd_pat$ano_incompleto <- oecd_pat$ano >= ultimo_ano
  utils::write.csv(oecd_pat, "data/processed/oecd_ai_patentes.csv",
                   row.names = FALSE)
  Registrar("oecd_ai_patentes.csv:", nrow(oecd_pat), "linhas,",
            length(unique(oecd_pat$iso3c)), "países; último ano",
            ultimo_ano, "marcado como incompleto")
} else {
  Registrar("patentes da OCDE ausentes: rode R/14_download_oecd_patentes.R")
}

# 3c. OECD.AI: VC em IA (Preqin), exportação manual do gráfico "VC
# investments in AI by country" (colunas Country, Country_label, INDUSTRY,
# STAGE, Sum_of_deals, Year; valores em milhões de US$ nominais) -------------
arquivo_vc <- "data/oecd-ai/vc_investimentos_pais_ano.csv"
oecd_vc <- NULL
if (file.exists(arquivo_vc)) {
  vc <- utils::read.csv(arquivo_vc, check.names = FALSE,
                        stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
  vc <- vc[nchar(vc$Country) == 3 & vc$STAGE == "VC", ]
  cpi <- BaixarWorldBank("FP.CPI.TOTL")
  cpi_eua <- cpi[cpi$iso3c == "USA", c("ano", "valor")]
  names(cpi_eua)[2] <- "cpi_eua"
  cpi_2021 <- cpi_eua$cpi_eua[cpi_eua$ano == 2021]
  oecd_vc <- data.frame(iso3c = vc$Country, ano = as.integer(vc$Year),
                        vc_preqin_mi_nominal = as.numeric(vc$Sum_of_deals),
                        stringsAsFactors = FALSE) |>
    dplyr::left_join(cpi_eua, by = "ano")
  ultimo_cpi <- cpi_eua$cpi_eua[which.max(cpi_eua$ano)]
  oecd_vc$cpi_eua[is.na(oecd_vc$cpi_eua)] <- ultimo_cpi
  oecd_vc$investimento_preqin <- oecd_vc$vc_preqin_mi_nominal * 1e6 *
    cpi_2021 / oecd_vc$cpi_eua
  oecd_vc <- oecd_vc[, c("iso3c", "ano", "vc_preqin_mi_nominal",
                         "investimento_preqin")]
  utils::write.csv(oecd_vc, "data/processed/oecd_ai_vc.csv",
                   row.names = FALSE)
  Registrar("oecd_ai_vc.csv:", nrow(oecd_vc), "linhas,",
            length(unique(oecd_vc$iso3c)), "países,", min(oecd_vc$ano), "-",
            max(oecd_vc$ano), "| zeros:", sum(oecd_vc$investimento_preqin == 0))
} else {
  Registrar("VC do OECD.AI ausente (exportação manual pendente; ver",
            "artigo/02_dados_externos.md)")
}

# 4. Checagens cruzadas com o CSET ---------------------------------------------
cset <- utils::read.csv("data/processed/cset_long.csv",
                        stringsAsFactors = FALSE)

# 4a. Investimento acumulado: CSET estimado 2016-2024 (nominal) vs Quid
# 2013-2024. Janelas e fornecedores diferem; a comparação é de ordem.
cset_acum <- cset |>
  dplyr::filter(ano >= 2016, ano <= 2024,
                inv_estimado_mi_completo %in% TRUE) |>
  dplyr::group_by(iso3c) |>
  dplyr::summarise(cset_estimado_acum_bi = sum(inv_estimado_mi) / 1e3,
                   anos_cset = dplyr::n(), .groups = "drop")
checagem_inv <- transversal |>
  dplyr::select(iso3c, pais, investimento_quid_acum_bi, empresas_quid_acum) |>
  dplyr::inner_join(cset_acum, by = "iso3c") |>
  dplyr::mutate(razao_cset_quid = cset_estimado_acum_bi /
                  investimento_quid_acum_bi) |>
  dplyr::arrange(dplyr::desc(investimento_quid_acum_bi))
rho_inv <- SpearmanComIc(checagem_inv$cset_estimado_acum_bi,
                         checagem_inv$investimento_quid_acum_bi)
Registrar("Spearman CSET x Quid (investimento acumulado):",
          paste(round(rho_inv, 3), collapse = " "))
SalvarTabela(checagem_inv, "checagem_investimento_cset_vs_quid")
SalvarTabela(as.data.frame(t(rho_inv)), "checagem_investimento_spearman")

fig8 <- ggplot2::ggplot(
  checagem_inv,
  ggplot2::aes(x = investimento_quid_acum_bi, y = cset_estimado_acum_bi,
               label = pais)) +
  ggplot2::geom_abline(slope = 1, intercept = 0, linetype = 3,
                       colour = "grey50") +
  ggplot2::geom_point(colour = "#1f77b4", size = 2.5) +
  ggrepel::geom_text_repel(size = 3, max.overlaps = 25) +
  ggplot2::scale_x_log10() +
  ggplot2::scale_y_log10() +
  ggplot2::labs(x = paste("AI Index / Quid: investimento privado acumulado",
                          "2013-24 (bi US$)"),
                y = "CSET: investimento estimado acumulado 2016-24 (bi US$)",
                title = "Investimento privado em IA: dois fornecedores",
                subtitle = sprintf("Spearman = %.2f [%.2f; %.2f], n = %d",
                                   rho_inv["rho"], rho_inv["ic_inf"],
                                   rho_inv["ic_sup"], nrow(checagem_inv))) +
  ggplot2::theme_minimal(base_size = 13)
ggplot2::ggsave("output/figures/fig8_investimento_cset_vs_quid.png", fig8,
                width = 9, height = 7, dpi = 200, bg = "white")

# 4b. Publicações: parcela mundial CSET vs OECD.AI (OpenAlex) para as
# economias exportadas, 2016-2024.
share_cset <- cset |>
  dplyr::filter(ano >= 2016, ano <= 2024, artigos_completo %in% TRUE) |>
  dplyr::group_by(ano) |>
  dplyr::mutate(share_pub_cset = 100 * artigos / sum(artigos)) |>
  dplyr::ungroup() |>
  dplyr::select(iso3c, ano, artigos, share_pub_cset)
checagem_pub <- oecd |>
  dplyr::inner_join(share_cset, by = c("iso3c", "ano")) |>
  dplyr::arrange(iso3c, ano)
rho_pub <- SpearmanComIc(checagem_pub$share_pub_cset,
                         checagem_pub$share_pub_oecd)
pearson_pub <- stats::cor(checagem_pub$share_pub_cset,
                          checagem_pub$share_pub_oecd)
Registrar("Publicações CSET x OECD.AI: Spearman",
          paste(round(rho_pub, 3), collapse = " "), "| Pearson",
          round(pearson_pub, 3))
SalvarTabela(checagem_pub, "checagem_publicacoes_cset_vs_oecd")
resumo_pub <- checagem_pub |>
  dplyr::group_by(iso3c) |>
  dplyr::summarise(anos = dplyr::n(), share_cset = mean(share_pub_cset),
                   share_oecd = mean(share_pub_oecd),
                   razao = share_cset / share_oecd, .groups = "drop")
SalvarTabela(resumo_pub, "checagem_publicacoes_resumo")
print(as.data.frame(resumo_pub))
# 4c. Patentes: CSET (pedidos, escritório de depósito) vs OCDE (famílias
# IP5, país do inventor), 2016-2021.
if (!is.null(oecd_pat)) {
  cset_pat <- cset |>
    dplyr::filter(ano >= 2016, ano <= 2021,
                  patentes_pedidos_completo %in% TRUE) |>
    dplyr::select(iso3c, ano, patentes_cset = patentes_pedidos)
  checagem_pat <- oecd_pat |>
    dplyr::filter(!ano_incompleto) |>
    dplyr::inner_join(cset_pat, by = c("iso3c", "ano")) |>
    dplyr::filter(patentes_cset > 0 | patentes_inventor > 0)
  rho_pat <- SpearmanComIc(checagem_pat$patentes_cset,
                           checagem_pat$patentes_inventor)
  Registrar("Patentes CSET x OCDE (país-ano):",
            paste(round(rho_pat, 3), collapse = " "))
  SalvarTabela(checagem_pat, "checagem_patentes_cset_vs_oecd")
  resumo_pat <- checagem_pat |>
    dplyr::group_by(iso3c) |>
    dplyr::summarise(anos = dplyr::n(), cset = mean(patentes_cset),
                     oecd_ip5 = mean(patentes_inventor),
                     razao_cset_oecd = cset / oecd_ip5, .groups = "drop") |>
    dplyr::arrange(dplyr::desc(oecd_ip5))
  rho_pat_pais <- SpearmanComIc(resumo_pat$cset, resumo_pat$oecd_ip5)
  resumo_pat$rho_pais <- rho_pat_pais["rho"]
  SalvarTabela(resumo_pat, "checagem_patentes_resumo")
  SalvarTabela(as.data.frame(t(rho_pat)), "checagem_patentes_spearman")
  fig9 <- ggplot2::ggplot(
    resumo_pat, ggplot2::aes(x = oecd_ip5 + 1, y = cset + 1, label = iso3c)) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = 3,
                         colour = "grey50") +
    ggplot2::geom_point(colour = "#1f77b4", size = 2.5) +
    ggrepel::geom_text_repel(size = 3, max.overlaps = 30) +
    ggplot2::scale_x_log10() +
    ggplot2::scale_y_log10() +
    ggplot2::labs(x = "OCDE: famílias IP5 de IA por país do inventor (+1)",
                  y = "CSET: pedidos de patente de IA por escritório (+1)",
                  title = paste("Patentes de IA: atribuição por inventor",
                                "vs escritório"),
                  subtitle = sprintf(
                    paste("Médias 2016-2021 por país; Spearman = %.2f",
                          "(país-ano %.2f)"),
                    rho_pat_pais["rho"], rho_pat["rho"])) +
    ggplot2::theme_minimal(base_size = 13)
  ggplot2::ggsave("output/figures/fig9_patentes_cset_vs_oecd.png", fig9,
                  width = 9, height = 7, dpi = 200, bg = "white")
  print(as.data.frame(utils::head(resumo_pat, 12)))
}
# 4d. Investimento por país-ano: CSET (estimado, Crunchbase) vs OECD.AI
# (Preqin), ambos em US$ constantes de 2021, 2016-2023.
if (!is.null(oecd_vc)) {
  cset_inv <- cset |>
    dplyr::filter(ano >= 2016, ano <= 2023,
                  inv_estimado_mi_completo %in% TRUE) |>
    dplyr::select(iso3c, ano, investimento_cset = investimento)
  checagem_vc <- oecd_vc |>
    dplyr::inner_join(cset_inv, by = c("iso3c", "ano")) |>
    dplyr::filter(investimento_cset > 0 | investimento_preqin > 0)
  rho_vc <- SpearmanComIc(checagem_vc$investimento_cset,
                          checagem_vc$investimento_preqin)
  Registrar("Investimento CSET x Preqin (país-ano):",
            paste(round(rho_vc, 3), collapse = " "))
  SalvarTabela(checagem_vc, "checagem_investimento_cset_vs_preqin")
  resumo_vc <- checagem_vc |>
    dplyr::group_by(iso3c) |>
    dplyr::summarise(anos = dplyr::n(),
                     cset_bi = mean(investimento_cset) / 1e9,
                     preqin_bi = mean(investimento_preqin) / 1e9,
                     razao_cset_preqin = cset_bi / preqin_bi,
                     .groups = "drop") |>
    dplyr::arrange(dplyr::desc(preqin_bi))
  rho_vc_pais <- SpearmanComIc(resumo_vc$cset_bi, resumo_vc$preqin_bi)
  resumo_vc$rho_pais <- rho_vc_pais["rho"]
  SalvarTabela(resumo_vc, "checagem_investimento_preqin_resumo")
  SalvarTabela(as.data.frame(t(rho_vc)),
               "checagem_investimento_preqin_spearman")
  fig10 <- ggplot2::ggplot(
    resumo_vc, ggplot2::aes(x = preqin_bi + 1e-3, y = cset_bi + 1e-3,
                            label = iso3c)) +
    ggplot2::geom_abline(slope = 1, intercept = 0, linetype = 3,
                         colour = "grey50") +
    ggplot2::geom_point(colour = "#1f77b4", size = 2.5) +
    ggrepel::geom_text_repel(size = 3, max.overlaps = 30) +
    ggplot2::scale_x_log10() +
    ggplot2::scale_y_log10() +
    ggplot2::labs(x = paste("OECD.AI / Preqin: VC em IA, média anual",
                            "2016-23 (bi US$ 2021)"),
                  y = paste("CSET: investimento estimado, média anual",
                            "(bi US$ 2021)"),
                  title = paste("Investimento em IA por país-ano:",
                                "Preqin vs Crunchbase"),
                  subtitle = sprintf(
                    "Spearman país-ano = %.2f [%.2f; %.2f]; por país = %.2f",
                    rho_vc["rho"], rho_vc["ic_inf"], rho_vc["ic_sup"],
                    rho_vc_pais["rho"])) +
    ggplot2::theme_minimal(base_size = 13)
  ggplot2::ggsave("output/figures/fig10_investimento_cset_vs_preqin.png",
                  fig10, width = 9, height = 7, dpi = 200, bg = "white")
  print(as.data.frame(utils::head(resumo_vc, 12)))
}
Registrar("FIM importação de fontes alternativas")
