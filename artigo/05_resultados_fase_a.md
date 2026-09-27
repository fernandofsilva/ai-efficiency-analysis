# Resultados preliminares — Fase A (dataset original, 2013–2021)

Base para a apresentação de 28/09/2026. Todos os números vêm de `output/tables/` (scripts `R/01` a `R/04`); figuras em `output/figures/`. Valores de eficiência estão na escala (0, 1], orientação a produto (quanto o país poderia expandir publicações e patentes com os mesmos insumos).

## 1. Dados e diagnóstico (slides 2–4)

- 208 observações país-ano, 37 países, 2013–2021, painel desbalanceado. Indicadores de IA vêm do CSET via Our World in Data: investimento privado em US$ constantes de 2021, publicações em contagem, patentes **por milhão de habitantes** (reconvertidas em contagem com a população do World Bank).
- Problemas de medida que condicionam tudo o que segue:
  - 17 observações com investimento igual a zero (sem negócio registrado na fonte) e 22 no "piso" de 1–2 milhões de dólares (granularidade de 1 milhão): juntas, 39 das 208 observações. As unidades "além da fronteira" na supereficiência são exatamente essas (China 2013, Austrália 2013, México 2013, Peru 2019–2020, Índia 2019–2020, Ucrânia 2018, Romênia 2016).
  - Ucrânia 2013–2017: zero de investimento com 134–359 publicações por ano — publicações não são produzidas por capital de risco. Por isso o modelo base (M2) adiciona o gasto total em P&D (GERD = P&D % PIB × PIB) como segundo insumo.
  - Correlações de Spearman insumo-produto (isotonicidade): investimento × publicações 0,73; investimento × patentes 0,63; GERD × publicações 0,88; GERD × patentes 0,73.
- Amostras: 191 observações sem zeros (36 países); 169 sem zeros e sem piso (34 países).

## 2. Modelos (slide 5)

| Modelo | Insumos | Produtos | Papel |
|---|---|---|---|
| M1 | investimento privado em IA | publicações, patentes | replicação de Ernst e Mishra (2021) |
| M2 (base) | investimento privado em IA, GERD | publicações, patentes | resultados principais |
| Canal acadêmico | idem M2 | publicações | H2, H3, H7 |
| Canal tecnológico | idem M2 | patentes | H2, H3, H6, H7 |

Fronteiras contemporâneas por ano (16 a 27 DMUs por ano), orientação a produto, CRS/VRS/NIRS; bootstrap de Simar-Wilson (1.000 réplicas); FDH, order-m (m ≈ 40% de n) e order-α (α = 0,95); metafronteira por grupo de renda (agrupada); Malmquist CRS no painel balanceado 2016–2019; segundo estágio com regressão truncada e bootstrap agrupado por país (300 réplicas), Simar-Wilson algoritmo 2 (rDEA) e Tobit.

## 3. Eficiência técnica e escala — H1 (slides 6–8)

- Eficiência média VRS (M2) por ano: 0,64 a 0,82; 5 a 12 países eficientes por ano. Eficiência de escala média: 0,54 a 0,76.
- Classificação de retornos de escala (M2): a maioria das DMUs opera sob retornos **decrescentes** (por exemplo, 2018: 20 DRS, 3 IRS, 4 CRS; 2021: 13 DRS, 0 IRS, 3 CRS). Sem os valores-piso, a parcela de DRS cai (2016: de 19 para 8 em 24 e 20 DMUs), sinal de que as observações-piso empurram os demais para a região de retornos decrescentes.
- Teste de retornos de escala com bootstrap (Simar-Wilson 2002, implementado sobre `Benchmarking` em `R/02b`; estatística S = média(D_H0)/média(D_VRS), mil réplicas do bootstrap suavizado, amostra agrupada de 191 observações):

| Modelo | H0 | S | p-valor | Decisão |
|---|---|---|---|---|
| M2 | retornos constantes | 0,666 | < 0,001 | rejeita CRS |
| M2 | retornos não crescentes | 0,989 | 0,60 | não rejeita NIRS |
| M1 | retornos constantes | 0,202 | < 0,001 | rejeita CRS |

  A tecnologia é de retornos variáveis e compatível com retornos não crescentes: a região relevante é a de retornos decrescentes, como previa H1.
- Leitura de H1: retornos variáveis confirmados pelo teste (CRS rejeitado, NIRS não rejeitado) e predominância de retornos decrescentes nos grandes investidores (Estados Unidos e China aparecem como DRS em todos os anos); a classificação por DMU é sensível aos valores-piso, o teste global não.

## 4. Ranking com inferência (slide 9, Figura 1)

- Viés médio do bootstrap: 0,15 (escore original médio 0,72 contra 0,57 corrigido); largura média do IC de 95%: 0,24. Diferenças ordinais só são defensáveis entre grupos com ICs disjuntos.
- Topo (média 2013–2021 dos escores corrigidos, M2): Itália 0,79 (2 anos), Grécia 0,77, Malásia 0,76, Indonésia 0,75, Bulgária 0,75, Índia 0,75, Romênia 0,75, Polônia 0,75, Peru 0,74, China 0,74.
- Base: Suíça 0,15, Israel 0,19, Irlanda 0,22, Noruega 0,24, África do Sul 0,25.
- Leitura: com produtos em **volume** (contagens) e GERD **total** (não específico de IA) como insumo, países pequenos e ricos com sistemas de P&D intensivos (Israel, Suíça, Noruega, Irlanda) aparecem como ineficientes, enquanto grandes economias emergentes e países europeus de renda média aparecem no topo. O escore mede, em parte, a "intensidade de IA" do sistema de pesquisa, não sua qualidade. Isso motiva os produtos ajustados por qualidade (citações, patentes concedidas) na versão artigo.

## 5. Robustez entre estimadores — R1 (slide 10, Figura 6)

Spearman (IC 95% bootstrap) entre o escore VRS (M2) e: escore corrigido 0,93 [0,88; 0,96]; FDH 0,70 [0,61; 0,77]; order-α 0,69 [0,59; 0,76]; order-m 0,51 [0,38; 0,63]; M1 (insumo único) 0,72 [0,62; 0,82]. Order-m × order-α: 0,74. Rankings moderadamente robustos; as fronteiras parciais (order-m) penalizam menos os países próximos das observações-piso, daí a menor concordância.

## 6. Canais e metafronteira — H3 (slides 11–12, Figuras 3 e 7)

- Spearman entre eficiência no canal acadêmico e no tecnológico: 0,52 [0,40; 0,63]; sem valores-piso 0,56 [0,43; 0,66]. Correlação moderada: H3a (ρ < 0,5) não é confirmada no ponto, mas o IC inclui 0,5.
- Metafronteira por grupo de renda (M2, agrupado): razão de gap tecnológico média 0,62 para alta renda e 0,94 para renda média (mediana 1,00); Mann-Whitney p < 0,001. Resultado **oposto** ao previsto em H3b: o grupo de renda média define a metafronteira (China, Índia, México, Peru), e a tecnologia do grupo de alta renda fica abaixo dela. Interpretação ligada ao ponto anterior (volume vs qualidade) e aos valores-piso; o resultado persiste sem os valores-piso (0,61 vs 0,95).
- Kruskal-Wallis por grupo de renda: canal de patentes difere (p < 0,001; média 0,34 na renda média-alta, 0,17 na alta renda); canal de publicações (p = 0,12) e modelo conjunto (p = 0,16) não.

## 7. Dinâmica 2016–2019 — H4 (slide 13, Figura 2)

Painel balanceado de 16 países (M2, CRS, produto), médias geométricas:

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência |
|---|---|---|---|---|
| Alta renda | 10 | 0,996 | 0,898 | 1,109 |
| Renda média | 6 | 1,000 | 0,931 | 1,074 |
| Todos | 16 | 0,997 | 0,910 | 1,096 |

- A mudança técnica explica 58% da variância do log do índice: o componente de fronteira domina (H4a, sentido previsto), mas a fronteira se desloca **para dentro** — o boom de investimento (denominador) cresce mais rápido que os produtos, como antecipado na hipótese.
- Catch-up: alta renda 1,11 contra renda média 1,07 — H4b (convergência da renda média) **não** encontra apoio neste painel curto. Maiores ganhos: Brasil (1,45, todo em catch-up), Áustria (1,27), Polônia (1,25), Grécia (1,23); maiores perdas: China (0,65, toda em mudança técnica: o investimento chinês cresceu muito mais que os produtos), Hungria (0,81), Japão (0,82), Estados Unidos (0,83).

## 8. Segundo estágio — H5, H6, H7 (slides 14–16, Figura 4)

Variável dependente: eficiência corrigida de viés em (0, 1], truncada em 1; coeficiente positivo = mais eficiente. IC 95% por bootstrap agrupado por país (36 clusters).

| Modelo | Variável | Coef. | IC 95% |
|---|---|---|---|
| H5 conjunto (M2) | efetividade governamental | −0,137 | [−0,329; −0,000] |
| H5 conjunto (M2) | exportações de alta tecnologia | 0,001 | [−0,010; 0,005] |
| H5 conjunto (M2) | log comércio | −0,024 | [−0,149; 0,148] |
| H5 conjunto (M2) | capitalização de mercado | −0,000 | [−0,002; 0,003] |
| H5 conjunto (M2) | crédito privado | 0,002 | [−0,000; 0,005] |
| H5 sem valores-piso | efetividade governamental | −0,120 | [−0,362; 0,013] |
| H5 com pesquisadores (n = 161) | log pesquisadores por milhão | 0,042 | [−0,053; 0,133] |
| H6 canal patentes | capitalização de mercado | 0,000 | [−0,001; 0,002] |
| H6 canal patentes | crédito privado | 0,001 | [−0,002; 0,003] |
| H7 canal patentes | log PIB per capita | −0,045 | [−0,154; 0,013] |
| H7 canal publicações | log PIB per capita | −0,093 | [−0,153; −0,014] |

- Simar-Wilson algoritmo 2 (rDEA, fronteira agrupada, escala de Farrell ≥ 1, sinal invertido): efetividade governamental +10,5 [5,6; 16,2] (menos eficiente) e crédito privado −0,15 [−0,24; −0,08] (mais eficiente); Tobit: efetividade −0,116 (p < 0,001), crédito +0,0013 (p = 0,003). Os três métodos concordam no sinal.
- H5: **não confirmada**; a associação entre qualidade institucional e eficiência medida é negativa e persiste sem os valores-piso (embora perca significância). Correlações simples com o escore corrigido: efetividade −0,25, PIB per capita −0,30, P&D % PIB −0,21.
- H6: **não confirmada** (finanças de mercado não se associam à eficiência no canal de patentes).
- H7: sinal **oposto** ao previsto — PIB per capita associa-se negativamente à eficiência no canal de publicações e não se associa no canal de patentes.
- Leitura conjunta: no dataset original, "eficiência" captura sobretudo a razão entre volume de produtos de IA e tamanho do sistema de P&D. Países ricos e bem governados têm GERD alto e produtos de IA proporcionalmente menores (em contagem); economias emergentes grandes têm o oposto. Sem ajuste por qualidade e sem insumo específico de IA, as hipóteses institucionais não podem ser testadas de forma limpa — argumento central para a versão artigo.

## 9. O que muda na versão artigo (slide 17)

- Painel reconstruído (CSET v1.12.0 + World Bank): 45 países, 2016–2024, com Alemanha, Coreia do Sul, Canadá, nórdicos e outros; modelo conjunto 2017–2021 com insumos defasados; 37 a 42 observações por ano (contra 16 a 27).
- Produtos ajustados por qualidade (citações até 2020; patentes concedidas até 2019) e insumo de investimento estimado (com imputação de negócios não divulgados), reduzindo zeros e valores-piso.
- Teste de RTS com 2.000 réplicas, SFA por canal com classes latentes, teste de separabilidade e matriz de robustez estimador × defasagem × qualidade × fonte.

## 10. Síntese por hipótese (slide 18)

| Hipótese | Evidência na Fase A | Status preliminar |
|---|---|---|
| H1 retornos de escala | CRS rejeitado (p < 0,001) e NIRS não rejeitado (p = 0,60); maioria DRS; grandes investidores DRS | apoiada |
| H2 insumos por canal | GERD eleva eficiência média de 0,42–0,71 (M1) para 0,64–0,82 (M2); ρ(M1, M2) = 0,72 | a testar com SFA |
| H3 divergência de canais | ρ = 0,52 [0,40; 0,63]; TGR maior na renda média | parcialmente apoiada (H3a); H3b contrariada |
| H4 dinâmica | mudança técnica domina (58% da variância), fronteira para dentro; catch-up não maior na renda média | H4a apoiada; H4b não |
| H5 instituições | efetividade governamental com sinal negativo (três métodos) | não apoiada |
| H6 finanças de mercado | coeficientes nulos no canal de patentes | não apoiada |
| H7 desenvolvimento | PIB per capita negativo em publicações, nulo em patentes | contrariada |
| R1 estimadores | ρ entre 0,51 e 0,93 | moderadamente robusto |
