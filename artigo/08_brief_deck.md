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
| Países | 37 (Argentina a Estados Unidos; sem Alemanha, Coreia, Canadá, nórdicos) |
| Período | 2013–2021, painel desbalanceado (1 a 9 anos por país) |
| Insumos | investimento privado em IA (US$ constantes de 2021); GERD = P&D % PIB × PIB |
| Produtos | publicações de IA (contagem); pedidos de patente de IA (contagem) |
| Contexto | governança (WGI), alta tecnologia, comércio, crédito, mercado de capitais, PIB per capita (World Bank) |

- Proveniência verificada: indicadores de IA do CSET Country Activity Tracker via Our World in Data; patentes vinham **por milhão de habitantes** e foram reconvertidas em contagem com a população do World Bank.
- Nota: destacar que a origem foi rastreada valor a valor (Argentina 2018: 1.079.101 no dataset e 1.079.102 na fonte).

## Slide 4 — Três problemas de medida que condicionam tudo

- **Zeros e piso**: 17 país-ano com investimento zero e 22 no piso de 1–2 milhões de dólares (granularidade de 1 milhão): 39 das 208 observações. As unidades "além da fronteira" são exatamente essas (China 2013, Austrália 2013, México 2013, Peru 2019–2020, Índia 2019–2020).
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
| M2 | retornos constantes | 0,666 | < 0,001 | rejeita |
| M2 | retornos não crescentes | 0,989 | 0,60 | não rejeita |
| M1 | retornos constantes | 0,202 | < 0,001 | rejeita |

- Eficiência média VRS por ano (M2): 0,64 a 0,82; eficiência de escala média: 0,54 a 0,76.
- A maioria dos países opera sob retornos decrescentes (2018: 20 DRS, 3 IRS, 4 CRS); Estados Unidos e China sempre em DRS.
- Nota: "a tecnologia tem retornos variáveis, e a região relevante é a de retornos decrescentes: dobrar o dinheiro não dobra os produtos".

## Slide 8 — Ranking com inferência

- Figura: `output/figures/fig1_ranking_m2.png` (página inteira).
- Viés médio do bootstrap 0,15 (escore médio 0,72 → 0,57 corrigido); largura média do intervalo 0,24: só há diferença ordinal defensável entre grupos com intervalos disjuntos.
- Topo: Itália 0,79, Grécia 0,77, Malásia 0,76, Indonésia 0,75, Bulgária 0,75, Índia 0,75; base: Suíça 0,15, Israel 0,19, Irlanda 0,22, Noruega 0,24, África do Sul 0,25.
- Nota: explicar por que Israel e Suíça ficam na base: GERD total alto (muito P&D empresarial) e produtos de IA em contagem pequenos; "eficiência" aqui mede em parte a intensidade de IA do sistema de pesquisa.

## Slide 9 — Robustez entre estimadores (R1)

- Figura: `output/figures/fig6_estimadores.png`.
- Spearman com o escore VRS: corrigido 0,93; FDH 0,70; order-α 0,69; order-m 0,51; modelo de insumo único 0,72.
- Nota: fronteiras parciais (order-m) penalizam menos os vizinhos das observações-piso, por isso a concordância menor; conclusão: ranking moderadamente robusto.

## Slide 10 — Dois canais, duas histórias (H3)

- Figura: `output/figures/fig3_canais.png` (meia página) e `output/figures/fig7_metafronteira.png` (meia página).
- Spearman entre eficiência acadêmica e tecnológica: 0,52 [0,40; 0,63] (0,56 sem valores-piso): correlação moderada.
- Metafronteira: razão de gap tecnológico 0,62 (alta renda) contra 0,94 (renda média), p < 0,001. Resultado **oposto** ao previsto: com contagens, o grupo de renda média define a fronteira (China, Índia, México, Peru).
- Kruskal-Wallis: o canal de patentes difere por renda (p < 0,001; 0,34 na renda média-alta contra 0,17 na alta renda); publicações e modelo conjunto não.
- Nota: ligar ao problema volume × qualidade do slide 4.

## Slide 11 — Dinâmica 2016–2019 (H4)

- Figura: `output/figures/fig2_malmquist_decomposicao.png`.

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência |
|---|---|---|---|---|
| Alta renda | 10 | 0,996 | 0,898 | 1,109 |
| Renda média | 6 | 1,000 | 0,931 | 1,074 |
| Todos | 16 | 0,997 | 0,910 | 1,096 |

- Mudança técnica explica 58% da variância do índice: a fronteira domina (H4a), mas recua em produtos por dólar durante o boom de investimento.
- Catch-up: 1,11 na alta renda contra 1,07 na renda média: sem convergência (H4b não apoiada). Maiores ganhos: Brasil 1,45, Áustria 1,27, Polônia 1,25; maiores perdas: China 0,65, Hungria 0,81, Japão 0,82.
- Em palavras simples: a produtividade sobe porque "os campeões avançaram" (todos aprenderam a fazer IA melhor) ou porque "o país se aproximou dos campeões"; o Malmquist separa os dois pedaços.

## Slide 12 — Segundo estágio (H5, H6, H7)

- Figura: `output/figures/fig4_segundo_estagio.png`.

| Modelo | Variável | Coeficiente | IC 95% |
|---|---|---|---|
| H5 conjunto | efetividade governamental | −0,137 | [−0,329; −0,000] |
| H5 sem piso | efetividade governamental | −0,120 | [−0,362; 0,013] |
| H6 patentes | capitalização de mercado | 0,000 | [−0,001; 0,002] |
| H7 patentes | log PIB per capita | −0,045 | [−0,154; 0,013] |
| H7 publicações | log PIB per capita | −0,093 | [−0,153; −0,014] |

- Dependente: eficiência corrigida em (0, 1]; positivo = mais eficiente. Simar-Wilson algoritmo 2 e Tobit concordam nos sinais.
- Leitura: H5 não confirmada (sinal negativo das instituições), H6 não confirmada, H7 contrariada. Com produtos em volume, "eficiência" cresce com o tamanho relativo do sistema de IA, não com a qualidade institucional.

## Slide 13 — Eficiência por grupo de renda e ano

- Figura: `output/figures/fig5_renda_ano.png`.
- Nota: sem tendência clara ao longo do tempo; dispersão maior nos anos com menos países (2020–2021).

## Slide 14 — Síntese por hipótese

| Hipótese | Evidência | Status |
|---|---|---|
| H1 escala | CRS rejeitado, NIRS não rejeitado; maioria DRS | apoiada |
| H2 insumos por canal | GERD eleva a eficiência média (M1 0,42–0,71 → M2 0,64–0,82) | a testar com SFA |
| H3 canais | ρ = 0,52; gap tecnológico maior na alta renda | parcial / contrariada |
| H4 dinâmica | fronteira domina; sem convergência | H4a sim, H4b não |
| H5 instituições | sinal negativo em três métodos | não apoiada |
| H6 finanças | coeficientes nulos | não apoiada |
| H7 desenvolvimento | PIB pc negativo em publicações | contrariada |
| R1 estimadores | ρ entre 0,51 e 0,93 | moderadamente robusto |

## Slide 15 — O que muda na versão artigo (painel reconstruído)

- Painel CSET + World Bank: 47 países (com Alemanha, Coreia, Canadá, nórdicos, Rússia), 2016–2024; modelo conjunto 2017–2021 com insumos defasados; 37 a 44 países por ano; teste de RTS confirma retornos variáveis (S = 0,577, p < 0,001; NIRS p = 0,45).
- Resultados preservados: instituições com sinal negativo (−0,18 [−0,30; −0,06]), sem convergência, canal de patentes mais eficiente na renda média-alta.
- **Ajuste por qualidade (citações e patentes concedidas) muda a história**: a metafronteira inverte (renda média abaixo da fronteira, TGR 0,84 contra 0,94), a associação negativa com instituições desaparece e Estados Unidos, Reino Unido, Austrália e Singapura sobem ao topo (ρ = 0,80 entre rankings).
- P&D público (HERD + GOVERD) como insumo corrige Israel (0,16 → 0,47) e Irlanda (0,20 → 0,46) e faz pesquisadores por milhão aparecerem com sinal positivo.
- Nota: apresentar como "próximos passos já executados".

## Slide 16 — Robustez à fonte dos dados

- Checagens entre fornecedores: investimento CSET × Quid (AI Index) ρ = 0,93 (84 países); CSET × Preqin (OECD.AI) ρ = 0,83 (513 país-ano); publicações CSET × OECD.AI ρ = 0,95; patentes CSET (escritório) × OCDE (inventor) ρ = 0,75.
- Trocar a fonte do insumo (Preqin) ou das patentes (inventor) mantém a ordem geral dos rankings (ρ = 0,89 e 0,85) e os sinais do segundo estágio; muda posições específicas (China, Estados Unidos, Japão, Suíça, Irlanda).
- Nota: "o que altera os resultados é a qualidade dos produtos, não o fornecedor".

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
