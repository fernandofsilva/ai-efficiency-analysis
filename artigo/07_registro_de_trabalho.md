# Registro de trabalho e guia de retomada (estado em 04/10/2026, após S01 e S02)

Documento de transferência: tudo o que foi feito, decidido e ficou pendente, para retomar o trabalho em nova sessão sem depender do histórico da conversa. Plano aprovado em `~/.claude/plans/esse-um-trabalho-cheerful-squirrel.md`.

## 1. Contexto e decisões do usuário

- Disciplina *Introdução à Análise de Eficiência em R* (Prof. Peter Wanke). Entregas: apresentação de diagnóstico em 28/09/2026 (dataset original) e manuscrito em português para periódico Qualis (painel reconstruído).
- Decisões: modelo principal conjunto (publicações + patentes) com modelos por canal; tudo em português; painel reconstruído (CSET + World Bank) substitui o dataset original na versão artigo; scripts R no estilo Google (BigCamelCase, `return()` explícito, `pkg::fun`, 80 colunas); todas as bases dentro de `data/`, uma subpasta por fonte; documentos em `artigo/` (o `.gitignore` ignora `docs/`).
- Commits em `main` e `origin/main` (sincronizados em 28/09/2026): `ae6c878` (pipeline e resultados), `c3b78ff` (resposta à análise crítica, `artigo/10`), `3b0799b` (cabeçalho de `R/05`), `91ee83c` (revisão 2 do brief), `f188559` (resposta à reanálise crítica, `artigo/11` → `artigo/12`, código e reexecução). Em 04/10/2026, só em `main` local (sem push): `c780f89` (deck da apresentação e `artigo/13`).
- Apresentação em aula feita em 28/09/2026. Os comentários do Prof. Peter Wanke e as pendências decorrentes (S01–S10) estão em `artigo/13_comentarios_apresentacao.md`; a ordem de execução acordada está na seção 6 abaixo.

## 2. Estrutura do repositório

- `data/AI_INVESTMENT.csv` — dataset original (208 país-ano, 37 países, 2013–2021). Proveniência verificada: CSET via Our World in Data (investimento em US$ constantes de 2021; publicações em contagem; patentes **por milhão de habitantes**) + World Bank WDI/WGI/GFDD.
- `data/cat/` — CSET Country AI Activity Metrics v1.12.0 (Zenodo 22772306), 2016–2026, campo `field == "All"`, coluna `complete` (artigos completos até 2024, pedidos de patente até 2021, concedidas até 2019, investimento em milhões de US$ nominais). Índia: patentes quebradas a partir de 2019 (tratadas como NA).
- `data/wdi/`, `data/wgi/` — World Bank (API v2, cache por indicador; WGI com códigos novos `GOV_WGI_*`, fonte 3). `data/ai_index/` — dados públicos do AI Index 2025 (CSVs por figura). `data/oecd-ai/` — export manual de publicações (`data.csv`), patentes de IA por país do inventor via API SDMX (`patentes_ia_ip5_inventor.csv`, `patentes_ia_triadicas_inventor.csv`) e export manual do VC da Preqin (`vc_investimentos_pais_ano.csv`). `data/msti/` — HERD/GOVERD (MSTI + Eurostat). `data/top500/` — parcial.
- `data/processed/` — `base_atual.csv` (Fase A), `cset_long.csv`, `ai_index_pais_ano.csv`, `ai_index_transversal.csv`, `oecd_ai_publicacoes.csv`, `oecd_ai_patentes.csv`, `painel_ia.csv` (47 países, 2016–2024). Inventário completo em `data/README.md`; codebook em `artigo/03_codebook.md`.
- `R/` — `00_setup.R` (pacotes, opções, pastas, `source("R/funcoes.R")`), `funcoes.R` (World Bank, DEA, bootstrap, Spearman com IC, interpolação), `01_prep_dataset_atual.R`, `02_fronteiras_dataset_atual.R`, `02b_teste_rts.R`, `03_segundo_estagio_dataset_atual.R`, `04_figuras_apresentacao.R`, `10_download_wdi.R`, `11_import_cset.R`, `12_import_fontes_alternativas.R`, `13_build_painel.R`, `14_download_oecd_patentes.R`.
- Scripts 02/02b/03/04 são parametrizados por variáveis de ambiente: `BASE_ARQUIVO` (padrão `data/processed/base_atual.csv`), `SUFIXO_SAIDA` (`""`, `_painel`, `_painel_qualidade`, `_painel_fonte`, `_painel_preqin`, `_painel_publico`), `INSUMOS` (`investimento,gerd`; `investimento_l1,gerd_l1`; `investimento_preqin_l1,gerd_l1`; `investimento_l1,pd_publico_l1`), `PRODUTOS` (`publicacoes,patentes`; `citacoes_ok,patentes_concedidas_ok`; `publicacoes,patentes_inventor`), `JANELA_MALMQUIST` (`2016,2019`; `2017,2021`; `2017,2019`), `N_REP_RTS`, `LIMITE_SW_SEG`. Runner único: `output/rodar_pipeline.sh` (modos `faseA`, `painel`, `variantes`, `rts`, `validacao`, `tudo`), com status por etapa em `output/status_execucao.txt`, interrupção da cadeia dependente em caso de falha e código de saída igual ao número de falhas; manifesto de execuções e de saídas (MD5) em `output/tables/manifesto_execucoes.csv` e `manifesto_saidas.csv`. `PADRONIZACAO` (`nenhuma` ou `minmax`) e `EPSILON_PADRONIZACAO` (padrão 0,01) valem também para o `05`; com min-max, as saídas ganham o sufixo `_minmax` (ver `artigo/14`).
- `output/tables/` (~100 CSVs) e `output/figures/` (fig1–fig7 por variante, fig8 investimento CSET × Quid, fig9 patentes CSET × OCDE, fig10 investimento CSET × Preqin, fig11 ranking com e sem padronização). Logs em `output/log_*.txt`.
- `artigo/` — `01_hipoteses.md`, `02_dados_externos.md` (inclui seção 5a: como obter patentes por inventor e VC), `03_codebook.md`, `05_resultados_fase_a.md`, `06_resultados_painel.md`, este registro, `08_brief_deck.md` (brief do deck, revisão 3), `09`/`10` (análise crítica 1 e resposta), `11`/`12` (reanálise crítica e resposta), `13_comentarios_apresentacao.md` (comentários do professor na apresentação de 28/09/2026 e pendências S01–S10), `14_padronizacao_minmax.md` (S01: padronização min-max, reexecução e comparação).

## 3. Pipeline (por variante)

1. `01` prepara o dataset original (renda harmonizada, patentes em contagem via população WDI, GERD = P&D% × PIB, flags `inv_zero` e `inv_piso`).
2. `02`: outliers (`outlier.ap`, `sdea`), DEA CRS/VRS/NIRS por ano com eficiência de escala e classificação de RTS, bootstrap de Simar-Wilson (`dea.boot`, 1.000 réplicas), FDH/order-m/order-α (`nonparaeff`, `frontiles`; frontiles devolve escores ≤ 1 = ineficiente, sem inversão), canais (DMUs com produto zero excluídas), metafronteira por grupo de renda (agrupada), Malmquist CRS no painel balanceado, bloco de sensibilidade sem valores-piso.
3. `02b`: teste de RTS de Simar-Wilson (2002) implementado sobre `Benchmarking` com a mesma construção da referência `rDEA::rts.test` (estatística 4.6, banda de Silverman `bw.nrd0` na amostra original, arredondamento em 1, p-valor (k+1)/(B+1)); tempo máximo por LP (`CONTROL = list(timeout = 10)`). O tamanho do teste é cerca de 0,20 sob CRS verdadeiro nas duas implementações (`R/02c`, `validacao_teste_rts.csv`): os p-valores são diagnósticos exploratórios. A referência na base real (banda de Silverman) não concluiu em tempo útil; com validação cruzada, não concluía em mais de uma hora.
4. `03`: bootstrap dos canais; regressão truncada sobre log(escore corrigido) (em (−∞, 0), truncada em 0; especificação principal, compatível com o suporte) com escores fixos e bootstrap agrupado por país (300 réplicas), convergência verificada em cada ajuste (`AjustarTruncada` em `R/funcoes.R`; réplicas tentadas × convergentes na tabela); parametrizações em escore truncado só em 1 e em Farrell como comparação; H5 (com e sem piso, com pesquisadores, com talento em IA), H6 (canal patentes), H7 (PIB per capita por canal); Tobit comparativo; Simar-Wilson algoritmo 2 do rDEA em processo filho com timeout e semente fixada no filho; Kruskal-Wallis (3 grupos) e Mann-Whitney (2 grupos) por renda, em país-ano e em médias por país; associação descritiva Z × escore.
5. `04`: figuras 1–7 (com `ggrepel`).
5a. `05b` (só com `PADRONIZACAO=minmax`): compara cada execução com a versão em unidades originais (escores, RTS, ranking, canais, metafronteira, Malmquist, teste de RTS, segundo estágio, `R/05`) e mede a sensibilidade a ε e a invariância à escala pura (`sensibilidade_padronizacao_epsilon.csv`; fig11).
5b. `06`: SFA por canal em log (S02/H2), nas seis bases; Cobb-Douglas meia-normal agrupada (principal), exponencial, translog centrada e painel (Battese e Coelli, 1988 e 1992); bootstrap em blocos de país (300 réplicas) com os dois canais no mesmo sorteio, o que dá o IC da diferença entre as elasticidades do investimento; diagnósticos de assimetria, colinearidade, convergência e tempo. Pulado com `PADRONIZACAO=minmax` (o log já remove a escala).
6. Fase B: `10` → `11` → `14` → `12` → `13` → 02/03/04 com variáveis de ambiente.

## 4. Resultados principais

Os resultados vigentes estão em `artigo/05_resultados_fase_a.md` (Fase A) e `artigo/06_resultados_painel.md` (painel e variantes), regenerados a partir das tabelas da reexecução de 28/09/2026 após a reanálise crítica (`artigo/11` → `artigo/12`). Este registro não duplica números: as duas rodadas de crítica (`artigo/09`/`10` em 27/09 e `artigo/11`/`12` em 28/09) mudaram procedimentos e valores, e as versões anteriores desta seção descreviam estados já superados (teste de RTS antes da correção, IC do ranking pela média dos limites, segundo estágio em escore truncado só em 1). O que cada rodada mudou de substância está nas seções finais de `artigo/10` e `artigo/12`.

## 5. Problemas encontrados e como foram resolvidos

- `rDEA` (rts.test e dea.env.robust) extremamente lento ou travando: substituído por implementação própria (02b) e envolto em processo filho com timeout (03).
- `frontiles` retorna escores orientados a produto ≤ 1 (ineficiente) — não inverter; `nonparaeff::fdh` é Farrell ≥ 1 — inverter. Verificado com dados sintéticos.
- Supereficiência inviável (Peru 2021) → NA. Zeros de investimento (17 no original) excluídos; valores-piso (≤ 2,5 M) testados em bloco de sensibilidade.
- `pkill` mata só o front-end `Rscript`; o back-end `exec/R` continua — sempre matar pelo PID de `exec/R`.
- Zenodo bloqueia scripts (403): CSET baixado manualmente em `data/cat/`. World Bank API mudou códigos do WGI.
- AI Index não traz investimento por país-ano (só China/Europa/EUA); usado como corte transversal (Quid) e painel de talento (LinkedIn).
- `summarise` do dplyr sobrescrevendo nomes usados nas expressões seguintes (cobertura do painel) — corrigido com nomes distintos.
- Dois processos `exec/R` sem `--file` que aparecem no `pgrep` são do VS Code, não do projeto.
- Rodada de 28/09 (`artigo/12`): `truncreg` devolve coeficientes mesmo sem convergência (`est.stat$message = "iteration limit exceeded"`) — verificar sempre; a truncada em Farrell é degenerada nos canais (sigma explode) e a normal truncada em 0 e 1 não tem máximo finito quando os escores se acumulam perto de zero — a truncada sobre log(escore) resolve os dois problemas; `parallel::mcparallel` reinicializa o gerador do filho pelo PID e horário — fixar a semente dentro do filho; a largura de banda do teste de RTS calculada na amostra refletida subsuavizava em amostras grandes — usar `bw.nrd0` na amostra original, como o rDEA; `rDEA::rts.test` roda em segundos em amostras simuladas (banda de Silverman), mas não conclui na base real; réplicas de `dea.boot` invertidas para a escala de escore explodem quando F* < 1 — usar pseudo-valores 2F̂ − F*; o texto do PDF do deck é vetorial (extração de texto devolve vazio; usar renderização por página para conferir); rótulos de modelo com vírgula quebram `cut` nos CSVs — usar leitor de CSV.

## 6. Pendências (estado em 04/10/2026, após S01 e S02)

### Concluído (não requer ação)

- Fase A completa: scripts `R/01`–`R/04`, `R/02b`, `R/02c`, figuras, `artigo/05`.
- Fase B, dados: World Bank/WGI (`R/10`), CSET (`R/11`), AI Index e OECD.AI (`R/12`), patentes por inventor OCDE (`R/14`), MSTI + Eurostat (`R/15`), painel de 47 países (`R/13`), codebook.
- Fase B, análises: painel em volume (`_painel`), qualidade (`_painel_qualidade`), patentes por inventor (`_painel_fonte`), VC Preqin (`_painel_preqin`), P&D público (`_painel_publico`, 41 países com MSTI + Eurostat, resumido na seção 9c do `artigo/06`); testes de RTS no dataset original e no painel; checagens entre fornecedores (investimento Quid e Preqin, publicações OECD.AI, patentes OCDE); talento em IA como Z.
- Documentação: `artigo/01`, `02` (com seções 5a e 6a de acesso às fontes), `03`, `05`, `06`, `07`; `data/README.md`; `README.md`.

### Aberto — depende do usuário

1. **Apresentação de 28/09**: feita. O deck `AI Effiency Analysis.pdf` (raiz) foi modificado em 28/09/2026 às 19:30, depois do último commit (20 páginas; a versão commitada, da revisão 1 do brief, tinha 19), e foi commitado em 04/10/2026 junto com o registro dos comentários; tem as sete figuras embutidas da revisão 3 de `artigo/08_brief_deck.md` (conferência dos números página a página não feita: o texto do PDF não é extraível sem poppler). Os comentários recebidos na apresentação estão em `artigo/13` e geram as pendências S01–S10 abaixo; para uma nova versão do deck ou para o relatório final, aplicar também S05 (legibilidade da fig1), S06 (decomposição do Malmquist por país no slide 11) e S07 (níveis de evidência no slide 12).
2. **Commits**: a resposta à reanálise crítica (código, saídas regeneradas, `artigo/01`, `05`, `06`, `07`, `08`, `10`, `11`, `12`, runner único) foi commitada e integrada em `main` em 28/09/2026 (`f188559`). O deck modificado (item 1) e o registro dos comentários da apresentação (`artigo/13`, este arquivo, `README.md`, `artigo/06`) foram commitados em 04/10/2026 (`c780f89`). A implementação e a reexecução de S01 (código, saídas `_minmax`, `artigo/14`) estão prontas para commit.
3. **Top500** (opcional, baixa prioridade): o site bloqueou os downloads por taxa; rerodar `Rscript R/16_download_top500.R` mais tarde ou baixar as planilhas manualmente para `data/top500/` e rodar o script para agregar. Depois, usar `top500_sistemas` como Z no segundo estágio.
4. **P&D público dos seis países sem fonte** (opcional): Brasil, Índia, Malásia, Filipinas, Arábia Saudita, Ucrânia só por fontes nacionais (RICYT, DST, MASTIC), manualmente. O UIS não publica mais a abertura por setor. Sem isso, esses países ficam fora apenas da variante `_painel_publico`.

### Aberto — sugestões do Prof. Peter Wanke na apresentação de 28/09/2026 (detalhes, estado atual e ações em `artigo/13_comentarios_apresentacao.md`)

- **S01 Padronização das variáveis da fronteira (min-max) e reexecução** [executado em 04/10/2026; resta uma decisão]: variante `PADRONIZACAO=minmax` (ε = 0,01, mín e máx da amostra completa, insumo mantido como insumo, mesma amostra) em todo o pipeline; comparação em `R/05b`; resultados em `artigo/14_padronizacao_minmax.md`.
  - A mudança de escala pura reproduz tudo (diferença menor que 4 × 10⁻¹²).
  - A min-max muda os resultados por translação e desloca a origem; por isso retornos de escala (H1) e Malmquist CRS (H4) não podem ser checados por ela.
  - Resistem: a base do ranking (Israel; Suíça e Noruega), H3b sem apoio e o sinal de H5 e de H7.
  - Não resistem: o topo do ranking, H6, a força de H3a, a inversão da metafronteira nas variantes e a diferença de coeficientes entre qualidade e base.
  - **Decisão pendente do autor, com o professor:** especificação principal. A recomendação do `artigo/14`, seção 7, é manter as unidades originais e apresentar a min-max como robustez dos resultados VRS. Depois da decisão, levar a tabela de robustez ao `artigo/05`, ao `artigo/06` e ao deck.
- **S02 SFA de H2** [executado em 04/10/2026]: `R/06_sfa_canais.R` nas seis bases (modo `sfa` do runner); resultados em `artigo/15_sfa_canais.md`.
  - Em log, cada ajuste converge em menos de meio segundo.
  - H2 não se confirma: critério estrito em 2 de 18 combinações; sem apoio na base do artigo nem com o P&D público.
  - O P&D domina nos dois canais, com retornos decrescentes em publicações e crescentes em patentes.
  - No corte agrupado, a ineficiência não é identificada em publicações.
  - As classes latentes ficam identificadas em 4 de 12 ajustes.
  - O status de H2 passa para a decisão do S03.
- **S03 Menos hipóteses; hipótese × pergunta de pesquisa** [alta, antes de escrever]: manter como hipóteses o que tem ancoragem (sugestão: H1, H3, H4 e H2 se o SFA convergir) e converter H5–H7 em RQs; ancorar cada hipótese na literatura ou em indução explícita; fechar cada uma na discussão (bateu, não bateu, por quê).
- **S04 Discussão de H1 por país** [média]: EUA, Japão e Reino Unido em DRS, China em CRS (não IRS, como dito na fala), Índia alternando; explicar com evidência contemporânea (platô japonês e britânico, desindustrialização e aposta em IA dos EUA, ascensão chinesa e indiana). Discutir em unidades originais: com min-max a origem muda e os retornos de escala perdem sentido; EUA, Reino Unido e China coincidem nas duas versões, o Japão não (`artigo/14`).
- **S05 Perfis do ranking** [média, liberado por S01]: três do topo e três ou quatro da base (países "nichados"), com fontes; aumentar a legibilidade da fig1. Pela robustez à padronização (`artigo/14`, seção 4), os candidatos mais estáveis são Itália, Grécia e Malásia no topo e Israel, Suíça e Noruega na base; Irlanda e África do Sul só ficam na base na versão original.
- **S06 Malmquist por país: frontier shift × catch-up** [média]: a decomposição já existe (`malmquist_m2.csv`, fig2), mas o slide e a fala destacaram o índice agregado; tabela por país em `artigo/05` e no deck (China e Índia só se movem com a fronteira; Brasil ganha por catch-up com fronteira parada); discutir a tese do platô; citar Moraes e Wanke (2019, *Cadernos EBAPE.BR*, 17(2)) com o achado correto (BNDES com efeito negativo no catch-up na siderurgia). A decomposição por país é sensível à especificação (Spearman do índice por país entre unidades originais e min-max de 0,33 a 0,42): ler em unidades originais e registrar a fragilidade.
- **S07 Segundo estágio: dois níveis de evidência e o que mede a efetividade governamental** [média]: acrescentar p-valor bootstrap, IC 90% e coluna de sinal previsto; classificar em significativo / "bateu na trave" (5–10%) / sinal confirmado / sinal contrário; descrever o WGI-GE e testar qualidade regulatória e estado de direito (já em `data/wgi/` e no painel) como Z alternativos.
- **S08 Heterogeneidade por grupo de renda e ano** [média]: a "abertura" de 2018 na renda média-baixa é a entrada das Filipinas; a dispersão da renda média-alta cresce (DP 0,15 em 2013 → 0,27–0,34 em 2016–2020, escore VRS), a alta renda não; tabela de dispersão com escore corrigido, teste de tendência e discussão (China descolada; Indonésia, Malásia, Peru; México; Ucrânia pré-guerra); rever a nota do slide 13.
- **S09 Literatura, evidência contemporânea e periódico-alvo** [média]: revisão por hipótese (Wang e Huang, 2007; Sharma e Thomas, 2008; Guan e Chen, 2012; Cullmann et al., 2012, a verificar); dossiê de evidência por país com fontes datadas; CEJOR como candidato (Holý e Šafr, 2018, saiu lá); decisão do usuário sobre seguir para artigo.
- **S10 Ordem acordada**: S01 → S02 → acréscimos leves (S07, S06, S08) → S03 → discussões (S04–S08 com S09) → relatório final e manuscrito.

### Aberto — decorrentes da análise crítica

- Reexportar o deck com as figuras regeneradas (I05/P01); roteiro de alterações em `artigo/08`, seção 2.
- Resolvidos na rodada de 28/09 (`artigo/12`): semente do algoritmo 2 no processo filho (P02); incerteza de postos e contrastes no ranking (I04/R07); manifesto de saídas com MD5 (I22/R13); comparação do teste de RTS com o `rDEA` em simulação e alinhamento da rotina (I09/R08); convergência das truncadas (R01) e especificação compatível com o suporte (I08/R09, truncada sobre log(escore)); fronteira comum nas comparações (R02/R03); eficiência inicial da β-convergência (R04); rótulos dos testes por grupo (R06); alvos de H3b (R10); runner com propagação de falhas (R13).
- Extensões metodológicas registradas como limitação: inferência de dois estágios para painel (I07); bootstrap de Malmquist de Simar e Wilson (1999) para propagar a incerteza das fronteiras aos intervalos de M, TC e EC (R11); validação da referência `rDEA::rts.test` em cenários com dependência temporal e sua execução na base real (R08); cobertura da agregação temporal do IC do ranking (R07); teste de separabilidade (Daraio, Simar e Wilson, 2018); limites alternativos de piso por fonte (I01).

### Aberto — trabalho analítico da versão artigo (sem dados novos)

5. SFA por canal e classes latentes: feitos em S02 (`artigo/15`). Extensões opcionais: painel com determinantes da ineficiência (Battese e Coelli, 1995), defasagem de dois anos do investimento e modelos com heterogeneidade separada da ineficiência (Greene, 2005). Teste de separabilidade formal (`npsf`); Malmquist com soma móvel de 3 anos; matriz de robustez consolidada (estimador × defasagem × qualidade × fonte × insumo público × padronização, S01) em uma tabela única.
6. `artigo/04_metodologia.md` e rascunho do manuscrito em português (introdução, dados, método, resultados, discussão), usando `artigo/01`, `02`, `05`, `06`.

## 7. Como retomar rapidamente

```bash
cd /Users/fernando/Projects/ai-efficiency-analysis
cat output/status_execucao.txt                 # status por etapa da última execução
zsh output/rodar_pipeline.sh faseA             # só a Fase A (02 -> 03 -> 04)
zsh output/rodar_pipeline.sh tudo              # tudo: Fase A, painel e variantes, 05, RTS, validação (~1h30)
zsh output/rodar_pipeline.sh sfa               # SFA por canal nas seis bases (S02, ~45 min)
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
