# Registro de trabalho e guia de retomada (estado em 28/09/2026, após a reanálise crítica)

Documento de transferência: tudo o que foi feito, decidido e ficou pendente, para retomar o trabalho em nova sessão sem depender do histórico da conversa. Plano aprovado em `~/.claude/plans/esse-um-trabalho-cheerful-squirrel.md`.

## 1. Contexto e decisões do usuário

- Disciplina *Introdução à Análise de Eficiência em R* (Prof. Peter Wanke). Entregas: apresentação de diagnóstico em 28/09/2026 (dataset original) e manuscrito em português para periódico Qualis (painel reconstruído).
- Decisões: modelo principal conjunto (publicações + patentes) com modelos por canal; tudo em português; painel reconstruído (CSET + World Bank) substitui o dataset original na versão artigo; scripts R no estilo Google (BigCamelCase, `return()` explícito, `pkg::fun`, 80 colunas); todas as bases dentro de `data/`, uma subpasta por fonte; documentos em `artigo/` (o `.gitignore` ignora `docs/`).
- Commits em `main` e `origin/main`: `ae6c878` (pipeline e resultados), `c3b78ff` (resposta à análise crítica, `artigo/10`), `3b0799b` (cabeçalho de `R/05`), `91ee83c` (revisão 2 do brief). A resposta à reanálise crítica de 28/09 (`artigo/11` → `artigo/12`, código e reexecução) ainda não foi commitada no momento desta escrita; conferir com `git status`.

## 2. Estrutura do repositório

- `data/AI_INVESTMENT.csv` — dataset original (208 país-ano, 37 países, 2013–2021). Proveniência verificada: CSET via Our World in Data (investimento em US$ constantes de 2021; publicações em contagem; patentes **por milhão de habitantes**) + World Bank WDI/WGI/GFDD.
- `data/cat/` — CSET Country AI Activity Metrics v1.12.0 (Zenodo 22772306), 2016–2026, campo `field == "All"`, coluna `complete` (artigos completos até 2024, pedidos de patente até 2021, concedidas até 2019, investimento em milhões de US$ nominais). Índia: patentes quebradas a partir de 2019 (tratadas como NA).
- `data/wdi/`, `data/wgi/` — World Bank (API v2, cache por indicador; WGI com códigos novos `GOV_WGI_*`, fonte 3). `data/ai_index/` — dados públicos do AI Index 2025 (CSVs por figura). `data/oecd-ai/` — export manual de publicações (`data.csv`), patentes de IA por país do inventor via API SDMX (`patentes_ia_ip5_inventor.csv`, `patentes_ia_triadicas_inventor.csv`) e export manual do VC da Preqin (`vc_investimentos_pais_ano.csv`). `data/msti/` — HERD/GOVERD (MSTI + Eurostat). `data/top500/` — parcial.
- `data/processed/` — `base_atual.csv` (Fase A), `cset_long.csv`, `ai_index_pais_ano.csv`, `ai_index_transversal.csv`, `oecd_ai_publicacoes.csv`, `oecd_ai_patentes.csv`, `painel_ia.csv` (47 países, 2016–2024). Inventário completo em `data/README.md`; codebook em `artigo/03_codebook.md`.
- `R/` — `00_setup.R` (pacotes, opções, pastas, `source("R/funcoes.R")`), `funcoes.R` (World Bank, DEA, bootstrap, Spearman com IC, interpolação), `01_prep_dataset_atual.R`, `02_fronteiras_dataset_atual.R`, `02b_teste_rts.R`, `03_segundo_estagio_dataset_atual.R`, `04_figuras_apresentacao.R`, `10_download_wdi.R`, `11_import_cset.R`, `12_import_fontes_alternativas.R`, `13_build_painel.R`, `14_download_oecd_patentes.R`.
- Scripts 02/02b/03/04 são parametrizados por variáveis de ambiente: `BASE_ARQUIVO` (padrão `data/processed/base_atual.csv`), `SUFIXO_SAIDA` (`""`, `_painel`, `_painel_qualidade`, `_painel_fonte`, `_painel_preqin`, `_painel_publico`), `INSUMOS` (`investimento,gerd`; `investimento_l1,gerd_l1`; `investimento_preqin_l1,gerd_l1`; `investimento_l1,pd_publico_l1`), `PRODUTOS` (`publicacoes,patentes`; `citacoes_ok,patentes_concedidas_ok`; `publicacoes,patentes_inventor`), `JANELA_MALMQUIST` (`2016,2019`; `2017,2021`; `2017,2019`), `N_REP_RTS`, `LIMITE_SW_SEG`. Runner único: `output/rodar_pipeline.sh` (modos `faseA`, `painel`, `variantes`, `rts`, `validacao`, `tudo`), com status por etapa em `output/status_execucao.txt`, interrupção da cadeia dependente em caso de falha e código de saída igual ao número de falhas; manifesto de execuções e de saídas (MD5) em `output/tables/manifesto_execucoes.csv` e `manifesto_saidas.csv`.
- `output/tables/` (~100 CSVs) e `output/figures/` (fig1–fig7 por variante, fig8 investimento CSET × Quid, fig9 patentes CSET × OCDE). Logs em `output/log_*.txt`.
- `artigo/` — `01_hipoteses.md`, `02_dados_externos.md` (inclui seção 5a: como obter patentes por inventor e VC), `03_codebook.md`, `05_resultados_fase_a.md`, `06_resultados_painel.md`, este registro.

## 3. Pipeline (por variante)

1. `01` prepara o dataset original (renda harmonizada, patentes em contagem via população WDI, GERD = P&D% × PIB, flags `inv_zero` e `inv_piso`).
2. `02`: outliers (`outlier.ap`, `sdea`), DEA CRS/VRS/NIRS por ano com eficiência de escala e classificação de RTS, bootstrap de Simar-Wilson (`dea.boot`, 1.000 réplicas), FDH/order-m/order-α (`nonparaeff`, `frontiles`; frontiles devolve escores ≤ 1 = ineficiente, sem inversão), canais (DMUs com produto zero excluídas), metafronteira por grupo de renda (agrupada), Malmquist CRS no painel balanceado, bloco de sensibilidade sem valores-piso.
3. `02b`: teste de RTS de Simar-Wilson (2002) implementado sobre `Benchmarking` com a mesma construção da referência `rDEA::rts.test` (estatística 4.6, banda de Silverman `bw.nrd0` na amostra original, arredondamento em 1, p-valor (k+1)/(B+1)); tempo máximo por LP (`CONTROL = list(timeout = 10)`). O tamanho do teste é cerca de 0,20 sob CRS verdadeiro nas duas implementações (`R/02c`, `validacao_teste_rts.csv`): os p-valores são diagnósticos exploratórios. A referência na base real (banda de Silverman) não concluiu em tempo útil; com validação cruzada, não concluía em mais de uma hora.
4. `03`: bootstrap dos canais; regressão truncada sobre log(escore corrigido) (em (−∞, 0), truncada em 0; especificação principal, compatível com o suporte) com escores fixos e bootstrap agrupado por país (300 réplicas), convergência verificada em cada ajuste (`AjustarTruncada` em `R/funcoes.R`; réplicas tentadas × convergentes na tabela); parametrizações em escore truncado só em 1 e em Farrell como comparação; H5 (com e sem piso, com pesquisadores, com talento em IA), H6 (canal patentes), H7 (PIB per capita por canal); Tobit comparativo; Simar-Wilson algoritmo 2 do rDEA em processo filho com timeout e semente fixada no filho; Kruskal-Wallis (3 grupos) e Mann-Whitney (2 grupos) por renda, em país-ano e em médias por país; associação descritiva Z × escore.
5. `04`: figuras 1–7 (com `ggrepel`).
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

## 6. Pendências (estado em 28/09/2026, após a reanálise crítica)

### Concluído (não requer ação)

- Fase A completa: scripts `R/01`–`R/04`, `R/02b`, `R/02c`, figuras, `artigo/05`.
- Fase B, dados: World Bank/WGI (`R/10`), CSET (`R/11`), AI Index e OECD.AI (`R/12`), patentes por inventor OCDE (`R/14`), MSTI + Eurostat (`R/15`), painel de 47 países (`R/13`), codebook.
- Fase B, análises: painel em volume (`_painel`), qualidade (`_painel_qualidade`), patentes por inventor (`_painel_fonte`), VC Preqin (`_painel_preqin`), P&D público (`_painel_publico`, 41 países com MSTI + Eurostat, resumido na seção 9c do `artigo/06`); testes de RTS no dataset original e no painel; checagens entre fornecedores (investimento Quid e Preqin, publicações OECD.AI, patentes OCDE); talento em IA como Z.
- Documentação: `artigo/01`, `02` (com seções 5a e 6a de acesso às fontes), `03`, `05`, `06`, `07`; `data/README.md`; `README.md`.

### Aberto — depende do usuário

1. **Apresentação de 28/09**: o deck `AI Effiency Analysis.pdf` (raiz) foi gerado a partir da revisão 1 do brief e está desatualizado; atualizá-lo página a página conforme a seção 2 de `artigo/08_brief_deck.md` (revisão 3, com os números da reexecução de 28/09), embutindo as sete figuras (o PDF atual não contém nenhuma imagem), e reexportar. Nenhum cálculo pendente.
2. **Commits**: a resposta à reanálise crítica (código, saídas regeneradas, `artigo/01`, `05`, `06`, `07`, `08`, `10`, `11`, `12`, runner único) foi commitada e integrada em `main` em 28/09/2026 (ver `git log`). Próximos commits: atualização do deck e trabalho da versão artigo.
3. **Top500** (opcional, baixa prioridade): o site bloqueou os downloads por taxa; rerodar `Rscript R/16_download_top500.R` mais tarde ou baixar as planilhas manualmente para `data/top500/` e rodar o script para agregar. Depois, usar `top500_sistemas` como Z no segundo estágio.
4. **P&D público dos seis países sem fonte** (opcional): Brasil, Índia, Malásia, Filipinas, Arábia Saudita, Ucrânia só por fontes nacionais (RICYT, DST, MASTIC), manualmente. O UIS não publica mais a abertura por setor. Sem isso, esses países ficam fora apenas da variante `_painel_publico`.

### Aberto — decorrentes da análise crítica

- Reexportar o deck com as figuras regeneradas (I05/P01); roteiro de alterações em `artigo/08`, seção 2.
- Resolvidos na rodada de 28/09 (`artigo/12`): semente do algoritmo 2 no processo filho (P02); incerteza de postos e contrastes no ranking (I04/R07); manifesto de saídas com MD5 (I22/R13); comparação do teste de RTS com o `rDEA` em simulação e alinhamento da rotina (I09/R08); convergência das truncadas (R01) e especificação compatível com o suporte (I08/R09, truncada sobre log(escore)); fronteira comum nas comparações (R02/R03); eficiência inicial da β-convergência (R04); rótulos dos testes por grupo (R06); alvos de H3b (R10); runner com propagação de falhas (R13).
- Extensões metodológicas registradas como limitação: inferência de dois estágios para painel (I07); bootstrap de Malmquist de Simar e Wilson (1999) para propagar a incerteza das fronteiras aos intervalos de M, TC e EC (R11); validação da referência `rDEA::rts.test` em cenários com dependência temporal e sua execução na base real (R08); cobertura da agregação temporal do IC do ranking (R07); teste de separabilidade (Daraio, Simar e Wilson, 2018); limites alternativos de piso por fonte (I01).

### Aberto — trabalho analítico da versão artigo (sem dados novos)

5. SFA por canal com classes latentes (`frontier`, `sfaR`; H2), teste de separabilidade formal (`npsf`), Malmquist com soma móvel de 3 anos, matriz de robustez consolidada (estimador × defasagem × qualidade × fonte × insumo público) em uma tabela única.
6. `artigo/04_metodologia.md` e rascunho do manuscrito em português (introdução, dados, método, resultados, discussão), usando `artigo/01`, `02`, `05`, `06`.

## 7. Como retomar rapidamente

```bash
cd /Users/fernando/Projects/ai-efficiency-analysis
cat output/status_execucao.txt                 # status por etapa da última execução
zsh output/rodar_pipeline.sh faseA             # só a Fase A (02 -> 03 -> 04)
zsh output/rodar_pipeline.sh tudo              # tudo: Fase A, painel e variantes, 05, RTS, validação (~1 h)
tail -5 output/tables/manifesto_execucoes.csv  # execuções registradas (id, base, MD5, status)
```

## 8. Histórico de rodadas (o que cada uma mudou)

| Data | Rodada | Registro | Mudanças de substância |
|---|---|---|---|
| 27/09/2026 | Construção: hipóteses, dados, pipeline Fase A e painel, variantes | `artigo/01`–`06`; commit `ae6c878` | resultados iniciais (superados) |
| 27/09/2026 | Análise crítica 1 (`artigo/09`) → resposta (`artigo/10`); commit `c3b78ff` | 24 itens, 22 verdadeiros + 2 em parte | piso pelo insumo usado; RTS com observações originais contra a pseudofronteira e validação; IC do ranking por réplicas; N efetivo; covariância no Malmquist; H3b redefinida; decomposição amostra × especificação; rótulos e manifesto |
| 27/09/2026 | Brief do deck, revisão 2; commit `91ee83c` | `artigo/08` | roteiro de edição do deck página a página |
| 28/09/2026 | Análise crítica 2 (`artigo/11`) → resposta (`artigo/12`) | 15 itens, 12 verdadeiros + 3 em parte | convergência verificada nas truncadas; especificação principal sobre log(escore); RTS alinhado ao `rDEA` e validado nas duas implementações (tamanho ≈ 0,20; nenhum p < 0,05 nas bases); ranking por pseudo-valores, postos e contrastes; amostra e fronteira comuns nas comparações; β-convergência com a fronteira do painel balanceado; testes por grupo identificados; dois alvos em H3b; intervalos do Malmquist rotulados; semente no processo filho; runner único com propagação de falhas e manifesto de saídas; nove divergências documentais |
