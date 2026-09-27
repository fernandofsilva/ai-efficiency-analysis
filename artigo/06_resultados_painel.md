# Resultados no painel reconstruído (Fase B), revisados após a análise crítica

Painel `data/processed/painel_ia.csv`: 47 países, 2016–2024 (CSET v1.12.0 + World Bank + AI Index + OECD.AI + OCDE/Eurostat). Modelo conjunto com insumos defasados um ano (investimento privado em IA em US$ de 2021 e GERD, ambos em t−1), produtos em contagem, janela 2017–2021. Todas as saídas reexecutadas em 27/09/2026 após as correções de `artigo/10_avaliacao_inconsistencias.md`; cada execução está no manifesto `output/tables/manifesto_execucoes.csv`. Sufixos das tabelas: `_painel` (base), `_painel_qualidade`, `_painel_fonte`, `_painel_preqin`, `_painel_publico`.

## 1. Quadro único de amostras

| Análise | Base (volume) | Qualidade | Fonte (patentes por inventor) | Preqin (insumo) | P&D exec. ES+gov (insumo) |
|---|---|---|---|---|---|
| Janela | 2017–2021 | 2017–2019 | 2017–2021 | 2017–2021 | 2017–2021 |
| DEA (obs./países) | 204/47 | 117/44 | 217/46 | 194/46 | 184/41 |
| Sem valores-piso (≤ 2,5 M no insumo usado) | 186/44 | 107/41 | 198/45 | 190/46 | 168/38 |
| Malmquist balanceado (países) | 34 | 34 | 38 | 32 | 32 |
| Truncada H5 (casos completos/países) | 144/38 | 85/35 | 152/39 | 136/38 | 128/34 |
| Algoritmo 2 rDEA (casos completos) | 144 | não concluído | ok | ok | ok |

O piso agora é calculado no insumo efetivamente usado (t−1, ou Preqin); as amostras "sem piso" diferem das reportadas antes da revisão.

## 2. Fronteiras e escala (H1)

- Eficiência média VRS por ano (base) entre 0,49 e 0,70; sem piso, 0,47 a 0,70. Retornos decrescentes predominam (2019: 32 DRS, 6 IRS, 3 CRS), com exceção de 2018.
- Por país (`rts_por_pais_m2_painel.csv`): 13 dos 47 países em DRS em todos os anos (Estados Unidos, SE média 0,26; Alemanha 0,25; Reino Unido 0,24; Japão 0,50); **China, Coreia do Sul e Índia são CRS em todos os seus anos** (SE = 1).
- Teste de retornos de escala (fronteira agrupada, mil réplicas, algoritmo corrigido):

| Modelo | H0 | S | p-valor | Réplicas válidas |
|---|---|---|---|---|
| M2 | retornos constantes | 0,577 | **0,10** | 967 |
| M2 | retornos não crescentes | 0,979 | 0,90 | 976 |
| M1 | retornos constantes | 0,347 | < 0,001 | 999 |

- Como o teste tem tamanho liberal (rejeita CRS em 20% das amostras sob CRS verdadeiro, `validacao_teste_rts.csv`), a não rejeição no painel é robusta: **H1 fica sem apoio conclusivo no painel** — os grandes investidores anglófonos e europeus operam em DRS, mas os três grandes asiáticos operam sobre o raio CRS e o teste global não rejeita retornos constantes.

## 3. Rankings (Figura `fig1_ranking_m2_painel.png`)

- Média 2017–2021 dos escores anuais corrigidos, com IC 95% bootstrap da média anual (centrado no estimador original); anos por país entre parênteses. Topo: Itália (5) 0,77 [0,09; 0,73]; Malásia (5) 0,76 [0,00; 0,74]; Croácia (2) 0,75; Rússia (5) 0,72; Sérvia (1) 0,72; Romênia (4) 0,72; Ucrânia (1) 0,72; Coreia do Sul (5) 0,71. Base: Suécia (5) 0,24 [0,18; 0,24]; Bélgica (5) 0,23; África do Sul (5) 0,23; Irlanda (2) 0,20; Israel (5) 0,16 [0,13; 0,16].
- Os intervalos do topo são largos (limite inferior próximo de 0 para países sobre a fronteira); os da base são estreitos. Só a separação base × restante é ordinalmente defensável. Spearman com o ranking da Fase A (34 países comuns): 0,82.
- Rankings das variantes contra a base (países comuns): qualidade 0,80 (44), patentes por inventor 0,85 (46), Preqin 0,89 (46), P&D executado por ensino superior e governo 0,88 (41).

## 4. Robustez entre estimadores (R1)

Spearman com o escore VRS (bootstrap em blocos de país): corrigido 0,96 [0,93; 0,98]; M1 0,82 [0,72; 0,90]; FDH 0,69 [0,53; 0,78]; order-α 0,65 [0,47; 0,75]; order-m 0,63 [0,45; 0,75]; order-m × order-α 0,94. Todos sobre a mesma fronteira anual.

## 5. Canais e metafronteira (H3)

| | Base | Qualidade | Fonte | Preqin | P&D ES+gov |
|---|---|---|---|---|---|
| Spearman entre canais | 0,48 [0,30; 0,63] | 0,42 [0,20; 0,60] | 0,30 [0,04; 0,50] | 0,55 [0,37; 0,67] | 0,55 [0,33; 0,70] |
| p unilateral de H0: ρ ≥ 0,5 | 0,37 | 0,19 | **0,026** | 0,71 | 0,67 |
| TGR alta / renda média | 0,61 / 0,93 | 0,94 / 0,84 | 0,68 / 0,89 | 0,78 / 0,84 | 0,92 / 0,82 |
| H3b (média < alta), p unilateral país-ano / médias por país | 1,0 / 1,0 | **0,006 / 0,041** | 1,0 / 1,0 | 0,99 / 0,89 | **0,002 / 0,018** |
| Kruskal-Wallis canal patentes (país-ano / médias por país) | < 0,001 / 0,010 | 0,067 / 0,096 | < 0,001 / 0,65 | 0,002 / 0,056 | 0,004 / 0,053 |

- H3a (ρ < 0,5): só a variante com patentes por país do inventor rejeita ρ ≥ 0,5; nas demais o resultado é compatível no ponto, mas inconclusivo.
- H3b (renda média abaixo da metafronteira): não apoiada em volume (o grupo de renda média define a metafronteira), apoiada nas variantes de qualidade e de P&D executado por ensino superior e governo. A seção 9 mostra o quanto disso é composição da amostra.

## 6. Dinâmica 2017–2021 (H4)

Painel balanceado, CRS, médias geométricas com IC 95% por bootstrap em blocos de país (base, 34 países):

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência [IC] |
|---|---|---|---|---|
| Alta renda | 27 | 0,94 | 0,85 | 1,107 [1,074; 1,143] |
| Renda média | 7 | 0,84 | 0,86 | 0,984 [0,909; 1,062] |
| Todos | 34 | 0,92 | 0,85 | 1,081 [1,042; 1,117] |

- Decomposição de Var(log M) = 0,065: Var(log TC) 0,048 + Var(log EC) 0,079 + 2 Cov −0,062. Parcela de TC com rateio simétrico da covariância: **0,26** (0,38 na soma das variâncias, indicador reportado antes da revisão). H4a não se sustenta no painel como "dominância": a mudança de eficiência varia mais entre países do que a mudança técnica, e as duas são negativamente correlacionadas. A fronteira continua recuando em produtos por dólar (TC 0,85).
- H4b: EC da renda média 0,98 [0,91; 1,06], IC inclui 1 → **não apoiada**; β-convergência: inclinação −0,008 (p = 0,73). Nas variantes: qualidade EC média 1,00 [0,89; 1,12]; Preqin 1,04 [1,00; 1,08] (limítrofe); P&D ES+gov 0,92 [0,80; 1,04].

## 7. Segundo estágio (H5, H6, H7)

Regressão truncada, escores fixos, bootstrap por país; dependente = eficiência corrigida em (0, 1] truncada em 1 (positivo = mais eficiente); N = casos completos. A parametrização em Farrell é reportada nas tabelas (`dependente = farrell`) e é instável nos canais.

| Modelo | Variável | Base | Qualidade | Fonte | Preqin | P&D ES+gov |
|---|---|---|---|---|---|---|
| H5 conjunto | efetividade governamental | −0,180 [−0,308; −0,065] (144/38) | −0,076 [−0,272; 0,101] (85/35) | −0,111 [−0,242; −0,013] (152/39) | −0,217 [−0,403; −0,024] (136/38) | −0,143 [−0,239; −0,053] (128/34) |
| H5 sem piso | efetividade governamental | −0,191 [−0,335; −0,059] | −0,091 [−0,269; 0,054] | −0,100 [−0,234; −0,001] | −0,212 [−0,401; −0,019] | −0,144 [−0,253; −0,043] |
| H5 pesquisadores | log pesquisadores/milhão | 0,063 [−0,038; 0,144] | 0,060 [−0,076; 0,189] | 0,096 [0,016; 0,168] | 0,038 [−0,065; 0,111] | 0,117 [0,024; 0,201] |
| H5 talento | log média por gênero | 0,005 [−0,156; 0,213] | 0,056 [−0,183; 0,336] | 0,170 [0,083; 0,304] | 0,001 [−0,203; 0,302] | 0,088 [−0,055; 0,274] |
| H6 patentes | crédito privado | 0,0023 [0,0003; 0,0038] | 0,0023 [−0,0002; 0,0040] | 0,0009 [−0,0033; 0,0036] | 0,0022 [0,0002; 0,0038] | 0,0026 [0,0007; 0,0043] |
| H6 patentes | capitalização de mercado | −0,001 [−0,002; 0,001] | −0,001 [−0,002; 0,001] | n.s. | n.s. | n.s. |
| H7 patentes | log PIB per capita | −0,057 [−0,121; −0,008] | −0,042 [−0,120; 0,016] | −0,032 [−0,122; 0,052] | −0,080 [−0,142; −0,029] | −0,095 [−0,178; −0,025] |
| H7 publicações | log PIB per capita | −0,068 [−0,149; 0,003] | 0,015 [−0,071; 0,097] | −0,093 [−0,163; −0,031] | −0,076 [−0,158; 0,001] | −0,088 [−0,178; −0,014] |

- Algoritmo 2 de Simar-Wilson (rDEA, fronteira agrupada, casos completos de contexto, escala de Farrell, sinal invertido): base efetividade +17,0 [6,1; 24,6]*, crédito −0,25*; fonte +2,85*; P&D ES+gov +2,95*; Preqin +59 (n.s.); qualidade: não concluído em 10 minutos (tabela anterior marcada como obsoleta).
- Leitura: a associação negativa entre efetividade governamental e eficiência medida aparece em quatro das cinco variantes com produtos em contagem e deixa de ser distinguível de zero na variante de qualidade; a seção 9 testa se essa diferença é de especificação ou de amostra. Pesquisadores por milhão e talento em IA só têm sinal positivo significativo nas variantes de fonte e de P&D executado por ensino superior e governo. Crédito bancário (não a capitalização) associa-se positivamente ao canal de patentes (H6 contrariada); PIB per capita é negativo ou nulo (H7 contrariada). Nenhum destes procedimentos testa separabilidade; o segundo estágio é exploratório.

## 8. Checagens entre fornecedores (`R/12`, bootstrap em blocos de país)

- Investimento acumulado CSET × Quid (AI Index), transversal, 84 países: Spearman 0,93 [0,87; 0,96].
- Investimento por país-ano CSET (VC + PE + fusões, estimado) × Preqin (só VC), 2016–2023, 513 pares, 83 países: 0,83 [0,76; 0,89]. Os dois universos de transações diferem; a razão China CSET/Preqin de 0,35 reflete cobertura e definição.
- Publicações CSET × OECD.AI (OpenAlex), parcela mundial, 9 economias, 81 pares: 0,95 [0,80; 0,99]; Pearson 0,99.
- Patentes CSET (famílias pelo país de prioridade) × OCDE (famílias IP5 pelo país do inventor), 302 pares, 63 países: 0,75 [0,61; 0,85].

## 9. Comparações em amostra comum (`R/05`)

Metafronteira por grupo de renda, três estimativas por variante (`comparacao_metafronteira_amostra_comum.csv`):

| Variante | Base na amostra original (204) | Base na amostra da variante | Variante na amostra da variante |
|---|---|---|---|
| P&D ES+gov (184) | 0,61 / 0,93 | **0,93 / 0,80** | 0,91 / 0,81 |
| Qualidade (117) | 0,61 / 0,93 | 0,59 / 0,87 | **0,94 / 0,83** |
| Patentes por inventor (203) | 0,61 / 0,93 | 0,61 / 0,93 | 0,70 / 0,88 |
| Preqin (194) | 0,61 / 0,93 | 0,61 / 0,96 | 0,78 / 0,84 |

- Na variante de P&D executado por ensino superior e governo, a inversão já ocorre ao restringir a amostra aos 184 país-ano com a especificação base: é **efeito de composição** (saem Brasil, Índia, Malásia, Filipinas, Arábia Saudita e Ucrânia, que definiam a metafronteira). A troca de insumo não altera o resultado.
- Na variante de qualidade, a inversão **não** ocorre com a especificação base na mesma amostra e ocorre com os produtos alternativos: é **efeito de especificação**.
- Coeficiente de efetividade governamental, base × variante na amostra comum, diferença com bootstrap pareado por país (`comparacao_coeficiente_efetividade_amostra_comum.csv`): P&D ES+gov −0,207 → −0,143 (dif. 0,064 [−0,004; 0,127]); qualidade −0,150 → −0,076 (0,074 [−0,026; 0,181]); fonte −0,180 → −0,136 (0,043 [−0,047; 0,150]); Preqin −0,180 → −0,217 (−0,038 [−0,152; 0,088]). **Nenhuma diferença é distinguível de zero**: a perda de significância na variante de qualidade não demonstra mudança de efeito.

## 9a. Variante de fonte: famílias de patentes por país do inventor (OCDE)

217 observações, 46 países. Ranking: Itália 0,74, Malásia 0,73, Rússia 0,73, **Estados Unidos 0,72**, Croácia, Índia, **Japão 0,70**; base: Suíça, Bélgica, Noruega, África do Sul, Dinamarca (0,19–0,21). Canais 0,30 [0,04; 0,50], única variante que rejeita ρ ≥ 0,5. Metafronteira 0,68/0,89 (H3b não apoiada). Malmquist: M 0,95, TC 0,97, EC 0,98 [0,95; 1,02]. A China passa a DRS em todos os anos (SE 0,43), pois as famílias IP5 por inventor reduzem muito suas patentes em relação aos depósitos domésticos. Pesquisadores (0,096*) e talento (0,170*) positivos.

## 9b. Variante de fonte: VC da Preqin como insumo (só estágio VC)

194 observações, 46 países. Troca de fornecedor **e** de universo de transações. Ranking: Malásia 0,81, Espanha 0,78, Japão 0,77, Itália 0,77, Turquia 0,74; base: Israel e Argentina 0,16, Irlanda 0,22. Canais 0,55; metafronteira 0,78/0,84 (H3b p = 0,99); Malmquist EC 1,10 [1,07; 1,12], renda média 1,04 [1,00; 1,08]. Efetividade −0,217 [−0,403; −0,024].

## 9c. Variante de insumo: P&D executado pelo ensino superior e pelo governo (MSTI + Eurostat)

184 observações, 41 países (sem Brasil, Índia, Malásia, Filipinas, Arábia Saudita e Ucrânia, sem fonte por setor). Ranking: Singapura 0,79, Espanha 0,78, Itália 0,78, Croácia 0,75, Rússia 0,75, Polônia 0,75; base: Finlândia 0,35, Dinamarca 0,32, Chile 0,31, Noruega 0,27, África do Sul 0,26. Israel sobe de 0,16 para 0,47 e Irlanda de 0,20 para 0,46 (efeito do insumo: o P&D empresarial deixa de ser contado). Metafronteira 0,92/0,82 (p = 0,002), mas a seção 9 mostra que a inversão é de composição. Pesquisadores por milhão positivos e significativos (0,117 [0,024; 0,201]); efetividade −0,143 [−0,239; −0,053]. A escolha deste insumo como acadêmico se justifica pela mensuração (setor de execução), não pela inversão.

## 10. Implicações para o artigo

1. H1 não tem apoio conclusivo no painel: o teste global (liberal) não rejeita CRS e três grandes economias asiáticas estão em CRS; reescrever a hipótese sobre retornos de escala como heterogeneidade por país.
2. O ajuste por qualidade dos produtos muda a metafronteira por especificação (não por amostra) e move posições do ranking (ρ = 0,80); a inversão na variante de P&D executado é composição da amostra.
3. A associação negativa entre efetividade governamental e eficiência medida é recorrente, mas as diferenças entre variantes não são distinguíveis de zero e nenhum procedimento testa separabilidade: tratar como padrão descritivo até o teste de Daraio, Simar e Wilson (2018).
4. Sem convergência da renda média em nenhuma variante; a mudança de eficiência varia mais que a técnica no painel.
5. Rankings moderadamente robustos à fonte (ρ 0,85–0,89); o canal de patentes é o mais sensível à atribuição (escritório vs inventor).
6. Pendências metodológicas: SFA por canal com classes latentes (H2); teste de separabilidade; inferência de dois estágios para painel; harmonização dos universos de investimento; limites alternativos de piso.
