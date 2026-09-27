# Registro de trabalho e guia de retomada (estado em 27/09/2026, ~15h10)

Documento de transferência: tudo o que foi feito, decidido e ficou pendente, para retomar o trabalho em nova sessão sem depender do histórico da conversa. Plano aprovado em `~/.claude/plans/esse-um-trabalho-cheerful-squirrel.md`.

## 1. Contexto e decisões do usuário

- Disciplina *Introdução à Análise de Eficiência em R* (Prof. Peter Wanke). Entregas: apresentação de diagnóstico em 28/09/2026 (dataset original) e manuscrito em português para periódico Qualis (painel reconstruído).
- Decisões: modelo principal conjunto (publicações + patentes) com modelos por canal; tudo em português; painel reconstruído (CSET + World Bank) substitui o dataset original na versão artigo; scripts R no estilo Google (BigCamelCase, `return()` explícito, `pkg::fun`, 80 colunas); todas as bases dentro de `data/`, uma subpasta por fonte; documentos em `artigo/` (o `.gitignore` ignora `docs/`).
- Nada foi commitado ainda (`git status`: `README.md` modificado; `R/`, `artigo/`, `data/`, `output/`, `others/` não rastreados).

## 2. Estrutura do repositório

- `data/AI_INVESTMENT.csv` — dataset original (208 país-ano, 37 países, 2013–2021). Proveniência verificada: CSET via Our World in Data (investimento em US$ constantes de 2021; publicações em contagem; patentes **por milhão de habitantes**) + World Bank WDI/WGI/GFDD.
- `data/cat/` — CSET Country AI Activity Metrics v1.12.0 (Zenodo 22772306), 2016–2026, campo `field == "All"`, coluna `complete` (artigos completos até 2024, pedidos de patente até 2021, concedidas até 2019, investimento em milhões de US$ nominais). Índia: patentes quebradas a partir de 2019 (tratadas como NA).
- `data/wdi/`, `data/wgi/` — World Bank (API v2, cache por indicador; WGI com códigos novos `GOV_WGI_*`, fonte 3). `data/ai_index/` — dados públicos do AI Index 2025 (CSVs por figura). `data/oecd-ai/` — export manual de publicações (`data.csv`), patentes de IA por país do inventor via API SDMX (`patentes_ia_ip5_inventor.csv`, `patentes_ia_triadicas_inventor.csv`); VC (Preqin) pendente.
- `data/processed/` — `base_atual.csv` (Fase A), `cset_long.csv`, `ai_index_pais_ano.csv`, `ai_index_transversal.csv`, `oecd_ai_publicacoes.csv`, `oecd_ai_patentes.csv`, `painel_ia.csv` (47 países, 2016–2024). Inventário completo em `data/README.md`; codebook em `artigo/03_codebook.md`.
- `R/` — `00_setup.R` (pacotes, opções, pastas, `source("R/funcoes.R")`), `funcoes.R` (World Bank, DEA, bootstrap, Spearman com IC, interpolação), `01_prep_dataset_atual.R`, `02_fronteiras_dataset_atual.R`, `02b_teste_rts.R`, `03_segundo_estagio_dataset_atual.R`, `04_figuras_apresentacao.R`, `10_download_wdi.R`, `11_import_cset.R`, `12_import_fontes_alternativas.R`, `13_build_painel.R`, `14_download_oecd_patentes.R`.
- Scripts 02/02b/03/04 são parametrizados por variáveis de ambiente: `BASE_ARQUIVO` (padrão `data/processed/base_atual.csv`), `SUFIXO_SAIDA` (`""`, `_painel`, `_painel_qualidade`, `_painel_fonte`), `INSUMOS` (`investimento,gerd` ou `investimento_l1,gerd_l1`), `PRODUTOS` (`publicacoes,patentes`; `citacoes_ok,patentes_concedidas_ok`; `publicacoes,patentes_inventor`), `JANELA_MALMQUIST` (`2016,2019`; `2017,2021`; `2017,2019`), `N_REP_RTS`, `LIMITE_SW_SEG`. Runners em `output/rodar_cadeias.sh`, `rodar_integracao.sh`, `rodar_pendentes.sh`, `rodar_fonte2.sh`.
- `output/tables/` (~100 CSVs) e `output/figures/` (fig1–fig7 por variante, fig8 investimento CSET × Quid, fig9 patentes CSET × OCDE). Logs em `output/log_*.txt`.
- `artigo/` — `01_hipoteses.md`, `02_dados_externos.md` (inclui seção 5a: como obter patentes por inventor e VC), `03_codebook.md`, `05_resultados_fase_a.md`, `06_resultados_painel.md`, este registro.

## 3. Pipeline (por variante)

1. `01` prepara o dataset original (renda harmonizada, patentes em contagem via população WDI, GERD = P&D% × PIB, flags `inv_zero` e `inv_piso`).
2. `02`: outliers (`outlier.ap`, `sdea`), DEA CRS/VRS/NIRS por ano com eficiência de escala e classificação de RTS, bootstrap de Simar-Wilson (`dea.boot`, 1.000 réplicas), FDH/order-m/order-α (`nonparaeff`, `frontiles`; frontiles devolve escores ≤ 1 = ineficiente, sem inversão), canais (DMUs com produto zero excluídas), metafronteira por grupo de renda (agrupada), Malmquist CRS no painel balanceado, bloco de sensibilidade sem valores-piso.
3. `02b`: teste de RTS de Simar-Wilson (2002) implementado sobre `Benchmarking` (rDEA::rts.test não concluía em mais de uma hora); estatística S = média(D_H0)/média(D_VRS), bootstrap suavizado com reflexão, tempo máximo por LP (`CONTROL = list(timeout = 10)`).
4. `03`: bootstrap dos canais, regressão truncada em (0,1] truncada à direita em 1 com bootstrap agrupado por país (300 réplicas), H5 (com e sem piso, com pesquisadores, com talento em IA), H6 (canal patentes), H7 (PIB per capita por canal), Tobit comparativo, Simar-Wilson algoritmo 2 do rDEA em processo filho com timeout (`parallel::mcparallel`), Kruskal-Wallis por renda, diagnóstico Z × escore.
5. `04`: figuras 1–7 (com `ggrepel`).
6. Fase B: `10` → `11` → `14` → `12` → `13` → 02/03/04 com variáveis de ambiente.

## 4. Resultados principais

- Dataset original (Fase A, `artigo/05`): eficiência VRS média 0,64–0,82; maioria DRS; teste de RTS: CRS rejeitado (S = 0,666, p < 0,001), NIRS não rejeitado (S = 0,989, p = 0,60), M1 CRS rejeitado (S = 0,202). Ranking corrigido de viés: topo Itália, Grécia, Malásia, Indonésia, Bulgária, Índia; base Suíça, Israel, Irlanda, Noruega. Spearman entre canais 0,52 [0,40; 0,63]; TGR renda média 0,94 vs alta 0,62 (contrário a H3b). Malmquist 2016–2019 (16 países): TC 0,91, EC 1,10, TC explica 58% da variância. Segundo estágio: efetividade governamental negativa (−0,137, três métodos), PIB per capita negativo em publicações, H6 não apoiada.
- Painel reconstruído (`artigo/06`): 47 países, modelo conjunto 2017–2021 (204 obs.); RTS: CRS rejeitado (S = 0,577), NIRS não rejeitado (S = 0,979, p = 0,45); Spearman canais 0,48; TGR renda média 0,93 vs alta 0,61; Malmquist 2017–2021 (34 países): M 0,92, TC 0,85, EC 1,08, sem convergência da renda média; efetividade −0,18 [−0,30; −0,06], crédito +0,0026, PIB pc negativo no canal de patentes; talento em IA não significativo.
- Variante de qualidade (citações + concedidas, 2017–2019, 117 obs.): Spearman canais 0,42; **TGR inverte** (alta 0,94, média 0,84, p = 0,011); efetividade deixa de ser significativa; Spearman entre rankings volume × qualidade = 0,80. Conclusão central: o ajuste por qualidade muda a história (R3).
- Checagens entre fornecedores: investimento acumulado CSET × Quid Spearman 0,93 [0,87; 0,96] (n = 84); publicações CSET × OECD.AI Spearman 0,95, Pearson 0,99; patentes CSET (escritório) × OCDE (inventor) Spearman 0,75 [0,69; 0,81] (302 país-ano).
- Variante de fonte (patentes por inventor): `02` rodou (217 obs., 46 países, Spearman canais 0,30, Malmquist 38 países); a cadeia completa foi relançada após dois bugs (produto zero no bootstrap dos canais; junção por id no bloco sem piso). Verificar `output/log_fonte.txt` ("FONTE OK") e, se OK, resumir em `artigo/06` (seção nova "Variante de fonte").

## 5. Problemas encontrados e como foram resolvidos

- `rDEA` (rts.test e dea.env.robust) extremamente lento ou travando: substituído por implementação própria (02b) e envolto em processo filho com timeout (03).
- `frontiles` retorna escores orientados a produto ≤ 1 (ineficiente) — não inverter; `nonparaeff::fdh` é Farrell ≥ 1 — inverter. Verificado com dados sintéticos.
- Supereficiência inviável (Peru 2021) → NA. Zeros de investimento (17 no original) excluídos; valores-piso (≤ 2,5 M) testados em bloco de sensibilidade.
- `pkill` mata só o front-end `Rscript`; o back-end `exec/R` continua — sempre matar pelo PID de `exec/R`.
- Zenodo bloqueia scripts (403): CSET baixado manualmente em `data/cat/`. World Bank API mudou códigos do WGI.
- AI Index não traz investimento por país-ano (só China/Europa/EUA); usado como corte transversal (Quid) e painel de talento (LinkedIn).
- `summarise` do dplyr sobrescrevendo nomes usados nas expressões seguintes (cobertura do painel) — corrigido com nomes distintos.
- Dois processos `exec/R` sem `--file` que aparecem no `pgrep` são do VS Code, não do projeto.

## 6. Pendências (estado em 27/09/2026, 16h)

### Concluído (não requer ação)

- Fase A completa: scripts `R/01`–`R/04`, `R/02b`, figuras, `artigo/05` (inclui teste de RTS).
- Fase B, dados: World Bank/WGI (`R/10`), CSET (`R/11`), AI Index e OECD.AI (`R/12`), patentes por inventor OCDE (`R/14`), MSTI + Eurostat (`R/15`), painel de 47 países (`R/13`), codebook.
- Fase B, análises: painel em volume (`_painel`), qualidade (`_painel_qualidade`), patentes por inventor (`_painel_fonte`), VC Preqin (`_painel_preqin`), P&D público (`_painel_publico`, 41 países com MSTI + Eurostat, resumido na seção 9c do `artigo/06`); testes de RTS no dataset original e no painel; checagens entre fornecedores (investimento Quid e Preqin, publicações OECD.AI, patentes OCDE); talento em IA como Z.
- Documentação: `artigo/01`, `02` (com seções 5a e 6a de acesso às fontes), `03`, `05`, `06`, `07`; `data/README.md`; `README.md`.

### Aberto — depende do usuário

1. **Apresentação de 28/09**: montar o deck de 20 minutos a partir de `artigo/05_resultados_fase_a.md` e das figuras sem sufixo em `output/figures/` (fig1–fig7). Nenhum cálculo pendente.
2. **Commit inicial**: nada foi commitado; `git status` mostra `R/`, `artigo/`, `data/`, `output/`, `others/` e `README.md`.
3. **Top500** (opcional, baixa prioridade): o site bloqueou os downloads por taxa; rerodar `Rscript R/16_download_top500.R` mais tarde ou baixar as planilhas manualmente para `data/top500/` e rodar o script para agregar. Depois, usar `top500_sistemas` como Z no segundo estágio.
4. **P&D público dos seis países sem fonte** (opcional): Brasil, Índia, Malásia, Filipinas, Arábia Saudita, Ucrânia só por fontes nacionais (RICYT, DST, MASTIC), manualmente. O UIS não publica mais a abertura por setor. Sem isso, esses países ficam fora apenas da variante `_painel_publico`.

### Aberto — trabalho analítico da versão artigo (sem dados novos)

5. SFA por canal com classes latentes (`frontier`, `sfaR`; H2), teste de separabilidade formal (`npsf`), Malmquist com soma móvel de 3 anos, matriz de robustez consolidada (estimador × defasagem × qualidade × fonte × insumo público) em uma tabela única.
6. `artigo/04_metodologia.md` e rascunho do manuscrito em português (introdução, dados, método, resultados, discussão), usando `artigo/01`, `02`, `05`, `06`.

## 7. Como retomar rapidamente

```bash
cd /Users/fernando/Projects/ai-efficiency-analysis
cat output/log_fonte.txt                      # estado da variante de fonte
Rscript R/01_prep_dataset_atual.R && Rscript R/02_fronteiras_dataset_atual.R \
  && Rscript R/03_segundo_estagio_dataset_atual.R && Rscript R/04_figuras_apresentacao.R   # Fase A
output/rodar_cadeias.sh                        # Fase A + painel + qualidade
output/rodar_fonte2.sh                         # variante de fonte
```
