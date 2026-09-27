# AI Efficiency Analysis

Eficiência dos países na conversão de investimento em inteligência artificial (e P&D) em produção científica (publicações em IA) e tecnológica (pedidos de patente em IA). Trabalho da disciplina *Introdução à Análise de Eficiência em R* (Prof. Peter Wanke), a ser convertido em artigo para periódico Qualis.

## Estrutura

- `data/` — todas as bases (inventário em `data/README.md`): dataset original, CSET (`cat/`), World Bank (`wdi/`, `wgi/`), bases processadas (`processed/`).
- `R/` — scripts em R no estilo do [Google R Style Guide](https://google.github.io/styleguide/Rguide.html) (funções em `BigCamelCase`, `return()` explícito, namespaces qualificados), comentários em português.
- `artigo/` — documentos do trabalho: hipóteses, catálogo de dados externos, codebook, resultados.
- `output/tables/` e `output/figures/` — tabelas (CSV) e figuras (PNG) geradas pelos scripts.
- `others/` — syllabus da disciplina.

## Como rodar

Fase A (dataset original, apresentação):

```bash
Rscript R/10_download_wdi.R            # indicadores do World Bank e WGI (cache em data/)
Rscript R/01_prep_dataset_atual.R      # prepara data/processed/base_atual.csv
Rscript R/02_fronteiras_dataset_atual.R    # DEA, bootstrap, FDH, order-m/alfa, canais, metafronteira, Malmquist
Rscript R/02b_teste_rts.R              # teste de retornos de escala (demorado)
Rscript R/03_segundo_estagio_dataset_atual.R  # Simar-Wilson, truncada, Tobit, Kruskal-Wallis
Rscript R/04_figuras_apresentacao.R    # figuras
```

Fase B (painel reconstruído CSET + World Bank, artigo):

```bash
Rscript R/11_import_cset.R             # lê data/cat/, deflaciona, aplica completude
Rscript R/14_download_oecd_patentes.R  # patentes de IA por país do inventor (API SDMX da OCDE)
Rscript R/15_download_msti.R           # HERD e GOVERD (P&D público) do OECD MSTI, API SDMX
Rscript R/16_download_top500.R         # listas TOP500 por país e ano (limite de taxa no site)
Rscript R/12_import_fontes_alternativas.R  # AI Index, OECD.AI e checagens entre fornecedores
Rscript R/13_build_painel.R            # monta data/processed/painel_ia.csv e o codebook
BASE_ARQUIVO=data/processed/painel_ia.csv SUFIXO_SAIDA=_painel \
INSUMOS=investimento_l1,gerd_l1 JANELA_MALMQUIST=2017,2021 \
  Rscript R/02_fronteiras_dataset_atual.R
# idem para R/03_... e R/04_... com as mesmas variáveis de ambiente
```

Os scripts 02, 03 e 04 são parametrizados por variáveis de ambiente (`BASE_ARQUIVO`, `SUFIXO_SAIDA`, `INSUMOS`, `PRODUTOS`, `JANELA_MALMQUIST`), de modo que o mesmo pipeline roda nas duas bases; as saídas da Fase B levam o sufixo `_painel`. A variante ajustada por qualidade (produtos `citacoes_ok` e `patentes_concedidas_ok`, janela 2017–2019) usa o sufixo `_painel_qualidade`; a variante de fonte alternativa (patentes por país do inventor, OCDE: `PRODUTOS=publicacoes,patentes_inventor`) usa `_painel_fonte`; a variante com VC da Preqin como insumo (`INSUMOS=investimento_preqin_l1,gerd_l1`) usa `_painel_preqin`. Runners: `output/rodar_fonte2.sh` e `output/rodar_preqin.sh`. O script `output/rodar_cadeias.sh` executa as três cadeias em sequência. O teste de retornos de escala aceita `N_REP_RTS` e `SUFIXO_SAIDA`.

## Documentos

- `artigo/01_hipoteses.md` — questão de pesquisa, enquadramento teórico e hipóteses H1–H7 com testes e critérios.
- `artigo/02_dados_externos.md` — proveniência do dataset original e catálogo priorizado de fontes externas.
- `artigo/03_codebook.md` — codebook do painel reconstruído.
- `artigo/05_resultados_fase_a.md` — resultados preliminares para a apresentação (dataset original).
- `artigo/06_resultados_painel.md` — resultados no painel reconstruído, variantes (qualidade, fontes alternativas, P&D público) e checagens entre fornecedores.
- `artigo/07_registro_de_trabalho.md` — registro de tudo o que foi feito e guia de retomada (ler primeiro em nova sessão).
- `artigo/08_brief_deck.md` — brief slide a slide para montar a apresentação no Claude Design.
