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
Rscript R/02b_teste_rts.R              # teste de retornos de escala (adaptado de Simar-Wilson 2002)
Rscript R/02c_validacao_rts.R          # validação por simulação do teste (tamanho e poder)
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

Os scripts 02, 03 e 04 são parametrizados por variáveis de ambiente (`BASE_ARQUIVO`, `SUFIXO_SAIDA`, `INSUMOS`, `PRODUTOS`, `JANELA_MALMQUIST`), de modo que o mesmo pipeline roda nas duas bases; as saídas da Fase B levam o sufixo `_painel`. A variante ajustada por qualidade (produtos `citacoes_ok` e `patentes_concedidas_ok`, janela 2017–2019) usa o sufixo `_painel_qualidade`; a variante de fonte alternativa (patentes por país do inventor, OCDE: `PRODUTOS=publicacoes,patentes_inventor`) usa `_painel_fonte`; a variante com VC da Preqin como insumo (`INSUMOS=investimento_preqin_l1,gerd_l1`) usa `_painel_preqin`. O teste de retornos de escala aceita `N_REP_RTS` e `SUFIXO_SAIDA`. Para executar tudo com propagação de falhas, use `zsh output/rodar_pipeline.sh tudo` (modos `faseA`, `painel`, `variantes`, `rts`, `validacao`, `padronizacao`); o status de cada etapa fica em `output/status_execucao.txt` e cada execução é registrada em `output/tables/manifesto_execucoes.csv` (com o MD5 das tabelas gravadas em `manifesto_saidas.csv`).

Padronização das variáveis da fronteira (S01): os scripts 02, 02b, 03, 04 e 05 aceitam `PADRONIZACAO=minmax` (padrão `nenhuma`, unidades originais) e `EPSILON_PADRONIZACAO` (padrão 0,01). Com min-max, insumos e produtos vão para [ε, 1] com mínimo e máximo da amostra completa (todos os anos), a seleção de amostra continua nas unidades originais e todas as saídas ganham o sufixo `_minmax`. `PADRONIZACAO=minmax zsh output/rodar_pipeline.sh tudo` refaz tudo nessa versão (status em `output/status_execucao_minmax.txt`) e termina com `R/05b_comparacao_padronizacao.R`, que compara as duas versões e mede a sensibilidade a ε.

## Documentos

- `artigo/01_hipoteses.md` — questão de pesquisa, enquadramento teórico e hipóteses H1–H7 com testes e critérios.
- `artigo/02_dados_externos.md` — proveniência do dataset original e catálogo priorizado de fontes externas.
- `artigo/03_codebook.md` — codebook do painel reconstruído.
- `artigo/05_resultados_fase_a.md` — resultados preliminares para a apresentação (dataset original).
- `artigo/06_resultados_painel.md` — resultados no painel reconstruído, variantes (qualidade, fontes alternativas, P&D público) e checagens entre fornecedores.
- `artigo/07_registro_de_trabalho.md` — registro de tudo o que foi feito e guia de retomada (ler primeiro em nova sessão).
- `artigo/08_brief_deck.md` — brief slide a slide para montar a apresentação no Claude Design.
- `artigo/09_analise_critica_inconsistencias.md` — revisão crítica externa (24 pontos).
- `artigo/10_avaliacao_inconsistencias.md` — veredito, correção adotada e estado de cada ponto, com os resultados após a reexecução.
- `artigo/11_reanalise_critica_inconsistencias.md` — segunda revisão crítica externa (13 achados e 2 pendências).
- `artigo/12_avaliacao_reanalise.md` — veredito e correção de cada achado da reanálise, com a reexecução de 28/09/2026.
- `artigo/13_comentarios_apresentacao.md` — comentários do Prof. Peter Wanke na apresentação de 28/09/2026 e pendências decorrentes (S01–S10).
- `artigo/14_padronizacao_minmax.md` — S01: padronização min-max das variáveis da fronteira, reexecução completa e comparação com as unidades originais.

Comparações em amostra comum entre variantes: `R/05_comparacoes_amostra_comum.R`. Comparação com e sem padronização: `R/05b_comparacao_padronizacao.R`. Manifesto de execuções: `output/tables/manifesto_execucoes.csv`.
