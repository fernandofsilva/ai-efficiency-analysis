# Brief para o deck da apresentação (28/09/2026) — usar no Claude Design

**Revisão 3, de 28/09/2026.** Substitui as revisões 1 (commit `ae6c878`, que gerou o deck `AI Effiency Analysis.pdf`, 19 páginas, na raiz do repositório) e 2 (commit `91ee83c`, que nunca chegou ao PDF). A revisão 3 incorpora as correções da reanálise crítica (`artigo/12_avaliacao_reanalise.md`, sucessora de `artigo/10`) e a reexecução completa do pipeline em 28/09/2026 (`output/rodar_pipeline.sh tudo`; status em `output/status_execucao.txt`). Todos os números foram conferidos contra as tabelas de `output/tables/`.

Como usar: para **regenerar o deck do zero**, usar as seções 3 e 4; para **editar o deck já gerado**, seguir a seção 2, página a página (o deck atual reflete a revisão 1). Nos dois casos, as sete figuras precisam ser embutidas como imagem.

## 1. O que mudou desde a revisão 1 (deck atual)

| Tema | Revisão 1 (deck atual) | Revisão 3 | Origem |
|---|---|---|---|
| Teste de retornos de escala (Fase A) | CRS rejeitado com p < 0,001 (M2) e p < 0,001 (M1); NIRS p = 0,60; "Estados Unidos e China sempre em retornos decrescentes" | rotina alinhada à referência `rDEA::rts.test`; M2 p = 0,091, M1 p = 0,116, NIRS p = 0,96: **sem indício contra CRS**; tamanho do teste ≈ 0,20 nas duas implementações (simulação); **China em CRS em todos os anos**, Estados Unidos em DRS; H1 sem apoio conclusivo | I02, I09, R08 |
| Teste de retornos de escala (painel) | "confirma retornos variáveis (p < 0,001)" | teste de RTS sem indício contra retornos constantes (S = 0,577, p = 0,44; M1: S = 0,347, p = 0,33; teste com tamanho ≈ 0,20) | R08 |
| Ranking (Figura 1) | barras = média dos limites anuais; "largura média do IC 0,24" | barras = IC 95% por pseudo-valores de Simar-Wilson da média anual (nenhum ponto fora da barra); intervalo de postos; contrastes pareados: Suíça abaixo de 35 dos 35 demais, Israel de 34, Irlanda de 32, Noruega e África do Sul de 31; base: Israel 0,19, Irlanda 0,22, Noruega 0,24 | I04, R07 |
| Supereficiência e piso | "as unidades além da fronteira são exatamente essas" | 19 supereficientes, 7 no piso e 12 fora dele | I17 |
| Canais (H3a) | ρ = 0,52 [0,40; 0,63] | ρ = 0,52 [0,31; 0,69], bootstrap por país; p unilateral de ρ ≥ 0,5 = 0,59: inconclusiva | I13, I14 |
| Metafronteira (H3b) | 0,62 vs 0,94, "p < 0,001" | 0,62 vs 0,94; dois alvos: Mann-Whitney p = 1,0 e diferença de TGR médio +0,32 [0,23; 0,40]: não apoiada, sinal contrário | I13, R10 |
| Testes por renda | "Kruskal-Wallis p < 0,001" | Kruskal-Wallis (3 grupos) p = 0,001 em país-ano e 0,022 em médias por país; Mann-Whitney (2 grupos) p < 0,001 e 0,020 | I14, R06 |
| Malmquist (H4a) | "explica 58% da variância" | parcela de TC com covariância rateada: 0,60 na Fase A e 0,26 no painel | I11 |
| Convergência (H4b) | "catch-up 1,11 vs 1,07" | EC da renda média 1,074 [0,958; 1,262] (intervalo por reamostragem de países, índices fixos: descritivo); critério não atendido; β-convergência com a fronteira do painel balanceado +0,11 (p = 0,11) | I12, R04, R11 |
| Segundo estágio | escore truncado só em 1; "Simar-Wilson alg. 2 e Tobit concordam"; sem piso −0,120 | especificação principal: truncada sobre **log do escore** (compatível com o suporte; convergência verificada em cada ajuste); efetividade −0,58 [−1,31; 0,02], sem piso −0,66 [−1,69; 0,02]: sinal negativo, não distinguível de zero; comparações: escore truncado em 1 −0,137 [−0,329; −0,000], algoritmo 2 +10,1 [5,4; 15,3] (Farrell), Tobit −0,116; Farrell degenerado | I06–I08, R01, R09 |
| Painel: instituições | −0,18 [−0,30; −0,06] | −0,69 [−1,20; −0,21] (log do escore; 144 casos completos em 38 países) | R09 |
| Painel: produtos alternativos | "metafronteira inverte (TGR 0,84 vs 0,94), a associação com instituições desaparece" | inversão por especificação confirmada na amostra e fronteira comuns (0,59/0,87 → 0,94/0,83); diferença do coeficiente de efetividade +0,43 [0,05; 0,75], distinguível de zero com fronteira comum | I15, R02, R03 |
| Painel: P&D público | "P&D público corrige Israel e Irlanda" e inverte a metafronteira | "P&D executado por ensino superior e governo"; Israel 0,16 → 0,22 (composição) → 0,47 (insumo); Irlanda 0,20 → 0,38 (composição) → 0,46; inversão por composição (saem cinco países de renda média e a Arábia Saudita) | I03, I18, R02, R12 |
| Fontes | "CSET × Preqin (513 país-ano)"; "CSET (escritório) × OCDE (inventor)" | CSET (VC + PE + fusões) × Preqin (só VC) 0,83 [0,76; 0,89]; CSET (país de prioridade) × OCDE (inventor) 0,75 [0,61; 0,85]; rankings em amostra e fronteira comuns ρ = 0,87 (Preqin) e 0,91 (inventor) | I20, I24, R02 |
| Dados | "sem Alemanha, Coreia, Canadá e nórdicos" | "sem Suécia, Finlândia e Dinamarca"; 36 países e 191 observações na DEA | I23 |
| Limitações | patentes "atribuídas ao escritório de depósito" | país de prioridade; teste de RTS liberal nas duas implementações; intervalos do Malmquist descritivos; pseudo-valores condicionais às fronteiras; segundo estágio exploratório | R07, R08, R11 |
| Figuras | nenhuma embutida (zero imagens no PDF) | embutir as sete; fig1, fig3, fig4 e fig6 mudaram de conteúdo; fig2, fig5 e fig7 não | I05 |

## 2. O que alterar no deck já gerado (`AI Effiency Analysis.pdf`, página a página)

Geral, antes de tudo:

- **Embutir as figuras** de `output/figures/` (sem sufixo) como imagem, não como caminho: fig1 (p. 8), fig6 (p. 9), fig3 e fig7 (p. 10), fig2 (p. 11), fig4 (p. 12), fig5 (p. 13). As caixas hoje estão vazias.
- Figuras com conteúdo novo desde a revisão 1: **fig1** (barras por pseudo-valores; rótulo com anos por país), **fig3** (subtítulo com o IC [0,31; 0,69]), **fig4** (dependente = log do escore; título novo), **fig6** (barras de IC por bloco de país). Sem mudança: fig2, fig5, fig7.
- Ao reexportar, conferir cada página e substituir o arquivo na raiz mantendo o mesmo nome (ou renomear para `AI Efficiency Analysis.pdf` com `git mv`, corrigindo a grafia).

| Página | Está no deck (revisão 1) | Trocar por (revisão 3) |
|---|---|---|
| 1, 2 | — | sem alteração |
| 3 | "sem Alemanha, Coreia, Canadá e nórdicos" | "sem Alemanha, Coreia, Canadá, Suécia, Finlândia e Dinamarca"; sob o "37 países", acrescentar "36 países e 191 observações na DEA (Eslovênia: 1 observação, investimento zero)" |
| 4 | "As unidades 'além da fronteira' são exatamente essas: China, Austrália e México 2013; Peru e Índia 2019–2020." | "19 unidades além da fronteira agrupada: 7 no piso (Austrália e México 2013, Romênia e Malásia 2016, Ucrânia 2018, Peru 2019, Bulgária 2021); as outras 12 (China 2013 e 2019–2021, Índia 2013, 2016 e 2019–2020, Malásia 2015, México 2018, Peru 2020, Romênia 2020) são pontos extremos ou revisões de safra, não granularidade." |
| 5 | H2 "(dado o P&D público)"; H3 "renda média abaixo da metafronteira"; H4 "renda média converge" | H2 "(dado o P&D executado no país)"; H3 "TGR da renda média deslocado para baixo e menor em média que o da alta renda"; H4 "renda média converge (catch-up > 1, critério numérico)" |
| 6 | "teste de retornos de escala"; "Regressão truncada com bootstrap agrupado por país, Simar-Wilson algoritmo 2 e Tobit; Kruskal-Wallis por renda" | "teste de retornos de escala alinhado a `rDEA::rts.test`, tamanho ≈ 0,20 por simulação (diagnóstico exploratório)"; "Regressão truncada sobre log(escore) com escores fixos e bootstrap por país (convergência verificada), algoritmo 2 de Simar-Wilson e Tobit; Kruskal-Wallis (3 grupos) e Mann-Whitney (2 grupos) por renda, em país-ano e em médias por país" |
| 7 | p-valores "< 0,001" (M2 CRS), "0,60" (NIRS), "< 0,001" (M1); decisões "rejeita"; "Estados Unidos e China sempre em retornos decrescentes." | "0,091", "0,96", "0,116"; decisão "sem indício (teste com tamanho ≈ 0,20)"; "15 dos 36 países em retornos decrescentes em todos os anos (Estados Unidos, Japão, Reino Unido); a China está em CRS, com eficiência de escala 1, em todos os anos; a Índia alterna." Os números grandes "20 DRS · 3 IRS · 4 CRS (2018)" continuam corretos. |
| 8 | "largura média do IC 0,24"; topo "Itália 0,79 · Grécia 0,77 · Malásia 0,76 · Indonésia 0,75 · Bulgária 0,75 · Índia 0,75"; base "Israel 0,19 · Irlanda 0,22 · Noruega 0,24"; "Diferença ordinal defensável só entre grupos com intervalos disjuntos." | retirar a largura média; "barras = IC 95% por pseudo-valores de Simar-Wilson da média anual; anos por país entre parênteses"; topo "Itália 0,80 [0,71; 0,90] · Grécia 0,78 · Malásia 0,77 · Indonésia 0,77 · Índia 0,77 · Bulgária 0,76"; base "África do Sul 0,25 · Noruega 0,24 · Irlanda 0,22 · Israel 0,19 [0,18; 0,20] · Suíça 0,15"; "Contrastes pareados: Suíça fica abaixo dos 35 demais, Israel de 34, Irlanda de 32, Noruega e África do Sul de 31; a ordem no topo não é distinguível (postos de 1 a 13–18)." Embutir fig1. |
| 9 | correlações sem IC | opcional: acrescentar os ICs (0,93 [0,83; 0,97]; M1 0,72 [0,57; 0,84]; FDH 0,70 [0,51; 0,82]; order-α 0,69 [0,48; 0,81]; order-m 0,51 [0,23; 0,70]). Embutir fig6. |
| 10 | "0,52 [0,40; 0,63] — correlação moderada (0,56 sem valores-piso)"; "0,62 alta renda vs 0,94 renda média (p < 0,001) — oposto ao previsto"; "Patentes diferem por renda (0,34 vs 0,17)" | "0,52 [0,31; 0,69], bootstrap por país; p unilateral de ρ ≥ 0,5 = 0,59: H3a inconclusiva"; "0,62 alta renda vs 0,94 renda média; Mann-Whitney p = 1,0 e diferença de TGR médio +0,32 [0,23; 0,40]: oposto ao previsto"; "Patentes diferem por renda (0,34 vs 0,17; Kruskal-Wallis p = 0,001 em país-ano, 0,022 em médias por país); publicações não." Embutir fig3 e fig7. |
| 11 | "Mudança técnica explica 58% da variância"; "Catch-up 1,11 vs 1,07: sem convergência (H4b não apoiada)"; tabela sem IC | "Parcela da mudança técnica na variância de log M (covariância rateada): 0,60"; "Catch-up da renda média 1,074 [0,958; 1,262] (intervalo por reamostragem de países, descritivo): critério não atendido; β-convergência com a fronteira do painel +0,11 (p = 0,11)"; coluna de intervalo na mudança de eficiência (tabela do slide 11 abaixo). Embutir fig2. |
| 12 | tabela com escore truncado em 1 (−0,137; −0,120; 0,000; −0,045; −0,093); "Simar-Wilson alg. 2 e Tobit concordam nos sinais. H5 e H6 não confirmadas" | tabela do slide 12 abaixo (dependente = log do escore): −0,58 [−1,31; 0,02]; −0,66 [−1,69; 0,02]; 0,000 [−0,015; 0,023]; −0,53 [−1,80; 0,27]; −0,36 [−0,66; −0,02]; "positivo = mais eficiente (semi-elasticidade); escores fixos e bootstrap por país; comparações: escore truncado em 1 −0,137 [−0,329; −0,000], algoritmo 2 +10,1 [5,4; 15,3] (Farrell, positivo = menos eficiente), Tobit −0,116: mesmo sinal, mas a principal não o distingue de zero; nenhum testa separabilidade." Embutir fig4. |
| 13 | — | texto sem alteração. Embutir fig5. |
| 14 | H1 "apoiada"; H3 "parcial / contrariada"; H4 "Fronteira domina; sem convergência"; H5 "Sinal negativo em três métodos / não apoiada" | tabela do slide 14 abaixo: H1 "sem apoio conclusivo; heterogeneidade por país"; H3a inconclusiva, H3b não apoiada (sinal contrário nos dois alvos); H4a sim (0,60), H4b critério não atendido; H5 "−0,58 [−1,31; 0,02]; sinal negativo em quatro procedimentos / não apoiada" |
| 15 | "RTS confirma retornos variáveis (S = 0,577, p < 0,001; NIRS p = 0,45)"; "−0,18 [−0,30; −0,06]"; caixa "AJUSTE POR QUALIDADE (CITAÇÕES E PATENTES CONCEDIDAS)"; "P&D público (HERD + GOVERD) corrige Israel e Irlanda" | teste de RTS sem indício contra retornos constantes (S = 0,577, p = 0,44; M1: S = 0,347, p = 0,33; teste com tamanho ≈ 0,20); "−0,69 [−1,20; −0,21] (log do escore, 144 casos completos)"; "sem convergência (EC 0,984 [0,909; 1,062]); no painel a mudança de eficiência varia mais que a técnica (parcela 0,26)"; caixa "PRODUTOS ALTERNATIVOS (CITAÇÕES; FAMÍLIAS POSTERIORMENTE CONCEDIDAS)": "a metafronteira inverte por especificação, confirmado em amostra e fronteira comuns (0,59/0,87 → 0,94/0,83); a associação com instituições se atenua de forma distinguível de zero (diferença +0,43 [0,05; 0,75])"; "P&D executado por ensino superior e governo: Israel 0,16 → 0,22 (composição) → 0,47 (insumo); Irlanda 0,20 → 0,38 (composição) → 0,46; a inversão da metafronteira nessa variante é composição da amostra" |
| 16 | "Investimento: CSET × Preqin (OECD.AI), 513 país-ano"; "Patentes: CSET (escritório) × OCDE (inventor)"; "mantém a ordem geral (ρ = 0,89 e 0,85) e os sinais do segundo estágio; mudam posições específicas: China, Estados Unidos, Japão, Suíça, Irlanda" | "CSET (VC + PE + fusões) × Preqin (só VC), 0,83 [0,76; 0,89]"; "CSET (país de prioridade) × OCDE (país do inventor), 0,75 [0,61; 0,85]"; "rankings em amostra e fronteira comuns: ρ = 0,87 (Preqin) e 0,91 (inventor); instituições continuam negativas com a Preqin (−1,12 [−1,58; −0,13]) e ficam no limite com patentes por inventor (−0,29 [−0,71; 0,01]); a China passa a DRS com patentes por inventor; Estados Unidos sobem ao topo (0,74); correlação entre canais 0,30" |
| 17 | "patentes atribuídas ao escritório de depósito"; três colunas | "famílias de patentes atribuídas ao país de prioridade (primeiro depósito), não ao país do inventor"; nova coluna "Inferência": teste de RTS com tamanho ≈ 0,20 nas duas implementações; intervalos do Malmquist por reamostragem de países (índices fixos); pseudo-valores do ranking condicionais às fronteiras anuais; segundo estágio com escores fixos e sem teste de separabilidade |
| 18 | "1 Retornos decrescentes e fronteira que recua..."; "3 ... ajustar produtos por qualidade e separar P&D público de privado" | "1 Retornos de escala heterogêneos: Estados Unidos, Japão e Reino Unido em retornos decrescentes, China sobre o raio CRS; o teste global, liberal, não fornece indício contra retornos constantes; a fronteira recua em produtos por dólar durante o boom"; "3 ... usar produtos alternativos (citações, famílias concedidas) e P&D por setor de execução: com fronteira comum, a troca de produtos atenua a associação negativa com instituições de forma distinguível de zero"; próximos passos: acrescentar "inferência de dois estágios para painel e bootstrap de Malmquist" |
| 19 | bibliografia só com autor e ano | trocar pela lista completa, com título e periódico, do slide 19 na seção 4 (inclui Daraio, Simar e Wilson, 2018, e Simar e Wilson, 1999) |

## 3. Instruções para o Claude Design

- Formato: apresentação 16:9, 18 slides (mais um de bibliografia, opcional), 20 minutos de fala, em português do Brasil, tom acadêmico e direto. Título da disciplina no rodapé: "Introdução à Análise de Eficiência em R — Prof. Peter Wanke".
- Autor: Fernando Silva. Título do trabalho: **"Quem converte melhor investimento em IA em ciência e patentes? Uma análise de fronteira para 37 países (2013–2021)"**.
- Identidade visual: fundo claro, uma cor de destaque (azul #1f77b4) e uma de contraste (laranja #ff7f0e), cinza para texto secundário; tipografia sem serifa; no máximo 5 bullets por slide; números grandes em destaque quando indicado.
- Figuras: **embutir os PNGs como imagem** (fazer o upload dos arquivos de `output/figures/`, sem sufixo), em página inteira ou meia página; não redesenhar gráficos e não deixar o caminho do arquivo no lugar da imagem (foi o que aconteceu na revisão 1).
- Cada slide abaixo traz: título, conteúdo (bullets ou tabela), figura (se houver) e nota do apresentador (o que falar, 60–80 segundos por slide).
- Escala dos escores: eficiência técnica em (0, 1], orientação a produto; 1 = na fronteira; "corrigido de viés" = após bootstrap de Simar-Wilson (1.000 réplicas).

## 4. Slides

### Slide 1 — Título

- Título do trabalho, nome, disciplina, data (28/09/2026).
- Nota: uma frase — "medimos quanto cada país consegue extrair, em publicações e patentes de IA, do dinheiro que entra em IA e em P&D".

### Slide 2 — Pergunta e por que importa

- Pergunta: quais países são mais eficientes em converter investimento privado em IA e gasto em P&D em produção científica (publicações) e tecnológica (patentes) de IA, e o que explica as diferenças?
- Por que fronteiras: comparar produtos com insumos, não volumes absolutos; Estados Unidos e China lideram em volume, não necessariamente em eficiência.
- Antecedente direto: Ernst e Mishra (2021), *AI Efficiency Index*, DEA para 27 países, 2015–2018. Nossa contribuição: mais países e anos, inferência por bootstrap, fronteiras robustas, dinâmica (Malmquist), heterogeneidade (metafronteira) e segundo estágio institucional.
- Nota: enquadrar como função de produção de conhecimento (Griliches; Furman, Porter e Stern) e capacidade de absorção (Cohen e Levinthal).

### Slide 3 — Dados

| Item | Valor |
|---|---|
| Observações | 208 país-ano na base bruta; 191 na DEA (17 zeros de investimento excluídos) |
| Países | 37 na base bruta, 36 na DEA (Eslovênia só tem uma observação, com investimento zero); sem Alemanha, Coreia, Canadá, Suécia, Finlândia e Dinamarca (a Noruega está na base) |
| Período | 2013–2021, painel desbalanceado (1 a 9 anos por país) |
| Insumos | investimento privado em IA (US$ constantes de 2021); GERD = P&D % PIB × PIB (P&D interno total, todos os setores) |
| Produtos | publicações de IA (contagem); pedidos de patente de IA (contagem) |
| Contexto | governança (WGI), alta tecnologia, comércio, crédito, mercado de capitais, PIB per capita (World Bank) |

- Proveniência verificada: indicadores de IA do CSET Country Activity Tracker via Our World in Data; patentes vinham **por milhão de habitantes** e foram reconvertidas em contagem com a população do World Bank.
- Nota: destacar que a origem foi rastreada valor a valor (Argentina 2018: 1.079.101 no dataset e 1.079.102 na fonte).

### Slide 4 — Três problemas de medida que condicionam tudo

- **Zeros e piso**: 17 país-ano com investimento zero e 22 no piso de 1–2 milhões de dólares (granularidade de 1 milhão): 39 das 208 observações. Zeros não inviabilizam o modelo de dois insumos, mas as unidades com zero saem eficientes por construção e rebaixam as demais; por isso ficam fora (zero = negócio não registrado).
- **Supereficiência não é só piso**: 19 unidades ficam além da fronteira agrupada; 7 estão no piso (Austrália e México 2013, Romênia e Malásia 2016, Ucrânia 2018, Peru 2019, Bulgária 2021); as outras 12 (China 2013 e 2019–2021, Índia 2013, 2016 e 2019–2020, Malásia 2015, México 2018, Peru 2020, Romênia 2020) são pontos extremos ou revisões de safra.
- **Publicações não nascem de capital de risco**: Ucrânia 2013–2017 tem investimento zero e 134–359 publicações por ano. Por isso o modelo base adiciona o GERD como segundo insumo.
- **Volume, não qualidade**: contagens favorecem sistemas grandes; China 2021 domina os Estados Unidos nos dois produtos com um sexto do insumo.
- Nota: "o diagnóstico começa reconhecendo o que os dados podem e não podem dizer".

### Slide 5 — Hipóteses

| | Hipótese (resumo) |
|---|---|
| H1 | Retornos variáveis de escala (teste global); grandes investidores com ineficiência de escala (país a país) |
| H2 | Investimento privado importa para patentes, não para publicações, dado o P&D executado no país |
| H3 | H3a: canais acadêmico e tecnológico pouco correlacionados (ρ < 0,5); H3b: TGR da renda média deslocado para baixo e menor em média que o da alta renda |
| H4 | H4a: mudança de fronteira domina a variação de produtividade; H4b: renda média converge (catch-up > 1, critério numérico) |
| H5 | Instituições e capacidade de absorção elevam a eficiência |
| H6 | Mercado de capitais (não crédito) eleva a eficiência em patentes |
| H7 | PIB per capita associado à eficiência em patentes, não em publicações |

- Nota: mencionar as proposições de robustez R1 (estimadores), R2 (defasagens) e R3 (produtos alternativos).

### Slide 6 — Método

- Modelos: M1 (insumo único: investimento; replicação de Ernst e Mishra) e M2 (investimento + GERD; base); canais separados (só publicações, só patentes).
- Fronteiras contemporâneas por ano (16 a 27 países por ano), orientação a produto, CRS/VRS/NIRS; eficiência de escala e classificação de retornos por país. Fronteira agrupada só para supereficiência, metafronteira, teste de retornos de escala e algoritmo 2.
- Inferência: bootstrap de Simar-Wilson (1.000 réplicas); ranking com pseudo-valores, intervalo de postos e contrastes pareados; teste de retornos de escala com a construção de `rDEA::rts.test`, tamanho ≈ 0,20 verificado por simulação nas duas implementações (diagnóstico exploratório); correlações com bootstrap em blocos de país.
- Robustez: FDH, order-m, order-α; metafronteira por grupo de renda (dois alvos: deslocamento e diferença de médias); Malmquist (CRS) no painel balanceado 2016–2019 (16 países), intervalos por reamostragem de países.
- Segundo estágio: regressão truncada sobre log(escore) com escores fixos e bootstrap por país (convergência verificada), algoritmo 2 de Simar-Wilson e Tobit; Kruskal-Wallis (3 grupos) e Mann-Whitney (2 grupos) por renda, em país-ano e em médias por país.
- Nota: tudo em R (Benchmarking, rDEA, nonparaeff, frontiles, truncreg), pipeline único com status por etapa e manifesto de saídas.

### Slide 7 — Escala e retornos (H1)

| Modelo | H0 | S | p-valor | Leitura |
|---|---|---|---|---|
| M2 | retornos constantes | 0,666 | 0,091 | sem indício (teste com tamanho ≈ 0,20) |
| M2 | retornos não crescentes | 0,989 | 0,96 | sem indício |
| M1 | retornos constantes | 0,202 | 0,116 | sem indício |

- Em 2018 (M2): 20 países em DRS, 3 em IRS, 4 em CRS. Eficiência média VRS por ano: 0,64 a 0,82; eficiência de escala média: 0,54 a 0,76.
- Por país: 15 dos 36 operam sob retornos decrescentes em todos os anos (Estados Unidos, SE média 0,35; Japão 0,67; Reino Unido 0,41); a **China está em CRS, com eficiência de escala 1, em todos os anos**; a Índia alterna (4 anos CRS, 4 DRS).
- Nota: "o teste global não decide (e, se decidisse, seria com um teste que rejeita demais); o que os dados mostram é heterogeneidade: os grandes ocidentais em retornos decrescentes, a China no tamanho de rendimento máximo. H1 fica sem apoio conclusivo".

### Slide 8 — Ranking com inferência

- Figura: `output/figures/fig1_ranking_m2.png` (página inteira; barras = IC 95% por pseudo-valores de Simar-Wilson da média anual; anos por país entre parênteses).
- Viés médio do bootstrap 0,15 (escore médio 0,72 → 0,57 corrigido). Nenhum ponto fora da própria barra; intervalo de postos: os oito primeiros vão de 1 a 13–18; Israel e Suíça têm posto fixo (35 e 36).
- Topo: Itália (2 anos) 0,80 [0,71; 0,90], Grécia (7) 0,78 [0,72; 0,84], Malásia (4) 0,77, Indonésia (2) 0,77, Índia (8) 0,77 [0,69; 0,84], Bulgária (3) 0,76; base: África do Sul (5) 0,25, Noruega (6) 0,24, Irlanda (2) 0,22, Israel (9) 0,19 [0,18; 0,20], Suíça (1) 0,15.
- Contrastes pareados (IC da diferença excluindo zero): Suíça abaixo dos 35 demais; Israel de 34; Irlanda de 32; Noruega e África do Sul de 31. A ordem dentro do topo não é distinguível.
- Nota: explicar por que Israel e Suíça ficam na base: GERD total alto (muito P&D empresarial) e produtos de IA em contagem pequenos; "eficiência" aqui mede em parte a intensidade de IA do sistema de pesquisa.

### Slide 9 — Robustez entre estimadores (R1)

- Figura: `output/figures/fig6_estimadores.png`.
- Spearman com o escore VRS (IC por bloco de país): corrigido 0,93 [0,83; 0,97]; modelo de insumo único 0,72 [0,57; 0,84]; FDH 0,70 [0,51; 0,82]; order-α 0,69 [0,48; 0,81]; order-m 0,51 [0,23; 0,70].
- Nota: fronteiras parciais (order-m) penalizam menos os vizinhos das observações-piso, por isso a concordância menor; conclusão: ranking moderadamente robusto.

### Slide 10 — Dois canais, duas histórias (H3)

- Figura: `output/figures/fig3_canais.png` (meia página) e `output/figures/fig7_metafronteira.png` (meia página).
- Spearman entre eficiência acadêmica e tecnológica: 0,52 [0,31; 0,69] com bootstrap por país; p unilateral de ρ ≥ 0,5 = 0,59 (sem piso: 0,56, p = 0,72): correlação moderada no ponto, H3a inconclusiva.
- Metafronteira: razão de gap tecnológico 0,62 (alta renda) contra 0,94 (renda média); Mann-Whitney unilateral p = 1,0 e diferença de TGR médio +0,32 [0,23; 0,40]. Resultado **oposto** ao previsto: com contagens, o grupo de renda média define a fronteira (China, Índia, México, Peru).
- Diferenças por renda no canal de patentes: Kruskal-Wallis (3 grupos) p = 0,001 em país-ano e 0,022 em médias por país (0,34 na renda média-alta contra 0,17 na alta renda); publicações e modelo conjunto não.
- Nota: ligar ao problema volume × qualidade do slide 4.

### Slide 11 — Dinâmica 2016–2019 (H4)

- Figura: `output/figures/fig2_malmquist_decomposicao.png`.

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência [intervalo] |
|---|---|---|---|---|
| Alta renda | 10 | 0,996 | 0,898 | 1,109 [1,007; 1,230] |
| Renda média | 6 | 1,000 | 0,931 | 1,074 [0,958; 1,262] |
| Todos | 16 | 0,997 | 0,910 | 1,096 [1,010; 1,197] |

- Intervalos por reamostragem de países com índices fixos (descritivos; não propagam a incerteza das fronteiras). Parcela da mudança técnica na variância de log M (covariância rateada): 0,60. A fronteira domina (H4a), mas recua em produtos por dólar durante o boom de investimento.
- Catch-up da renda média 1,074 [0,958; 1,262]: critério numérico não atendido; a alta renda tem catch-up acima de 1 (1,109 [1,007; 1,230]); β-convergência com a fronteira do painel balanceado +0,11 (p = 0,11): H4b não apoiada. Maiores ganhos: Brasil 1,45, Áustria 1,27, Polônia 1,25; maiores perdas: China 0,65, Hungria 0,81, Japão 0,82.
- Em palavras simples: a produtividade sobe porque "os campeões avançaram" (todos aprenderam a fazer IA melhor) ou porque "o país se aproximou dos campeões"; o Malmquist separa os dois pedaços; aqui o primeiro domina e quem se aproximou foram, em média, os ricos.

### Slide 12 — Segundo estágio (H5, H6, H7)

- Figura: `output/figures/fig4_segundo_estagio.png`.

| Modelo | Variável | Coeficiente | IC 95% |
|---|---|---|---|
| H5 conjunto (191 obs., 36 países) | efetividade governamental | −0,58 | [−1,31; 0,02] |
| H5 sem piso (169/34) | efetividade governamental | −0,66 | [−1,69; 0,02] |
| H6 patentes (191/36) | capitalização de mercado | 0,000 | [−0,015; 0,023] |
| H7 patentes (191/36) | log PIB per capita | −0,53 | [−1,80; 0,27] |
| H7 publicações (191/36) | log PIB per capita | −0,36 | [−0,66; −0,02] |

- Dependente: log do escore corrigido, truncada em 0 (suporte compatível com o escore); positivo = mais eficiente (semi-elasticidade); escores fixos e bootstrap por país, todas as réplicas convergentes.
- Comparações: escore truncado só em 1 (versão anterior) −0,137 [−0,329; −0,000]; algoritmo 2 de Simar-Wilson (Farrell, positivo = menos eficiente) +10,1 [5,4; 15,3]; Tobit −0,116 (p < 0,001). Quatro procedimentos dão o mesmo sinal negativo para as instituições, mas a especificação principal não o distingue de zero; nenhum testa separabilidade, então a leitura é exploratória.
- Leitura: H5 não apoiada (sinal negativo, não significativo na principal, não robusto ao piso), H6 não apoiada, H7 contrariada. Com produtos em volume, "eficiência" cresce com o tamanho relativo do sistema de IA, não com a qualidade institucional.

### Slide 13 — Eficiência por grupo de renda e ano

- Figura: `output/figures/fig5_renda_ano.png`.
- Nota: sem tendência clara ao longo do tempo; dispersão maior nos anos com menos países (2020–2021).

### Slide 14 — Síntese por hipótese

| Hipótese | Evidência | Status |
|---|---|---|
| H1 escala | teste global sem indício contra CRS (p = 0,09; tamanho ≈ 0,20); EUA em DRS, China em CRS | sem apoio conclusivo; heterogeneidade por país |
| H2 insumos por canal | GERD eleva a eficiência média (M1 0,42–0,71 → M2 0,64–0,82) | a testar com SFA |
| H3a canais | ρ = 0,52 [0,31; 0,69], p(ρ ≥ 0,5) = 0,59 | inconclusiva |
| H3b metafronteira | TGR média 0,94 > alta 0,62; diferença +0,32 [0,23; 0,40] | não apoiada (sinal contrário) |
| H4a dinâmica | fronteira domina (parcela 0,60) e recua | apoiada |
| H4b convergência | EC média 1,074 [0,958; 1,262]; β +0,11 (p = 0,11) | critério não atendido |
| H5 instituições | efetividade −0,58 [−1,31; 0,02]; sinal negativo em quatro procedimentos | não apoiada |
| H6 finanças | coeficientes nulos | não apoiada |
| H7 desenvolvimento | PIB pc negativo em publicações, nulo em patentes | contrariada |
| R1 estimadores | ρ entre 0,51 e 0,93 | moderadamente robusto |

### Slide 15 — O que muda na versão artigo (painel reconstruído)

- Painel CSET + World Bank: 47 países (com Alemanha, Coreia, Canadá, nórdicos, Rússia), 2016–2024; modelo conjunto 2017–2021 com insumos defasados; 39 a 44 países por ano (204 observações). teste de RTS sem indício contra retornos constantes (S = 0,577, p = 0,44; M1: S = 0,347, p = 0,33; teste com tamanho ≈ 0,20); China, Coreia e Índia em CRS.
- Resultados preservados: instituições com sinal negativo e significativo (−0,69 [−1,20; −0,21], log do escore, 144 casos completos em 38 países); sem convergência (EC da renda média 0,984 [0,909; 1,062]); canal de patentes mais eficiente na renda média-alta. Diferença: no painel a mudança de eficiência varia mais que a técnica (parcela de TC 0,26), então H4a não vale como dominância.
- **Produtos alternativos (citações e famílias posteriormente concedidas)**: a metafronteira inverte por especificação, confirmado em amostra e fronteira comuns (0,59/0,87 em volume contra 0,94/0,83); Índia, Grécia, Austrália, Malásia e Singapura no topo; a associação com instituições se atenua de forma distinguível de zero (diferença de coeficientes +0,43 [0,05; 0,75]); ranking ρ = 0,78 com a base.
- P&D executado por ensino superior e governo como insumo: Israel 0,16 → 0,22 (composição da amostra) → 0,47 (insumo); Irlanda 0,20 → 0,38 (composição) → 0,46; a inversão da metafronteira nessa variante é composição da amostra (saem cinco países de renda média e a Arábia Saudita), não o insumo.
- Nota: apresentar como "próximos passos já executados".

### Slide 16 — Robustez à fonte dos dados

- Checagens entre fornecedores (bootstrap por país): investimento CSET × Quid ρ = 0,93 (84 países); CSET (VC + PE + fusões) × Preqin (só VC) ρ = 0,83 [0,76; 0,89]; publicações CSET × OECD.AI ρ = 0,95; patentes CSET (país de prioridade) × OCDE (país do inventor) ρ = 0,75 [0,61; 0,85].
- Trocar a fonte do insumo (Preqin) ou das patentes (inventor) mantém a ordem geral dos rankings em amostra e fronteira comuns (ρ = 0,87 e 0,91); as instituições continuam negativas com a Preqin (−1,12 [−1,58; −0,13]) e ficam no limite com patentes por inventor (−0,29 [−0,71; 0,01]); muda posições específicas (a China passa a DRS com patentes por inventor; Estados Unidos sobem ao topo, 0,74) e a correlação entre canais (0,30 com patentes por inventor).
- Nota: "os fornecedores preservam a ordem geral; a atribuição das patentes e a escolha dos produtos mudam resultados específicos".

### Slide 17 — Limitações

- **Medida**: produtos em contagem (volume) e insumo de P&D não específico de IA; famílias de patentes atribuídas ao país de prioridade (primeiro depósito), não ao país do inventor; cobertura do Crunchbase; granularidade de 1 milhão de dólares no investimento; citações e famílias concedidas não isolam qualidade de volume e maturação.
- **Dimensionalidade**: poucas DMUs por ano (16 a 27) com quatro variáveis: muitas unidades eficientes e intervalos largos.
- **Inferência**: teste de retornos de escala com tamanho ≈ 0,20 nas duas implementações (diagnóstico exploratório); intervalos do Malmquist por reamostragem de países com índices fixos; pseudo-valores do ranking condicionais às fronteiras anuais; segundo estágio com escores fixos, sem propagar a incerteza da fronteira.
- **Separabilidade**: segundo estágio condicionado à separabilidade, ainda sem teste formal (Daraio, Simar e Wilson, 2018, na versão artigo).

### Slide 18 — Conclusões e próximos passos

- Três mensagens: (1) retornos de escala heterogêneos: Estados Unidos, Japão e Reino Unido em retornos decrescentes, China sobre o raio de produtividade máxima, e o teste global, liberal, não fornece indício contra retornos constantes; a fronteira recua em produtos por dólar durante o boom; (2) os dois canais divergem e o de patentes é o mais sensível a renda e à atribuição das patentes; (3) medir eficiência em IA exige produtos alternativos (citações, famílias concedidas) e P&D por setor de execução: com fronteira comum, a troca de produtos atenua a associação negativa com instituições de forma distinguível de zero; sem isso, "eficiência" confunde-se com intensidade relativa de IA.
- Próximos passos do artigo: SFA por canal com classes latentes, teste de separabilidade formal, inferência de dois estágios para painel e bootstrap de Malmquist, matriz de robustez consolidada, manuscrito em português para periódico Qualis.
- Nota final: agradecer e abrir para perguntas.

### Referências para o slide de bibliografia (opcional, slide 19)

Mesmo formato da lista de `artigo/01_hipoteses.md`. Em duas colunas; título do artigo em redondo e periódico em itálico.

- Banker, R. D.; Charnes, A.; Cooper, W. W. (1984). Some models for estimating technical and scale inefficiencies in data envelopment analysis. *Management Science*, 30(9), 1078–1092.
- Bogetoft, P.; Otto, L. (2011). *Benchmarking with DEA, SFA, and R*. Springer.
- Cazals, C.; Florens, J.-P.; Simar, L. (2002). Nonparametric frontier estimation: a robust approach. *Journal of Econometrics*, 106(1), 1–25.
- Charnes, A.; Cooper, W. W.; Rhodes, E. (1978). Measuring the efficiency of decision making units. *European Journal of Operational Research*, 2(6), 429–444.
- Cohen, W. M.; Levinthal, D. A. (1990). Absorptive capacity: a new perspective on learning and innovation. *Administrative Science Quarterly*, 35(1), 128–152.
- Daraio, C.; Simar, L. (2005). Introducing environmental variables in nonparametric frontier models: a probabilistic approach. *Journal of Productivity Analysis*, 24, 93–121.
- Daraio, C.; Simar, L.; Wilson, P. W. (2018). Central limit theorems for conditional efficiency measures and tests of the "separability" condition in non-parametric, two-stage models of production. *The Econometrics Journal*, 21(2), 170–191.
- Ernst, E.; Mishra, S. (2021). AI Efficiency Index: identifying regulatory and policy constraints for resilient national AI ecosystems. *SSRN Working Paper* 3800783.
- Färe, R.; Grosskopf, S.; Norris, M.; Zhang, Z. (1994). Productivity growth, technical progress, and efficiency change in industrialized countries. *American Economic Review*, 84(1), 66–83.
- Furman, J. L.; Porter, M. E.; Stern, S. (2002). The determinants of national innovative capacity. *Research Policy*, 31(6), 899–933.
- Holý, V.; Šafr, K. (2018). Are economically advanced countries more efficient in basic and applied research? *Central European Journal of Operations Research*, 26, 933–950.
- Hsu, P.-H.; Tian, X.; Xu, Y. (2014). Financial development and innovation: cross-country evidence. *Journal of Financial Economics*, 112(1), 116–135.
- O'Donnell, C. J.; Rao, D. S. P.; Battese, G. E. (2008). Metafrontier frameworks for the study of firm-level efficiencies and technology ratios. *Empirical Economics*, 34, 231–255.
- Simar, L.; Wilson, P. W. (1998). Sensitivity analysis of efficiency scores: how to bootstrap in nonparametric frontier models. *Management Science*, 44(1), 49–61.
- Simar, L.; Wilson, P. W. (1999). Estimating and bootstrapping Malmquist indices. *European Journal of Operational Research*, 115(3), 459–471.
- Simar, L.; Wilson, P. W. (2002). Non-parametric tests of returns to scale. *European Journal of Operational Research*, 139(1), 115–132.
- Simar, L.; Wilson, P. W. (2007). Estimation and inference in two-stage, semi-parametric models of production processes. *Journal of Econometrics*, 136(1), 31–64.

## 5. Fontes dos números

`artigo/05_resultados_fase_a.md` (slides 3–14), `artigo/06_resultados_painel.md` (slides 15–16), `artigo/12_avaliacao_reanalise.md` (seções 1 e 2 deste brief), tabelas em `output/tables/` (`teste_rts`, `validacao_teste_rts`, `rts_por_pais_m2`, `ranking_paises_boot`, `ranking_contrastes_resumo`, `spearman_estimadores_m2`, `spearman_canais`, `metafronteira_resumo`, `testes_grupo_renda`, `malmquist_resumo`, `malmquist_decomposicao_variancia`, `malmquist_beta_convergencia`, `segundo_estagio_truncada`, `segundo_estagio_simar_wilson_m2`, `segundo_estagio_tobit`, `supereficiencia_cruzada_piso`, `comparacao_*_amostra_comum`) e figuras em `output/figures/`.
