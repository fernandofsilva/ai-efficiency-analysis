# AI Efficiency Analysis

Eficiência dos países na conversão de investimento em inteligência artificial (e P&D) em produção científica (publicações em IA) e tecnológica (pedidos de patente em IA). Trabalho da disciplina *Introdução à Análise de Eficiência em R* (Escola de Métodos, Prof. Peter Wanke), a ser convertido em artigo para periódico Qualis.

## Estrutura

- `data/` — todas as bases (inventário em `data/README.md`): dataset original, CSET (`cat/`), World Bank (`wdi/`, `wgi/`), bases processadas (`processed/`).
- `R/` — scripts em R no estilo do [Google R Style Guide](https://google.github.io/styleguide/Rguide.html) (funções em `BigCamelCase`, `return()` explícito, namespaces qualificados), comentários em português.
- `artigo/` — documentos do trabalho: hipóteses, catálogo de dados externos, codebook, resultados.
- `output/tables/` e `output/figures/` — tabelas (CSV) e figuras (PNG) geradas pelos scripts.
- `others/` — syllabus da disciplina.

## Ambiente

Resultados de 04/10/2026 gerados em macOS com R 4.5.2 (`/usr/local/bin/Rscript`). Versões dos pacotes usados:

| Pacote | Versão | Pacote | Versão |
|---|---|---|---|
| Benchmarking | 0.33 | frontier | 1.1.8 |
| rDEA | 1.2.8 | sfaR | 1.0.1 |
| nonparaeff | 0.5.15 | npsf | 0.8.0 |
| frontiles | 1.3.1 | plm | 2.6.7 |
| truncreg | 0.2.5 | lmtest | 0.9.40 |
| AER | 1.2.15 | boot | 1.3.32 |
| dplyr | 1.1.4 | tidyr | 1.3.1 |
| ggplot2 | 4.0.1 | ggrepel | 0.9.8 |
| countrycode | 1.9.0 | curl | 7.0.0 |
| jsonlite | 2.0.0 | readxl | 1.4.5 |
| lpSolveAPI | 5.5.2.0.17.15 | | |

**Cuidados com as versões e a máquina:**
- **Pacotes ausentes.** `R/00_setup.R` instala do CRAN os que faltarem, e a versão instalada pode ser outra.
- **Malmquist.** O sentido dos índices depende da convenção do `Benchmarking` (na 0.33, orientação a produto, menor que 1 é melhora). Por isso `IndicesMalmquist` confere a convenção a cada execução e para o script se ela mudar.
- **Python.** O da máquina não tem certificados SSL (`CERTIFICATE_VERIFY_FAILED`): os downloads usam o pacote `curl` do R ou o `curl` da linha de comando.
- **PDF do deck.** Para inspecionar o PDF, o PyMuPDF foi instalado num ambiente virtual temporário.

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
Rscript R/06_sfa_canais.R              # SFA por canal em log (H2): Cobb-Douglas, exponencial, translog, painel
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

Os scripts 02, 03 e 04 são parametrizados por variáveis de ambiente (`BASE_ARQUIVO`, `SUFIXO_SAIDA`, `INSUMOS`, `PRODUTOS`, `JANELA_MALMQUIST`), de modo que o mesmo pipeline roda nas duas bases; as saídas da Fase B levam o sufixo `_painel`. A variante ajustada por qualidade (produtos `citacoes_ok` e `patentes_concedidas_ok`, janela 2017–2019) usa o sufixo `_painel_qualidade`; a variante de fonte alternativa (patentes por país do inventor, OCDE: `PRODUTOS=publicacoes,patentes_inventor`) usa `_painel_fonte`; a variante com VC da Preqin como insumo (`INSUMOS=investimento_preqin_l1,gerd_l1`) usa `_painel_preqin`. O teste de retornos de escala aceita `N_REP_RTS` e `SUFIXO_SAIDA`; o SFA por canal (`R/06`) aceita as mesmas variáveis de base, insumos e produtos e `N_BOOT_SFA` (réplicas do bootstrap por país, padrão 300). Para executar tudo com propagação de falhas, use `zsh output/rodar_pipeline.sh tudo` (modos `faseA`, `painel`, `variantes`, `cadeias`, `rts`, `sfa`, `estagio2`, `validacao`, `padronizacao`; `estagio2` refaz só o segundo estágio e as figuras; `cadeias` refaz 02 → 03 → 04 nas seis bases, sem o 05). O status de cada etapa fica em `output/status_execucao.txt`; `STATUS_ARQUIVO` muda o arquivo, para rodar dois modos ao mesmo tempo.

**Manifesto de execução.** Os scripts de análise e de checagem (`02`, `02b`, `02c`, `03`, `04`, `05`, `05b`, `06` e `12`) registram cada execução em `output/tables/manifesto_execucoes.csv`, com a base, o seu MD5, as variáveis da execução e o status. Cada tabela e cada figura gravada vai para `manifesto_saidas.csv`, com o MD5. As tabelas derivadas que o `04` e o `05b` leem vão para `manifesto_entradas.csv`, com o MD5 no momento da leitura, o que liga cada figura à versão dos resultados que ela mostra. Os scripts de preparação e importação (`01`, `10`, `11`, `13` a `16`) não entram no manifesto: eles gravam as bases em `data/`, cuja proveniência está em `data/README.md` e em `artigo/02_dados_externos.md`.

Padronização das variáveis da fronteira (S01): os scripts 02, 02b, 03, 04 e 05 aceitam `PADRONIZACAO=minmax` (padrão `nenhuma`, unidades originais) e `EPSILON_PADRONIZACAO` (padrão 0,01). Com min-max, insumos e produtos vão para [ε, 1] com mínimo e máximo da amostra completa (todos os anos), a seleção de amostra continua nas unidades originais e todas as saídas ganham o sufixo `_minmax`. `PADRONIZACAO=minmax zsh output/rodar_pipeline.sh tudo` refaz tudo nessa versão (status em `output/status_execucao_minmax.txt`) e termina com `R/05b_comparacao_padronizacao.R`, que compara as duas versões e mede a sensibilidade a ε.

## Documentos

- `artigo/01_hipoteses.md` — questão de pesquisa, enquadramento teórico, hipóteses H1–H3 e perguntas de pesquisa RQ1–RQ2 (estrutura decidida em 04/10/2026), com testes, critérios e situação atual.
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
- `artigo/15_sfa_canais.md` — S02: fronteira estocástica por canal em log e teste de H2.
- `artigo/16_acrescimos_s06_s07_s08.md` — S06–S08: Malmquist por país, níveis de evidência do segundo estágio (com as dimensões do WGI) e dispersão por renda e ano.
- `artigo/17_analise_critica_inconsistencias.md` — terceira revisão crítica (15 achados, entre eles o sentido invertido do Malmquist).
- `artigo/18_avaliacao_analise_critica.md` — veredito, correção adotada e estado de cada achado da terceira revisão, com a reexecução de 04/10/2026.
- `artigo/19_orientacoes_sessoes_1_2.md` — orientações dos laboratórios de 14 e 21/09/2026 e exigências do programa da disciplina, trazidas do repositório anterior ([investimentos_ia](https://github.com/fernandofsilva/investimentos_ia)), com a situação de cada uma aqui e as pendências.

**Convenção do Malmquist.** As tabelas `malmquist_*` usam índice maior que 1 = melhora (Färe et al., 1994): M > 1, a produtividade cresce; TC > 1, a fronteira avança; EC > 1, o país se aproxima da fronteira. Na orientação a produto, o `Benchmarking` devolve os recíprocos, e `IndicesMalmquist` (em `R/funcoes.R`) faz a conversão.

Comparações em amostra comum entre variantes: `R/05_comparacoes_amostra_comum.R`. Comparação com e sem padronização: `R/05b_comparacao_padronizacao.R`. Manifesto de execuções: `output/tables/manifesto_execucoes.csv`.
