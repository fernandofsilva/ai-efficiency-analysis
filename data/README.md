# Inventário de dados (`data/`)

Regra do projeto: todas as bases usadas — brutas e processadas — ficam nesta pasta, uma subpasta por fonte. Datas em formato AAAA-MM-DD.

## `AI_INVESTMENT.csv` — dataset original da disciplina

- 208 observações país-ano, 37 países, 2013–2021 (painel desbalanceado), 33 colunas.
- Proveniência verificada em 2026-09-27: indicadores de IA do CSET Country Activity Tracker via Our World in Data (`AI.Investment` em US$ constantes de 2021 deflacionados pelo CPI dos EUA; `AI.Publications` em contagem; `AI.Patent.Applications` em pedidos **por milhão de habitantes**); variáveis de contexto do World Bank (WDI, WGI, GFDD).
- Usado na Fase A (apresentação). Preparado por `R/01_prep_dataset_atual.R` → `processed/base_atual.csv`.

## `cat/` — CSET/ETO Country AI Activity Metrics (pronto)

- Fonte: Emerging Technology Observatory, CSET (Georgetown). Zenodo, registro 22772306 (v1.12.0, publicado 2026-09-15; DOI conceito 10.5281/zenodo.13984221). Licença CC BY-NC 4.0. Download manual em 2026-09-27 (o Zenodo bloqueia scripts).
- Documentação: https://eto.tech/dataset-docs/country-ai-activity-metrics/
- Arquivos (usar `field == "All"`; os `*_summary.csv` são totais acumulados e não são usados):
  - `publications_yearly_articles.csv` — artigos de IA por país e ano, 204 países, 2016–2026, coluna `complete` (completo até 2024).
  - `publications_yearly_citations.csv` — citações recebidas; sem flag de completude (viés de janela nos anos recentes; usamos até 2020).
  - `patents_yearly_applications.csv` — pedidos de patente de IA por escritório de depósito, 70 países; completo até 2021.
  - `patents_yearly_granted.csv` — patentes concedidas, 65 países; completo até 2019.
  - `companies_yearly_estimated.csv` — investimento estimado em empresas privadas de IA, **milhões de US$ nominais**, 124 países; completo até 2025.
  - `companies_yearly_disclosed.csv` — investimento divulgado, milhões de US$ nominais.
  - `companies_summary.csv`, `patents_summary.csv`, `publications_summary.csv` — totais acumulados (não usados).
- Importado por `R/11_import_cset.R` → `processed/cset_long.csv`.

## `wdi/` — World Bank WDI e GFDD (API v2)

- Baixado por `R/10_download_wdi.R` em 2026-09-27, todos os países, 2010–2024, um CSV por indicador (`<código>.csv` com `iso3c, pais, ano, valor, codigo`). Licença CC BY 4.0.
- Indicadores: `SP.POP.TOTL` (população), `SP.POP.SCIE.RD.P6` (pesquisadores por milhão), `GB.XPD.RSDV.GD.ZS` (P&D % PIB), `NY.GDP.MKTP.KD` (PIB constante 2015), `NY.GDP.PCAP.KD` (PIB per capita), `NY.GDP.MKTP.PP.KD` (PIB PPC), `PA.NUS.PPP` (fator PPC), `IP.JRN.ARTC.SC` (artigos C&T), `SE.TER.ENRR` (matrícula terciária), `IT.NET.USER.ZS` (internet), `IT.NET.BBND.P2` (banda larga), `TX.VAL.TECH.MF.ZS` (exportações de alta tecnologia), `FS.AST.PRVT.GD.ZS` (crédito privado), `CM.MKT.LCAP.GD.ZS` (capitalização de mercado), `FB.AST.NPER.ZS` (NPL), `GFDD.SI.01` (Z-score), `IP.PAT.RESD` e `IP.PAT.NRES` (patentes), `NE.TRD.GNFS.ZS` (comércio), `FP.CPI.TOTL` (CPI; a série dos EUA deflaciona o investimento do CSET).
- `paises_world_bank.csv` — lista de economias com região e grupo de renda vigentes (endpoint `/v2/country`).

## `wgi/` — Worldwide Governance Indicators

- `GOV_WGI_GE.EST.csv`, `GOV_WGI_CC.EST.csv`, `GOV_WGI_RL.EST.csv`, `GOV_WGI_RQ.EST.csv` — estimativas de efetividade governamental, controle da corrupção, estado de direito e qualidade regulatória (API v2, fonte 3, códigos novos), 2010–2024.
- `wgidataset.xlsx` — arquivo oficial completo (https://www.worldbank.org/content/dam/sites/govindicators/doc/wgidataset.xlsx), fallback.

## `msti/` — OECD Main Science and Technology Indicators (pronto)

- `msti_pd_setor_pct_pib.csv` — HERD, GOVERD e GERD em % do PIB por economia e ano (2010–2022, 45 economias), baixado por `R/15_download_msti.R` da API SDMX (`OECD.STI.STP,DSD_MSTI@DF_MSTI`); `pd_publico_pct_pib = herd + goverd`. Complementado pelo Eurostat (`eurostat_gerd_setor.csv`, `rd_e_gerdtot`, setores HES e GOV) para Bulgária, Croácia e Sérvia. Cobre 41 dos 47 países do painel; sem fonte pública por setor: BRA, IND, MYS, PHL, SAU, UKR (o UIS não publica mais a abertura por setor).

## `top500/` — TOP500 (parcial)

- `TOP500_AAAAMM.xlsx` por lista semestral, baixadas por `R/16_download_top500.R` (sem login; o site limita a taxa: em 27/09 só `TOP500_202111.xlsx` foi obtida). `top500_pais_ano.csv` agrega sistemas e Rmax por país e ano das listas disponíveis.

## `processed/` — bases montadas pelos scripts

- `base_atual.csv` — dataset original preparado (`R/01`): grupos de renda harmonizados, patentes em contagem, GERD em US$, flags `inv_zero` e `inv_piso`.
- `ai_index_pais_ano.csv`, `ai_index_transversal.csv`, `oecd_ai_publicacoes.csv` — fontes alternativas processadas (`R/12`).
- `cset_long.csv` — CSET por país-ano (`R/11`): flags de completude aplicadas, ISO3, investimento deflacionado para US$ 2021, Índia sem patentes a partir de 2019.
- `painel_ia.csv` — painel reconstruído 2016–2024 (`R/13`), 47 países, com as variáveis de talento do AI Index juntadas; codebook em `artigo/03_codebook.md`; cobertura em `output/tables/painel_cobertura_por_ano.csv` e `painel_elegibilidade.csv`.

## `ai_index/` — Stanford AI Index 2025, dados públicos (pronto)

- Fonte: Stanford HAI, AI Index Report 2025, pasta "Public Data" (Google Drive, link "Access the Public Data" em https://hai.stanford.edu/ai-index/2025-ai-index-report). Download manual em 2026-09-27. Estrutura: uma pasta por capítulo (`1. Research and Development` … `8. Public Opinion`), cada uma com `Charts/` (PDF) e `Data/fig_x.y.z.csv` (317 arquivos de dados; CSV com BOM UTF-8).
- Arquivos usados por `R/12_import_fontes_alternativas.R`:
  - `4. Economy/Data/fig_4.2.19.csv` — concentração de talento em IA por país, ano (2016–2024) e gênero (LinkedIn), 43 países; a série usada no painel (`talento_ia_media_genero_pct`) é a média NÃO ponderada das taxas feminina e masculina, que não equivale à concentração total (ver `fig_4.2.17.csv`, total de 2024).
  - `fig_4.2.14.csv` — taxa relativa de contratação em IA, mensal 2018–2024, 47 países (agregada por média anual).
  - `fig_4.2.23.csv` — migração líquida de talento em IA por 10 mil membros, 2019–2024, 48 países.
  - `fig_4.2.1.csv` e `fig_4.2.2.csv` — vagas em IA (% de todas as vagas), 2014–2024, 21 países (Lightcast).
  - `fig_4.3.9.csv` e `fig_4.3.13.csv` — investimento privado e empresas recém-financiadas acumulados 2013–24 por país (91 países, Quid); `fig_4.2.15.csv` (penetração de habilidades) e `fig_4.2.17.csv` (talento 2024).
- Limitação importante: o investimento privado **por país e ano** (`fig_4.3.10`) cobre só China, Europa e Estados Unidos; por isso o Quid entra apenas como checagem transversal do CSET, não como insumo alternativo no painel.
- Saídas: `processed/ai_index_pais_ano.csv`, `processed/ai_index_transversal.csv`.

## `oecd-ai/` — OECD.AI e OECD Data Explorer

- `data.csv` + `metadata.txt` — exportação manual do OECD.AI (2026-09-27): parcela mundial de publicações de IA (%, OpenAlex) para 9 economias (CAN, CHN, DEU, FRA, GBR, IND, JPN, KOR, USA) e o agregado EU27, 2000–2026. Usada como checagem das parcelas do CSET (`R/12`).
- `patentes_ia_ip5_inventor.csv` e `patentes_ia_triadicas_inventor.csv` — baixados por script (`R/14_download_oecd_patentes.R`) da API SDMX do OECD Data Explorer (dataflow `OECD.STI.PIE,DSD_PATENTS@DF_PATENTS_OECDSPECIFIC`, tecnologia `AI`, unidade famílias, data de prioridade, papel `INVENTOR`): famílias de patentes relacionadas a IA por país de residência do inventor, contagem fracionária, 104 países, 2010–2022 (o último ano é incompleto por defasagem e é excluído do painel). Licença OCDE (uso livre com citação). Chave SDMX: `9P50_3.A.PF.PATN_FM.PRIORITY.._Z.INVENTOR._Z._Z.AI` (IP5) e `9P50_2...` (triádicas).
- `vc_investimentos_pais_ano.csv` + `vc_metadata.txt` — exportação manual (2026-09-27) do gráfico "VC investments in AI by country" em https://oecd.ai/en/data?selectedArea=investments-in-ai-and-data (Preqin, licenciado; sem API). Colunas `Country` (ISO3 e agregados EU27/GPAI/OECD), `Country_label`, `INDUSTRY` (todas), `STAGE` (**apenas VC**: universo mais estreito que o do CSET, que inclui private equity e fusões), `Sum_of_deals` (milhões de US$ nominais), `Year` (2012–2026). 114 países. Harmonizado por `R/12` para US$ de 2021. Metadados do export em `vc_metadata.txt` (descrição genérica da Preqin; filtros registrados aqui).
- Observação: o `metadata.txt` do export de publicações foi sobrescrito por engano pelo texto da Preqin e restaurado com a descrição original (OpenAlex) em 2026-09-27.
- Saídas: `processed/oecd_ai_publicacoes.csv`, `processed/oecd_ai_patentes.csv`, `processed/oecd_ai_vc.csv`.
