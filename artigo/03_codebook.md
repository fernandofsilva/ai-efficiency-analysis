# Codebook do painel reconstruído (`data/processed/painel_ia.csv`)

Gerado por `R/13_build_painel.R` em 2026-09-27. Janela 2016-2024; 47 países; critério de inclusão: >= 100 artigos de IA em 2016, >= 3 anos de patentes, >= 6 anos de investimento, PIB e população em todos os anos, >= 3 anos de P&D % PIB.

| Variável | Descrição | Fonte |
|---|---|---|
| `id` | país-ano | construída |
| `iso3c` | código ISO3 | construída |
| `pais_cset` | nome do país no CSET | CSET |
| `ano` | ano | - |
| `grupo_renda` | grupo de renda do World Bank (classificação vigente) | World Bank |
| `regiao_wb` | região do World Bank | World Bank |
| `subamostra_original` | país presente no dataset original | construída |
| `publicacoes` | artigos de IA (campo All), apenas anos completos | CSET (Zenodo v1.12.0, 15/09/2026) |
| `citacoes_ok` | citações recebidas por artigos de IA, apenas até 2020 | CSET (Zenodo v1.12.0, 15/09/2026) |
| `patentes` | famílias de patentes de IA atribuídas ao país de prioridade (primeira jurisdição de depósito), pelo ano do primeiro depósito; anos completos (<= 2021); Índia NA a partir de 2019 | CSET (Zenodo v1.12.0, 15/09/2026) |
| `patentes_concedidas_ok` | famílias de patentes de IA depositadas no ano e posteriormente concedidas (não é contagem por ano de concessão); anos completos (<= 2019) | CSET (Zenodo v1.12.0, 15/09/2026) |
| `patentes_suspeitas` | flag: série de patentes suspeita (Índia >= 2019) | CSET (Zenodo v1.12.0, 15/09/2026) |
| `investimento` | investimento em ações de empresas privadas de IA (VC + private equity + fusões e aquisições; exclui dívida, subsídios e empresas listadas), estimado com imputação de negócios não divulgados, US$ de 2021 | CSET + CPI-EUA (WDI FP.CPI.TOTL) |
| `investimento_divulgado` | investimento divulgado, US$ constantes de 2021 | CSET + CPI-EUA (WDI FP.CPI.TOTL) |
| `investimento_l1` | investimento no ano anterior | construída |
| `investimento_mm3` | soma do investimento em t, t-1 e t-2 | construída |
| `inv_zero` | flag: investimento igual a zero (sem negócio registrado) | construída |
| `gerd` | GERD: P&D interno total executado no país (todos os setores, inclusive empresas), US$ constantes de 2015 | construída (WDI GB.XPD.RSDV.GD.ZS x NY.GDP.MKTP.KD) |
| `gerd_l1` | GERD no ano anterior | construída (WDI GB.XPD.RSDV.GD.ZS x NY.GDP.MKTP.KD) |
| `pd_pct_pib` | P&D % PIB (interpolado quando faltante) | WDI GB.XPD.RSDV.GD.ZS |
| `pd_pct_pib_imputado` | flag: P&D % PIB imputado por interpolação | construída |
| `populacao` | população | WDI SP.POP.TOTL |
| `pesquisadores_pm` | pesquisadores em P&D por milhão | WDI SP.POP.SCIE.RD.P6 |
| `pib` | PIB constante 2015 US$ | WDI NY.GDP.MKTP.KD |
| `pib_pc` | PIB per capita constante 2015 US$ | WDI NY.GDP.PCAP.KD |
| `pib_ppc` | PIB PPC constante | WDI NY.GDP.MKTP.PP.KD |
| `artigos_ct` | artigos científicos e técnicos (todas as áreas) | WDI IP.JRN.ARTC.SC |
| `matricula_terciaria` | matrícula terciária bruta (%) | WDI SE.TER.ENRR |
| `internet_pct` | usuários de internet (%) | WDI IT.NET.USER.ZS |
| `banda_larga_p100` | assinaturas de banda larga fixa por 100 hab. | WDI IT.NET.BBND.P2 |
| `alta_tec_export` | exportações de alta tecnologia (% das manufaturadas) | WDI TX.VAL.TECH.MF.ZS |
| `credito_privado` | crédito doméstico ao setor privado (% PIB) | WDI FS.AST.PRVT.GD.ZS |
| `market_cap` | capitalização de mercado (% PIB) | WDI CM.MKT.LCAP.GD.ZS |
| `npl` | empréstimos inadimplentes (% do total) | WDI FB.AST.NPER.ZS |
| `zscore` | Z-score bancário | GFDD GFDD.SI.01 |
| `patentes_residentes` | pedidos de patente de residentes (todas as áreas) | WDI IP.PAT.RESD |
| `patentes_nao_resid` | pedidos de patente de não residentes | WDI IP.PAT.NRES |
| `comercio` | comércio (% PIB) | WDI NE.TRD.GNFS.ZS |
| `efetividade_governo` | WGI efetividade governamental (estimativa) | WGI GOV_WGI_GE.EST |
| `controle_corrupcao` | WGI controle da corrupção | WGI GOV_WGI_CC.EST |
| `estado_direito` | WGI estado de direito | WGI GOV_WGI_RL.EST |
| `qualidade_regulatoria` | WGI qualidade regulatória | WGI GOV_WGI_RQ.EST |
| `patentes_pm` | patentes de IA por milhão de hab. | construída |
| `publicacoes_pm` | artigos de IA por milhão de hab. | construída |
| `investimento_pib` | investimento / PIB | construída |
| `inv_piso` | flag: investimento no piso de granularidade (<= 2,5 M US$) | construída |
| `pais` | nome do país (igual a pais_cset) | construída |
| `log_pib_pc` | log do PIB per capita | construída |
| `log_comercio` | log do comércio (% PIB) | construída |
| `obs_modelo_conjunto` | flag: observação usável no modelo conjunto (insumos em t-1 > 0, dois produtos) | construída |
| `talento_ia_media_genero_pct` | média NÃO ponderada das taxas de concentração de talento em IA de mulheres e homens (% dos membros do LinkedIn); não é a concentração total do país | AI Index 2025 (LinkedIn), fig. 4.2.19 |
| `talento_ia_fem_pct` | concentração de talento em IA, mulheres (%) | AI Index 2025 (LinkedIn), fig. 4.2.19 |
| `talento_ia_masc_pct` | concentração de talento em IA, homens (%) | AI Index 2025 (LinkedIn), fig. 4.2.19 |
| `contratacao_ia_rel_pct` | taxa relativa de contratação em IA, variação anual (%), média dos meses | AI Index 2025 (LinkedIn), fig. 4.2.14 |
| `meses_contratacao` | número de meses na média da contratação | AI Index 2025 (LinkedIn), fig. 4.2.14 |
| `migracao_talento_10k` | migração líquida de talento em IA por 10 mil membros | AI Index 2025 (LinkedIn), fig. 4.2.23 |
| `vagas_ia_pct` | vagas em IA (% de todas as vagas), Lightcast | AI Index 2025 (Lightcast), figs. 4.2.1-4.2.2 |
| `investimento_quid_acum_bi` | investimento privado em IA acumulado 2013-24, bi US$ (Quid) | AI Index 2025 (Quid), fig. 4.3.9 |
| `empresas_quid_acum` | empresas de IA recém-financiadas acumuladas 2013-24 (Quid) | AI Index 2025 (Quid), fig. 4.3.13 |
| `penetracao_habilidades_ia` | penetração relativa de habilidades em IA 2015-24 (LinkedIn) | AI Index 2025 (LinkedIn), fig. 4.2.15 |
| `talento_ia_2024_pct` | concentração de talento em IA em 2024 (%) | AI Index 2025 (LinkedIn), fig. 4.2.17 |
| `patentes_inventor` | famílias de patentes de IA (IP5) por país de residência do inventor, contagem fracionária, data de prioridade; último ano da fonte excluído por defasagem | OECD Data Explorer, DSD_PATENTS@DF_PATENTS_OECDSPECIFIC, tecnologia AI |
| `patentes_triadicas` | famílias triádicas de patentes de IA por país do inventor | OECD Data Explorer, DSD_PATENTS@DF_PATENTS_OECDSPECIFIC, tecnologia AI |
| `patentes_inventor_pm` | famílias IP5 de IA por milhão de habitantes | construída |
| `investimento_preqin` | VC em IA por país (Preqin via OECD.AI), US$ constantes de 2021; apenas estágio VC, todas as indústrias — universo de transações mais estreito que o do CSET | OECD.AI (Preqin), gráfico VC investments in AI by country |
| `investimento_preqin_l1` | VC Preqin no ano anterior | construída |
| `herd_pct_pib` | HERD: P&D executado pelo ensino superior (% PIB) | OECD MSTI (DSD_MSTI@DF_MSTI), medidas H e GV |
| `goverd_pct_pib` | GOVERD: P&D executado pelo governo (% PIB) | OECD MSTI (DSD_MSTI@DF_MSTI), medidas H e GV |
| `pd_publico_pct_pib` | P&D executado pelo ensino superior e pelo governo (HERD + GOVERD, % PIB), interpolado por país; setor de execução, não fonte de financiamento | construída (MSTI) |
| `pd_publico_pct_pib_imputado` | flag: P&D público imputado por interpolação | construída (MSTI) |
| `pd_publico` | P&D executado por ensino superior e governo em US$ constantes de 2015 (% PIB x PIB) | construída (MSTI) |
| `pd_publico_l1` | P&D de ensino superior e governo no ano anterior | construída (MSTI) |
