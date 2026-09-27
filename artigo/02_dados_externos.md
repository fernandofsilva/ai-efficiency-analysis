# Dados externos: catálogo, proveniência e instruções

Regra do projeto: **todas as bases usadas ficam dentro de `data/`**, ao lado de `data/AI_INVESTMENT.csv`, uma subpasta por fonte (`data/cat/`, `data/wdi/`, `data/wgi/`, `data/ai_index/`, `data/oecd_ai/`) e as bases montadas em `data/processed/`. O inventário fica em `data/README.md`.

## 1. Proveniência do dataset original (`data/AI_INVESTMENT.csv`)

Verificação feita em 27/09/2026 comparando valores com as fontes:

| Variável | Origem | Unidade | Evidência |
|---|---|---|---|
| `AI.Investment` | CSET Country Activity Tracker, série "estimated funding raised by privately held AI companies", via Our World in Data | US$ constantes de 2021 (CPI-EUA) | Argentina 2018 = 1.079.101 no dataset e 1.079.102 no OWID; todos os valores são múltiplos de 1 milhão × (CPI 2021 / CPI do ano) |
| `AI.Publications` | CSET (artigos de IA, campo "All"), via OWID | contagem | Luxemburgo 2021 = 248 em ambos |
| `AI.Patent.Applications` | CSET (pedidos de patente de IA por escritório de depósito) | **por milhão de habitantes** | valor × população dá inteiros: Argentina 2013 ≈ 1, Colômbia 2015 = 2, Luxemburgo 2021 ≈ 38 |
| Variáveis de contexto | World Bank WDI, WGI e GFDD | diversas | códigos listados na seção 3 |

Consequências: (i) patentes precisam voltar a contagem com a população; (ii) os zeros de investimento estão na fonte ("sem negócio registrado") e não podem entrar em DEA com retornos constantes; (iii) a granularidade de 1 milhão de dólares cria observações "hiperprodutivas" artificiais.

## 2. CSET / ETO Country AI Activity Metrics — `data/cat/` (pronto)

- **Origem:** Emerging Technology Observatory (CSET, Georgetown). Zenodo, DOI conceito 10.5281/zenodo.13984221; versão baixada v1.12.0 (15/09/2026), registro https://zenodo.org/records/22772306. Licença CC BY-NC 4.0. Documentação: https://eto.tech/dataset-docs/country-ai-activity-metrics/
- **Arquivos usados** (filtrar `field == "All"`; ignorar os `*_summary.csv`, que são totais acumulados):
  - `publications_yearly_articles.csv` — artigos de IA por país e ano (204 países), coluna `complete`.
  - `publications_yearly_citations.csv` — citações recebidas (sem flag de completude; forte viés de janela nos anos recentes).
  - `patents_yearly_applications.csv` — **famílias** de patentes de IA atribuídas ao **país de prioridade** (primeira jurisdição em que o inventor depositou), pelo ano do primeiro depósito (70 países), coluna `complete`.
  - `patents_yearly_granted.csv` — famílias depositadas no ano e **posteriormente concedidas** em qualquer jurisdição (não é contagem por ano de concessão), 65 países, coluna `complete`.
  - `companies_yearly_estimated.csv` — investimento em ações de empresas fechadas de IA (**VC + private equity + fusões e aquisições**; exclui dívida, subsídios, crowdfunding e empresas listadas), com imputação de negócios não divulgados pela mediana por estágio, país e ano; **milhões de US$ nominais**.
  - `companies_yearly_disclosed.csv` — investimento divulgado, milhões de US$ nominais.
- **Cobertura:** 2016–2026. Anos completos: artigos até 2024; pedidos de patente até 2021; concedidas até 2019; investimento até 2025.
- **Uso:** painel reconstruído 2016–2024 (modelo conjunto 2017–2021 com insumos defasados); variante de "produtos alternativos" (citações totais até 2020; famílias posteriormente concedidas até 2019), que não isola qualidade de volume e maturação; investimento deflacionado para US$ de 2021 com o CPI dos EUA, para manter comparabilidade com o dataset original.
- **Caveats a declarar no artigo:** patentes atribuídas ao escritório de depósito e não ao país do inventor (cerca de metade dos depósitos nos EUA vem do exterior); omite publicações apenas em chinês; cobertura do Crunchbase é menor para empresas de baixo perfil; defasagem de 18 meses na publicação de pedidos de patente; série de patentes da Índia quebrada a partir de 2019 (270 pedidos em 2018 contra 12 em 2019).

## 3. World Bank — `data/wdi/` e `data/wgi/` (script `R/10_download_wdi.R`)

Baixado pela API v2 com cache em CSV (um arquivo por indicador, 2010–2024, todos os países). Códigos validados em 27/09/2026:

| Nome no projeto | Código | Uso |
|---|---|---|
| população | `SP.POP.TOTL` | converter patentes por milhão em contagem; per capita |
| pesquisadores por milhão | `SP.POP.SCIE.RD.P6` | insumo de P&D público alternativo / contexto (lacunas: Brasil, Índia, Suíça) |
| P&D % PIB | `GB.XPD.RSDV.GD.ZS` | GERD em US$ = P&D % PIB × PIB constante |
| PIB constante 2015 | `NY.GDP.MKTP.KD` | escala, GERD |
| PIB per capita constante | `NY.GDP.PCAP.KD` | H7 |
| PIB PPC constante | `NY.GDP.MKTP.PP.KD` | normalização alternativa |
| fator de conversão PPC | `PA.NUS.PPP` | robustez de unidades |
| artigos científicos totais | `IP.JRN.ARTC.SC` | denominador de especialização em IA |
| matrícula terciária | `SE.TER.ENRR` | capital humano |
| usuários de internet | `IT.NET.USER.ZS` | infraestrutura digital |
| banda larga fixa por 100 | `IT.NET.BBND.P2` | infraestrutura digital |
| exportações de alta tecnologia % | `TX.VAL.TECH.MF.ZS` | capacidade de absorção (H5) |
| crédito ao setor privado % PIB | `FS.AST.PRVT.GD.ZS` | H6 |
| capitalização de mercado % PIB | `CM.MKT.LCAP.GD.ZS` | H6 |
| empréstimos inadimplentes % | `FB.AST.NPER.ZS` | fragilidade bancária (H6) |
| Z-score bancário | `GFDD.SI.01` | fragilidade bancária (até 2021) |
| patentes residentes / não residentes | `IP.PAT.RESD`, `IP.PAT.NRES` | contexto (até 2021) |
| comércio % PIB | `NE.TRD.GNFS.ZS` | abertura |
| CPI | `FP.CPI.TOTL` | deflacionar investimento CSET (série dos EUA) |
| WGI efetividade governamental, controle da corrupção, estado de direito, qualidade regulatória | `GOV_WGI_GE.EST`, `GOV_WGI_CC.EST`, `GOV_WGI_RL.EST`, `GOV_WGI_RQ.EST` (fonte 3) | H5 |

Observações: a API mudou os códigos do WGI (os antigos `GE.EST`/`CC.EST` não respondem mais); o arquivo oficial `wgidataset.xlsx` (https://www.worldbank.org/content/dam/sites/govindicators/doc/wgidataset.xlsx) é o fallback e também é salvo em `data/wgi/`. A API é lenta e ocasionalmente dá timeout; por isso o script tenta três vezes e mantém cache. Taiwan não existe no World Bank: fica fora do painel a menos que se use o FMI WEO para PIB e população.

## 4. Our World in Data (espelhos do CSET) — checagem por script

Endpoints CSV, sem autenticação: `https://ourworldindata.org/grapher/<slug>.csv?v=1&csvType=full&useColumnShortNames=true`

- `annual-scholarly-publications-on-artificial-intelligence` (2016–2024, 204 entidades)
- `scholarly-publications-on-artificial-intelligence-per-million-people`
- `private-investment-in-artificial-intelligence-cset` (2016–2025, 125 entidades, US$ constantes 2021)
- `private-investment-in-artificial-intelligence` (série do AI Index / Quid; só EUA, China, Reino Unido e UE)

Uso: verificação cruzada e reprodutibilidade da deflação. Não substitui o Zenodo (não traz citações nem patentes; começa em 2016).

## 5. Fontes de alta prioridade para robustez entre fornecedores (download manual)

| Fonte | O que traz | Onde salvar | Como obter |
|---|---|---|---|
| Stanford AI Index 2025/2026 (dados públicos) | investimento privado por país (Quid, fornecedor independente do Crunchbase), empresas de IA recém-financiadas, patentes concedidas por 100 mil hab., concentração de talento (LinkedIn), vagas em IA (Lightcast) | `data/ai_index/` | link "Access the Public Data" em https://hai.stanford.edu/ai-index/2025-ai-index-report (pasta Google Drive https://drive.google.com/drive/folders/1AxxxL9-AsaeMdDKtTNHCR1KqEJTsHCod) |
| OECD.AI | publicações de IA (OpenAlex), patentes de IA por **país do inventor** (famílias IP5, STI Micro-data Lab), VC em IA (Preqin, 2012–2025) | `data/oecd_ai/` | exportação por gráfico em https://oecd.ai/en/data ; relatório "Venture capital investments in AI through 2025" (OCDE, fev/2026) com StatLinks |

Uso: R1/R3 (refazer fronteiras com insumo e produto de fornecedor alternativo) e correção da atribuição de patentes (inventor versus escritório).

Status em 27/09/2026 (downloads feitos, ver `data/README.md`): o AI Index não publica investimento privado por país e ano (só China, Europa e Estados Unidos), de modo que o Quid entra como checagem transversal do investimento acumulado do CSET (91 países) e como fonte das variáveis de talento (concentração 2016–2024 em 43 países, contratação, migração, vagas), usadas como contexto no segundo estágio. A exportação do OECD.AI contém apenas a parcela mundial de publicações para nove economias (2000–2026), usada como checagem das parcelas do CSET; patentes por país do inventor e VC (Preqin) ainda não foram exportados.

## 5a. Como obter patentes por país do inventor e VC do OECD.AI

**Patentes de IA por país do inventor: por script, sem exportação manual.** O OECD Data Explorer expõe o dataflow `DSD_PATENTS@DF_PATENTS_OECDSPECIFIC` (agência `OECD.STI.PIE`) com o domínio tecnológico `AI` ("Technologies related to artificial intelligence", método OECD de CPC + palavras-chave), medida "famílias de patentes", data de prioridade, papel do agente "inventor" e contagem fracionária por país de residência do inventor. O script `R/14_download_oecd_patentes.R` chama a API SDMX pública:

```
https://sdmx.oecd.org/public/rest/data/OECD.STI.PIE,DSD_PATENTS@DF_PATENTS_OECDSPECIFIC,1.0/
  9P50_3.A.PF.PATN_FM.PRIORITY.._Z.INVENTOR._Z._Z.AI
  ?startPeriod=2010&dimensionAtObservation=AllDimensions&format=csvfilewithlabels
```

As 11 posições da chave são: autoridade (`9P50_3` = famílias IP5; `9P50_2` = triádicas), frequência anual, medida `PF`, unidade `PATN_FM`, tipo de data `PRIORITY`, país (vazio = todos), país parceiro `_Z`, papel `INVENTOR`, cooperação `_Z`, domínio WIPO `_Z`, tecnologia `AI`. O resultado cobre 104 países em 2010–2022 (2022 incompleto pela defasagem de 18 meses entre prioridade e publicação; o painel usa até 2021). Caveats: contagem fracionária (uma família com inventores em dois países conta 0,5 para cada), famílias IP5 exigem depósito em pelo menos dois dos cinco grandes escritórios (subestima países com patenteamento só doméstico, como Índia e Brasil), e a identificação de IA segue a taxonomia OCDE, diferente do classificador do CSET. Para verificar a estrutura do dataflow: `https://sdmx.oecd.org/public/rest/dataflow/OECD.STI.PIE/DSD_PATENTS@DF_PATENTS_OECDSPECIFIC/1.0?references=all`. Alternativa manual equivalente: em https://oecd.ai/en/data?selectedArea=ai-patents, gráficos "Evolution of AI-related patents by country" e "Intensity of AI-related patents by country" (mesma fonte, botão de download).

**VC em IA (Preqin): só por exportação manual.** Os dados de capital de risco do OECD.AI vêm da Preqin sob licença e não estão no Data Explorer nem na API. Procedimento:

1. Abrir https://oecd.ai/en/data?selectedArea=investments-in-ai-and-data e localizar, no bloco "Investments in AI start-ups", o gráfico **"VC investments in AI by country"** (valores anuais em US$ por país; há também "Share of total venture capital investment in AI by country" e "Worldwide VC investments in AI").
2. Nos filtros do gráfico, selecionar todos os países (ou pelo menos os 47 do painel), todos os anos (2012 até o último disponível) e a métrica em valor (US$ milhões), não em participação.
3. Clicar no ícone de download no canto do gráfico (o mesmo usado para exportar as publicações): o site entrega um `.zip` com `data.csv` e `metadata.txt`.
4. Salvar o CSV como `data/oecd-ai/vc_investimentos_pais_ano.csv` (e o `metadata.txt` como `vc_metadata.txt`). O script `R/12` detecta o arquivo, registra as colunas e copia para `data/processed/oecd_ai_vc_bruto.csv`; a harmonização final (ISO3, deflação para US$ de 2021 com o CPI dos EUA, junção ao painel como `investimento_preqin`) é feita depois de conferir os nomes das colunas.
5. Se quiser também o número de negócios, repetir com o gráfico de contagem de transações, quando disponível.

Uso no artigo: `investimento_preqin_l1` como insumo alternativo ao CSET (dimensão "fonte" da matriz de robustez) e checagem cruzada por país-ano com o investimento estimado do CSET, como já feito para o acumulado do Quid.

Status em 27/09/2026 (15h30): exportação feita (`data/oecd-ai/vc_investimentos_pais_ano.csv`, colunas `Country, Country_label, INDUSTRY = -- All industries --, STAGE = VC, Sum_of_deals, Year`; 114 países, 2012–2026, valores em milhões de US$ nominais; 160 país-ano com zero). `R/12` deflaciona para US$ de 2021 (CPI-EUA), grava `data/processed/oecd_ai_vc.csv`, compara com o CSET por país-ano e gera `fig10`; `R/13` junta ao painel (`investimento_preqin`, `investimento_preqin_l1`). O pipeline roda com `INSUMOS=investimento_preqin_l1,gerd_l1` e sufixo `_painel_preqin`.

## 6. Fontes opcionais (contexto adicional)

- **UNESCO UIS** (bulk SDMX): GERD por setor de execução (ensino superior + governo) e pesquisadores EPT — insumo de P&D público mais limpo que o GERD total.
- **Top500** (https://top500.org): número de supercomputadores por país, listas semestrais — proxy de capital computacional.
- **GitHub Innovation Graph** (https://github.com/github/innovationgraph): desenvolvedores e repositórios por economia, trimestral desde 2020 — descritivo.
- **OECD MSTI** (GBARD, HERD): apenas membros da OCDE.
- **CPI-EUA no FRED** (`CPIAUCSL`): alternativa ao `FP.CPI.TOTL` para deflacionar séries nominais.

## 6a. Como baixar as fontes opcionais que fazem diferença

**P&D público por setor de execução (HERD + GOVERD) — OECD MSTI, por script.** `R/15_download_msti.R` chama a API SDMX do OECD Data Explorer (dataflow `OECD.STI.STP,DSD_MSTI@DF_MSTI`, medidas `H` = HERD, `GV` = GOVERD, `G` = GERD, unidade `PT_B1GQ` = % do PIB, 2010 em diante) e grava `data/msti/msti_pd_setor_pct_pib.csv` com `pd_publico_pct_pib = herd + goverd`. Cobre 45 economias (membros da OCDE e parceiros como Argentina, China, Romênia, Rússia, Singapura, África do Sul, Taiwan), 2010–2022: 38 dos 47 países do painel. Faltam Brasil, Bulgária, Croácia, Índia, Malásia, Filipinas, Arábia Saudita, Sérvia e Ucrânia.

```
https://sdmx.oecd.org/public/rest/data/OECD.STI.STP,DSD_MSTI@DF_MSTI,1.0/
  .A.H+GV+G.PT_B1GQ..?startPeriod=2010&dimensionAtObservation=AllDimensions&format=csvfilewithlabels
```

**Os países que faltam no MSTI.** O UNESCO UIS **não** oferece mais a abertura por setor de execução: o Data Browser e a API pública (`https://api.uis.unesco.org/api/public/definitions/indicators`) expõem só 12 indicadores de C&T (GERD total % PIB, pesquisadores por milhão e participações femininas), e os zips do antigo serviço de dados em massa redirecionam para a página inicial. Verificado em 27/09/2026. Para membros e candidatos da UE, o Eurostat (`rd_e_gerdtot`, setores `HES` e `GOV`, unidade `PC_GDP`) tem os dados por API e o `R/15` já os acrescenta (Bulgária, Croácia, Sérvia). Continuam sem fonte pública por setor: Brasil, Índia, Malásia, Filipinas, Arábia Saudita e Ucrânia; eles ficam fora apenas da variante `_painel_publico` (o modelo principal com GERD total não muda). Se quiser incluí-los, a via é manual e nacional: RICYT (`ricyt.org`, indicador "gasto en I+D por sector de ejecución") para o Brasil; DST *Research and Development Statistics* para a Índia; MASTIC *National Survey of R&D* para a Malásia. Não vale o esforço antes do manuscrito.

**Top500 — por script, com limite de taxa.** `R/16_download_top500.R` baixa a planilha de cada lista semestral (`https://www.top500.org/lists/top500/AAAA/MM/download/TOP500_AAAAMM.xlsx/`, sem login) para `data/top500/` e agrega sistemas e Rmax por país e ano em `data/top500/top500_pais_ano.csv`. O site bloqueia sequências rápidas de requisições: o script pausa 15 segundos entre listas e tenta três vezes; se ainda falhar, baixar manualmente na página de cada lista (botão de download da planilha) e salvar com o mesmo nome (`TOP500_201306.xlsx` etc.), rodando o script depois para agregar. Em 27/09/2026 só a lista 2021/11 foi obtida antes do bloqueio.

## 7. Fontes a evitar no painel

- **IMF AI Preparedness Index**: corte transversal (2023).
- **Oxford Insights Government AI Readiness Index**: desde 2019, mas a metodologia muda entre edições.
- **Tortoise Global AI Index**: índice composto proprietário que já embute publicações e investimento (endógeno aos produtos).

Podem aparecer apenas como descrição ou validação externa dos rankings.

## 8. Reconciliação prevista (testes de sanidade)

- Argentina 2018: 279 artigos, 7 pedidos de patente, 6 concedidas, 1 milhão de US$ nominal (≈ 1,08 milhão em US$ de 2021).
- Luxemburgo 2021: 236 artigos, 37 pedidos, 394 milhões.
- China 2021: 72.439 artigos, 92.950 pedidos, 17.750 milhões.
- Os 37 países do dataset original estão todos presentes nos três arquivos do CSET; a safra nova revisa valores (China 2021 artigos 72.439 contra 77.180 no dataset), o que deve ser declarado.
