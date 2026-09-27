# Brief para o deck da apresentação (28/09/2026) — usar no Claude Design

## Instruções para o Claude Design

- Formato: apresentação 16:9, 18 slides, 20 minutos de fala, em português do Brasil, tom acadêmico e direto. Título da disciplina no rodapé: "Introdução à Análise de Eficiência em R — Prof. Peter Wanke".
- Autor: Fernando Silva. Título do trabalho: **"Quem converte melhor investimento em IA em ciência e patentes? Uma análise de fronteira para 37 países (2013–2021)"**.
- Identidade visual: fundo claro, uma cor de destaque (azul #1f77b4) e uma de contraste (laranja #ff7f0e), cinza para texto secundário; tipografia sem serifa; no máximo 5 bullets por slide; números grandes em destaque quando indicado. Figuras: usar os PNGs indicados (caminhos abaixo, pasta `output/figures/`, sem sufixo), em página inteira ou meia página; não redesenhar gráficos.
- Cada slide abaixo traz: título, conteúdo (bullets ou tabela), figura (se houver) e nota do apresentador (o que falar, 60–80 segundos por slide).
- Escala dos escores: eficiência técnica em (0, 1], orientação a produto; 1 = na fronteira; "corrigido de viés" = após bootstrap de Simar-Wilson.

## Slide 1 — Título

- Título do trabalho, nome, disciplina, data (28/09/2026).
- Nota: uma frase — "medimos quanto cada país consegue extrair, em publicações e patentes de IA, do dinheiro que entra em IA e em P&D".

## Slide 2 — Pergunta e por que importa

- Pergunta: quais países são mais eficientes em converter investimento privado em IA e gasto em P&D em produção científica (publicações) e tecnológica (patentes) de IA, e o que explica as diferenças?
- Por que fronteiras: comparar produtos com insumos, não volumes absolutos; Estados Unidos e China lideram em volume, não necessariamente em eficiência.
- Antecedente direto: Ernst e Mishra (2021), *AI Efficiency Index*, DEA para 27 países, 2015–2018. Nossa contribuição: mais países e anos, inferência por bootstrap, fronteiras robustas, dinâmica (Malmquist), heterogeneidade (metafronteira) e segundo estágio institucional.
- Nota: enquadrar como função de produção de conhecimento (Griliches; Furman, Porter e Stern) e capacidade de absorção (Cohen e Levinthal).

## Slide 3 — Dados

| Item | Valor |
|---|---|
| Observações | 208 país-ano |
| Países | 37 na base bruta, 36 na DEA (Eslovênia só tem uma observação, com investimento zero); sem Alemanha, Coreia, Canadá, Suécia, Finlândia e Dinamarca |
| Período | 2013–2021, painel desbalanceado (1 a 9 anos por país) |
| Insumos | investimento privado em IA (US$ constantes de 2021); GERD = P&D % PIB × PIB |
| Produtos | publicações de IA (contagem); pedidos de patente de IA (contagem) |
| Contexto | governança (WGI), alta tecnologia, comércio, crédito, mercado de capitais, PIB per capita (World Bank) |

- Proveniência verificada: indicadores de IA do CSET Country Activity Tracker via Our World in Data; patentes vinham **por milhão de habitantes** e foram reconvertidas em contagem com a população do World Bank.
- Nota: destacar que a origem foi rastreada valor a valor (Argentina 2018: 1.079.101 no dataset e 1.079.102 na fonte).

## Slide 4 — Três problemas de medida que condicionam tudo

- **Zeros e piso**: 17 país-ano com investimento zero e 22 no piso de 1–2 milhões de dólares (granularidade de 1 milhão): 39 das 208 observações. Das 19 unidades "além da fronteira" agrupada, 7 estão no piso (Austrália e México 2013, Peru 2019, Ucrânia 2018, Romênia 2016); as outras 12 (China 2013, Índia 2019–2020, México 2018) são pontos extremos ou revisões de safra, não granularidade.
- **Publicações não nascem de capital de risco**: Ucrânia 2013–2017 tem investimento zero e 134–359 publicações por ano. Por isso o modelo base adiciona o GERD como segundo insumo.
- **Volume, não qualidade**: contagens favorecem sistemas grandes; China 2021 domina os Estados Unidos nos dois produtos com um sexto do insumo.
- Nota: "o diagnóstico começa reconhecendo o que os dados podem e não podem dizer".

## Slide 5 — Hipóteses

| | Hipótese (resumo) |
|---|---|
| H1 | Retornos variáveis de escala; grandes investidores em retornos decrescentes |
| H2 | Investimento privado importa para patentes, não para publicações (dado o P&D público) |
| H3 | Canais acadêmico e tecnológico pouco correlacionados; renda média abaixo da metafronteira |
| H4 | Mudança de fronteira domina a produtividade; renda média converge |
| H5 | Instituições e capacidade de absorção elevam a eficiência |
| H6 | Mercado de capitais (não crédito) eleva a eficiência em patentes |
| H7 | PIB per capita associado à eficiência em patentes, não em publicações |

- Nota: mencionar as proposições de robustez R1 (estimadores), R2 (defasagens) e R3 (qualidade).

## Slide 6 — Método

- Modelos: M1 (insumo único: investimento; replicação de Ernst e Mishra) e M2 (investimento + GERD; base); canais separados (só publicações, só patentes).
- Fronteiras por ano (16 a 27 países por ano), orientação a produto, CRS/VRS/NIRS; eficiência de escala e classificação de retornos.
- Inferência: bootstrap de Simar-Wilson (1.000 réplicas) com intervalos de 95%; teste de retornos de escala com bootstrap.
- Robustez: FDH, order-m, order-α; metafronteira por grupo de renda; Malmquist (CRS) no painel balanceado 2016–2019.
- Segundo estágio: regressão truncada com bootstrap agrupado por país, Simar-Wilson algoritmo 2 e Tobit; Kruskal-Wallis por renda.
- Nota: tudo em R (Benchmarking, rDEA, nonparaeff, frontiles, truncreg), scripts reproduzíveis.

## Slide 7 — Escala e retornos (H1)

| Modelo | H0 | S | p-valor | Decisão |
|---|---|---|---|---|
| M2 | retornos constantes | 0,666 | 0,025 | rejeita (teste liberal: tamanho 0,20 sob CRS) |
| M2 | retornos não crescentes | 0,989 | 0,89 | não rejeita |
| M1 | retornos constantes | 0,202 | < 0,001 | rejeita |

- Eficiência média VRS por ano (M2): 0,64 a 0,82; eficiência de escala média: 0,54 a 0,76.
- 15 dos 36 países operam sob retornos decrescentes em todos os anos (Estados Unidos, Japão, Reino Unido); a **China está em CRS, com eficiência de escala 1, em todos os anos**; a Índia alterna.
- Nota: "a tecnologia parece ter retornos variáveis, mas o teste é liberal e a China contradiz a leitura simples de que os grandes investidores estão em retornos decrescentes: H1 é só parcialmente apoiada".

## Slide 8 — Ranking com inferência

- Figura: `output/figures/fig1_ranking_m2.png` (página inteira; barras = IC 95% bootstrap da média anual; anos por país entre parênteses).
- Viés médio do bootstrap 0,15 (escore médio 0,72 → 0,57 corrigido). Intervalos largos no topo (países sobre a fronteira) e estreitos na base: só a separação entre a base (Israel, Suíça, Noruega, Irlanda, África do Sul) e o restante é ordinalmente defensável; a ordem dentro do topo não.
- Topo: Itália (2 anos) 0,79 [0,42; 0,89], Grécia (7) 0,77 [0,36; 0,78], Malásia (4) 0,76, Indonésia (2) 0,75, Bulgária (3) 0,75, Índia (8) 0,75; base: Suíça (1) 0,15, Israel (9) 0,18 [0,14; 0,19], Irlanda (2) 0,21, Noruega (6) 0,23, África do Sul (5) 0,25.
- Nota: explicar por que Israel e Suíça ficam na base: GERD total alto (muito P&D empresarial) e produtos de IA em contagem pequenos; "eficiência" aqui mede em parte a intensidade de IA do sistema de pesquisa.

## Slide 9 — Robustez entre estimadores (R1)

- Figura: `output/figures/fig6_estimadores.png`.
- Spearman com o escore VRS: corrigido 0,93; FDH 0,70; order-α 0,69; order-m 0,51; modelo de insumo único 0,72.
- Nota: fronteiras parciais (order-m) penalizam menos os vizinhos das observações-piso, por isso a concordância menor; conclusão: ranking moderadamente robusto.

## Slide 10 — Dois canais, duas histórias (H3)

- Figura: `output/figures/fig3_canais.png` (meia página) e `output/figures/fig7_metafronteira.png` (meia página).
- Spearman entre eficiência acadêmica e tecnológica: 0,52 [0,31; 0,69] com bootstrap por país; p unilateral de ρ ≥ 0,5 = 0,59: correlação moderada, H3a inconclusiva.
- Metafronteira: razão de gap tecnológico 0,62 (alta renda) contra 0,95 (renda média); H3b (renda média abaixo da alta) tem p = 1,0. Resultado **oposto** ao previsto: com contagens, o grupo de renda média define a fronteira (China, Índia, México, Peru).
- Kruskal-Wallis: o canal de patentes difere por renda (p = 0,001 em país-ano, 0,020 em médias por país; 0,34 na renda média-alta contra 0,17 na alta renda); publicações e modelo conjunto não.
- Nota: ligar ao problema volume × qualidade do slide 4.

## Slide 11 — Dinâmica 2016–2019 (H4)

- Figura: `output/figures/fig2_malmquist_decomposicao.png`.

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência |
|---|---|---|---|---|
| Alta renda | 10 | 0,996 | 0,898 | 1,109 [1,007; 1,230] |
| Renda média | 6 | 1,000 | 0,931 | 1,074 [0,958; 1,262] |
| Todos | 16 | 0,997 | 0,910 | 1,096 [1,010; 1,197] |

- Parcela da mudança técnica na variância de log M (covariância rateada simetricamente): 0,60. A fronteira domina (H4a), mas recua em produtos por dólar durante o boom de investimento.
- Catch-up da renda média: 1,07 com IC [0,96; 1,26], que inclui 1; β-convergência nula (p = 0,47): H4b não apoiada. Maiores ganhos: Brasil 1,45, Áustria 1,27, Polônia 1,25; maiores perdas: China 0,65, Hungria 0,81, Japão 0,82.
- Em palavras simples: a produtividade sobe porque "os campeões avançaram" (todos aprenderam a fazer IA melhor) ou porque "o país se aproximou dos campeões"; o Malmquist separa os dois pedaços.

## Slide 12 — Segundo estágio (H5, H6, H7)

- Figura: `output/figures/fig4_segundo_estagio.png`.

| Modelo | Variável | Coeficiente | IC 95% |
|---|---|---|---|
| H5 conjunto (191 obs., 36 países) | efetividade governamental | −0,137 | [−0,329; −0,000] |
| H5 sem piso (169/34) | efetividade governamental | −0,121 | [−0,363; 0,012] |
| H6 patentes | capitalização de mercado | 0,000 | [−0,001; 0,002] |
| H7 patentes | log PIB per capita | −0,045 | [−0,154; 0,013] |
| H7 publicações | log PIB per capita | −0,093 | [−0,153; −0,014] |

- Dependente: eficiência corrigida em (0, 1]; positivo = mais eficiente; escores fixos e bootstrap por país (não é o algoritmo 2). O algoritmo 2 de Simar-Wilson (fronteira agrupada) e o Tobit dão o mesmo sinal; nenhum testa separabilidade, então a leitura é exploratória.
- Leitura: H5 não confirmada (sinal negativo das instituições, não robusto ao piso), H6 não confirmada, H7 contrariada. Com produtos em volume, "eficiência" cresce com o tamanho relativo do sistema de IA, não com a qualidade institucional.

## Slide 13 — Eficiência por grupo de renda e ano

- Figura: `output/figures/fig5_renda_ano.png`.
- Nota: sem tendência clara ao longo do tempo; dispersão maior nos anos com menos países (2020–2021).

## Slide 14 — Síntese por hipótese

| Hipótese | Evidência | Status |
|---|---|---|
| H1 escala | CRS rejeitado (p = 0,025, teste liberal); EUA em DRS, China em CRS | parcialmente apoiada |
| H2 insumos por canal | GERD eleva a eficiência média (M1 0,42–0,71 → M2 0,64–0,82) | a testar com SFA |
| H3 canais | ρ = 0,52, p(ρ ≥ 0,5) = 0,59; gap tecnológico maior na alta renda | H3a inconclusiva; H3b não apoiada |
| H4 dinâmica | fronteira domina (0,60); EC média 1,07 [0,96; 1,26] | H4a sim, H4b não |
| H5 instituições | sinal negativo em três métodos | não apoiada |
| H6 finanças | coeficientes nulos | não apoiada |
| H7 desenvolvimento | PIB pc negativo em publicações | contrariada |
| R1 estimadores | ρ entre 0,51 e 0,93 | moderadamente robusto |

## Slide 15 — O que muda na versão artigo (painel reconstruído)

- Painel CSET + World Bank: 47 países (com Alemanha, Coreia, Canadá, nórdicos, Rússia), 2016–2024; modelo conjunto 2017–2021 com insumos defasados; 37 a 44 países por ano. Teste de RTS no painel **não rejeita** retornos constantes (S = 0,577, p = 0,10); China, Coreia e Índia em CRS.
- Resultados preservados: instituições com sinal negativo (−0,18 [−0,31; −0,06], 144 casos completos), sem convergência, canal de patentes mais eficiente na renda média-alta.
- **Produtos alternativos (citações e famílias posteriormente concedidas)**: a metafronteira inverte por especificação, confirmado na amostra comum (0,59/0,87 em volume contra 0,94/0,83); Estados Unidos, Reino Unido, Austrália e Singapura sobem ao topo (ρ = 0,80 entre rankings). A associação com instituições deixa de ser distinguível de zero, mas a diferença de coeficientes não é significativa (0,07 [−0,03; 0,18]).
- P&D executado por ensino superior e governo como insumo corrige Israel (0,16 → 0,47) e Irlanda (0,20 → 0,46); a inversão da metafronteira nessa variante é efeito da composição da amostra (saem seis países de renda média), não do insumo.
- Nota: apresentar como "próximos passos já executados".

## Slide 16 — Robustez à fonte dos dados

- Checagens entre fornecedores (bootstrap por país): investimento CSET × Quid ρ = 0,93 (84 países); CSET (VC + PE + fusões) × Preqin (só VC) ρ = 0,83 [0,76; 0,89]; publicações CSET × OECD.AI ρ = 0,95; patentes CSET (país de prioridade) × OCDE (país do inventor) ρ = 0,75 [0,61; 0,85].
- Trocar a fonte do insumo (Preqin) ou das patentes (inventor) mantém a ordem geral dos rankings (ρ = 0,89 e 0,85) e o sinal das instituições; muda posições específicas (China passa a DRS com patentes por inventor; Estados Unidos e Japão sobem) e a correlação entre canais (0,30 com patentes por inventor).
- Nota: "os fornecedores preservam a ordem geral; a atribuição das patentes e a escolha dos produtos mudam resultados específicos".

## Slide 17 — Limitações

- Produtos em contagem (volume) e insumo de P&D não específico de IA; patentes atribuídas ao escritório de depósito; cobertura do Crunchbase; granularidade de 1 milhão de dólares no investimento.
- Poucas DMUs por ano (16 a 27) com quatro variáveis: muitas unidades eficientes e intervalos largos.
- Segundo estágio condicionado à separabilidade (diagnóstico simples; teste formal na versão artigo).

## Slide 18 — Conclusões e próximos passos

- Três mensagens: (1) retornos decrescentes e fronteira que recua em produtos por dólar durante o boom; (2) os dois canais divergem e o de patentes é o mais sensível a renda e fonte; (3) medir eficiência em IA exige ajustar produtos por qualidade e separar P&D público de privado; sem isso, "eficiência" confunde-se com intensidade relativa de IA.
- Próximos passos do artigo: SFA por canal com classes latentes, teste de separabilidade formal, matriz de robustez consolidada, manuscrito em português para periódico Qualis.
- Nota final: agradecer e abrir para perguntas.

## Referências mínimas para o slide de bibliografia (opcional, slide 19)

Banker, Charnes e Cooper (1984); Charnes, Cooper e Rhodes (1978); Simar e Wilson (1998, 2002, 2007); Cazals, Florens e Simar (2002); Daraio e Simar (2005); Färe et al. (1994); O'Donnell, Rao e Battese (2008); Furman, Porter e Stern (2002); Cohen e Levinthal (1990); Ernst e Mishra (2021); Holý e Šafr (2018); Hsu, Tian e Xu (2014); Bogetoft e Otto (2011).

## Fontes dos números

`artigo/05_resultados_fase_a.md` (slides 3–14), `artigo/06_resultados_painel.md` (slides 15–16), tabelas em `output/tables/` e figuras em `output/figures/`.
