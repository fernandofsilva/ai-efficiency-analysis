# Resultados — Fase A (dataset original, 2013–2021), revisados após a análise crítica

Base para a apresentação. Todos os números vêm de `output/tables/` (scripts `R/01` a `R/04`, `R/02b`, `R/02c`), reexecutados em 27/09/2026 após as correções registradas em `artigo/10_avaliacao_inconsistencias.md`; figuras em `output/figures/` (sem sufixo). Eficiência na escala (0, 1], orientação a produto; "corrigido" = após bootstrap de Simar-Wilson.

## 1. Dados e diagnóstico

- 208 observações país-ano, 37 países na base bruta, 2013–2021, painel desbalanceado. A DEA principal usa **36 países e 191 observações** (17 zeros de investimento excluídos: Eslovênia só tem uma observação, com zero). Indicadores de IA do CSET via Our World in Data; patentes originalmente por milhão de habitantes, reconvertidas em contagem com a população do World Bank.
- **Zeros e piso.** 17 zeros e 22 valores no piso de 1–2 milhões de US$ (granularidade de 1 milhão). Zeros não inviabilizam o modelo de dois insumos (a LP é viável), mas as unidades com zero saem eficientes ou quase por construção e rebaixam as demais (2015: escore médio das cinco unidades com zero 0,91; média das outras cai de 0,77 para 0,72; `sensibilidade_zeros_m2.csv`). A exclusão é uma escolha de medida (zero = negócio não registrado), não de viabilidade.
- **Supereficiência.** 19 das 191 observações ficam além da fronteira agrupada (M2); **7 estão no piso** (Austrália 2013, México 2013, Peru 2019, Ucrânia 2018, Romênia 2016 e outras) e 12 não (China 2013, Índia 2019–2020, Peru 2020, México 2018). Pontos extremos não se explicam só pela granularidade (`supereficiencia_cruzada_piso.csv`).
- **Publicações não nascem de capital de risco.** Ucrânia 2013–2017: investimento zero, 134–359 publicações. O modelo base adiciona o GERD (P&D interno total, todos os setores) como segundo insumo.
- Correlações de Spearman insumo-produto: investimento × publicações 0,73; investimento × patentes 0,63; GERD × publicações 0,88; GERD × patentes 0,73.

## 2. Modelos

| Modelo | Insumos | Produtos | Papel |
|---|---|---|---|
| M1 | investimento privado em IA | publicações, patentes | replicação de Ernst e Mishra (2021) |
| M2 (base) | investimento privado em IA, GERD | publicações, patentes | resultados principais |
| Canal acadêmico | idem M2 | publicações | H2, H3, H7 |
| Canal tecnológico | idem M2 | patentes | H2, H3, H6, H7 |

Fronteiras **contemporâneas por ano** (16 a 27 países por ano) para escores, rankings, canais e segundo estágio por regressão truncada; fronteira **agrupada** (todas as observações) para supereficiência, metafronteira por renda, teste de retornos de escala e algoritmo 2 de Simar-Wilson. As duas tecnologias temporais são objetos diferentes e não se validam mutuamente. Bootstrap de Simar-Wilson (1.000 réplicas); FDH, order-m (m ≈ 40% de n) e order-α (0,95); Malmquist CRS no painel balanceado 2016–2019 (16 países); segundo estágio com regressão truncada (escores fixos, bootstrap por país, 300 réplicas), algoritmo 2 do rDEA e Tobit.

## 3. Escala e retornos (H1)

- Teste de retornos de escala adaptado de Simar-Wilson (2002), fronteira agrupada, mil réplicas, observações originais avaliadas contra a pseudofronteira:

| Modelo | H0 | S | p-valor | Decisão a 5% |
|---|---|---|---|---|
| M2 | retornos constantes | 0,666 | 0,025 | rejeita |
| M2 | retornos não crescentes | 0,989 | 0,89 | não rejeita |
| M1 | retornos constantes | 0,202 | < 0,001 | rejeita |

- **Validação por simulação** (`R/02c`, 100 simulações, 40 DMUs, 100 réplicas): sob CRS verdadeiro o teste rejeita a 5% em **20%** das amostras (tamanho liberal); poder de 0,84 sob retornos decrescentes fortes e 0,49 sob moderados. O p-valor de 0,025 do M2 deve ser lido como indicativo, não conclusivo.
- Por país (`rts_por_pais_m2.csv`): 15 dos 36 países estão em retornos decrescentes em todos os anos (Estados Unidos, SE média 0,35; Japão 0,67; Reino Unido 0,41); a **China é CRS com eficiência de escala 1 em todos os nove anos** e a Índia alterna (4 anos CRS, 4 DRS, SE média 0,93).
- Leitura de H1: **parcialmente apoiada**. A tecnologia global é compatível com retornos variáveis e não crescentes, mas o enunciado sobre "os grandes investidores" só vale para os Estados Unidos; a China está sobre o raio de produtividade máxima.

## 4. Ranking com inferência (Figura 1)

- Escore médio por país dos escores anuais corrigidos; IC 95% bootstrap da média anual (construção de Simar-Wilson centrada no estimador original; réplicas independentes entre anos). Entre parênteses, anos por país. Viés médio do bootstrap 0,15; escore médio 0,72 → 0,57 corrigido.
- Topo: Itália (2 anos) 0,79 [0,42; 0,89]; Grécia (7) 0,77 [0,36; 0,78]; Malásia (4) 0,76 [0,00; 0,79]; Indonésia (2) 0,75; Bulgária (3) 0,75; Índia (8) 0,75 [0,00; 0,69]; Romênia (4) 0,75; Polônia (9) 0,75 [0,49; 0,73]. Base: África do Sul (5) 0,25 [0,18; 0,26]; Noruega (6) 0,23 [0,17; 0,24]; Irlanda (2) 0,21; Israel (9) 0,18 [0,14; 0,19]; Suíça (1) 0,15.
- Os intervalos dos países no topo são largos e assimétricos (limite inferior em 0 para vários), porque unidades sobre a fronteira têm réplicas muito dispersas; só a base do ranking tem intervalos estreitos. Diferenças ordinais defensáveis existem entre o grupo da base (Israel, Suíça, Noruega, Irlanda, África do Sul) e o restante, não dentro do topo. A ordenação mistura países com 1 a 9 anos.
- Leitura: com produtos em contagem e GERD total como insumo, países pequenos e ricos com P&D intensivo em empresas aparecem como ineficientes; o escore mede em parte a intensidade de IA do sistema de pesquisa.

## 5. Robustez entre estimadores — R1 (Figura 6)

Spearman com o escore VRS (bootstrap em blocos de país, 36 blocos): corrigido 0,93 [0,83; 0,97]; FDH 0,70 [0,51; 0,82]; order-α 0,69 [0,48; 0,81]; order-m 0,51 [0,23; 0,70]; M1 0,72 [0,57; 0,84]. Order-m × order-α 0,74. Rankings moderadamente robustos; as fronteiras parciais divergem mais.

## 6. Canais e metafronteira — H3 (Figuras 3 e 7)

- Spearman entre eficiência acadêmica e tecnológica (país-ano, blocos de país): 0,52 [0,31; 0,69]; p-valor unilateral de H0: ρ ≥ 0,5 = 0,59 (sem piso: 0,56, p = 0,72). **H3a inconclusiva**: compatível no ponto com correlação moderada, sem evidência contra ρ ≥ 0,5.
- Metafronteira agrupada por grupo de renda: TGR média 0,62 (alta renda) e 0,95 (renda média). H3b, redefinida como TGR(média) < TGR(alta): Mann-Whitney unilateral p = 1,0 (também em médias por país). **Não apoiada**: com contagens, o grupo de renda média define a metafronteira (China, Índia, México, Peru).
- Kruskal-Wallis por renda: canal de patentes difere (p = 0,001 em país-ano; p = 0,020 em médias por país; 0,34 na renda média-alta contra 0,17 na alta renda); publicações e modelo conjunto não.

## 7. Dinâmica 2016–2019 — H4 (Figura 2)

Painel balanceado de 16 países (M2, CRS, produto), médias geométricas com IC 95% por bootstrap em blocos de país:

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência [IC] |
|---|---|---|---|---|
| Alta renda | 10 | 0,996 | 0,898 | 1,109 [1,007; 1,230] |
| Renda média | 6 | 1,000 | 0,931 | 1,074 [0,958; 1,262] |
| Todos | 16 | 0,997 | 0,910 | 1,096 [1,010; 1,197] |

- Decomposição de Var(log M) = 0,286: Var(log TC) 0,204 + Var(log EC) 0,147 + 2 Cov −0,065. Parcela de TC com rateio simétrico da covariância: **0,60** (convenção contábil). H4a apoiada: o componente de fronteira domina, e a fronteira recua em produtos por dólar durante o boom de investimento.
- H4b (EC da renda média > 1 com IC excluindo 1): EC = 1,07 com IC [0,96; 1,26] → **não apoiada**; a alta renda é que tem catch-up significativo (1,11 [1,01; 1,23]). β-convergência: inclinação de log EC no log da eficiência CRS inicial +0,043 (p = 0,47), sem convergência.
- Em palavras simples: a produtividade sobe porque "os campeões avançaram" ou porque "o país se aproximou dos campeões"; o Malmquist separa os dois pedaços; aqui o primeiro domina e os que se aproximaram foram, em média, os ricos.

## 8. Segundo estágio — H5, H6, H7 (Figura 4)

Regressão truncada com escores fixos e bootstrap por país (36 países), dependente = eficiência corrigida em (0, 1] truncada em 1 (positivo = mais eficiente); a parametrização em Farrell (≥ 1, truncada à esquerda) é reportada como sensibilidade do modelo conjunto e é instável nos canais (caudas extremas). N = casos completos da fórmula.

| Modelo | Variável | Coef. | IC 95% | n obs./países |
|---|---|---|---|---|
| H5 conjunto (M2) | efetividade governamental | −0,137 | [−0,329; −0,000] | 191/36 |
| H5 sem valores-piso | efetividade governamental | −0,121 | [−0,363; 0,012] | 169/34 |
| H5 com pesquisadores | log pesquisadores por milhão | 0,042 | [−0,053; 0,133] | 161/33 |
| H6 canal patentes | capitalização de mercado | 0,000 | [−0,001; 0,002] | 191/36 |
| H6 canal patentes | crédito privado | 0,001 | [−0,002; 0,003] | 191/36 |
| H7 canal patentes | log PIB per capita | −0,045 | [−0,154; 0,013] | 191/36 |
| H7 canal publicações | log PIB per capita | −0,093 | [−0,153; −0,014] | 191/36 |

- Parametrização em Farrell (H5 conjunto): efetividade +57,3 [0,04; 82,4] (positivo = menos eficiente), mesmo sentido. Algoritmo 2 de Simar-Wilson (rDEA, fronteira agrupada, Farrell): efetividade +10,5 [5,6; 16,2]; crédito −0,15 [−0,24; −0,08]. Tobit: efetividade −0,116 (p < 0,001). Três procedimentos com fronteiras e amostras distintas dão o mesmo sinal; nenhum deles testa separabilidade (associações descritivas em `associacao_z_vs_escore.csv`: efetividade −0,25, PIB per capita −0,30, P&D % PIB −0,21), por isso o segundo estágio é exploratório.
- H5 não confirmada (sinal negativo das instituições, no limite da significância e não robusto ao piso); H6 não confirmada; H7 contrariada (PIB per capita negativo em publicações, nulo em patentes).

## 9. O que muda na versão artigo

Ver `artigo/06_resultados_painel.md`: painel de 47 países (2017–2021), teste de RTS inconclusivo no painel (CRS p = 0,10), sinais preservados no segundo estágio, e comparações em amostra comum mostrando que a inversão da metafronteira nas variantes de qualidade e de P&D público decorre, em parte, da composição da amostra.

## 10. Síntese por hipótese

| Hipótese | Evidência na Fase A | Status |
|---|---|---|
| H1 escala | CRS rejeitado (p = 0,025, teste liberal), NIRS não rejeitado; EUA em DRS; China em CRS | parcialmente apoiada |
| H2 insumos por canal | GERD eleva a eficiência média (M1 0,42–0,71 → M2 0,64–0,82) | a testar com SFA |
| H3a canais | ρ = 0,52 [0,31; 0,69], p(ρ ≥ 0,5) = 0,59 | inconclusiva |
| H3b metafronteira | TGR média 0,95 > alta 0,62 (p = 1,0) | não apoiada |
| H4a dinâmica | TC domina (parcela 0,60), fronteira recua | apoiada |
| H4b convergência | EC média 1,07 [0,96; 1,26]; β +0,04 (p = 0,47) | não apoiada |
| H5 instituições | efetividade −0,14 [−0,33; −0,00]; não robusto ao piso | não apoiada |
| H6 finanças | coeficientes nulos | não apoiada |
| H7 desenvolvimento | PIB pc negativo em publicações, nulo em patentes | contrariada |
| R1 estimadores | ρ entre 0,51 e 0,93 | moderadamente robusto |
