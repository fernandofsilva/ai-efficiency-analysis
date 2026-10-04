# Registro de trabalho e guia de retomada (estado em 04/10/2026, após S01, S02, S03, S06, S07, S08, a análise crítica 3 e o rascunho do manuscrito)

Documento de transferência: tudo o que foi feito, decidido e ficou pendente, para retomar o trabalho em nova sessão sem depender do histórico da conversa. Plano aprovado em `~/.claude/plans/esse-um-trabalho-cheerful-squirrel.md`.

## 1. Contexto e decisões do usuário

- Disciplina *Introdução à Análise de Eficiência em R* (Escola de Métodos, Prof. Peter Wanke, 30 horas; programa em `others/`).
  - **Avaliação:** manuscrito submetido a periódico Qualis até a data-limite de lançamento das notas (pode ser em grupo e deve refletir as metodologias do curso) e apresentação em PowerPoint de 20 minutos com diagnóstico setorial.
  - **Entregas deste trabalho:** apresentação de diagnóstico em 28/09/2026 (dataset original) e manuscrito em português para periódico Qualis (painel reconstruído).
  - **Técnicas a replicar:** o programa pede que o aluno replique as técnicas das sessões; o que falta está no `artigo/19`, seção 1.
- **Trabalho anterior.** As orientações dos laboratórios de 14 e 21/09/2026 ficaram num repositório anterior, `~/Projects/investimentos_ia` (https://github.com/fernandofsilva/investimentos_ia). Este repositório começou em 27/09 com um plano novo. O resumo das orientações e a situação de cada uma estão no `artigo/19`.
- Decisões: modelo principal conjunto (publicações + patentes) com modelos por canal; tudo em português; painel reconstruído (CSET + World Bank) substitui o dataset original na versão artigo; scripts R no estilo Google (BigCamelCase, `return()` explícito, `pkg::fun`, 80 colunas); todas as bases dentro de `data/`, uma subpasta por fonte; documentos em `artigo/` (o `.gitignore` ignora `docs/`).
- Commits em `main`, sincronizada com `origin/main`:
  - 27 e 28/09/2026: `ae6c878` (pipeline e resultados), `c3b78ff` (resposta à análise crítica, `artigo/10`), `3b0799b` (cabeçalho de `R/05`), `91ee83c` (revisão 2 do brief), `f188559` (resposta à reanálise crítica, `artigo/11` → `artigo/12`, código e reexecução);
  - 04/10/2026: `c780f89` (deck e `artigo/13`), `a8fbb21` (S01), `ee19b58` (S02), `ea0c969` (S06–S08), `72b54a7` (S03), `a1af12f` (decisão do S01), `61c274f` (análise crítica 3, `artigo/17` → `artigo/18`), `a355fa3` (orientações dos laboratórios, convenções e ambiente), `f628249` (brief do deck, revisão 5).
  - Aguardam commit: o rascunho do manuscrito (`artigo/20`), o `R/07` com as suas tabelas e as correções de 04/10/2026 nos documentos 01, 05, 07, 08 e 15 e no README.
- Especificação principal decidida em 04/10/2026 (S01): unidades originais; a padronização min-max entra como verificação de robustez (R4).
- Estrutura do artigo decidida em 04/10/2026 (S03, opção B): três hipóteses (H1 retornos de escala, H2 insumos por canal, H3 canais e metafronteira) e duas perguntas de pesquisa exploratórias (RQ1 dinâmica, antiga H4; RQ2 determinantes, antigas H5–H7 como expectativas E5–E7). Os rótulos de código e tabelas mantêm a numeração antiga.
- Apresentação em aula feita em 28/09/2026. Os comentários do Prof. Peter Wanke e as pendências decorrentes (S01–S10) estão em `artigo/13_comentarios_apresentacao.md`; a ordem de execução acordada está na seção 6 abaixo.

## 1a. Convenções de trabalho

- **Versionamento.** Commit e push só quando o autor pede, assim:
  - cada rodada vai num branch próprio, integrado em `main` por fast-forward e enviado ao GitHub; o branch local é apagado em seguida;
  - mensagens de commit em português, com o que mudou e por quê.
- **Análises críticas e comentários do professor.** Cada item recebe veredito ou estado atual e a ação escolhida, com justificativa. O registro vai num arquivo novo, numerado em `artigo/`:
  - análises críticas: 09 → 10, 11 → 12, 17 → 18;
  - comentários da apresentação: 13; orientações dos laboratórios: 19.

  As pendências se consolidam na seção 6 deste registro. Documentos de rodadas anteriores não são reescritos: recebem nota de superação quando um resultado deles muda.
- **Números e reexecução.** Toda mudança de método é reexecutada pelo runner e conferida contra as tabelas versionadas antes de entrar nos textos. Os números dos documentos saem das tabelas de `output/tables/`, nunca de memória.
- **Língua, estilo e dados:** ver a seção 1 (tudo em português; estilo Google em R; bases em `data/`). Ambiente e versões dos pacotes: `README.md`, seção "Ambiente".

## 2. Estrutura do repositório

- `data/AI_INVESTMENT.csv` — dataset original (208 país-ano, 37 países, 2013–2021). Proveniência verificada: CSET via Our World in Data (investimento em US$ constantes de 2021; publicações em contagem; patentes **por milhão de habitantes**) + World Bank WDI/WGI/GFDD.
- `data/cat/` — CSET Country AI Activity Metrics v1.12.0 (Zenodo 22772306), 2016–2026, campo `field == "All"`, coluna `complete` (artigos completos até 2024, pedidos de patente até 2021, concedidas até 2019, investimento em milhões de US$ nominais). Índia: patentes quebradas a partir de 2019 (tratadas como NA).
- `data/wdi/`, `data/wgi/` — World Bank (API v2, cache por indicador; WGI com códigos novos `GOV_WGI_*`, fonte 3). `data/ai_index/` — dados públicos do AI Index 2025 (CSVs por figura). `data/oecd-ai/` — export manual de publicações (`data.csv`), patentes de IA por país do inventor via API SDMX (`patentes_ia_ip5_inventor.csv`, `patentes_ia_triadicas_inventor.csv`) e export manual do VC da Preqin (`vc_investimentos_pais_ano.csv`). `data/msti/` — HERD/GOVERD (MSTI + Eurostat). `data/top500/` — parcial.
- `data/processed/` — `base_atual.csv` (Fase A), `cset_long.csv`, `ai_index_pais_ano.csv`, `ai_index_transversal.csv`, `oecd_ai_publicacoes.csv`, `oecd_ai_patentes.csv`, `painel_ia.csv` (47 países, 2016–2024). Inventário completo em `data/README.md`; codebook em `artigo/03_codebook.md`.
- `R/` — `00_setup.R` (pacotes, opções, pastas, `source("R/funcoes.R")`), `funcoes.R` (World Bank, DEA, bootstrap, Spearman com IC, Malmquist, manifesto, interpolação), `01_prep_dataset_atual.R`, `02_fronteiras_dataset_atual.R`, `02b_teste_rts.R`, `02c_validacao_rts.R`, `03_segundo_estagio_dataset_atual.R`, `04_figuras_apresentacao.R`, `05_comparacoes_amostra_comum.R`, `05b_comparacao_padronizacao.R`, `06_sfa_canais.R`, `07_tabelas_manuscrito.R`, `10_download_wdi.R`, `11_import_cset.R`, `12_import_fontes_alternativas.R`, `13_build_painel.R`, `14_download_oecd_patentes.R`, `15_download_msti.R`, `16_download_top500.R`.
- Scripts 02/02b/03/04 são parametrizados por variáveis de ambiente: `BASE_ARQUIVO` (padrão `data/processed/base_atual.csv`), `SUFIXO_SAIDA` (`""`, `_painel`, `_painel_qualidade`, `_painel_fonte`, `_painel_preqin`, `_painel_publico`), `INSUMOS` (`investimento,gerd`; `investimento_l1,gerd_l1`; `investimento_preqin_l1,gerd_l1`; `investimento_l1,pd_publico_l1`), `PRODUTOS` (`publicacoes,patentes`; `citacoes_ok,patentes_concedidas_ok`; `publicacoes,patentes_inventor`), `JANELA_MALMQUIST` (`2016,2019`; `2017,2021`; `2017,2019`), `N_REP_RTS`, `LIMITE_SW_SEG`. Runner único: `output/rodar_pipeline.sh` (modos `faseA`, `painel`, `variantes`, `cadeias`, `rts`, `sfa`, `estagio2`, `validacao`, `padronizacao`, `tudo`), com status por etapa em `output/status_execucao.txt` (ou no arquivo de `STATUS_ARQUIVO`), interrupção da cadeia dependente em caso de falha e código de saída igual ao número de falhas. Manifesto de execuções, de saídas (tabelas e figuras, com MD5) e de tabelas derivadas lidas pelo `04` e pelo `05b` em `output/tables/manifesto_execucoes.csv`, `manifesto_saidas.csv` e `manifesto_entradas.csv`; os scripts de preparação e importação (`01`, `10`, `11`, `13` a `16`) ficam fora. `PADRONIZACAO` (`nenhuma` ou `minmax`) e `EPSILON_PADRONIZACAO` (padrão 0,01) valem também para o `05`; com min-max, as saídas ganham o sufixo `_minmax` (ver `artigo/14`).
- `output/tables/` (~100 CSVs) e `output/figures/` (fig1–fig7 por variante, fig8 investimento CSET × Quid, fig9 patentes CSET × OCDE, fig10 investimento CSET × Preqin, fig11 ranking com e sem padronização). Logs em `output/log_*.txt`.
- `artigo/` — `01_hipoteses.md`, `02_dados_externos.md` (inclui seção 5a: como obter patentes por inventor e VC), `03_codebook.md`, `05_resultados_fase_a.md`, `06_resultados_painel.md`, este registro, `08_brief_deck.md` (brief do deck, revisão 5), `09`/`10` (análise crítica 1 e resposta), `11`/`12` (reanálise crítica e resposta), `13_comentarios_apresentacao.md` (comentários do professor na apresentação de 28/09/2026 e pendências S01–S10), `14_padronizacao_minmax.md` (S01: padronização min-max, reexecução e comparação), `15_sfa_canais.md` (S02: SFA por canal e H2), `16_acrescimos_s06_s07_s08.md` (S06–S08), `17_analise_critica_inconsistencias.md` (análise crítica 3), `18_avaliacao_analise_critica.md` (resposta), `19_orientacoes_sessoes_1_2.md` (orientações dos laboratórios de 14 e 21/09 e exigências do programa, a partir do repositório anterior) e `20_manuscrito.md` (rascunho do manuscrito, 04/10/2026).

## 3. Pipeline (por variante)

1. `01` prepara o dataset original (renda harmonizada, patentes em contagem via população WDI, GERD = P&D% × PIB, flags `inv_zero` e `inv_piso`).
2. `02`: outliers (`outlier.ap`, `sdea`), DEA CRS/VRS/NIRS por ano com eficiência de escala e classificação de RTS, bootstrap de Simar-Wilson (`dea.boot`, 1.000 réplicas), FDH/order-m/order-α (`nonparaeff`, `frontiles`; frontiles devolve escores ≤ 1 = ineficiente, sem inversão), canais (DMUs com produto zero excluídas), metafronteira por grupo de renda (agrupada), Malmquist CRS no painel balanceado (índices na convenção maior que 1 = melhora, via `IndicesMalmquist`; escores CRS contemporâneos de todos os anos em `malmquist_escores_crs`), bloco de sensibilidade sem valores-piso.
3. `02b`: teste de RTS de Simar-Wilson (2002) implementado sobre `Benchmarking` com a mesma construção da referência `rDEA::rts.test` (estatística 4.6, banda de Silverman `bw.nrd0` na amostra original, arredondamento em 1, p-valor (k+1)/(B+1)); tempo máximo por LP (`CONTROL = list(timeout = 10)`). O tamanho do teste é cerca de 0,20 sob CRS verdadeiro nas duas implementações (`R/02c`, `validacao_teste_rts.csv`): os p-valores são diagnósticos exploratórios. A referência na base real (banda de Silverman) não concluiu em tempo útil; com validação cruzada, não concluía em mais de uma hora.
4. `03`: bootstrap dos canais; regressão truncada sobre log(escore corrigido) (em (−∞, 0), truncada em 0; especificação principal, compatível com o suporte) com escores fixos e bootstrap agrupado por país (300 réplicas), convergência verificada em cada ajuste (`AjustarTruncada` em `R/funcoes.R`; réplicas tentadas × convergentes na tabela); parametrizações em escore truncado só em 1 e em Farrell como comparação; H5 (com e sem piso, com pesquisadores, com talento em IA), H6 (canal patentes), H7 (PIB per capita por canal); Tobit comparativo; Simar-Wilson algoritmo 2 do rDEA em processo filho com timeout e semente fixada no filho; Kruskal-Wallis (3 grupos) e Mann-Whitney (2 grupos) por renda, em país-ano e em médias por país; associação descritiva Z × escore.
5. `04`: figuras 1–7 (com `ggrepel`); fig4 colorida pelo nível de evidência (S07); tabelas `malmquist_por_pais` (S06; "na fronteira em todos os anos" pelos escores CRS contemporâneos) e `dispersao_renda_ano`/`dispersao_renda_tendencia` (S08; IQR absoluto e relativo; diferença entre metades com bootstrap de países); registra o manifesto, com as tabelas lidas e as figuras.
5a. `05b` (só com `PADRONIZACAO=minmax`): compara cada execução com a versão em unidades originais (escores, RTS, ranking, canais, metafronteira, Malmquist, teste de RTS, segundo estágio, `R/05`) e mede a sensibilidade a ε e a invariância à escala pura (`sensibilidade_padronizacao_epsilon.csv`; fig11).
5b. `06`: SFA por canal em log (S02/H2), nas seis bases; Cobb-Douglas meia-normal agrupada (principal), exponencial, translog centrada e painel (Battese e Coelli, 1988 e 1992); reinício do otimizador do próprio ponto final quando o `frontier` para sem convergir (ajuste pontual e réplicas); bootstrap em blocos de país (300 réplicas) com os dois canais no mesmo sorteio, o que dá o IC da diferença entre as elasticidades do investimento e o IC dos retornos de escala (soma na réplica, `sfa_retornos`); veredito de H2 pela especificidade relativa com direção, só com ajuste pontual válido e pelo menos 90% de réplicas convergentes; diagnósticos de assimetria, colinearidade, convergência e tempo. Pulado com `PADRONIZACAO=minmax` (o log já remove a escala).
5c. `07`: tabelas descritivas do manuscrito (`manuscrito_descritiva_painel` e `manuscrito_medianas_ano_painel`), a partir de `data/processed/painel_ia.csv` restrito à amostra da DEA (`dea_ano_m2_painel.csv`, registrada como entrada no manifesto). Rodar depois da cadeia do painel; fora do runner.
6. Fase B: `10` → `11` → `14` → `12` → `13` → 02/03/04 com variáveis de ambiente.

## 4. Resultados principais

Os resultados vigentes estão em `artigo/05_resultados_fase_a.md` (Fase A) e `artigo/06_resultados_painel.md` (painel e variantes). Partem da reexecução de 28/09/2026 após a reanálise crítica (`artigo/11` → `artigo/12`). Em 04/10/2026 foram atualizados pelas rodadas S01 (`artigo/14`), S02 (`artigo/15`), S06–S08 (`artigo/16`) e pela análise crítica 3 (`artigo/18`), que corrigiu a leitura invertida do Malmquist. Este registro não duplica números: as duas rodadas de crítica (`artigo/09`/`10` em 27/09 e `artigo/11`/`12` em 28/09) mudaram procedimentos e valores, e as versões anteriores desta seção descreviam estados já superados (teste de RTS antes da correção, IC do ranking pela média dos limites, segundo estágio em escore truncado só em 1). O que cada rodada mudou de substância está nas seções finais de `artigo/10` e `artigo/12`.

## 5. Problemas encontrados e como foram resolvidos

- `rDEA` (rts.test e dea.env.robust) extremamente lento ou travando: substituído por implementação própria (02b) e envolto em processo filho com timeout (03).
- `frontiles` retorna escores orientados a produto ≤ 1 (ineficiente) — não inverter; `nonparaeff::fdh` é Farrell ≥ 1 — inverter. Verificado com dados sintéticos.
- Supereficiência inviável (Peru 2021) → NA. Zeros de investimento (17 no original) excluídos; valores-piso (≤ 2,5 M) testados em bloco de sensibilidade.
- `pkill` mata só o front-end `Rscript`; o back-end `exec/R` continua — sempre matar pelo PID de `exec/R`.
- Zenodo bloqueia scripts (403): CSET baixado manualmente em `data/cat/`. World Bank API mudou códigos do WGI.
- AI Index não traz investimento por país-ano (só China/Europa/EUA); usado como corte transversal (Quid) e painel de talento (LinkedIn).
- `summarise` do dplyr sobrescrevendo nomes usados nas expressões seguintes (cobertura do painel) — corrigido com nomes distintos.
- Dois processos `exec/R` sem `--file` que aparecem no `pgrep` são do VS Code, não do projeto.
- Rodada de 28/09 (`artigo/12`): `truncreg` devolve coeficientes mesmo sem convergência (`est.stat$message = "iteration limit exceeded"`) — verificar sempre; a truncada em Farrell é degenerada nos canais (sigma explode) e a normal truncada em 0 e 1 não tem máximo finito quando os escores se acumulam perto de zero — a truncada sobre log(escore) resolve os dois problemas; `parallel::mcparallel` reinicializa o gerador do filho pelo PID e horário — fixar a semente dentro do filho; a largura de banda do teste de RTS calculada na amostra refletida subsuavizava em amostras grandes — usar `bw.nrd0` na amostra original, como o rDEA; `rDEA::rts.test` roda em segundos em amostras simuladas (banda de Silverman), mas não conclui na base real; réplicas de `dea.boot` invertidas para a escala de escore explodem quando F* < 1 — usar pseudo-valores 2F̂ − F*; o texto do PDF do deck não sai com as ferramentas do sistema, mas sai com PyMuPDF, que também renderiza cada página (instalar num ambiente virtual temporário); rótulos de modelo com vírgula quebram `cut` nos CSVs — usar leitor de CSV.
- Rodada de 04/10/2026 (`artigo/18`):
  - **Malmquist do `Benchmarking`.** Na orientação a produto, o pacote devolve índices em que valor menor que 1 é melhora (medidas de Farrell, `ec = e11/e00`). O projeto lia o contrário desde o início. `IndicesMalmquist` converte num só ponto e interrompe a execução se a convenção do pacote mudar.
  - **`summarise` do dplyr.** Uma média que sobrescreve a coluna anual é usada pelas expressões seguintes do mesmo `summarise`. Usar nomes distintos para os valores anuais e para os agregados.
  - **Código 5 do `frontier`.** O otimizador não acha parâmetros com log-verossimilhança maior que a do passo anterior: às vezes está no máximo, às vezes não. Reiniciar do próprio ponto final resolve quase todos os casos; descartar essas réplicas enviesava os intervalos.
  - **WGI da Fase A.** O dataset original traz uma cópia da efetividade governamental e do controle da corrupção diferente da do World Bank (até 0,53); não misturar as cópias.
  - **Checagens entre fontes.** Usar as colunas tratadas, nunca as brutas.

## 6. Pendências (estado em 04/10/2026, após S01–S03, S06–S08, a análise crítica 3 e o registro dos laboratórios)

### Concluído (não requer ação)

- Fase A completa: scripts `R/01`–`R/04`, `R/02b`, `R/02c`, figuras, `artigo/05`.
- Fase B, dados: World Bank/WGI (`R/10`), CSET (`R/11`), AI Index e OECD.AI (`R/12`), patentes por inventor OCDE (`R/14`), MSTI + Eurostat (`R/15`), painel de 47 países (`R/13`), codebook.
- Fase B, análises: painel em volume (`_painel`), qualidade (`_painel_qualidade`), patentes por inventor (`_painel_fonte`), VC Preqin (`_painel_preqin`), P&D público (`_painel_publico`, 41 países com MSTI + Eurostat, resumido na seção 9c do `artigo/06`); testes de RTS no dataset original e no painel; checagens entre fornecedores (investimento Quid e Preqin, publicações OECD.AI, patentes OCDE); talento em IA como Z.
- Documentação: `artigo/01`, `02` (com seções 5a e 6a de acesso às fontes), `03`, `05`, `06`, `07`; `data/README.md`; `README.md`.

### Aberto — depende do usuário

1. **Apresentação de 28/09**: feita. O deck `AI Effiency Analysis.pdf` (raiz) foi modificado em 28/09/2026 às 19:30, depois do último commit (20 páginas; a versão commitada, da revisão 1 do brief, tinha 19), e foi commitado em 04/10/2026 junto com o registro dos comentários. É o registro do que foi apresentado e fica intocado. Ele **não** tem as sete figuras da revisão 3 em todas as páginas: na página 12, a imagem é a fig4 da versão anterior, em escore (0,1], ao lado de uma tabela em log do escore (`artigo/17`, A14). Além disso, os slides 11, 14, 15 e 18 leem o Malmquist no sentido inverso (A01). A errata página a página está em `artigo/08`, seção 2, e o brief da revisão 5 (seções 3 e 4) gera o deck atualizado, a exportar em .pptx e PDF. Gerá-lo no Claude Design depende do autor (fonte não versionada). Os comentários recebidos na apresentação estão em `artigo/13` e geram as pendências S01–S10 abaixo; para a nova versão do deck ou para o relatório final, aplicar também S05 (legibilidade da fig1), S06 (decomposição do Malmquist por país no slide 11) e S07 (níveis de evidência no slide 12).
2. **Commits**: tudo até o brief da revisão 5 está em `main` e em `origin/main` (`f628249`, 04/10/2026). Aguardam commit o rascunho do manuscrito (`artigo/20`), o `R/07` com as suas tabelas e as correções de 04/10/2026 nos documentos (seção 1).
3. **Top500** (opcional, baixa prioridade): o site bloqueou os downloads por taxa; rerodar `Rscript R/16_download_top500.R` mais tarde ou baixar as planilhas manualmente para `data/top500/` e rodar o script para agregar. Depois, usar `top500_sistemas` como Z no segundo estágio.
4. **P&D público dos seis países sem fonte** (opcional): Brasil, Índia, Malásia, Filipinas, Arábia Saudita, Ucrânia só por fontes nacionais (RICYT, DST, MASTIC), manualmente. O UIS não publica mais a abertura por setor. Sem isso, esses países ficam fora apenas da variante `_painel_publico`.
5. **Página do comparativo min-max para o professor** (S01, publicada em 04/10/2026): https://claude.ai/artifact/Au7Lf6rbbB4952vuHK7Mdx. É privada até ser compartilhada pelo menu Share da página. Conteúdo: mecanismo da translação, comparação por hipótese e por RQ, níveis de evidência, figuras de ranking, sensibilidade a ε e especificação adotada.

### Aberto — sugestões do Prof. Peter Wanke na apresentação de 28/09/2026 (detalhes, estado atual e ações em `artigo/13_comentarios_apresentacao.md`)

- **S01 Padronização das variáveis da fronteira (min-max) e reexecução** [executado em 04/10/2026; resta uma decisão]: variante `PADRONIZACAO=minmax` (ε = 0,01, mín e máx da amostra completa, insumo mantido como insumo, mesma amostra) em todo o pipeline; comparação em `R/05b`; resultados em `artigo/14_padronizacao_minmax.md`.
  - A mudança de escala pura reproduz tudo (diferença menor que 4 × 10⁻¹²).
  - A min-max muda os resultados por translação e desloca a origem; por isso retornos de escala (H1) e Malmquist CRS (H4) não podem ser checados por ela.
  - Resistem: a base do ranking (Israel; Suíça e Noruega), H3b sem apoio e o sinal de H5 e de H7.
  - Não resistem: o topo do ranking, H6, a força de H3a, a inversão da metafronteira nas variantes e a diferença de coeficientes entre qualidade e base.
  - **Decisão do autor (04/10/2026):** especificação principal em unidades originais; min-max como verificação de robustez dos resultados VRS (R4). Comparativo para o professor em página compartilhável (link abaixo, em "Aberto — depende do usuário").
- **S02 SFA de H2** [executado em 04/10/2026; refeito após a análise crítica 3, `artigo/18`]: `R/06_sfa_canais.R` nas seis bases (modo `sfa` do runner); resultados em `artigo/15_sfa_canais.md`.
  - Em log, cada ajuste converge em menos de meio segundo. Com o reinício do otimizador, 55 de 60 ajustes têm inferência válida, e de 294 a 300 réplicas convergem.
  - H2, pelo critério de especificidade relativa com direção:
    - apoiada em 3 de 18 combinações (modelos de painel da Fase A; agrupado do inventor, no limite);
    - apoio parcial em 2;
    - sem apoio na base do artigo nem com o P&D público.
  - O P&D domina nos dois canais. Retornos com IC por país: decrescentes em publicações; em patentes, no máximo levemente crescentes (12 de 18, limite inferior colado em 1).
  - No corte agrupado, a ineficiência não é identificada em publicações.
  - As classes latentes ficam identificadas em 4 de 12 ajustes.
  - O status de H2 foi decidido no S03 (continua hipótese).
- **S03 Hipóteses × perguntas de pesquisa** [decidido em 04/10/2026, opção B]: H1–H3 como hipóteses; RQ1 (dinâmica) e RQ2 (determinantes) exploratórias; `artigo/01` reescrito (base, teste, critério e situação de cada ponto) e síntese do `artigo/05` atualizada. Falta: revisão de literatura por hipótese (S09) e o fechamento de cada uma na discussão.
- **S04 Discussão de H1 por país** [média]: EUA, Japão e Reino Unido em DRS, China em CRS (não IRS, como dito na fala), Índia alternando; explicar com evidência contemporânea (platô japonês e britânico, desindustrialização e aposta em IA dos EUA, ascensão chinesa e indiana). Discutir em unidades originais: com min-max a origem muda e os retornos de escala perdem sentido; EUA, Reino Unido e China coincidem nas duas versões, o Japão não (`artigo/14`).
- **S05 Perfis do ranking** [média, liberado por S01]: três do topo e três ou quatro da base (países "nichados"), com fontes; aumentar a legibilidade da fig1. Pela robustez à padronização (`artigo/14`, seção 4), os candidatos mais estáveis são Itália, Grécia e Malásia no topo e Israel, Suíça e Noruega na base; Irlanda e África do Sul só ficam na base na versão original.
- **S06 Malmquist por país** [executado em 04/10/2026, `artigo/16`; leitura corrigida após a análise crítica 3]:
  - `malmquist_por_pais<sufixo>.csv` nas seis bases e tabela da Fase A no `artigo/05`, seção 7.
  - Na convenção corrigida (maior que 1 = melhora), a fronteira avança e a maioria dos países se afasta dela.
  - Na fronteira em todos os anos: China, Índia e Grécia na Fase A; China, Malásia e Coreia do Sul no painel.
  - O Brasil se afasta da fronteira, e a tese do platô não se confirma.
  - Moraes e Wanke (2019) conferido (o artigo chama o catch-up de "Mudança Técnica").
  - Tabela por país no deck: feita no brief da revisão 5 (`artigo/08`, slide 14). Falta a evidência sobre a FINEP.
- **S07 Níveis de evidência no segundo estágio** [executado em 04/10/2026, `artigo/16`]:
  - p-valor bootstrap, IC 90%, sinal previsto e nível em todas as tabelas, e a fig4 mostra os níveis.
  - A efetividade governamental tem sinal contrário em todas as 23 especificações (13 a 5%, depois da correção da amostra do inventor), igual a todas as dimensões do WGI.
  - O bloco WGI usa uma só cópia dos dados; as dimensões têm correlação de 0,93 a 0,96 entre si.
  - H6 (crédito) e H7 (patentes) são contrariadas.
- **S08 Dispersão por renda e ano** [executado em 04/10/2026, `artigo/16`; refeito após a análise crítica 3]:
  - `dispersao_renda_ano` (com IQR relativo) e `dispersao_renda_tendencia` (bootstrap de países).
  - Nenhuma diferença entre as metades do período é distinguível de zero.
  - Na renda média-alta, o CV sobe na Fase A e cai no painel (descrição).
  - A abertura de 2018 na renda média-baixa é a entrada das Filipinas.
  - O texto com evidência contemporânea depende do S09.
- **S09 Literatura, evidência contemporânea e periódico-alvo** [média]:
  - revisão por hipótese: dados bibliográficos e resumos conferidos em fonte primária em 04/10/2026 e incorporados ao manuscrito (`artigo/20`, seções 2 e 6), com o título de Cullmann et al. (2012) corrigido; falta ler os textos completos;
  - dossiê de evidência por país com fontes datadas: ainda não feito;
  - periódico: CEJOR como candidato (Holý e Šafr, 2018, saiu lá). Ele publica em inglês, e o manuscrito está em português.
- **S10 Ordem acordada**: S01 → S02 → acréscimos leves (S07, S06, S08) → S03 → discussões (S04–S08 com S09) → relatório final e manuscrito.

### Aberto — orientações dos laboratórios de 14 e 21/09 e exigências do programa (`artigo/19`)

- **Zeros de investimento** [decisão com o professor]: na sessão 2 ele disse que "zero é zero". Este repositório exclui os zeros do modelo principal e os chama de "negócio não registrado" (`artigo/05`, seção 1).
  - Saída A: manter a exclusão, com a justificativa reescrita. Sob retornos variáveis, a unidade sem investimento só é comparada a outras sem investimento e sai eficiente por construção.
  - Saída B: trazer os zeros de volta ao modelo principal e discuti-los como casos.
  - A sensibilidade já existe: `sensibilidade_zeros_m2*.csv`.
- **Técnicas do programa que faltam:**
  - ganhos com fusões (`Benchmarking::dea.merge`, por exemplo com blocos regionais);
  - TOPSIS para agregar os estimadores num ranking final;
  - análise das folgas (já calculadas nas tabelas `dea_ano_*`);
  - opcionais: classes latentes com `poLCA` e o teste de Kolmogorov-Smirnov, como no material de aula.
- **Base industrial** (sessão 1: a pesquisa só vira patente com base industrial): decidir se a manufatura (% do PIB) e a participação das exportações de manufaturados entram como contextuais na RQ2, ou justificar a omissão.
- **Regra dos três anos** (sessão 2, "trabalho de cirurgião"): ranking só com países com pelo menos três anos.
  - Hoje ficariam de fora 8 de 36 países na Fase A, inclusive o primeiro (Itália) e o último (Suíça), e 7 de 47 no painel.
  - Isso afeta a escolha dos perfis do S05.
- **Manuscrito** (rascunho em `artigo/20`, 04/10/2026):
  - tabela de regressões no formato de periódico: a Tabela 8 do manuscrito é compacta; falta a tabela com os modelos lado a lado;
  - parágrafo "por que fronteira, e não mediação ou moderação": feito (seção 4.1);
  - posicionamento contra Fukuyama, Tan e Wanke (2025): feito com base no resumo (seções 2.2 e 6.4). Faltam o texto completo e o estudo econométrico do grupo, se o professor o disponibilizar.
- **Opcionais:** *voice and accountability* no bloco WGI; participação de STEM na produção científica; Malmquist global (Pastor e Lovell, 2005); tempo desde o primeiro investimento; modelo de conversão de publicações em patentes (DEA em rede).

### Aberto — decorrentes da análise crítica

- Reexportar o deck com as figuras regeneradas (I05/P01); roteiro de alterações em `artigo/08`, seção 2.
- Resolvidos na rodada de 28/09 (`artigo/12`): semente do algoritmo 2 no processo filho (P02); incerteza de postos e contrastes no ranking (I04/R07); manifesto de saídas com MD5 (I22/R13); comparação do teste de RTS com o `rDEA` em simulação e alinhamento da rotina (I09/R08); convergência das truncadas (R01) e especificação compatível com o suporte (I08/R09, truncada sobre log(escore)); fronteira comum nas comparações (R02/R03); eficiência inicial da β-convergência (R04); rótulos dos testes por grupo (R06); alvos de H3b (R10); runner com propagação de falhas (R13).
- Decorrentes da análise crítica 3 (`artigo/18`):
  - **Deck:** gerar o deck atualizado no Claude Design com o brief da revisão 5 do `artigo/08` (errata do deck apresentado na seção 2) e salvar como `AI Efficiency Analysis - revisado` (.pptx e PDF); o PDF de 28/09 fica como registro.
  - **Dispersão (opcional, A15):** medida em tecnologia de referência comum (fronteira agrupada, amostra estável), outro objeto em relação às fronteiras contemporâneas.
  - **Efeitos marginais (opcional, A09):** só se o manuscrito interpretar magnitudes do segundo estágio; calcular da distribuição truncada ajustada, com incerteza.
  - **Equivalência em H2 (opcional, A03):** só com margem fixada antes dos resultados.
  - **Manifesto da preparação (A13):** registrar `01`, `11` e `13` quando as bases forem reconstruídas.
  - **Malmquist:** o bootstrap de Simar e Wilson (1999) ganhou peso, porque a leitura da RQ1 mudou de sentido e os intervalos atuais são só descritivos.
- Extensões metodológicas registradas como limitação: inferência de dois estágios para painel (I07); bootstrap de Malmquist de Simar e Wilson (1999) para propagar a incerteza das fronteiras aos intervalos de M, TC e EC (R11); validação da referência `rDEA::rts.test` em cenários com dependência temporal e sua execução na base real (R08); cobertura da agregação temporal do IC do ranking (R07); teste de separabilidade (Daraio, Simar e Wilson, 2018); limites alternativos de piso por fonte (I01).

### Aberto — trabalho analítico da versão artigo (sem dados novos)

5. SFA por canal e classes latentes: feitos em S02 (`artigo/15`). Extensões opcionais: painel com determinantes da ineficiência (Battese e Coelli, 1995), defasagem de dois anos do investimento e modelos com heterogeneidade separada da ineficiência (Greene, 2005). Teste de separabilidade formal (`npsf`); Malmquist com soma móvel de 3 anos; matriz de robustez consolidada (estimador × defasagem × qualidade × fonte × insumo público × padronização, S01) em uma tabela única.
6. Rascunho do manuscrito em português: feito em 04/10/2026 (`artigo/20`). A metodologia ficou na seção 4 do manuscrito, sem um `artigo/04` separado. As pendências antes da submissão estão nas notas de trabalho, no topo do arquivo:
   - periódico e língua;
   - decisões com o professor (zeros, regra dos três anos, base industrial);
   - técnicas do programa que faltam (folgas, fusões, TOPSIS, separabilidade);
   - autoria e declarações.

## 7. Como retomar rapidamente

```bash
cd /Users/fernando/Projects/ai-efficiency-analysis
cat output/status_execucao.txt                 # status por etapa da última execução
zsh output/rodar_pipeline.sh faseA             # só a Fase A (02 -> 03 -> 04)
zsh output/rodar_pipeline.sh tudo              # tudo: Fase A, painel e variantes, 05, RTS, validação (~1h30)
zsh output/rodar_pipeline.sh sfa               # SFA por canal nas seis bases (S02, ~45 min)
zsh output/rodar_pipeline.sh estagio2          # só o segundo estágio e as figuras (03 -> 04) nas seis bases (~25 min)
zsh output/rodar_pipeline.sh cadeias           # 02 -> 03 -> 04 nas seis bases, sem o 05 (~30 min)
STATUS_ARQUIVO=output/status_execucao_sfa.txt zsh output/rodar_pipeline.sh sfa  # SFA em paralelo a outro modo
PADRONIZACAO=minmax zsh output/rodar_pipeline.sh tudo  # versão min-max (S01) + comparação 05b (~20 min)
cat output/status_execucao_minmax.txt          # status da versão min-max
tail -5 output/tables/manifesto_execucoes.csv  # execuções registradas (id, base, MD5, status)
```

## 8. Histórico de rodadas (o que cada uma mudou)

| Data | Rodada | Registro | Mudanças de substância |
|---|---|---|---|
| 27/09/2026 | Construção: hipóteses, dados, pipeline Fase A e painel, variantes | `artigo/01`–`06`; commit `ae6c878` | resultados iniciais (superados) |
| 27/09/2026 | Análise crítica 1 (`artigo/09`) → resposta (`artigo/10`); commit `c3b78ff` | 24 itens, 22 verdadeiros + 2 em parte | piso pelo insumo usado; RTS com observações originais contra a pseudofronteira e validação; IC do ranking por réplicas; N efetivo; covariância no Malmquist; H3b redefinida; decomposição amostra × especificação; rótulos e manifesto |
| 27/09/2026 | Brief do deck, revisão 2; commit `91ee83c` | `artigo/08` | roteiro de edição do deck página a página |
| 28/09/2026 | Análise crítica 2 (`artigo/11`) → resposta (`artigo/12`) | 15 itens, 12 verdadeiros + 3 em parte | convergência verificada nas truncadas; especificação principal sobre log(escore); RTS alinhado ao `rDEA` e validado nas duas implementações (tamanho ≈ 0,20; nenhum p < 0,05 nas bases); ranking por pseudo-valores, postos e contrastes; amostra e fronteira comuns nas comparações; β-convergência com a fronteira do painel balanceado; testes por grupo identificados; dois alvos em H3b; intervalos do Malmquist rotulados; semente no processo filho; runner único com propagação de falhas e manifesto de saídas; nove divergências documentais |
| 28/09/2026 | Apresentação em aula e comentários do Prof. Peter Wanke (transcrição) | `artigo/13` | pendências S01–S10: padronização min-max das variáveis da fronteira e reexecução; SFA em variáveis reescalonadas; menos hipóteses e RQs; discussão de H1, do ranking, do Malmquist por país e da heterogeneidade por renda com evidência contemporânea; níveis de evidência no segundo estágio e dimensões do WGI; literatura por hipótese e periódico-alvo (CEJOR) |
| 04/10/2026 | S01: padronização min-max das variáveis da fronteira e reexecução completa | `artigo/14` | variante `_minmax` em todo o pipeline (`R/02`, `02b`, `03`, `04`, `05`) e comparação `R/05b`; escala pura sem efeito (até 4 × 10⁻¹²); a min-max muda os resultados por translação e desloca a origem (H1 e Malmquist sem leitura); resistem a base do ranking, H3b e o sinal de H5 e H7; não resistem o topo do ranking, H6, a força de H3a e as inversões da metafronteira nas variantes; modo padrão conferido contra as tabelas versionadas (linhas de H6 em Farrell da Fase A regravadas, coerentes com o código) |
| 04/10/2026 | S02: fronteira estocástica por canal em log | `artigo/15` | `R/06_sfa_canais.R` e modo `sfa` do runner (seis bases; bootstrap em blocos de país, paralelo e reproduzível); H2 não se confirma (2 de 18 combinações; sem apoio no painel nem com P&D público); elasticidade do P&D robusta (0,59–0,70 em publicações, 0,94–1,41 em patentes); retornos decrescentes em publicações e crescentes em patentes; ineficiência não identificada no corte agrupado de publicações; classes latentes identificadas em 4 de 12 ajustes |
| 04/10/2026 | S06, S07 e S08: acréscimos leves | `artigo/16` | `R/03` com p-valor bootstrap, IC 90%, sinal previsto e nível de evidência (truncada, Tobit e algoritmo 2) e H5 com as outras dimensões do WGI; `R/04` com Malmquist por país, dispersão por renda e ano com testes de tendência e fig4 por nível de evidência; modo `estagio2` do runner; efetividade com sinal contrário robusto e igual em todo o WGI; tese do platô em parte; dispersão sem tendência; linhas de Farrell sem convergência regravadas em três variantes |
| 04/10/2026 | S03: decisão do autor (opção B) | `artigo/01` | três hipóteses (H1–H3) e duas perguntas de pesquisa (RQ1 dinâmica; RQ2 determinantes com expectativas E5–E7); `artigo/01` reescrito; síntese do `artigo/05` e notas no `artigo/06` e no `artigo/13` |
| 04/10/2026 | S01: decisão do autor e comparativo atualizado | `artigo/14` | especificação principal em unidades originais e min-max como robustez (R4); segundo estágio min-max refeito com níveis de evidência e dimensões do WGI (64 de 105 coeficientes com o mesmo nível; robustos: instituições e PIB per capita em patentes; não robustos: pesquisadores e crédito); `R/05b` compara níveis de evidência e WGI |
| 04/10/2026 | Análise crítica 3 (`artigo/17`) → resposta (`artigo/18`) | 15 achados, 15 verdadeiros (12 com a sugestão do revisor, 3 adaptados) | **Malmquist com sentido invertido desde o início** (o `Benchmarking` devolve, na orientação a produto, índices em que menor que 1 é melhora): a fronteira avança e a maioria dos países se afasta dela, o oposto do que se lia; "na fronteira em todos os anos" pelos escores CRS de todos os anos; H2 pela especificidade relativa com direção, só com ajuste válido; reinício do `frontier` (o descarte de réplicas com código 5 não era neutro); retornos do SFA com IC por país; amostra do conjunto preservada (inventor: 154 casos); bloco WGI com uma só cópia (Fase A: efetividade do cache significativa a 5%); checagem de patentes sem a Índia quebrada (ρ 0,76); dispersão com bootstrap de países e IQR relativo; ε minúsculo na sensibilidade; manifesto com figuras e entradas; errata do deck. Reexecução: cadeias 02 → 03 → 04 nas seis bases (originais e min-max), SFA, `R/12` e `R/05b` |
| 04/10/2026 | Memória × documentação: orientações dos laboratórios e convenções | `artigo/19`; seção 1a deste registro; README | orientações dos laboratórios de 14 e 21/09 (repositório anterior `investimentos_ia`) trazidas para cá, com a situação de cada uma; conflito "zero é zero" × exclusão dos zeros registrado como decisão pendente; técnicas do programa que faltam (fusões, TOPSIS, folgas); Fukuyama, Tan e Wanke (2025) nas referências; convenções de trabalho e ambiente (R 4.5.2, versões dos pacotes) documentados |
| 04/10/2026 | Brief do deck, revisão 5; commit `f628249` | `artigo/08` | deck novo de 21 slides com a estrutura do S03, os resultados de S01, S02 e S06–S08 e as correções da análise crítica 3, a exportar em .pptx e PDF; errata do deck de 28/09 na seção 2; quatro arredondamentos duplos corrigidos nos documentos 05, 06, 14, 15 e 16 |
| 04/10/2026 | Rascunho do manuscrito | `artigo/20`; `R/07_tabelas_manuscrito.R` | manuscrito em português, com o painel como base principal e a base original como replicação; tabelas descritivas novas (`manuscrito_descritiva_painel`, `manuscrito_medianas_ano_painel`); 23 referências conferidas em fonte primária (título de Cullmann et al., 2012, corrigido no `artigo/01`); o M1 deixa de ser chamado de replicação de Ernst e Mishra (2021), que usam outros insumos e produtos (`artigo/05` e `artigo/08`); faixa das elasticidades significativas do investimento corrigida no `artigo/15` (0,01 a 0,21) |
