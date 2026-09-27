# Avaliação das 24 inconsistências apontadas em `09_analise_critica_inconsistencias.md`

Avaliação feita em 27/09/2026. Cada item foi conferido contra código, tabelas e bases do repositório antes do veredito. Convenções: **Verdadeira** = divergência confirmada; **Verdadeira em parte** = a observação procede, mas a conclusão ou a justificativa do revisor não se sustenta integralmente; **Falsa** = descartada, com o motivo. "Correção" indica a alternativa adotada (a do revisor, ou uma adaptação, com a razão) e "Estado" indica se já foi aplicada nesta rodada (código, reexecução e/ou texto), documentada como limitação ou deixada pendente.

Resumo: 22 verdadeiras (das quais 6 em parte), 0 falsas, 2 verdadeiras cuja correção completa fica registrada como limitação metodológica (I07 e I09, inferência de dois estágios e validação do teste de RTS). Todas as correções de código foram aplicadas e o pipeline inteiro foi reexecutado (`output/rodar_tudo.sh`; manifesto por execução em `output/tables/manifesto_execucoes.csv`).

| ID | Veredito | Correção adotada | Estado |
|---|---|---|---|
| I01 | Verdadeira | Marca de piso sempre a partir do insumo usado (sugestão do revisor) | Aplicada, reexecutada |
| I02 | Verdadeira | Tabela de RTS por país; H1 reclassificada como parcialmente apoiada | Aplicada |
| I03 | Verdadeira | Decomposição amostra × especificação em amostra comum (novo `R/05`) | Aplicada |
| I04 | Verdadeira | IC bootstrap da média anual a partir das réplicas; rótulo e anos por país | Aplicada (adaptação) |
| I05 | Verdadeira | Reincorporar os PNGs no deck e reexportar | Pendente (usuário, ferramenta externa) |
| I06 | Verdadeira | Casos completos por fórmula antes do ajuste; N efetivo | Aplicada |
| I07 | Verdadeira | Rotular o procedimento; manter algoritmo 2 como inferência de dois estágios | Aplicada como rótulo; limitação registrada |
| I08 | Verdadeira | Rodar as duas parametrizações (Farrell à esquerda e escore à direita) | Aplicada (adaptação) |
| I09 | Verdadeira em parte | Descartar réplica inteira em falha; validação por simulação; rótulo "adaptado de SW 2002" | Aplicada (simulação em curso) |
| I10 | Verdadeira | Declarar a tecnologia temporal de cada análise; não usar teste agrupado como validação das anuais | Aplicada no texto |
| I11 | Verdadeira | Identidade completa com covariância; rateio simétrico como convenção | Aplicada, reexecutada |
| I12 | Verdadeira | IC por bloco de país para EC por grupo; β-convergência; critério fixo | Aplicada |
| I13 | Verdadeira | H3a: p unilateral bootstrap para ρ ≥ 0,5; H3b redefinida como TGR média < TGR alta | Aplicada |
| I14 | Verdadeira | Bootstrap por bloco de país nas correlações; testes também em médias por país | Aplicada |
| I15 | Verdadeira | Comparações na amostra comum e diferença de coeficientes por bootstrap pareado | Aplicada (`R/05`) |
| I16 | Verdadeira em parte | Corrigir a justificativa (medida, não inviabilidade); sensibilidade com zeros | Aplicada |
| I17 | Verdadeira | Tabela cruzada supereficiência × piso; texto quantificado | Aplicada |
| I18 | Verdadeira | Renomear como P&D executado por setor; reescrever H2 | Aplicada no codebook e texto |
| I19 | Verdadeira | Renomear como média não ponderada por gênero; total 2024 como referência | Aplicada |
| I20 | Verdadeira | Definições do CSET registradas; "qualidade" rotulada como produtos alternativos | Aplicada |
| I21 | Verdadeira | Tabela renomeada como associação descritiva; segundo estágio exploratório | Aplicada |
| I22 | Verdadeira | Tabela antiga renomeada como obsoleta em falha; arquivo de status; manifesto | Aplicada |
| I23 | Verdadeira | Números e pendências regenerados a partir das saídas | Aplicada no texto |
| I24 | Verdadeira | Variante rotulada como troca de fornecedor e de universo; metadados | Aplicada no texto |

## I01 — Filtro "sem piso" com o insumo errado

**Veredito: verdadeira.** Conferido: em `_painel`, a marca vinda de `R/13` (investimento em t) removia 8 observações, mas 18 estavam no piso do insumo efetivo (investimento em t−1); 6 remoções indevidas e 16 mantidas no piso. Mesmo padrão nas demais variantes (qualidade 5/9, fonte 6/15, Preqin 6/3, público 5/14).

**Correção.** Adotada a sugestão do revisor: `R/02` calcula `inv_piso` sempre a partir de `amostra[[insumos[1]]]` (limite de 2,5 milhões de US$ de 2021), guardando a marca da base como `inv_piso_base`. Sobre o limite por fonte: a Preqin também publica valores em milhões inteiros, portanto o mesmo limite de duas unidades de granularidade é defensável; limites alternativos ficam como sensibilidade futura. Todas as saídas `_sem_piso` e os segundos estágios correspondentes foram reexecutados.

## I02 — China descrita como DRS

**Veredito: verdadeira.** Conferido em `dea_ano_m2.csv` e `dea_ano_m2_painel.csv`: a China é CRS com eficiência de escala 1 em todos os anos (2013–2021 e 2017–2021); a Índia é CRS em 2014, 2015, 2017, 2020 (Fase A) e 2017–2018 (painel). Os Estados Unidos são DRS em todos os anos.

**Correção.** Sugestão do revisor adotada: nova tabela `rts_por_pais_m2*.csv` (anos em DRS/IRS/CRS e eficiência de escala média por país) e H1 reclassificada como **parcialmente apoiada**: a tecnologia global tem retornos variáveis (CRS rejeitado, NIRS não rejeitado), os Estados Unidos operam em DRS, mas a China está sobre o raio de produtividade máxima (CRS) em todos os anos. O critério individual "SE < 0,8 para os grandes" não vale para a China.

## I03 — Inversão da metafronteira atribuída ao P&D público

**Veredito: verdadeira.** Reproduzido: com GERD na amostra original (204), TGR alta/média = 0,606/0,932; com GERD na amostra da variante pública (184), 0,927/0,798; com HERD + GOVERD na mesma amostra, 0,915/0,815. A inversão decorre da saída de Brasil, Índia, Malásia, Filipinas, Arábia Saudita e Ucrânia, países de renda média que definiam a metafronteira; a troca de insumo pouco altera a razão.

**Correção.** Sugestão do revisor adotada e generalizada: `R/05_comparacoes_amostra_comum.R` produz, para cada variante, a tripla (base na amostra original; base na amostra da variante; variante na amostra da variante), separando efeito de amostra e de especificação. A recomendação de modelo principal com P&D público passa a apoiar-se apenas em razão de mensuração (setor de execução, ver I18), não na inversão.

## I04 — Barras do ranking rotuladas como IC 95%

**Veredito: verdadeira.** O código fazia a média dos limites anuais e os chamava de IC 95% da média, sem base para a cobertura declarada.

**Correção.** Adaptação da sugestão: `R/02` agora guarda as réplicas de `dea.boot` por ano e calcula, para cada país, a distribuição bootstrap da média anual dos escores (média sobre os anos de 1/F replicado), com IC básico de 95% (`ranking_paises_boot*.csv`); `R/04` usa essa tabela e rotula "IC 95% bootstrap da média anual; entre parênteses, anos por país". Réplicas de anos diferentes são independentes; a dependência entre unidades no mesmo ano é a do bootstrap homogêneo e não é modelada entre anos, o que fica declarado. A alternativa completa do revisor (incerteza de postos e diferenças pareadas) fica como extensão.

## I05 — PDF sem os gráficos

**Veredito: verdadeira.** `AI Effiency Analysis.pdf` tem 19 páginas e zero objetos de imagem embutidos.

**Correção.** Sugestão do revisor: reincorporar os PNGs de `output/figures/` (versões regeneradas nesta rodada) no documento de origem do deck e reexportar, conferindo cada página. Depende da ferramenta externa usada pelo usuário; o brief (`artigo/08`) já traz os caminhos.

## I06 — N superestimado nas regressões

**Veredito: verdadeira.** Conferido: H5 no painel usa 144 casos completos (não 204) e na variante de qualidade 85 (não 117), pela ausência de `market_cap` e `credito_privado` em vários países.

**Correção.** Sugestão do revisor adotada: `TruncadaAgrupada` forma o quadro de casos completos da fórmula antes do ajuste e da reamostragem, e reporta `n_obs` e `n_paises` desse quadro. Comparações entre especificações na mesma amostra estão em `R/05` (I15).

## I07 — Bootstrap do segundo estágio com escores fixos

**Veredito: verdadeira.** O procedimento reamostra países com os escores já estimados; não propaga a incerteza da fronteira e não herda a validade do algoritmo 2.

**Correção.** Adotado o rótulo explícito ("truncada, escores fixos, bootstrap por país", coluna `inferencia` nas tabelas) e mantido o algoritmo 2 de Simar–Wilson (rDEA, fronteira agrupada) como a única inferência de dois estágios. Uma extensão validada para painel com dependência temporal não existe pronta nos pacotes usados e fica registrada como limitação do artigo, como o revisor sugere; não foi implementada uma "DEA em bootstrap ingênuo" justamente porque não garantiria validade.

## I08 — Suporte da variável dependente na truncada

**Veredito: verdadeira.** A truncada à direita em 1 sobre 1/F admite valores negativos e não equivale ao modelo em Farrell.

**Correção.** Adaptação: `R/03` roda as duas parametrizações (`TruncadaDupla`): Farrell ≥ 1 com truncamento à esquerda em 1 (a de Simar–Wilson 2007) e escore em (0, 1] com truncamento à direita (sensibilidade de escala). As tabelas ganham a coluna `dependente` e o texto reporta ambas, sinalizando quando a versão Farrell é instável nos canais de poucos produtos. A alternativa de um modelo com dois limites (Badunenko e Tauchmann) fica como extensão.

## I09 — Teste de RTS adaptado sem validação

**Veredito: verdadeira em parte.** É verdade que a rotina não é a de `rDEA` e que `na.rm = TRUE` podia contar réplicas com LPs falhos. Não procede tratá-la como implementação divergente em essência: a suavização com reflexão em 1 aplicada a distâncias de Shephard (≤ 1) é a mesma operação de Simar–Wilson (1998) sobre medidas de Farrell orientadas a insumo (≤ 1); a reflexão em 1 é simétrica para as duas leituras. O corte em 1e-4 evita produtos nulos e afeta apenas valores fora do suporte.

**Correção.** Adotadas as partes válidas: réplica inteira descartada se qualquer LP falhar (`TesteRtsBootstrap` em `R/funcoes.R`), rótulo "adaptado de Simar e Wilson (2002)" e validação por simulação (`R/02c_validacao_rts.R`: tamanho sob CRS verdadeiro e poder sob DRS, 40 DMUs, 100 réplicas, 30 simulações por cenário; resultado em `validacao_teste_rts.csv`). A comparação com `rDEA::rts.test` em amostras pequenas fica como extensão, dado o custo computacional observado.

## I10 — Fronteiras anuais e agrupadas misturadas

**Veredito: verdadeira.** Rankings e truncada usam fronteiras anuais; metafronteira, teste de RTS e algoritmo 2 usam a fronteira agrupada (o algoritmo 2 ainda restrito a casos completos de contexto).

**Correção.** Sugestão do revisor adotada no texto: cada análise declara a tecnologia temporal que mede (coluna `fronteira` nas tabelas de RTS e do algoritmo 2; quadro de fronteiras em `artigo/06`), e a frase "três métodos concordam" passa a "três procedimentos, com fronteiras e amostras distintas, dão o mesmo sinal". A comparação de estimadores (FDH, order-m, order-α) já era feita sobre a mesma fronteira anual.

## I11 — Parcela de variância sem a covariância

**Veredito: verdadeira.** Reproduzido no painel: Var(log M) = 0,0647; Var(log TC) = 0,0479; Var(log EC) = 0,0788; 2 Cov = −0,0621. O indicador anterior (0,378) usava um denominador quase o dobro da variância do índice.

**Correção.** Sugestão do revisor adotada: `R/02` grava a identidade completa (`malmquist_decomposicao_variancia*.csv`) e reporta a parcela de TC pelo rateio simétrico da covariância (0,261 no painel), explicitamente como convenção contábil; o indicador antigo permanece na tabela sob o nome correto ("parcela na soma das variâncias"). O critério de H4a passa a usar o rateio simétrico.

## I12 — Convergência julgada por critério diferente

**Veredito: verdadeira.** O critério declarado (EC da renda média > 1 com IC excluindo 1) não havia sido testado; a decisão usou a comparação entre grupos.

**Correção.** Sugestão adotada: `R/02` calcula IC 95% por bootstrap em blocos de país das médias geométricas de M, TC e EC por grupo (`malmquist_resumo*.csv`) e uma regressão de β-convergência (log EC médio do país contra log da eficiência CRS inicial, `malmquist_beta_convergencia*.csv`). O texto separa aproximação da própria fronteira, convergência relativa e β-convergência, e reporta "não testada formalmente" onde o IC não permite decisão.

## I13 — H3 julgada com testes diferentes do enunciado

**Veredito: verdadeira.** ρ = 0,42 [0,26; 0,54] e 0,48 [0,37; 0,59] incluem 0,5; e TGR ≤ 1 por construção torna "TGR < 1" não testável; o Mann–Whitney testava a diferença entre grupos.

**Correção.** Sugestão adotada: H3a ganha p-valor unilateral bootstrap de H0: ρ ≥ 0,5 (`SpearmanComIc(..., limiar = 0,5)`, com blocos de país); H3b é redefinida em `artigo/01` como TGR(renda média) < TGR(alta renda), com Mann–Whitney unilateral em país-ano e em médias por país. Status passam a "compatível no ponto, inconclusivo" quando o teste não decide.

## I14 — Observações repetidas por país tratadas como independentes

**Veredito: verdadeira.** `SpearmanComIc` reamostrava linhas; Mann–Whitney e Kruskal–Wallis usavam país-ano.

**Correção.** Sugestão adotada: `SpearmanComIc` ganha o argumento `grupo` (reamostragem por trajetórias completas de país), usado nos canais, nos estimadores, nas checagens entre fornecedores em painel e na associação Z × escore; os testes por grupo de renda são reportados também em médias por país. A dependência pela fronteira compartilhada permanece não modelada nessas correlações e é declarada como limitação, como o revisor indica.

## I15 — Troca de significância e correlação de rankings

**Veredito: verdadeira.** Conferido: na amostra comum de 117 observações, a metafronteira com produtos em volume dá 0,593/0,867 e com produtos alternativos 0,944/0,835 — a inversão persiste, mas a comparação de coeficientes entre amostras diferentes não era um teste da diferença.

**Correção.** Sugestão adotada: `R/05` reestima metafronteira e coeficiente de efetividade governamental na amostra comum de cada variante e testa a diferença de coeficientes com bootstrap pareado por país (`comparacao_coeficiente_efetividade_amostra_comum.csv`). Texto: "desaparece" vira "deixa de ser distinguível de zero nesta especificação"; a frase "o que altera é a qualidade, não o fornecedor" é substituída pela descrição do que muda em cada dimensão.

## I16 — Zeros e inviabilidade

**Veredito: verdadeira em parte.** Confirmado que, com dois insumos, a LP orientada a produto é viável com investimento zero (todas as unidades de 2015 e 2017 têm Farrell finito). Mas a conclusão de que a exclusão não tem base não procede: as unidades com zero saem eficientes por construção ou quase (escores CRS de 0,59 a 1,00, três em 1,00) e viram pares das demais, cuja média cai de 0,59 para 0,44 em 2015 e de 0,51 para 0,41 em 2017. Como o zero significa negócio não registrado, a exclusão continua sendo a escolha de mensuração correta.

**Correção.** Justificativa corrigida no código e no texto (medida, não inviabilidade; a inviabilidade vale para M1) e nova tabela de sensibilidade com zeros incluídos (`sensibilidade_zeros_m2*.csv`), como sugere o revisor. Não foram substituídos zeros por constantes.

## I17 — Supereficiência não restrita ao piso

**Veredito: verdadeira.** Conferido: 19 observações supereficientes, 7 no piso; entre as demais, China 2013 (US$ 141 M), Índia 2019–2020 e México 2018.

**Correção.** Sugestão adotada: tabela cruzada supereficiência × piso (`supereficiencia_cruzada_piso*.csv`) e texto quantificado ("7 das 19 supereficientes estão no piso; as outras são pontos extremos legítimos ou revisões de safra, como Índia 2020").

## I18 — Setor de execução não é fonte de financiamento

**Veredito: verdadeira.** GERD é o total interno; HERD + GOVERD identifica quem executa, não quem financia (Manual de Frascati, cap. 4).

**Correção.** Sugestão adotada: codebook e textos renomeados ("P&D executado pelo ensino superior e pelo governo"); H2 reescrita em termos de P&D não empresarial versus investimento privado em IA, sem falar em "financiamento público"; nota de que os dois insumos não são parcelas exclusivas do custo de IA. GERD por fonte de recursos fica como extensão.

## I19 — Talento como média não ponderada

**Veredito: verdadeira.** Conferido contra o total publicado para 2024: Israel 2,24 vs 1,98; Grécia 1,00 vs 0,83; Alemanha 1,02 vs 1,09.

**Correção.** Sugestão adotada: variável renomeada `talento_ia_media_genero_pct`, codebook e rótulos explícitos, total de 2024 mantido como referência transversal; taxas por gênero preservadas para sensibilidade. As conclusões sobre talento passam a ser reportadas com essa ressalva.

## I20 — Definições de patentes e "qualidade"

**Veredito: verdadeira.** Confirmado na documentação do CSET: unidade = família de patentes; atribuição ao país de prioridade (primeira jurisdição em que o inventor depositou); ano = primeiro depósito; "concedidas" = famílias depositadas no ano e posteriormente concedidas.

**Correção.** Sugestão adotada: codebook e `artigo/02` com essas definições; a variante passa a chamar-se "produtos alternativos (citações até 2020; famílias posteriormente concedidas)", com a ressalva de que qualidade não foi isolada de volume e maturação.

## I21 — "Diagnóstico de separabilidade" que não testa separabilidade

**Veredito: verdadeira.**

**Correção.** Sugestão adotada: tabela renomeada `associacao_z_vs_escore` (com bootstrap por país), comentário corrigido e segundo estágio descrito como exploratório até o teste de Daraio, Simar e Wilson (2018).

## I22 — Tabela antiga sobrevivendo à falha do algoritmo 2

**Veredito: verdadeira.**

**Correção.** Sugestão adotada de forma proporcional: em falha, a tabela anterior é renomeada como `_OBSOLETO` e um arquivo de status é gravado; todo script de análise registra uma linha no manifesto (`manifesto_execucoes.csv`: horário, script, sufixo, base e seu MD5, insumos, produtos, status). O manifesto completo com hashes de todas as saídas fica como extensão.

## I23 — Divergências entre documentos

**Veredito: verdadeira** em todos os pontos listados (45 vs 47 países; pendências desatualizadas no registro; item 4 da seção 10; arredondamento 0,92/0,82 em vez de 0,91/0,81; "sem nórdicos" quando a Noruega está na base; 37 países na base bruta e 36 na DEA).

**Correção.** Sugestão adotada: textos regenerados a partir das saídas desta reexecução, quadro único de amostras (base bruta, DEA, sensibilidades, Malmquist, cada regressão) em `artigo/06`, brief corrigido ("sem Suécia, Finlândia e Dinamarca").

## I24 — CSET e Preqin com universos diferentes

**Veredito: verdadeira.** O CSET inclui VC, private equity e fusões e aquisições em empresas fechadas; o export da Preqin restringe-se ao estágio VC.

**Correção.** Sugestão adotada: variante rotulada "troca de fornecedor e de universo (só VC)", codebook e `data/README.md` com filtros e unidade; o `vc_metadata.txt` original está guardado separado do `metadata.txt` reconstruído das publicações; a razão China CSET/Preqin não é mais atribuída só à cobertura.

## Resultados após a reexecução (27/09/2026, 17h–19h)

Pipeline reexecutado por inteiro com as correções (`output/rodar_tudo.sh`, `rodar_restante.sh`, `rodar_rankings.sh`; manifesto em `output/tables/manifesto_execucoes.csv`). Textos regenerados: `artigo/05` (Fase A) e `artigo/06` (painel). O que mudou de substância:

- **I09 (teste de RTS).** A validação por simulação da primeira versão corrigida mostrou tamanho de 0,40 sob CRS verdadeiro; a causa era avaliar os pseudoprodutos contra si mesmos. Com as observações originais avaliadas contra a pseudofronteira (como em Simar e Wilson), o tamanho cai para 0,20 (100 simulações, 40 DMUs) e o poder é 0,84 sob DRS forte. O teste continua liberal e passa a ser reportado como indicativo. Consequência: na Fase A, CRS ainda é rejeitado (p = 0,025), no painel **não** (p = 0,10, antes p = 0). H1 passa a "parcialmente apoiada" na Fase A e "sem apoio conclusivo" no painel.
- **I02.** China (e, no painel, Coreia e Índia) em CRS em todos os anos; tabela `rts_por_pais_m2*.csv`.
- **I03 e I15.** Decomposição em amostra comum (`R/05`): a inversão da metafronteira na variante de P&D executado por ensino superior e governo é composição da amostra (0,93/0,80 já com GERD nos mesmos 184 país-ano); na variante de produtos alternativos é especificação (0,59/0,87 → 0,94/0,83 nos mesmos 117). Diferenças do coeficiente de efetividade governamental entre especificações, com bootstrap pareado por país, todas com IC incluindo zero.
- **I01.** Marca de piso pelo insumo usado: amostras sem piso passam a 186 (base), 107 (qualidade), 198 (fonte), 190 (Preqin) e 168 (P&D executado) observações; conclusões de sensibilidade inalteradas em sinal.
- **I04.** IC 95% da média anual por réplicas (construção de Simar-Wilson centrada no estimador original): intervalos largos e assimétricos no topo do ranking, estreitos na base; só a separação base × restante é ordinalmente defensável.
- **I06.** N efetivo: H5 base 144 obs./38 países (antes reportado 204/47); qualidade 85/35.
- **I08.** Parametrização em Farrell reportada como sensibilidade; instável nos canais (coeficientes na casa das centenas), coerente em sinal no modelo conjunto (efetividade +57 [0,04; 82] na Fase A).
- **I11.** Parcela de TC com rateio simétrico: 0,60 na Fase A (antes 0,58) e **0,26 no painel** (antes 0,38); H4a deixa de valer como "dominância" no painel.
- **I12.** ICs por bloco de país: EC da renda média 1,07 [0,96; 1,26] na Fase A e 0,98 [0,91; 1,06] no painel; β-convergência nula. H4b não apoiada nas duas bases.
- **I13.** H3a inconclusiva (p unilateral de ρ ≥ 0,5: 0,59 na Fase A, 0,37 no painel; só a variante de patentes por inventor rejeita, p = 0,026); H3b redefinida como TGR(média) < TGR(alta): não apoiada em volume (p = 1,0), apoiada nas variantes de produtos alternativos (p = 0,006) e de P&D executado (p = 0,002, mas por composição da amostra).
- **I14.** Intervalos das correlações alargaram-se com blocos de país (ex.: canais na Fase A de [0,40; 0,63] para [0,31; 0,69]; publicações CSET × OECD.AI de [0,91; 0,98] para [0,80; 0,99]).
- **I16.** Sensibilidade com zeros: unidades com zero saem com escores de 0,68 a 1,00 e rebaixam a média das demais em até 0,07.
- **I17.** 19 supereficientes na Fase A, 7 no piso; 15 no painel, 3 no piso.
- **I22.** Na variante de qualidade o algoritmo 2 não concluiu em 10 minutos: tabela anterior renomeada `_OBSOLETO`, status gravado, texto sem esse número.
