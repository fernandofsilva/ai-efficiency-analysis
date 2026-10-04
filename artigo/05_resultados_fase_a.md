# Resultados — Fase A (dataset original, 2013–2021), revisados após a reanálise crítica

Base para a apresentação. Todos os números vêm de `output/tables/` (scripts `R/01` a `R/04`, `R/02b`, `R/02c`), reexecutados em 28/09/2026 (`output/rodar_pipeline.sh tudo`) após as correções registradas em `artigo/12_avaliacao_reanalise.md`, que sucedem as de `artigo/10`. Em 04/10/2026, após a análise crítica 3 (`artigo/18`), foram refeitos o Malmquist (seção 7, com a leitura invertida corrigida), o bloco WGI (seção 8), a dispersão (seção 6) e o SFA (síntese); figuras em `output/figures/` (sem sufixo). Eficiência na escala (0, 1], orientação a produto; "corrigido" = após bootstrap de Simar-Wilson.

## 1. Dados e diagnóstico

- 208 observações país-ano, 37 países na base bruta, 2013–2021, painel desbalanceado. A DEA principal usa **36 países e 191 observações** (17 zeros de investimento excluídos: Eslovênia só tem uma observação, com zero). Indicadores de IA do CSET via Our World in Data; patentes originalmente por milhão de habitantes, reconvertidas em contagem com a população do World Bank.
- **Zeros e piso.** 17 zeros e 22 valores no piso de 1–2 milhões de US$ (granularidade de 1 milhão). Zeros não inviabilizam o modelo de dois insumos (a LP é viável), mas as unidades com zero saem eficientes ou quase por construção e rebaixam as demais (2015: escore médio das cinco unidades com zero 0,91; média das outras cai de 0,77 para 0,72; `sensibilidade_zeros_m2.csv`). A exclusão é uma escolha de medida (zero = negócio não registrado), não de viabilidade.
- **Supereficiência.** 19 das 191 observações ficam além da fronteira agrupada (M2); **7 estão no piso** (Austrália e México 2013, Romênia e Malásia 2016, Ucrânia 2018, Peru 2019, Bulgária 2021) e 12 não (China 2013 e 2019–2021, Índia 2013, 2016 e 2019–2020, Malásia 2015, México 2018, Peru 2020, Romênia 2020). Pontos extremos não se explicam só pela granularidade (`supereficiencia_cruzada_piso.csv`).
- **Publicações não nascem de capital de risco.** Ucrânia 2013–2017: investimento zero, 134–359 publicações. O modelo base adiciona o GERD (P&D interno total, todos os setores, inclusive o empresarial) como segundo insumo.
- Correlações de Spearman insumo-produto: investimento × publicações 0,73; investimento × patentes 0,63; GERD × publicações 0,88; GERD × patentes 0,73.

## 2. Modelos

| Modelo | Insumos | Produtos | Papel |
|---|---|---|---|
| M1 | investimento privado em IA | publicações, patentes | comparação sem o P&D; não replica Ernst e Mishra (2021), que usam três insumos (cursos *online* de IA, investimento em empresas de IA e contratações em IA) e outros produtos (corrigido em 04/10/2026, `artigo/20`) |
| M2 (base) | investimento privado em IA, GERD | publicações, patentes | resultados principais |
| Canal acadêmico | idem M2 | publicações | H2, H3, H7 |
| Canal tecnológico | idem M2 | patentes | H2, H3, H6, H7 |

Fronteiras **contemporâneas por ano** (16 a 27 países por ano) para escores, rankings, canais e segundo estágio por regressão truncada; fronteira **agrupada** (todas as observações) para supereficiência, metafronteira por renda, teste de retornos de escala e algoritmo 2 de Simar-Wilson. As duas tecnologias temporais são objetos diferentes e não se validam mutuamente. Bootstrap de Simar-Wilson (1.000 réplicas); FDH, order-m (m ≈ 40% de n) e order-α (0,95); Malmquist CRS no painel balanceado 2016–2019 (16 países); segundo estágio com regressão truncada sobre o log do escore corrigido (escores fixos, bootstrap por país, 300 réplicas, convergência verificada em cada ajuste), algoritmo 2 do rDEA (semente fixada no processo filho) e Tobit.

## 3. Escala e retornos (H1)

- Teste de retornos de escala adaptado de Simar-Wilson (2002), rotina própria com a mesma construção da referência `rDEA::rts.test` (estatística 4.6, banda de Silverman), fronteira agrupada, mil réplicas, observações originais avaliadas contra a pseudofronteira:

| Modelo | H0 | S | p-valor | Leitura |
|---|---|---|---|---|
| M2 | retornos constantes | 0,666 | 0,091 | sem indício a 5% |
| M2 | retornos não crescentes | 0,989 | 0,96 | sem indício |
| M1 | retornos constantes | 0,202 | 0,116 | sem indício a 5% |

- **Validação por simulação** (`R/02c`, 100 simulações, B = 100, rotina própria e referência `rDEA::rts.test`): sob retornos constantes verdadeiros, as duas implementações rejeitam a 5% em cerca de 20% das amostras (rotina própria 0,19 com 40 unidades, 0,23 com 191 e dois insumos, 0,25 com 191 e um insumo; referência 0,15, 0,21 e 0,23; IC binomial de 95% da frequência de 0,20 em 100 amostras: [0,13; 0,29]). O tamanho não é controlado; os p-valores são diagnósticos exploratórios. A versão anterior da rotina (banda calculada na amostra refletida) era ainda mais liberal com n = 191 (0,30 e 0,48) e dava p = 0,025 (M2) e p < 0,001 (M1) nestes dados; com a rotina alinhada à referência, nenhum p fica abaixo de 0,05.
- Por país (`rts_por_pais_m2.csv`, classificação anual pela regra de Färe, Grosskopf e Lovell): 15 dos 36 países estão em retornos decrescentes em todos os anos (Estados Unidos, SE média 0,35; Japão 0,67; Reino Unido 0,41); a **China é CRS com eficiência de escala 1 em todos os nove anos** e a Índia alterna (4 anos CRS, 4 DRS, SE média 0,93). Em 2018 (M2): 20 países em DRS, 3 em IRS, 4 em CRS.
- Leitura de H1: **sem apoio conclusivo**. O teste global não fornece indício contra retornos constantes (e, se fornecesse, teria tamanho em torno de 0,20). A evidência é descritiva e heterogênea: os grandes investidores anglófonos e o Japão operam em retornos decrescentes; a China está sobre o raio de produtividade máxima.

## 4. Ranking com inferência (Figura 1)

- Construção: pseudo-valores de Simar e Wilson (1998) por país-ano e réplica (F̃ = 2F̂ − F*), invertidos para a escala de escore e agregados sobre os anos do país réplica a réplica (réplicas pareadas dentro do ano, independentes entre anos). Ponto = média das pseudo-réplicas (escore corrigido de viés na escala da média anual; coincide, a menos de 0,01, com a média dos escores anuais corrigidos); IC 95% = quantis das médias pseudo-replicadas; nenhum ponto fica fora do próprio intervalo. Também: intervalo de postos e contrastes pareados entre os cinco países da base e os demais (`ranking_paises_boot.csv`, `ranking_contrastes_base.csv`). Viés médio do bootstrap 0,15 (escore médio 0,72 → 0,57 corrigido).
- Topo: Itália (2 anos) 0,80 [0,71; 0,90], posto [1; 13]; Grécia (7) 0,78 [0,72; 0,84], posto [1; 13]; Malásia (4) 0,77 [0,68; 0,87]; Indonésia (2) 0,77 [0,63; 0,91]; Índia (8) 0,77 [0,69; 0,84], posto [1; 15]; Bulgária (3) 0,76; Romênia (4) 0,76; China (9) 0,76 [0,68; 0,84], posto [2; 15]. Base: Filipinas (1) 0,36; África do Sul (5) 0,25 [0,24; 0,27], posto [32; 33]; Noruega (6) 0,24 [0,22; 0,25], posto [32; 34]; Irlanda (2) 0,22 [0,19; 0,24], posto [33; 34]; Israel (9) 0,19 [0,18; 0,20], posto [35; 35]; Suíça (1) 0,15 [0,12; 0,18], posto [36; 36].
- Contrastes pareados (IC da diferença excluindo zero): a Suíça fica abaixo dos 35 demais países; Israel, de 34; Irlanda, de 32; Noruega e África do Sul, de 31. Já a ordem dentro do topo não é distinguível: os oito primeiros têm intervalos de posto que vão de 1 a 13–18. A ordenação mistura países com 1 a 9 anos, e os pseudo-valores condicionam-se às fronteiras anuais estimadas.
- Leitura: com produtos em contagem e GERD total como insumo, países pequenos e ricos com P&D intensivo em empresas aparecem como ineficientes; o escore mede em parte a intensidade de IA do sistema de pesquisa.

## 5. Robustez entre estimadores — R1 (Figura 6)

Spearman com o escore VRS (bootstrap em blocos de país, 36 blocos): corrigido 0,93 [0,83; 0,97]; FDH 0,70 [0,51; 0,82]; order-α 0,69 [0,48; 0,81]; order-m 0,51 [0,23; 0,70]; M1 0,72 [0,57; 0,84]. Order-m × order-α 0,74. Rankings moderadamente robustos; as fronteiras parciais divergem mais.

## 6. Canais e metafronteira — H3 (Figuras 3 e 7)

- Spearman entre eficiência acadêmica e tecnológica (país-ano, blocos de país): 0,52 [0,31; 0,69]; p-valor unilateral de H0: ρ ≥ 0,5 = 0,59 (sem piso: 0,56, p = 0,72). **H3a inconclusiva**: compatível no ponto com correlação moderada, sem evidência contra ρ ≥ 0,5.
- Metafronteira agrupada por grupo de renda: TGR média 0,62 (alta renda, 24 países) e 0,94 (renda média, 12 países). H3b, com dois alvos: (i) deslocamento de distribuição, Mann-Whitney unilateral (renda média abaixo), p = 1,0 em país-ano e em médias por país; (ii) diferença de TGR médio (renda média menos alta renda) +0,32 [+0,23; +0,40] por bootstrap em blocos de país. **Não apoiada**, com sinal contrário: com contagens, o grupo de renda média define a metafronteira (China, Índia, México, Peru). Ambos os alvos condicionam-se às fronteiras estimadas.
- Diferenças por grupo de renda (mesmo teste nas duas unidades amostrais): canal de patentes, Kruskal-Wallis com três grupos p = 0,001 em país-ano e 0,022 em médias por país; Mann-Whitney com dois grupos p < 0,001 e 0,020 (0,34 na renda média-alta contra 0,17 na alta renda); publicações e modelo conjunto sem diferença em nenhuma versão.
- **Dispersão por grupo de renda e ano** (Figura 5; S08, detalhes em `artigo/16`, seção 4; escore corrigido). As fronteiras são anuais: as medidas descrevem a dispersão observada em cada referência anual, e nem as relativas (CV, IQR/mediana) são automaticamente comparáveis entre anos. O IQR é dispersão absoluta. O teste compara o desvio absoluto mediano entre as metades do período (2013–2017 × 2018–2021), com bootstrap de países, porque os mesmos países aparecem nas duas metades.
  - **Renda média-alta:** o CV sobe 0,022 por ano, só como descrição de tendência (MQO com 9 pontos e composição variável). O desvio mediano passa de 0,021 para 0,054: diferença +0,033 [−0,088; 0,170], p bootstrap 0,53 (Wilcoxon pareado em 7 países, p = 0,67). O mínimo é o Brasil até 2015, a África do Sul de 2016 a 2019 e a Argentina em 2020–2021; o máximo alterna entre Indonésia, México, Malásia e China.
  - **Alta renda:** CV sem tendência (−0,007 por ano). Desvio mediano de 0,129 para 0,169: +0,040 [−0,074; 0,111], p = 0,56 (pareado, 19 países: p = 0,86). Israel é o mínimo em todos os anos.
  - **Renda média-baixa:** só tem a Índia, exceto em 2018, quando entram as Filipinas (0,35). A "abertura" de 2018 na Figura 5 é composição, não crise.

## 7. Dinâmica 2016–2019 — H4 (Figura 2)

**Convenção (revista em 04/10/2026, `artigo/18`, A01):** índice maior que 1 = melhora (Färe et al., 1994). M > 1, a produtividade cresce; TC > 1, a fronteira avança; EC > 1, o país se aproxima da fronteira. As versões anteriores desta seção liam os índices do `Benchmarking` no sentido inverso: o que estava escrito como recuo da fronteira e catch-up era avanço da fronteira e afastamento dela.

Painel balanceado de 16 países (M2, CRS, produto), médias geométricas; intervalos por reamostragem de países com os índices mantidos fixos (descrevem a variação de composição entre trajetórias e não propagam a incerteza das fronteiras):

| Grupo | n | Malmquist | Mudança técnica [intervalo] | Mudança de eficiência [intervalo] |
|---|---|---|---|---|
| Alta renda | 10 | 1,004 | 1,114 [1,006; 1,236] | 0,902 [0,813; 0,993] |
| Renda média | 6 | 1,000 | 1,074 [0,934; 1,265] | 0,931 [0,792; 1,044] |
| Todos | 16 | 1,003 | 1,099 [1,017; 1,188] | 0,913 [0,835; 0,990] |

- **Produtividade estável.** A fronteira avança cerca de 10% ao ano (TC 1,10, intervalo acima de 1), e os países, em média, se afastam dela quase na mesma proporção (EC 0,91, intervalo abaixo de 1).
- **Decomposição.** Var(log M) = 0,286: Var(log TC) 0,204 + Var(log EC) 0,147 + 2 Cov −0,065. Parcela de TC com rateio simétrico da covariância: **0,60** (convenção contábil; não muda com a convenção do índice). H4a: o componente de fronteira domina a variação, e a fronteira **avança**.
- **H4b** (critério numérico: EC da renda média > 1 com o intervalo excluindo 1): EC = 0,931 [0,792; 1,044] → **não atendido**. No ponto, a renda média se afasta da fronteira um pouco menos que a alta renda (0,902 [0,813; 0,993]), com intervalos sobrepostos.
- **β-convergência** (MQO descritivo; eficiência inicial CRS medida contra a mesma fronteira do painel balanceado, `e00` do Malmquist): inclinação de log EC no log da eficiência inicial −0,106 (p = 0,11). O sinal é de convergência (quem começou mais longe se afastou menos), mas sem significância; parte de uma inclinação negativa é mecânica (escore limitado a 1).
- **Em palavras simples:** a produtividade de um país muda porque "os campeões avançaram" ou porque ele "se aproximou dos campeões". Aqui os campeões avançaram, e a maioria dos países ficou para trás.

**Por país (S06; `malmquist_por_pais.csv`).** Médias geométricas 2016–2019. A leitura usa faixas de 5% em torno de 1: TC acima de 1,05, a fronteira avança; abaixo de 0,95, recua. EC acima de 1,05 é catch-up; abaixo de 0,95, o país se afasta. "Na fronteira em todos os anos" exige escore CRS contemporâneo igual a 1 nos quatro anos (`malmquist_escores_crs.csv`); a versão anterior usava EC médio igual a 1 e incluía por engano a Argentina, cujo escore cai a 0,42 em 2017 (`artigo/18`, A02).

| País | Grupo | Malmquist | Mudança técnica (TC) | Mudança de eficiência (EC) | Escore CRS 2016 → 2019 | Leitura |
|---|---|---|---|---|---|---|
| China | Renda média | 1,54 | 1,54 | 1,00 | 1,00 → 1,00 | na fronteira em todos os anos: só deslocamento da fronteira |
| Hungria | Alta renda | 1,23 | 1,21 | 1,02 | 0,53 → 0,57 | estável; fronteira avança |
| Japão | Alta renda | 1,22 | 1,31 | 0,93 | 0,56 → 0,46 | se afasta; fronteira avança |
| Estados Unidos | Alta renda | 1,21 | 1,47 | 0,83 | 0,36 → 0,20 | se afasta; fronteira avança |
| África do Sul | Renda média | 1,15 | 1,02 | 1,14 | 0,20 → 0,30 | catch-up; fronteira estável |
| Israel | Alta renda | 1,11 | 1,05 | 1,06 | 0,10 → 0,12 | catch-up; fronteira estável |
| Singapura | Alta renda | 1,10 | 1,04 | 1,06 | 0,50 → 0,60 | catch-up; fronteira estável |
| Índia | Renda média | 1,05 | 1,05 | 1,00 | 1,00 → 1,00 | na fronteira em todos os anos: só deslocamento da fronteira |
| Espanha | Alta renda | 1,05 | 1,02 | 1,03 | 0,44 → 0,48 | estável; fronteira estável |
| México | Renda média | 0,93 | 1,07 | 0,87 | 1,00 → 0,66 | se afasta; fronteira avança |
| Noruega | Alta renda | 0,87 | 1,09 | 0,80 | 0,37 → 0,19 | se afasta; fronteira avança |
| Argentina | Renda média | 0,83 | 0,83 | 1,00 | 1,00 → 1,00 (0,42 em 2017) | estável; fronteira recua |
| Grécia | Alta renda | 0,81 | 0,81 | 1,00 | 1,00 → 1,00 | na fronteira em todos os anos: só deslocamento da fronteira |
| Polônia | Alta renda | 0,80 | 1,00 | 0,80 | 1,00 → 0,51 | se afasta; fronteira estável |
| Áustria | Alta renda | 0,79 | 1,28 | 0,61 | 1,00 → 0,23 | se afasta; fronteira avança |
| Brasil | Renda média | 0,69 | 1,05 | 0,66 | 1,00 → 0,28 | se afasta; fronteira estável |

- **Na fronteira em todos os anos** (só se movem com ela): China, Índia e Grécia. A China tem o maior ganho de produtividade da amostra (1,54 ao ano): ela é quem empurra a fronteira. Na Grécia, a fronteira recua no seu ponto (0,81).
- **Se afastam da fronteira:** Brasil (EC 0,66), Áustria, Polônia, Noruega, México, Estados Unidos e Japão.
  - Nos Estados Unidos e no Japão, a fronteira avança muito no seu ponto (TC 1,47 e 1,31), e a produtividade cresce mesmo com o afastamento.
  - O Brasil perde produtividade (0,69) porque se afasta de uma fronteira quase parada no seu ponto (TC 1,05): o oposto do que se leu antes e do que o professor antecipou.
- **Catch-up:** África do Sul, Israel e Singapura, a partir de escores baixos.
- **Tese do platô:** não se confirma no Malmquist. Quem está perto da fronteira e investe muito (China, Estados Unidos, Japão) é justamente onde a fronteira mais avança. O que aparece é outra coisa: a fronteira se descola da maioria dos países, inclusive dos de renda média (EC 0,93). Os retornos decrescentes por país (seção 3) descrevem a escala, e não a dinâmica.
- **Moraes e Wanke (2019)**, *Cadernos EBAPE.BR*, 17(2): na siderurgia brasileira, o financiamento do BNDES tem efeito negativo sobre o catch-up e nenhum sobre o deslocamento da fronteira. O artigo chama o catch-up de "Mudança Técnica", ao contrário deste projeto, em que esse nome designa o deslocamento da fronteira (ver `artigo/16`, seção 3).

## 8. Segundo estágio — H5, H6, H7 (Figura 4)

Especificação principal: regressão normal truncada sobre o **log do escore corrigido** (log s em (−∞, 0), truncada à direita em 0), escores fixos, bootstrap por país (36 países), convergência verificada no ajuste pontual e em cada réplica (todas as 300 convergem em todos os modelos abaixo). É uma especificação exploratória própria, escolhida pelo suporte compatível e pela estabilidade numérica, e não o modelo de Simar e Wilson (2007) em outra escala (`artigo/18`, A09). Coeficiente positivo = mais eficiente; a leitura é de sinal, porque o coeficiente se refere à média latente antes da truncagem e não é um efeito percentual sobre o escore. N = casos completos da fórmula.

| Modelo | Variável | Coef. | IC 95% | p bootstrap | Nível de evidência (S07) | n obs./países |
|---|---|---|---|---|---|---|
| H5 conjunto (M2) | efetividade governamental | −0,581 | [−1,309; 0,016] | 0,060 | sinal contrário, 5–10% | 191/36 |
| H5 sem valores-piso | efetividade governamental | −0,656 | [−1,687; 0,016] | 0,087 | sinal contrário, 5–10% | 169/34 |
| H5 com pesquisadores | log pesquisadores por milhão | 0,146 | [−0,177; 0,445] | 0,433 | só o sinal | 161/33 |
| H6 canal patentes | capitalização de mercado | 0,000 | [−0,015; 0,023] | 0,933 | sem sinal (≈ 0) | 191/36 |
| H6 canal patentes | crédito privado | 0,014 | [−0,022; 0,042] | 0,347 | compatível (previsão: não positivo) | 191/36 |
| H7 canal patentes | log PIB per capita | −0,534 | [−1,803; 0,273] | 0,213 | sinal contrário | 191/36 |
| H7 canal publicações | log PIB per capita | −0,360 | [−0,660; −0,023] | 0,033 | compatível (previsão: não positivo) | 191/36 |

Níveis de evidência (S07): significativo a 5% (IC 95% exclui zero), "bateu na trave" (só o IC 90% exclui), só o sinal ou sinal contrário; definição completa em `artigo/16`, seção 2. As exportações de alta tecnologia têm o sinal previsto, sem significância, nos três modelos de H5.

**Outras dimensões do WGI (S07; revisto em 04/10/2026, `artigo/18`, A07).** Na Fase A, a efetividade e o controle da corrupção do dataset original diferem da cópia do World Bank em todas as 191 observações (até 0,53; `wgi_original_vs_cache.csv`). Por isso o bloco WGI usa as quatro dimensões, o índice e a própria efetividade de referência da mesma cópia (cache), na mesma amostra. O sinal é negativo em todas:
- efetividade (cópia do cache): −0,66 [−1,32; −0,04];
- qualidade regulatória: −0,56 [−1,28; 0,04] (5–10%);
- estado de direito: −0,49 [−1,06; −0,04];
- controle da corrupção: −0,49 [−0,99; −0,06];
- índice composto: −0,57 [−1,17; −0,06].

Com a cópia do cache, a efetividade passa de "bateu na trave" (−0,58, cópia original) para significativa a 5%: parte da diferença entre dimensões vinha da cópia dos dados, e não do conceito. As quatro dimensões têm correlação de 0,93 a 0,96 nesta amostra, então não é possível separar capacidade regulatória de qualidade institucional geral (`segundo_estagio_wgi.csv`, `artigo/16`).

- Comparações (`dependente` na tabela): escore truncado só em 1, a especificação das versões anteriores, dá efetividade −0,137 [−0,329; −0,000]; seu suporte (−∞, 1) é incompatível com o escore, com massa condicional abaixo de zero desprezível no modelo conjunto (0,2% na mediana) mas de 16% na mediana (máximo 46%) no canal de patentes. Em Farrell (truncada à esquerda em 1), o ajuste é degenerado: H5 "converge" para +57 [0,04; 90] com sigma = 10; H6 de patentes não é estimado; H7 de patentes tem 228 de 300 réplicas convergentes. A normal truncada em 0 e em 1 não tem máximo finito nos canais de patentes e foi descartada.
- Algoritmo 2 de Simar-Wilson (rDEA, fronteira agrupada, Farrell, semente fixada): efetividade +10,1 [5,4; 15,3] (positivo = menos eficiente); crédito −0,15 [−0,23; −0,07]. Tobit: efetividade −0,116 (p < 0,001). Três procedimentos com fronteiras, amostras e escalas distintas dão o mesmo sinal negativo para as instituições; a especificação principal, porém, não o distingue de zero. Nenhum deles testa separabilidade (associações descritivas em `associacao_z_vs_escore.csv`), por isso o segundo estágio é exploratório.
- H5 não apoiada (sinal negativo, IC da principal inclui zero; não robusto ao piso); H6 não apoiada; H7 contrariada (PIB per capita negativo em publicações, nulo em patentes).

## 9. O que muda na versão artigo

Ver `artigo/06_resultados_painel.md`: painel de 47 países (2017–2021), teste de RTS sem indício contra retornos constantes, instituições com sinal negativo e significativo na especificação principal em quatro variantes, e comparações em amostra e fronteira comuns mostrando que a inversão da metafronteira nas variantes de produtos alternativos e de P&D executado por ensino superior e governo tem origens diferentes (especificação e composição da amostra, respectivamente).

## 10. Síntese por hipótese e por pergunta de pesquisa

Estrutura decidida em 04/10/2026 (S03; `artigo/01`): três hipóteses (H1 a H3) e duas perguntas de pesquisa exploratórias (RQ1, dinâmica, antiga H4; RQ2, determinantes, antigas H5 a H7, com as expectativas E5 a E7).

| | Evidência na Fase A | Status |
|---|---|---|
| H1 escala | teste global sem indício contra CRS (p = 0,09; tamanho ≈ 0,2); EUA em DRS, China em CRS; SFA com IC por país: retornos decrescentes em publicações (0,69 [0,55; 0,79]) e não distinguíveis de constantes em patentes (1,25 [0,92; 1,45]) | sem apoio conclusivo; heterogeneidade por país e por canal |
| H2 insumos por canal | SFA (`artigo/15`): no modelo agrupado, efeito em patentes e diferença entre canais não distinguíveis de zero; nos modelos de painel, efeito positivo em patentes e diferença acima de zero (1988: 0,12 [0,03; 0,20]; 1992: 0,13 [0,03; 0,23]); elasticidade do GERD 0,59 (publicações) e 1,17 (patentes). A DEA M1 × M2 não entra: acrescentar insumo nunca reduz o escore | apoiada só nos modelos de painel; não se repete no painel do artigo |
| H3a canais | ρ = 0,52 [0,31; 0,69], p(ρ ≥ 0,5) = 0,59 | inconclusiva |
| H3b metafronteira | TGR média 0,94 > alta 0,62; diferença +0,32 [0,23; 0,40]; MW p = 1,0 | não apoiada (sinal contrário) |
| RQ1 dinâmica | fronteira avança (TC 1,10 [1,02; 1,19]) e domina a variância (parcela 0,60); países se afastam (EC 0,91 [0,84; 0,99]); EC da renda média 0,931 [0,792; 1,044] contra 0,902 na alta renda; β −0,11 (p = 0,11); China, Índia e Grécia na fronteira em todos os anos; o Brasil se afasta (EC 0,66) | resposta: a fronteira avança e domina; a maioria fica para trás; sem catch-up da renda média |
| RQ2-E5 instituições | efetividade −0,58 [−1,31; 0,02] (cópia original; sinal contrário, 5–10%) e −0,66 [−1,32; −0,04] com a cópia do cache usada no bloco WGI; negativa em quatro procedimentos e com todas as dimensões do WGI; exportações de alta tecnologia e pesquisadores só com o sinal esperado | associação negativa robusta com as instituições, contrária à expectativa |
| RQ2-E6 finanças | capitalização ≈ 0; crédito compatível com a expectativa | sem associação |
| RQ2-E7 desenvolvimento | PIB per capita negativo em patentes (sinal contrário, sem significância) e em publicações (compatível) | contrária à expectativa no canal de patentes |
| R1 estimadores | ρ entre 0,51 e 0,93 | moderadamente robusto |

**Robustez à padronização (S01, 04/10/2026; detalhes em `artigo/14_padronizacao_minmax.md`).** Com as variáveis da fronteira em min-max (ε = 0,01), a Fase A mantém:
- a base do ranking (Israel em 35º/36º; Suíça);
- H3b sem apoio (TGR renda média − alta +0,27 [0,18; 0,35]);
- o sinal de H5: efetividade −0,53 [−0,94; −0,08], agora com IC que exclui zero;
- o sinal de H7.

Mudam o topo do ranking (Spearman entre versões 0,45) e a classificação de retornos de escala. Esta última não tem leitura econômica com min-max, porque a origem muda; H1 e o Malmquist seguem lidos em unidades originais. A especificação principal é a de unidades originais (decisão do autor de 04/10/2026), e a min-max entra como verificação de robustez (R4).
