# 13_build_painel.R
# Fase B: monta o painel reconstruído (CSET 2016-2024 + World Bank) em
# data/processed/painel_ia.csv, com critério de inclusão explícito, insumos
# defasados e somas móveis, GERD em US$, classificação de renda do World
# Bank,
# tabela de cobertura e codebook (artigo/03_codebook.md).
# Uso: Rscript R/13_build_painel.R (após R/10 e R/11)

source("R/00_setup.R")

cset <- utils::read.csv("data/processed/cset_long.csv",
                        stringsAsFactors = FALSE)

# Indicadores do World Bank (cache de R/10) ----------------------------------
wdi_codigos <- c(populacao = "SP.POP.TOTL",
                 pesquisadores_pm = "SP.POP.SCIE.RD.P6",
                 pd_pct_pib = "GB.XPD.RSDV.GD.ZS", pib = "NY.GDP.MKTP.KD",
                 pib_pc = "NY.GDP.PCAP.KD", pib_ppc = "NY.GDP.MKTP.PP.KD",
                 artigos_ct = "IP.JRN.ARTC.SC",
                 matricula_terciaria = "SE.TER.ENRR",
                 internet_pct = "IT.NET.USER.ZS",
                 banda_larga_p100 = "IT.NET.BBND.P2",
                 alta_tec_export = "TX.VAL.TECH.MF.ZS",
                 credito_privado = "FS.AST.PRVT.GD.ZS",
                 market_cap = "CM.MKT.LCAP.GD.ZS", npl = "FB.AST.NPER.ZS",
                 zscore = "GFDD.SI.01", patentes_residentes = "IP.PAT.RESD",
                 patentes_nao_resid = "IP.PAT.NRES",
                 comercio = "NE.TRD.GNFS.ZS")
wdi <- NULL
for (nome in names(wdi_codigos)) {
  tabela <- LerWorldBank(wdi_codigos[[nome]], nome)
  wdi <- if (is.null(wdi)) tabela else dplyr::full_join(wdi, tabela,
                                                        by = c("iso3c", "ano"))
}
wgi_codigos <- c(efetividade_governo = "GOV_WGI_GE.EST",
                 controle_corrupcao = "GOV_WGI_CC.EST",
                 estado_direito = "GOV_WGI_RL.EST",
                 qualidade_regulatoria = "GOV_WGI_RQ.EST")
for (nome in names(wgi_codigos)) {
  tabela <- LerWorldBank(wgi_codigos[[nome]], nome, pasta = "data/wgi")
  wdi <- dplyr::full_join(wdi, tabela, by = c("iso3c", "ano"))
}
paises_wb <- BaixarPaisesWorldBank()

# Junção -----------------------------------------------------------------------
painel <- cset |>
  dplyr::filter(ano >= 2016, ano <= 2024) |>
  dplyr::left_join(wdi, by = c("iso3c", "ano")) |>
  dplyr::left_join(paises_wb, by = "iso3c")

# Critério de inclusão ---------------------------------------------------------
artigos_2016 <- painel |>
  dplyr::filter(ano == 2016) |>
  dplyr::select(iso3c, artigos_2016 = publicacoes)
tem_patentes <- painel |>
  dplyr::group_by(iso3c) |>
  dplyr::summarise(anos_patentes = sum(!is.na(patentes)),
                   anos_investimento = sum(!is.na(investimento)),
                   anos_pib = sum(!is.na(pib) & !is.na(populacao)),
                   anos_gerd = sum(!is.na(pd_pct_pib)), .groups = "drop")
criterios <- artigos_2016 |>
  dplyr::full_join(tem_patentes, by = "iso3c") |>
  dplyr::left_join(dplyr::distinct(painel, iso3c, pais_cset), by = "iso3c") |>
  dplyr::mutate(
    artigos_2016 = ifelse(is.na(artigos_2016), 0, artigos_2016),
    ok_artigos = artigos_2016 >= 100,
    ok_patentes = anos_patentes >= 3,     # Índia tem 2016-2018 completos
    ok_investimento = anos_investimento >= 6,
    ok_pib = anos_pib >= 9,
    ok_gerd = anos_gerd >= 3,          # interpolação exige >= 2 pontos
    elegivel = ok_artigos & ok_patentes & ok_investimento & ok_pib & ok_gerd)
SalvarTabela(criterios[criterios$ok_artigos, ], "painel_elegibilidade")
elegiveis <- criterios[criterios$elegivel, ]
excluidos <- criterios[criterios$ok_artigos & !criterios$elegivel, ]
Registrar("países elegíveis:", nrow(elegiveis), "| candidatos excluídos:",
          paste(excluidos$pais_cset, collapse = ", "))
painel <- painel[painel$iso3c %in% elegiveis$iso3c, ]

# GERD com interpolação dentro do país (anos recentes sem dado) ---------------
painel <- InterpolarPorPais(painel, "pd_pct_pib")
painel$gerd <- painel$pd_pct_pib / 100 * painel$pib

# Defasagens e somas móveis (por país) ----------------------------------------
painel <- painel |>
  dplyr::arrange(iso3c, ano) |>
  dplyr::group_by(iso3c) |>
  dplyr::mutate(
    investimento_l1 = dplyr::lag(investimento, 1),
    investimento_mm3 = investimento + dplyr::lag(investimento, 1) +
      dplyr::lag(investimento, 2),
    gerd_l1 = dplyr::lag(gerd, 1),
    patentes_pm = patentes / populacao * 1e6,
    publicacoes_pm = publicacoes / populacao * 1e6,
    investimento_pib = investimento / pib,
    inv_zero = !is.na(investimento) & investimento == 0,
    inv_piso = !is.na(investimento) & investimento > 0 &
      investimento <= 2.5e6) |>
  dplyr::ungroup()

# Colunas compatíveis com o pipeline da Fase A ---------------------------------
painel$pais <- painel$pais_cset
painel$log_pib_pc <- log(painel$pib_pc)
painel$log_comercio <- log(painel$comercio)
painel$obs_modelo_conjunto <- !is.na(painel$publicacoes) &
  !is.na(painel$patentes) & !is.na(painel$investimento_l1) &
  painel$investimento_l1 > 0 & !is.na(painel$gerd_l1)

# Fontes alternativas (AI Index), se já importadas por R/12 -------------------
arquivo_talento <- "data/processed/ai_index_pais_ano.csv"
if (file.exists(arquivo_talento)) {
  talento <- utils::read.csv(arquivo_talento, stringsAsFactors = FALSE)
  painel <- dplyr::left_join(painel, talento, by = c("iso3c", "ano"))
  Registrar("AI Index (talento) juntado:",
            sum(!is.na(painel$talento_ia_media_genero_pct)),
            "obs. com concentração")
}
arquivo_oecd_pat <- "data/processed/oecd_ai_patentes.csv"
if (file.exists(arquivo_oecd_pat)) {
  oecd_pat <- utils::read.csv(arquivo_oecd_pat, stringsAsFactors = FALSE)
  oecd_pat <- oecd_pat[!oecd_pat$ano_incompleto, ]
  oecd_pat$ano_incompleto <- NULL
  painel <- dplyr::left_join(painel, oecd_pat, by = c("iso3c", "ano"))
  painel$patentes_inventor_pm <- painel$patentes_inventor /
    painel$populacao * 1e6
  Registrar("patentes OCDE (inventor) juntadas:",
            sum(!is.na(painel$patentes_inventor)), "obs.")
}
arquivo_vc <- "data/processed/oecd_ai_vc.csv"
if (file.exists(arquivo_vc)) {
  oecd_vc <- utils::read.csv(arquivo_vc, stringsAsFactors = FALSE)
  painel <- dplyr::left_join(painel, oecd_vc[, c("iso3c", "ano",
                                                  "investimento_preqin")],
                             by = c("iso3c", "ano"))
  painel <- painel |>
    dplyr::arrange(iso3c, ano) |>
    dplyr::group_by(iso3c) |>
    dplyr::mutate(
      investimento_preqin_l1 = dplyr::lag(investimento_preqin, 1)) |>
    dplyr::ungroup()
  Registrar("VC Preqin juntado:", sum(!is.na(painel$investimento_preqin)),
            "obs.")
}
arquivo_msti <- "data/msti/msti_pd_setor_pct_pib.csv"
if (file.exists(arquivo_msti)) {
  msti <- utils::read.csv(arquivo_msti, stringsAsFactors = FALSE)
  msti <- msti[, c("iso3c", "ano", "herd_pct_pib", "goverd_pct_pib",
                   "pd_publico_pct_pib")]
  painel <- dplyr::left_join(painel, msti, by = c("iso3c", "ano"))
  painel <- InterpolarPorPais(painel, "pd_publico_pct_pib")
  painel$pd_publico <- painel$pd_publico_pct_pib / 100 * painel$pib
  painel <- painel |>
    dplyr::arrange(iso3c, ano) |>
    dplyr::group_by(iso3c) |>
    dplyr::mutate(pd_publico_l1 = dplyr::lag(pd_publico, 1)) |>
    dplyr::ungroup()
  Registrar("MSTI (P&D público) juntado:", sum(!is.na(painel$pd_publico)),
            "obs.,", length(unique(painel$iso3c[!is.na(painel$pd_publico)])),
            "países")
}
arquivo_transversal <- "data/processed/ai_index_transversal.csv"
if (file.exists(arquivo_transversal)) {
  transversal <- utils::read.csv(arquivo_transversal,
                                 stringsAsFactors = FALSE)
  transversal$pais <- NULL
  painel <- dplyr::left_join(painel, transversal, by = "iso3c")
}

# Grupo de renda (World Bank vigente) e subamostra original -------------------
painel$grupo_renda <- dplyr::case_when(
  painel$renda_wb == "High income" ~ "Alta renda",
  painel$renda_wb == "Upper middle income" ~ "Renda média-alta",
  painel$renda_wb == "Lower middle income" ~ "Renda média-baixa",
  painel$renda_wb == "Low income" ~ "Baixa renda",
  TRUE ~ NA_character_)
originais <- unique(utils::read.csv("data/AI_INVESTMENT.csv")$Country)
originais_iso <- countrycode::countrycode(originais, "country.name", "iso3c")
painel$subamostra_original <- painel$iso3c %in% originais_iso
painel$id <- paste(painel$iso3c, painel$ano, sep = "-")
painel <- painel |>
  dplyr::relocate(id, iso3c, pais_cset, ano, grupo_renda, regiao_wb,
                  subamostra_original)
utils::write.csv(painel, "data/processed/painel_ia.csv", row.names = FALSE)
Registrar("gravado data/processed/painel_ia.csv:", nrow(painel), "linhas,",
          length(unique(painel$iso3c)), "países")

# Cobertura --------------------------------------------------------------------
cobertura <- painel |>
  dplyr::group_by(ano) |>
  dplyr::summarise(paises = dplyr::n(),
                   n_publicacoes = sum(!is.na(publicacoes)),
                   n_patentes = sum(!is.na(patentes)),
                   n_concedidas = sum(!is.na(patentes_concedidas_ok)),
                   n_citacoes = sum(!is.na(citacoes_ok)),
                   n_investimento = sum(!is.na(investimento)),
                   n_inv_zero = sum(inv_zero),
                   n_gerd = sum(!is.na(gerd)),
                   n_modelo_conjunto = sum(obs_modelo_conjunto),
                   .groups = "drop")
SalvarTabela(cobertura, "painel_cobertura_por_ano")
print(as.data.frame(cobertura))
resumo_paises <- painel |>
  dplyr::group_by(iso3c, pais_cset, grupo_renda, subamostra_original) |>
  dplyr::summarise(anos = dplyr::n(),
                   anos_conjunto = sum(obs_modelo_conjunto), .groups = "drop")
SalvarTabela(resumo_paises, "painel_cobertura_por_pais")
Registrar("grupos de renda:", paste(names(table(resumo_paises$grupo_renda)),
                                    table(resumo_paises$grupo_renda),
                                    collapse = "; "))

# Codebook ---------------------------------------------------------------------
codebook <- data.frame(
  variavel = c("id", "iso3c", "pais_cset", "ano", "grupo_renda", "regiao_wb",
               "subamostra_original", "publicacoes", "citacoes_ok", "patentes",
               "patentes_concedidas_ok", "patentes_suspeitas", "investimento",
               "investimento_divulgado", "investimento_l1", "investimento_mm3",
               "inv_zero", "gerd", "gerd_l1", "pd_pct_pib",
               "pd_pct_pib_imputado",
               "populacao", "pesquisadores_pm", "pib", "pib_pc", "pib_ppc",
               "artigos_ct", "matricula_terciaria", "internet_pct",
               "banda_larga_p100", "alta_tec_export", "credito_privado",
               "market_cap", "npl", "zscore", "patentes_residentes",
               "patentes_nao_resid", "comercio", "efetividade_governo",
               "controle_corrupcao", "estado_direito", "qualidade_regulatoria",
               "patentes_pm", "publicacoes_pm", "investimento_pib", "inv_piso",
               "pais", "log_pib_pc", "log_comercio", "obs_modelo_conjunto"),
  descricao = c("país-ano", "código ISO3", "nome do país no CSET", "ano",
                "grupo de renda do World Bank (classificação vigente)",
                "região do World Bank", "país presente no dataset original",
                "artigos de IA (campo All), apenas anos completos",
                "citações recebidas por artigos de IA, apenas até 2020",
                paste("famílias de patentes de IA atribuídas ao país de",
                      "prioridade (primeira jurisdição de depósito), pelo ano",
                      "do primeiro depósito; anos completos (<= 2021); Índia",
                      "NA a partir de 2019"),
                paste("famílias de patentes de IA depositadas no ano e",
                      "posteriormente concedidas (não é contagem por ano de",
                      "concessão); anos completos (<= 2019)"),
                "flag: série de patentes suspeita (Índia >= 2019)",
                paste("investimento em ações de empresas privadas de IA",
                      "(VC + private equity + fusões e aquisições; exclui",
                      "dívida, subsídios e empresas listadas), estimado com",
                      "imputação de negócios não divulgados, US$ de 2021"),
                "investimento divulgado, US$ constantes de 2021",
                "investimento no ano anterior",
                "soma do investimento em t, t-1 e t-2",
                "flag: investimento igual a zero (sem negócio registrado)",
                paste("GERD: P&D interno total executado no país (todos os",
                      "setores, inclusive empresas), US$ constantes de 2015"),
                "GERD no ano anterior",
                "P&D % PIB (interpolado quando faltante)",
                "flag: P&D % PIB imputado por interpolação", "população",
                "pesquisadores em P&D por milhão", "PIB constante 2015 US$",
                "PIB per capita constante 2015 US$", "PIB PPC constante",
                "artigos científicos e técnicos (todas as áreas)",
                "matrícula terciária bruta (%)", "usuários de internet (%)",
                "assinaturas de banda larga fixa por 100 hab.",
                "exportações de alta tecnologia (% das manufaturadas)",
                "crédito doméstico ao setor privado (% PIB)",
                "capitalização de mercado (% PIB)",
                "empréstimos inadimplentes (% do total)", "Z-score bancário",
                "pedidos de patente de residentes (todas as áreas)",
                "pedidos de patente de não residentes", "comércio (% PIB)",
                "WGI efetividade governamental (estimativa)",
                "WGI controle da corrupção", "WGI estado de direito",
                "WGI qualidade regulatória",
                "patentes de IA por milhão de hab.",
                "artigos de IA por milhão de hab.", "investimento / PIB",
                "flag: investimento no piso de granularidade (<= 2,5 M US$)",
                "nome do país (igual a pais_cset)", "log do PIB per capita",
                "log do comércio (% PIB)",
                paste("flag: observação usável no modelo conjunto",
                      "(insumos em t-1 > 0, dois produtos)")),
  fonte = c(rep("construída", 2), "CSET", "-", "World Bank", "World Bank",
            "construída", rep("CSET (Zenodo v1.12.0, 15/09/2026)", 5),
            rep("CSET + CPI-EUA (WDI FP.CPI.TOTL)", 2), rep("construída", 3),
            rep("construída (WDI GB.XPD.RSDV.GD.ZS x NY.GDP.MKTP.KD)", 2),
            "WDI GB.XPD.RSDV.GD.ZS", "construída", "WDI SP.POP.TOTL",
            "WDI SP.POP.SCIE.RD.P6", "WDI NY.GDP.MKTP.KD", "WDI NY.GDP.PCAP.KD",
            "WDI NY.GDP.MKTP.PP.KD", "WDI IP.JRN.ARTC.SC", "WDI SE.TER.ENRR",
            "WDI IT.NET.USER.ZS", "WDI IT.NET.BBND.P2", "WDI TX.VAL.TECH.MF.ZS",
            "WDI FS.AST.PRVT.GD.ZS", "WDI CM.MKT.LCAP.GD.ZS",
            "WDI FB.AST.NPER.ZS",
            "GFDD GFDD.SI.01", "WDI IP.PAT.RESD", "WDI IP.PAT.NRES",
            "WDI NE.TRD.GNFS.ZS", "WGI GOV_WGI_GE.EST", "WGI GOV_WGI_CC.EST",
            "WGI GOV_WGI_RL.EST", "WGI GOV_WGI_RQ.EST", rep("construída", 8)),
  stringsAsFactors = FALSE)
extras <- data.frame(
  variavel = c("talento_ia_media_genero_pct", "talento_ia_fem_pct",
               "talento_ia_masc_pct",
               "contratacao_ia_rel_pct", "meses_contratacao",
               "migracao_talento_10k", "vagas_ia_pct",
               "investimento_quid_acum_bi", "empresas_quid_acum",
               "penetracao_habilidades_ia", "talento_ia_2024_pct",
               "patentes_inventor", "patentes_triadicas",
               "patentes_inventor_pm", "investimento_preqin",
               "investimento_preqin_l1", "herd_pct_pib", "goverd_pct_pib",
               "pd_publico_pct_pib", "pd_publico_pct_pib_imputado",
               "pd_publico", "pd_publico_l1"),
  descricao = c(paste("média NÃO ponderada das taxas de concentração de",
                      "talento em IA de mulheres e homens (% dos membros do",
                      "LinkedIn); não é a concentração total do país"),
                "concentração de talento em IA, mulheres (%)",
                "concentração de talento em IA, homens (%)",
                paste("taxa relativa de contratação em IA, variação anual",
                      "(%), média dos meses"),
                "número de meses na média da contratação",
                "migração líquida de talento em IA por 10 mil membros",
                "vagas em IA (% de todas as vagas), Lightcast",
                "investimento privado em IA acumulado 2013-24, bi US$ (Quid)",
                "empresas de IA recém-financiadas acumuladas 2013-24 (Quid)",
                "penetração relativa de habilidades em IA 2015-24 (LinkedIn)",
                "concentração de talento em IA em 2024 (%)",
                paste("famílias de patentes de IA (IP5) por país de residência",
                      "do inventor, contagem fracionária, data de prioridade;",
                      "último ano da fonte excluído por defasagem"),
                "famílias triádicas de patentes de IA por país do inventor",
                "famílias IP5 de IA por milhão de habitantes",
                paste("VC em IA por país (Preqin via OECD.AI), US$ constantes",
                      "de 2021; apenas estágio VC, todas as indústrias;",
                      "universo de transações mais estreito que o do CSET"),
                "VC Preqin no ano anterior",
                "HERD: P&D executado pelo ensino superior (% PIB)",
                "GOVERD: P&D executado pelo governo (% PIB)",
                paste("P&D executado pelo ensino superior e pelo governo",
                      "(HERD + GOVERD, % PIB), interpolado por país; setor de",
                      "execução, não fonte de financiamento"),
                "flag: P&D público imputado por interpolação",
                paste("P&D executado por ensino superior e governo em US$",
                      "constantes de 2015 (% PIB x PIB)"),
                "P&D de ensino superior e governo no ano anterior"),
  fonte = c(rep("AI Index 2025 (LinkedIn), fig. 4.2.19", 3),
            rep("AI Index 2025 (LinkedIn), fig. 4.2.14", 2),
            "AI Index 2025 (LinkedIn), fig. 4.2.23",
            "AI Index 2025 (Lightcast), figs. 4.2.1-4.2.2",
            "AI Index 2025 (Quid), fig. 4.3.9",
            "AI Index 2025 (Quid), fig. 4.3.13",
            "AI Index 2025 (LinkedIn), fig. 4.2.15",
            "AI Index 2025 (LinkedIn), fig. 4.2.17",
            rep(paste("OECD Data Explorer,",
                      "DSD_PATENTS@DF_PATENTS_OECDSPECIFIC, tecnologia AI"),
                2),
            "construída",
            "OECD.AI (Preqin), gráfico VC investments in AI by country",
            "construída",
            rep("OECD MSTI (DSD_MSTI@DF_MSTI), medidas H e GV", 2),
            rep("construída (MSTI)", 4)),
  stringsAsFactors = FALSE)
codebook <- rbind(codebook, extras[extras$variavel %in% names(painel), ])
stopifnot(all(codebook$variavel %in% names(painel)))
titulo <- "# Codebook do painel reconstruído (`data/processed/painel_ia.csv`)"
linhas <- c(titulo, "",
            paste0("Gerado por `R/13_build_painel.R` em ", format(Sys.Date()),
                   ". Janela 2016-2024; ", length(unique(painel$iso3c)),
                   " países; critério de inclusão: >= 100 artigos de IA",
                   " em 2016, ",
                   ">= 3 anos de patentes, >= 6 anos de investimento, PIB e ",
                   "população em todos os anos, >= 3 anos de P&D % PIB."), "",
            "| Variável | Descrição | Fonte |", "|---|---|---|",
            sprintf("| `%s` | %s | %s |", codebook$variavel, codebook$descricao,
                    codebook$fonte))
writeLines(linhas, "artigo/03_codebook.md")
Registrar("codebook gravado em artigo/03_codebook.md")
