# Brief para o deck da apresentação (28/09/2026) — usar no Claude Design

**Revisão 2, de 27/09/2026.** Substitui a revisão 1 (commit `ae6c878`), que gerou o deck `AI Effiency Analysis.pdf` (19 páginas, na raiz do repositório). A revisão 2 incorpora as correções da análise crítica (`artigo/10_avaliacao_inconsistencias.md`) e a reexecução completa do pipeline em 27/09/2026 (manifesto em `output/tables/manifesto_execucoes.csv`). Todos os números abaixo foram conferidos contra as tabelas de `output/tables/` nesta revisão.

Como usar: para **regenerar o deck do zero**, usar as seções "Instruções" e "Slides"; para **editar o deck já gerado**, seguir a seção "O que alterar no deck já gerado", página a página. Nos dois casos, as sete figuras precisam ser embutidas como imagem (ver seção 2).

## 1. O que mudou da revisão 1 para a revisão 2

| Tema | Revisão 1 (deck atual) | Revisão 2 | Origem (`artigo/10`) |
|---|---|---|---|
| Teste de retornos de escala (Fase A) | CRS rejeitado com p < 0,001; NIRS p = 0,60; "Estados Unidos e China sempre em retornos decrescentes" | CRS rejeitado com p = 0,025 (teste liberal: rejeita CRS verdadeiro em 20% das simulações); NIRS p = 0,89; **China em CRS em todos os anos**, Estados Unidos em DRS; H1 passa a "parcialmente apoiada" | I02, I09 |
| Teste de retornos de escala (painel) | "confirma retornos variáveis (p < 0,001)" | **não rejeita CRS** (p = 0,10); China, Coreia e Índia em CRS | I09 |
| Ranking (Figura 1) | barras = média dos limites anuais, chamadas de IC 95%; "largura média do IC 0,24" | barras = IC 95% bootstrap da média anual, por réplicas; anos por país no rótulo; intervalos largos no topo e estreitos na base; base: Israel 0,18, Irlanda 0,21, Noruega 0,23 | I04 |
| Supereficiência e piso | "as unidades além da fronteira são exatamente essas (China, Austrália, México 2013; Peru e Índia 2019–2020)" | 19 supereficientes, **7 no piso** e 12 fora dele (pontos extremos ou revisões de safra) | I17 |
| Canais (H3a) | ρ = 0,52 [0,40; 0,63], "correlação moderada" | ρ = 0,52 [0,31; 0,69] com bootstrap por país; p unilateral de ρ ≥ 0,5 = 0,59: **inconclusiva** | I13, I14 |
| Metafronteira (H3b) | 0,62 vs 0,94, "p < 0,001" (teste de diferença entre grupos) | 0,62 vs 0,94; H3b redefinida como TGR(média) < TGR(alta), p = 1,0: **não apoiada** | I13 |
| Kruskal-Wallis | p < 0,001 em país-ano | p = 0,001 em país-ano e 0,020 em médias por país | I14 |
| Malmquist (H4a) | "mudança técnica explica 58% da variância" (soma das variâncias) | parcela de TC na variância de log M com covariância rateada: **0,60** na Fase A e **0,26 no painel** (no painel H4a não vale como dominância) | I11 |
| Convergência (H4b) | "catch-up 1,11 vs 1,07: sem convergência" | EC da renda média 1,07 com IC [0,96; 1,26] (inclui 1); β-convergência p = 0,47; ICs por bloco de país na tabela | I12 |
| Segundo estágio | "Simar-Wilson alg. 2 e Tobit concordam nos sinais"; N não declarado; sem piso −0,120 [−0,362; 0,013] | rótulo "truncada, escores fixos, bootstrap por país"; N = casos completos (191/36; 169/34); sem piso −0,121 [−0,363; 0,012]; parametrização em Farrell como sensibilidade; três procedimentos com fronteiras e amostras distintas dão o mesmo sinal; nenhum testa separabilidade | I06, I07, I08, I10, I21 |
| Painel: instituições | −0,18 [−0,30; −0,06] | −0,18 [−0,31; −0,06], 144 casos completos em 38 países | I06 |
| Painel: "ajuste por qualidade" | "metafronteira inverte (TGR 0,84 vs 0,94), a associação com instituições desaparece" | "produtos alternativos (citações; famílias posteriormente concedidas)"; inversão confirmada na amostra comum (0,59/0,87 → 0,94/0,83); associação "deixa de ser distinguível de zero", diferença de coeficientes 0,07 [−0,03; 0,18] (não significativa) | I15, I20 |
| Painel: P&D público | "P&D público (HERD + GOVERD) corrige Israel e Irlanda" e inverte a metafronteira | "P&D executado por ensino superior e governo"; corrige Israel e Irlanda; a inversão nessa variante é **composição da amostra** (saem seis países de renda média) | I03, I18 |
| Fontes | "CSET × Preqin (513 país-ano)"; "CSET (escritório) × OCDE (inventor)"; "o que altera é a qualidade, não o fornecedor" | CSET (VC + PE + fusões) × Preqin (só VC) 0,83 [0,76; 0,89]; CSET (país de prioridade) × OCDE (país do inventor) 0,75 [0,61; 0,85]; frase substituída pela descrição do que muda em cada dimensão | I20, I24 |
| Dados | "sem Alemanha, Coreia, Canadá e nórdicos" | "sem Alemanha, Coreia, Canadá, Suécia, Finlândia e Dinamarca" (a Noruega está na base); 37 países na base bruta, 36 países e 191 observações na DEA | I23 |
| Limitações | patentes "atribuídas ao escritório de depósito" | famílias atribuídas ao país de prioridade (primeiro depósito); teste de RTS liberal; segundo estágio com escores fixos; "qualidade" não isolada de volume e maturação | I07, I09, I20 |
| Conclusão 1 | "retornos decrescentes e fronteira que recua" | retornos de escala heterogêneos (grandes ocidentais em DRS, China em CRS, painel não rejeita CRS); fronteira recua em produtos por dólar | I02, I09 |
| Figuras | nenhuma foi embutida (o PDF tem zero imagens; as páginas 8 a 13 mostram só o caminho do PNG) | embutir as sete figuras; fig1, fig3, fig4 e fig6 foram regeneradas com conteúdo novo; fig2, fig5 e fig7 não mudaram | I05 |

## 2. O que alterar no deck já gerado (`AI Effiency Analysis.pdf`, página a página)

Geral, antes de tudo:

- **Embutir as figuras** de `output/figures/` (sem sufixo) como imagem, não como caminho: fig1 (p. 8), fig6 (p. 9), fig3 e fig7 (p. 10), fig2 (p. 11), fig4 (p. 12), fig5 (p. 13). As caixas hoje estão vazias.
- Figuras com conteúdo novo desde a revisão 1: **fig1** (barras = IC bootstrap da média anual; rótulo com anos por país), **fig3** (subtítulo com o novo IC [0,31; 0,69]), **fig4** (título "truncada, escores fixos, bootstrap por país"; só a parametrização em escore), **fig6** (barras de IC por bloco de país). Sem mudança: fig2, fig5, fig7.
- Ao reexportar, conferir cada página e substituir o arquivo na raiz mantendo o mesmo nome (ou renomear para `AI Efficiency Analysis.pdf` com `git mv`, corrigindo a grafia).

| Página | Está no deck (revisão 1) | Trocar por (revisão 2) |
|---|---|---|
| 1, 2 | — | sem alteração |
| 3 | "sem Alemanha, Coreia, Canadá e nórdicos" | "sem Alemanha, Coreia, Canadá, Suécia, Finlândia e Dinamarca"; sob o "37 países", acrescentar "36 países e 191 observações na DEA (Eslovênia: 1 observação, investimento zero)" |
| 4 | "As unidades 'além da fronteira' são exatamente essas: China, Austrália e México 2013; Peru e Índia 2019–2020." | "19 unidades além da fronteira agrupada: 7 no piso (Austrália e México 2013, Romênia e Malásia 2016, Ucrânia 2018, Peru 2019, Bulgária 2021); as outras 12 (China 2013 e 2019–2021, Índia 2013, 2016 e 2019–2020, Malásia 2015, México 2018, Peru 2020, Romênia 2020) são pontos extremos ou revisões de safra, não granularidade." |
| 5 | H2 "(dado o P&D público)"; H3 "renda média abaixo da metafronteira"; H4 "renda média converge" | H2 "(dado o P&D não empresarial)"; H3 "gap tecnológico maior na renda média que na alta renda"; H4 "renda média converge (catch-up > 1 com IC excluindo 1)" |
| 6 | "teste de retornos de escala"; "Regressão truncada com bootstrap agrupado por país, Simar-Wilson algoritmo 2 e Tobit; Kruskal-Wallis por renda" | "teste de retornos de escala adaptado de Simar e Wilson (2002), tamanho verificado por simulação"; "Regressão truncada com escores fixos e bootstrap por país (duas parametrizações), algoritmo 2 de Simar-Wilson e Tobit; Kruskal-Wallis e Mann-Whitney por renda, em país-ano e em médias por país" |
| 7 | p-valor M2/CRS "< 0,001" e decisão "rejeita"; M2/NIRS "0,60"; "Estados Unidos e China sempre em retornos decrescentes." | "0,025" e "rejeita (teste liberal)"; "0,89"; "15 dos 36 países em retornos decrescentes em todos os anos (Estados Unidos, Japão, Reino Unido); a China está em CRS, com eficiência de escala 1, em todos os anos; a Índia alterna." Os números grandes "20 DRS · 3 IRS · 4 CRS (2018)" continuam corretos. |
| 8 | "largura média do IC 0,24"; base "Israel 0,19 · Irlanda 0,22 · Noruega 0,24"; "Diferença ordinal defensável só entre grupos com intervalos disjuntos." | retirar a largura média; "barras = IC 95% bootstrap da média anual (anos por país entre parênteses): largas no topo, estreitas na base"; base "Israel 0,18 · Irlanda 0,21 · Noruega 0,23"; "Só a separação entre a base (Israel, Suíça, Noruega, Irlanda, África do Sul) e o restante é ordinalmente defensável; a ordem dentro do topo não." Embutir fig1. |
| 9 | correlações sem IC | opcional: acrescentar os ICs (0,93 [0,83; 0,97]; M1 0,72 [0,57; 0,84]; FDH 0,70 [0,51; 0,82]; order-α 0,69 [0,48; 0,81]; order-m 0,51 [0,23; 0,70]). Embutir fig6. |
| 10 | "0,52 [0,40; 0,63] — correlação moderada (0,56 sem valores-piso)"; "0,62 alta renda vs 0,94 renda média (p < 0,001) — oposto ao previsto"; "Patentes diferem por renda (0,34 vs 0,17)" | "0,52 [0,31; 0,69], bootstrap por país; p unilateral de ρ ≥ 0,5 = 0,59: H3a inconclusiva"; "0,62 alta renda vs 0,94 renda média; H3b (renda média abaixo da alta) p = 1,0: oposto ao previsto"; "Patentes diferem por renda (0,34 vs 0,17; p = 0,001 em país-ano, 0,020 em médias por país); publicações não." Embutir fig3 e fig7. |
| 11 | "Mudança técnica explica 58% da variância"; "Catch-up 1,11 vs 1,07: sem convergência (H4b não apoiada)"; tabela sem IC | "Parcela da mudança técnica na variância de log M (covariância rateada): 0,60"; "Catch-up da renda média 1,07 [0,96; 1,26], IC inclui 1; alta renda 1,11 [1,01; 1,23]; β-convergência nula (p = 0,47): H4b não apoiada"; coluna de IC na mudança de eficiência (tabela do slide 11 abaixo). Embutir fig2. |
| 12 | "H5 sem piso −0,120 [−0,362; 0,013]"; "Simar-Wilson alg. 2 e Tobit concordam nos sinais. H5 e H6 não confirmadas" | "−0,121 [−0,363; 0,012]"; N nos rótulos ("H5 conjunto, 191 obs./36 países"; "sem piso, 169/34"); "escores fixos e bootstrap por país; algoritmo 2 (fronteira agrupada) e Tobit dão o mesmo sinal; nenhum testa separabilidade: leitura exploratória. H5 não confirmada (sinal negativo, não robusto ao piso), H6 não confirmada." Embutir fig4. |
| 13 | — | texto sem alteração. Embutir fig5. |
| 14 | H1 "CRS rejeitado, NIRS não rejeitado; maioria DRS / apoiada"; H3 "ρ = 0,52; gap tecnológico maior na alta renda / parcial · contrariada"; H4 "Fronteira domina; sem convergência"; H5 "Sinal negativo em três métodos" | H1 "CRS rejeitado (p = 0,025, teste liberal); EUA em DRS, China em CRS / parcialmente apoiada"; H3 "ρ = 0,52, p(ρ ≥ 0,5) = 0,59; gap maior na alta renda / H3a inconclusiva · H3b não apoiada"; H4 "fronteira domina (0,60); EC média 1,07 [0,96; 1,26] / H4a sim · H4b não"; H5 "sinal negativo em três procedimentos, com fronteiras e amostras distintas; não robusto ao piso" |
| 15 | "RTS confirma retornos variáveis (S = 0,577, p < 0,001; NIRS p = 0,45)"; "−0,18 [−0,30; −0,06]"; caixa "AJUSTE POR QUALIDADE (CITAÇÕES E PATENTES CONCEDIDAS)": "metafronteira inverte (TGR 0,84 vs 0,94), a associação negativa com instituições desaparece"; "P&D público (HERD + GOVERD) como insumo corrige Israel e Irlanda" | "teste de RTS não rejeita retornos constantes (S = 0,577, p = 0,10); China, Coreia e Índia em CRS; 39 a 44 países por ano"; "−0,18 [−0,31; −0,06], 144 casos completos"; "sem convergência (EC média 0,98 [0,91; 1,06]); no painel a mudança de eficiência varia mais que a técnica (parcela 0,26)"; caixa "PRODUTOS ALTERNATIVOS (CITAÇÕES; FAMÍLIAS POSTERIORMENTE CONCEDIDAS)": "a metafronteira inverte por especificação, confirmado na amostra comum (0,59/0,87 → 0,94/0,83); a associação com instituições deixa de ser distinguível de zero, mas a diferença de coeficientes não é significativa (0,07 [−0,03; 0,18])"; "P&D executado por ensino superior e governo como insumo corrige Israel (0,16 → 0,47) e Irlanda (0,20 → 0,46); a inversão da metafronteira nessa variante é composição da amostra (saem seis países de renda média), não o insumo" |
| 16 | "Investimento: CSET × Preqin (OECD.AI), 513 país-ano"; "Patentes: CSET (escritório) × OCDE (inventor)"; "mantém a ordem geral (ρ = 0,89 e 0,85) e os sinais do segundo estágio; mudam posições específicas: China, Estados Unidos, Japão, Suíça, Irlanda" | "CSET (VC + PE + fusões) × Preqin (só VC), 0,83 [0,76; 0,89]"; "CSET (país de prioridade) × OCDE (país do inventor), 0,75 [0,61; 0,85]"; "mantém a ordem geral (ρ = 0,89 e 0,85) e o sinal das instituições; muda posições específicas (a China passa a DRS com patentes por inventor; Estados Unidos e Japão sobem) e a correlação entre canais (0,30 com patentes por inventor)" |
| 17 | "patentes atribuídas ao escritório de depósito" (coluna Medida); três colunas | "famílias de patentes atribuídas ao país de prioridade (primeiro depósito), não ao país do inventor"; acrescentar a coluna "Inferência" (teste de RTS liberal; segundo estágio com escores fixos, sem propagar a incerteza da fronteira; dependência dentro do país tratada por blocos); na coluna Medida, "citações e famílias concedidas não isolam qualidade de volume e maturação" |
| 18 | "1 Retornos decrescentes e fronteira que recua em produtos por dólar durante o boom"; "3 ... ajustar produtos por qualidade e separar P&D público de privado" | "1 Retornos de escala heterogêneos: Estados Unidos, Japão e Reino Unido em retornos decrescentes, China sobre o raio CRS, e o painel não rejeita CRS; a fronteira recua em produtos por dólar durante o boom"; "3 ... usar produtos alternativos (citações, famílias concedidas) e P&D por setor de execução; sem isso, 'eficiência' confunde-se com intensidade relativa de IA; as diferenças entre especificações ainda não são distinguíveis de zero"; próximos passos: acrescentar "inferência de dois estágios para painel" |
| 19 | bibliografia | acrescentar Daraio, Simar e Wilson (2018) |

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
| H2 | Investimento privado importa para patentes, não para publicações, dado o P&D não empresarial |
| H3 | H3a: canais acadêmico e tecnológico pouco correlacionados (ρ < 0,5); H3b: gap tecnológico maior na renda média que na alta renda |
| H4 | H4a: mudança de fronteira domina a variação de produtividade; H4b: renda média converge (catch-up > 1 com IC excluindo 1) |
| H5 | Instituições e capacidade de absorção elevam a eficiência |
| H6 | Mercado de capitais (não crédito) eleva a eficiência em patentes |
| H7 | PIB per capita associado à eficiência em patentes, não em publicações |

- Nota: mencionar as proposições de robustez R1 (estimadores), R2 (defasagens) e R3 (produtos alternativos).

### Slide 6 — Método

- Modelos: M1 (insumo único: investimento; replicação de Ernst e Mishra) e M2 (investimento + GERD; base); canais separados (só publicações, só patentes).
- Fronteiras contemporâneas por ano (16 a 27 países por ano), orientação a produto, CRS/VRS/NIRS; eficiência de escala e classificação de retornos por país. Fronteira agrupada só para supereficiência, metafronteira, teste de retornos de escala e algoritmo 2.
- Inferência: bootstrap de Simar-Wilson (1.000 réplicas) com intervalos de 95%; teste de retornos de escala adaptado de Simar e Wilson (2002), com tamanho verificado por simulação; correlações com bootstrap em blocos de país.
- Robustez: FDH, order-m, order-α; metafronteira por grupo de renda; Malmquist (CRS) no painel balanceado 2016–2019 (16 países) com IC por bloco de país.
- Segundo estágio: regressão truncada com escores fixos e bootstrap por país (duas parametrizações), algoritmo 2 de Simar-Wilson e Tobit; Kruskal-Wallis e Mann-Whitney por renda, em país-ano e em médias por país.
- Nota: tudo em R (Benchmarking, rDEA, nonparaeff, frontiles, truncreg), scripts reproduzíveis.

### Slide 7 — Escala e retornos (H1)

| Modelo | H0 | S | p-valor | Decisão |
|---|---|---|---|---|
| M2 | retornos constantes | 0,666 | 0,025 | rejeita (teste liberal: tamanho 0,20 sob CRS) |
| M2 | retornos não crescentes | 0,989 | 0,89 | não rejeita |
| M1 | retornos constantes | 0,202 | < 0,001 | rejeita |

- Em 2018 (M2): 20 países em DRS, 3 em IRS, 4 em CRS. Eficiência média VRS por ano: 0,64 a 0,82; eficiência de escala média: 0,54 a 0,76.
- Por país: 15 dos 36 operam sob retornos decrescentes em todos os anos (Estados Unidos, SE média 0,35; Japão 0,67; Reino Unido 0,41); a **China está em CRS, com eficiência de escala 1, em todos os anos**; a Índia alterna (4 anos CRS, 4 DRS).
- Nota: "a tecnologia parece ter retornos variáveis, mas o teste é liberal e a China contradiz a leitura simples de que os grandes investidores estão em retornos decrescentes: H1 é só parcialmente apoiada".

### Slide 8 — Ranking com inferência

- Figura: `output/figures/fig1_ranking_m2.png` (página inteira; barras = IC 95% bootstrap da média anual; anos por país entre parênteses).
- Viés médio do bootstrap 0,15 (escore médio 0,72 → 0,57 corrigido). Intervalos largos no topo (países sobre a fronteira) e estreitos na base: só a separação entre a base (Israel, Suíça, Noruega, Irlanda, África do Sul) e o restante é ordinalmente defensável; a ordem dentro do topo não.
- Topo: Itália (2 anos) 0,79 [0,42; 0,89], Grécia (7) 0,77 [0,36; 0,78], Malásia (4) 0,76, Indonésia (2) 0,75, Bulgária (3) 0,75, Índia (8) 0,75; base: Suíça (1) 0,15, Israel (9) 0,18 [0,14; 0,19], Irlanda (2) 0,21, Noruega (6) 0,23, África do Sul (5) 0,25.
- Nota: explicar por que Israel e Suíça ficam na base: GERD total alto (muito P&D empresarial) e produtos de IA em contagem pequenos; "eficiência" aqui mede em parte a intensidade de IA do sistema de pesquisa.

### Slide 9 — Robustez entre estimadores (R1)

- Figura: `output/figures/fig6_estimadores.png`.
- Spearman com o escore VRS (IC por bloco de país): corrigido 0,93 [0,83; 0,97]; modelo de insumo único 0,72 [0,57; 0,84]; FDH 0,70 [0,51; 0,82]; order-α 0,69 [0,48; 0,81]; order-m 0,51 [0,23; 0,70].
- Nota: fronteiras parciais (order-m) penalizam menos os vizinhos das observações-piso, por isso a concordância menor; conclusão: ranking moderadamente robusto.

### Slide 10 — Dois canais, duas histórias (H3)

- Figura: `output/figures/fig3_canais.png` (meia página) e `output/figures/fig7_metafronteira.png` (meia página).
- Spearman entre eficiência acadêmica e tecnológica: 0,52 [0,31; 0,69] com bootstrap por país; p unilateral de ρ ≥ 0,5 = 0,59 (sem piso: 0,56, p = 0,72): correlação moderada no ponto, H3a inconclusiva.
- Metafronteira: razão de gap tecnológico 0,62 (alta renda) contra 0,94 (renda média); H3b (renda média abaixo da alta) tem p = 1,0. Resultado **oposto** ao previsto: com contagens, o grupo de renda média define a fronteira (China, Índia, México, Peru).
- Kruskal-Wallis: o canal de patentes difere por renda (p = 0,001 em país-ano, 0,020 em médias por país; 0,34 na renda média-alta contra 0,17 na alta renda); publicações e modelo conjunto não.
- Nota: ligar ao problema volume × qualidade do slide 4.

### Slide 11 — Dinâmica 2016–2019 (H4)

- Figura: `output/figures/fig2_malmquist_decomposicao.png`.

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência [IC 95%] |
|---|---|---|---|---|
| Alta renda | 10 | 0,996 | 0,898 | 1,109 [1,007; 1,230] |
| Renda média | 6 | 1,000 | 0,931 | 1,074 [0,958; 1,262] |
| Todos | 16 | 0,997 | 0,910 | 1,096 [1,010; 1,197] |

- Parcela da mudança técnica na variância de log M (covariância rateada simetricamente): 0,60. A fronteira domina (H4a), mas recua em produtos por dólar durante o boom de investimento.
- Catch-up da renda média: 1,07 com IC [0,96; 1,26], que inclui 1; a alta renda é que tem catch-up significativo (1,11 [1,01; 1,23]); β-convergência nula (p = 0,47): H4b não apoiada. Maiores ganhos: Brasil 1,45, Áustria 1,27, Polônia 1,25; maiores perdas: China 0,65, Hungria 0,81, Japão 0,82.
- Em palavras simples: a produtividade sobe porque "os campeões avançaram" (todos aprenderam a fazer IA melhor) ou porque "o país se aproximou dos campeões"; o Malmquist separa os dois pedaços; aqui o primeiro domina e quem se aproximou foram, em média, os ricos.

### Slide 12 — Segundo estágio (H5, H6, H7)

- Figura: `output/figures/fig4_segundo_estagio.png`.

| Modelo | Variável | Coeficiente | IC 95% |
|---|---|---|---|
| H5 conjunto (191 obs., 36 países) | efetividade governamental | −0,137 | [−0,329; −0,000] |
| H5 sem piso (169/34) | efetividade governamental | −0,121 | [−0,363; 0,012] |
| H6 patentes (191/36) | capitalização de mercado | 0,000 | [−0,001; 0,002] |
| H7 patentes (191/36) | log PIB per capita | −0,045 | [−0,154; 0,013] |
| H7 publicações (191/36) | log PIB per capita | −0,093 | [−0,153; −0,014] |

- Dependente: eficiência corrigida em (0, 1]; positivo = mais eficiente; escores fixos e bootstrap por país (não é o algoritmo 2). Sensibilidade na escala de Farrell (positivo = menos eficiente): efetividade +57 [0,04; 82], mesmo sentido; instável nos canais.
- Algoritmo 2 de Simar-Wilson (fronteira agrupada, Farrell): efetividade +10,5 [4,4; 15,9]; Tobit: −0,116 (p < 0,001). Três procedimentos com fronteiras e amostras distintas dão o mesmo sinal; nenhum testa separabilidade, então a leitura é exploratória.
- Leitura: H5 não confirmada (sinal negativo das instituições, no limite da significância e não robusto ao piso), H6 não confirmada, H7 contrariada. Com produtos em volume, "eficiência" cresce com o tamanho relativo do sistema de IA, não com a qualidade institucional.

### Slide 13 — Eficiência por grupo de renda e ano

- Figura: `output/figures/fig5_renda_ano.png`.
- Nota: sem tendência clara ao longo do tempo; dispersão maior nos anos com menos países (2020–2021).

### Slide 14 — Síntese por hipótese

| Hipótese | Evidência | Status |
|---|---|---|
| H1 escala | CRS rejeitado (p = 0,025, teste liberal), NIRS não rejeitado; EUA em DRS, China em CRS | parcialmente apoiada |
| H2 insumos por canal | GERD eleva a eficiência média (M1 0,42–0,71 → M2 0,64–0,82) | a testar com SFA |
| H3a canais | ρ = 0,52 [0,31; 0,69], p(ρ ≥ 0,5) = 0,59 | inconclusiva |
| H3b metafronteira | TGR média 0,94 > alta 0,62 (p = 1,0) | não apoiada |
| H4a dinâmica | fronteira domina (parcela 0,60) e recua | apoiada |
| H4b convergência | EC média 1,07 [0,96; 1,26]; β +0,04 (p = 0,47) | não apoiada |
| H5 instituições | sinal negativo em três procedimentos (fronteiras e amostras distintas); não robusto ao piso | não apoiada |
| H6 finanças | coeficientes nulos | não apoiada |
| H7 desenvolvimento | PIB pc negativo em publicações, nulo em patentes | contrariada |
| R1 estimadores | ρ entre 0,51 e 0,93 | moderadamente robusto |

### Slide 15 — O que muda na versão artigo (painel reconstruído)

- Painel CSET + World Bank: 47 países (com Alemanha, Coreia, Canadá, nórdicos, Rússia), 2016–2024; modelo conjunto 2017–2021 com insumos defasados; 39 a 44 países por ano (204 observações). Teste de RTS no painel **não rejeita** retornos constantes (S = 0,577, p = 0,10); China, Coreia e Índia em CRS.
- Resultados preservados: instituições com sinal negativo (−0,18 [−0,31; −0,06], 144 casos completos em 38 países); sem convergência (EC da renda média 0,98 [0,91; 1,06]); canal de patentes mais eficiente na renda média-alta. Diferença: no painel a mudança de eficiência varia mais que a técnica (parcela de TC 0,26), então H4a não vale como dominância.
- **Produtos alternativos (citações e famílias posteriormente concedidas)**: a metafronteira inverte por especificação, confirmado na amostra comum (0,59/0,87 em volume contra 0,94/0,83); Estados Unidos, Reino Unido, Austrália e Singapura sobem ao topo (ρ = 0,80 entre rankings). A associação com instituições deixa de ser distinguível de zero, mas a diferença de coeficientes não é significativa (0,07 [−0,03; 0,18]).
- P&D executado por ensino superior e governo como insumo corrige Israel (0,16 → 0,47) e Irlanda (0,20 → 0,46); a inversão da metafronteira nessa variante é efeito da composição da amostra (saem seis países de renda média), não do insumo.
- Nota: apresentar como "próximos passos já executados".

### Slide 16 — Robustez à fonte dos dados

- Checagens entre fornecedores (bootstrap por país): investimento CSET × Quid ρ = 0,93 (84 países); CSET (VC + PE + fusões) × Preqin (só VC) ρ = 0,83 [0,76; 0,89]; publicações CSET × OECD.AI ρ = 0,95; patentes CSET (país de prioridade) × OCDE (país do inventor) ρ = 0,75 [0,61; 0,85].
- Trocar a fonte do insumo (Preqin) ou das patentes (inventor) mantém a ordem geral dos rankings (ρ = 0,89 e 0,85) e o sinal das instituições; muda posições específicas (China passa a DRS com patentes por inventor; Estados Unidos e Japão sobem) e a correlação entre canais (0,30 com patentes por inventor).
- Nota: "os fornecedores preservam a ordem geral; a atribuição das patentes e a escolha dos produtos mudam resultados específicos".

### Slide 17 — Limitações

- **Medida**: produtos em contagem (volume) e insumo de P&D não específico de IA; famílias de patentes atribuídas ao país de prioridade (primeiro depósito), não ao país do inventor; cobertura do Crunchbase; granularidade de 1 milhão de dólares no investimento; citações e famílias concedidas não isolam qualidade de volume e maturação.
- **Dimensionalidade**: poucas DMUs por ano (16 a 27) com quatro variáveis: muitas unidades eficientes e intervalos largos.
- **Inferência**: teste de retornos de escala liberal (tamanho 0,20 a 5%); segundo estágio com escores fixos, que não propaga a incerteza da fronteira; observações do mesmo país tratadas por blocos, mas a dependência pela fronteira compartilhada não é modelada.
- **Separabilidade**: segundo estágio condicionado à separabilidade, ainda sem teste formal (Daraio, Simar e Wilson, 2018, na versão artigo).

### Slide 18 — Conclusões e próximos passos

- Três mensagens: (1) retornos de escala heterogêneos: Estados Unidos, Japão e Reino Unido em retornos decrescentes, China sobre o raio de produtividade máxima, e o painel não rejeita retornos constantes; a fronteira recua em produtos por dólar durante o boom; (2) os dois canais divergem e o de patentes é o mais sensível a renda e à atribuição das patentes; (3) medir eficiência em IA exige produtos alternativos (citações, famílias concedidas) e P&D por setor de execução; sem isso, "eficiência" confunde-se com intensidade relativa de IA, e as diferenças entre especificações ainda não são distinguíveis de zero.
- Próximos passos do artigo: SFA por canal com classes latentes, teste de separabilidade formal, inferência de dois estágios para painel, matriz de robustez consolidada, manuscrito em português para periódico Qualis.
- Nota final: agradecer e abrir para perguntas.

### Referências mínimas para o slide de bibliografia (opcional, slide 19)

Banker, Charnes e Cooper (1984); Charnes, Cooper e Rhodes (1978); Simar e Wilson (1998, 2002, 2007); Cazals, Florens e Simar (2002); Daraio e Simar (2005); Daraio, Simar e Wilson (2018); Färe et al. (1994); O'Donnell, Rao e Battese (2008); Furman, Porter e Stern (2002); Cohen e Levinthal (1990); Ernst e Mishra (2021); Holý e Šafr (2018); Hsu, Tian e Xu (2014); Bogetoft e Otto (2011).

## 5. Fontes dos números

`artigo/05_resultados_fase_a.md` (slides 3–14), `artigo/06_resultados_painel.md` (slides 15–16), `artigo/10_avaliacao_inconsistencias.md` (seções 1 e 2 deste brief), tabelas em `output/tables/` (`teste_rts`, `validacao_teste_rts`, `rts_por_pais_m2`, `ranking_paises_boot`, `spearman_estimadores_m2`, `spearman_canais`, `metafronteira_resumo`, `testes_grupo_renda`, `malmquist_resumo`, `malmquist_decomposicao_variancia`, `malmquist_beta_convergencia`, `segundo_estagio_truncada`, `segundo_estagio_simar_wilson_m2`, `segundo_estagio_tobit`, `supereficiencia_cruzada_piso`, `comparacao_*_amostra_comum`) e figuras em `output/figures/`.
