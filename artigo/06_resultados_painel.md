# Resultados no painel reconstruído (Fase B), revisados após a reanálise crítica

Painel `data/processed/painel_ia.csv`: 47 países, 2016–2024 (CSET v1.12.0 + World Bank + AI Index + OECD.AI + OCDE/Eurostat). Modelo conjunto com insumos defasados um ano (investimento privado em IA em US$ de 2021 e GERD, ambos em t−1), produtos em contagem, janela 2017–2021. Todas as saídas reexecutadas em 28/09/2026 (`output/rodar_pipeline.sh tudo`) após as correções de `artigo/12_avaliacao_reanalise.md`; cada execução está em `output/tables/manifesto_execucoes.csv` e cada tabela gravada em `manifesto_saidas.csv`. Sufixos das tabelas: `_painel` (base), `_painel_qualidade` (produtos alternativos), `_painel_fonte` (patentes por país do inventor), `_painel_preqin` (VC da Preqin como insumo), `_painel_publico` (P&D executado por ensino superior e governo como insumo).

## 1. Quadro único de amostras

| Análise | Base (volume) | Produtos alternativos | Patentes por inventor | Preqin (insumo) | P&D ES+gov (insumo) |
|---|---|---|---|---|---|
| Janela | 2017–2021 | 2017–2019 | 2017–2021 | 2017–2021 | 2017–2021 |
| DEA (obs./países) | 204/47 | 117/44 | 217/46 | 194/46 | 184/41 |
| Sem valores-piso (≤ 2,5 M no insumo usado) | 186/44 | 107/41 | 199/45 | 190/46 | 168/38 |
| Malmquist balanceado (países) | 34 | 34 | 38 | 32 | 32 |
| Truncada H5 (casos completos/países) | 144/38 | 85/35 | 152/39 | 136/38 | 128/34 |
| Algoritmo 2 rDEA (casos completos) | 144 | não concluído em 300 s | ok | ok | ok |
| Amostra comum com a base (`R/05`) | — | 117 | 203 (14 só na variante) | 191 (3 zeros só na variante) | 184 |

O piso é calculado no insumo efetivamente usado (t−1, ou Preqin). A amostra comum com a base é a interseção das amostras admissíveis nas duas especificações: na Preqin ficam de fora `LUX-2017`, `COL-2019` e `SVN-2019`, com investimento CSET defasado igual a zero.

## 2. Fronteiras e escala (H1)

- Eficiência média VRS por ano (base) entre 0,49 e 0,70; sem piso, 0,47 a 0,70. Retornos decrescentes predominam (2019: 32 DRS, 6 IRS, 3 CRS), com exceção de 2018.
- Por país (`rts_por_pais_m2_painel.csv`): 13 dos 47 países em DRS em todos os anos (Estados Unidos, SE média 0,26; Alemanha 0,25; Reino Unido 0,24; Japão 0,50); **China, Coreia do Sul e Índia são CRS em todos os seus anos** (SE = 1).
- Teste de retornos de escala (fronteira agrupada, mil réplicas, rotina alinhada à referência `rDEA::rts.test`; tamanho em torno de 0,20 sob CRS verdadeiro nas duas implementações, `validacao_teste_rts.csv`):

| Modelo | H0 | S | p-valor | Réplicas válidas | Leitura |
|---|---|---|---|---|---|
| M2 | retornos constantes | 0,577 | 0,436 | 970 | sem indício a 5% |
| M2 | retornos não crescentes | 0,979 | 0,97 | 975 | sem indício a 5% |
| M1 | retornos constantes | 0,347 | 0,326 | 998 | sem indício a 5% |

- Leitura: **H1 sem apoio conclusivo no painel** — o teste global, liberal, não fornece indício contra retornos constantes no modelo base; a evidência descritiva é de heterogeneidade: grandes investidores anglófonos e europeus em DRS, os três grandes asiáticos sobre o raio CRS.

## 3. Rankings (Figura `fig1_ranking_m2_painel.png`)

- Média 2017–2021 dos escores anuais, com IC 95% por pseudo-valores de Simar-Wilson (réplicas pareadas dentro do ano), intervalo de postos e contrastes pareados (`ranking_paises_boot_painel.csv`, `ranking_contrastes_base_painel.csv`); nenhum ponto fora do próprio intervalo. Topo: Itália (5) 0,78 [0,72; 0,85], posto [1; 8]; Malásia (5) 0,77 [0,71; 0,85], posto [1; 9]; Croácia (2) 0,76 [0,62; 0,91]; Sérvia (1) 0,74 [0,58; 0,98]; Ucrânia (1) 0,74 [0,57; 0,98]. Base: Suécia (5) 0,24 [0,22; 0,25], posto [42; 45]; Bélgica (5) 0,23; África do Sul (5) 0,23; Irlanda (2) 0,21 [0,18; 0,23], posto [46; 46]; Israel (5) 0,16 [0,15; 0,16], posto [47; 47].
- Contrastes (IC da diferença excluindo zero): Israel fica abaixo dos 46 demais países; Irlanda, de 45; Bélgica e África do Sul, de 42; Suécia, de 40. A ordem no topo não é distinguível (postos de 1 a 8–21).
- Rankings das variantes contra a base, em amostra e fronteira comuns (`R/05`, médias por país): produtos alternativos 0,78; patentes por inventor 0,91; Preqin 0,87; P&D executado por ensino superior e governo 0,89.

## 4. Robustez entre estimadores (R1)

Spearman com o escore VRS (bootstrap em blocos de país): corrigido 0,96 [0,93; 0,98]; M1 0,82 [0,72; 0,90]; FDH 0,69 [0,53; 0,78]; order-α 0,65 [0,47; 0,75]; order-m 0,63 [0,45; 0,75]; order-m × order-α 0,94. Todos sobre a mesma fronteira anual.

## 5. Canais e metafronteira (H3)

| | Base | Produtos alternativos | Patentes por inventor | Preqin | P&D ES+gov |
|---|---|---|---|---|---|
| Spearman entre canais | 0,48 [0,30; 0,63] | 0,42 [0,20; 0,60] | 0,30 [0,04; 0,50] | 0,55 [0,37; 0,67] | 0,55 [0,33; 0,70] |
| p unilateral de H0: ρ ≥ 0,5 | 0,37 | 0,19 | **0,027** | 0,71 | 0,67 |
| TGR alta / renda média | 0,61 / 0,93 | 0,94 / 0,83 | 0,68 / 0,89 | 0,78 / 0,84 | 0,91 / 0,81 |
| H3b (i): Mann-Whitney unilateral, país-ano / médias por país | 1,0 / 1,0 | **0,006 / 0,041** | 1,0 / 1,0 | 0,99 / 0,89 | **0,002 / 0,018** |
| H3b (ii): diferença de TGR médio (média − alta) [IC por blocos de país] | +0,33 [0,24; 0,40] | **−0,11 [−0,21; −0,02]** | +0,21 [0,08; 0,32] | +0,07 [−0,02; 0,16] | −0,10 [−0,20; +0,01] |
| Canal de patentes por renda: Kruskal-Wallis 3 grupos, país-ano / médias por país | < 0,001 / 0,040 | 0,067 / 0,24 | < 0,001 / 0,15 | 0,002 / 0,16 | 0,004 / 0,052 |
| Canal de patentes por renda: Mann-Whitney 2 grupos, país-ano / médias por país | < 0,001 / 0,010 | 0,022 / 0,096 | 0,042 / 0,65 | < 0,001 / 0,056 | 0,004 / 0,053 |

- H3a (ρ < 0,5): só a variante com patentes por país do inventor rejeita ρ ≥ 0,5; nas demais o resultado é compatível no ponto, mas inconclusivo.
- H3b (renda média abaixo da metafronteira; critério exige os dois alvos): não apoiada em volume (o grupo de renda média define a metafronteira, com sinal contrário nos dois alvos); **apoiada na variante de produtos alternativos** (deslocamento e diferença de médias); na variante de P&D executado, apoiada no deslocamento mas com a diferença de médias incluindo zero, e a seção 9 mostra que a inversão ali é composição da amostra.
- Agregar por país enfraquece a diferença do canal de patentes por renda em todas as variantes (mesmo teste, unidade amostral diferente): a repetição temporal inflava a evidência.

## 6. Dinâmica 2017–2021 (H4)

Painel balanceado, CRS, médias geométricas; intervalos por reamostragem de países com índices fixos (descritivos; não propagam a incerteza das fronteiras). Base, 34 países:

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência [intervalo] |
|---|---|---|---|---|
| Alta renda | 27 | 0,94 | 0,85 | 1,107 [1,074; 1,143] |
| Renda média | 7 | 0,84 | 0,86 | 0,984 [0,909; 1,062] |
| Todos | 34 | 0,92 | 0,85 | 1,081 [1,042; 1,117] |

- Decomposição de Var(log M) = 0,065: Var(log TC) 0,048 + Var(log EC) 0,079 + 2 Cov −0,062. Parcela de TC com rateio simétrico da covariância: **0,26**. H4a não se sustenta no painel como "dominância": a mudança de eficiência varia mais entre países do que a mudança técnica, e as duas são negativamente correlacionadas. A fronteira continua recuando em produtos por dólar (TC 0,85).
- H4b, critério numérico (EC da renda média > 1 com o intervalo excluindo 1, valores não arredondados): base 0,984 [0,909; 1,062] → não atendido; produtos alternativos 0,997 [0,886; 1,123] → não; patentes por inventor 0,956 [0,864; 1,036] → não; **Preqin 1,0378 [1,0012; 1,0820] → atendido** (limite inferior acima de 1 em 20 sementes de 20; evidência descritiva de catch-up, não confirmação inferencial); P&D executado 0,916 [0,801; 1,043] → não.
- β-convergência (MQO descritivo; eficiência inicial CRS medida contra a fronteira do painel balanceado): base +0,001 (p = 0,96); produtos alternativos +0,115 (p = 0,066); patentes por inventor **+0,100 (p < 0,001)**; Preqin −0,020 (p = 0,32); P&D executado +0,115 (p < 0,001). Nenhuma variante mostra inclinação negativa; em duas, quem começou mais eficiente ganhou mais eficiência (divergência, não convergência).

## 7. Segundo estágio (H5, H6, H7)

Especificação principal: regressão truncada sobre o log do escore corrigido (truncada em 0), escores fixos, bootstrap por país, convergência verificada em cada ajuste (300 de 300 réplicas em todos os modelos abaixo); coeficiente positivo = mais eficiente (semi-elasticidade). N = casos completos. Parametrizações em escore truncado em 1 e em Farrell ficam nas tabelas como comparação (`dependente`), com os sinais de convergência; em Farrell, H6 de patentes não é estimado em nenhuma variante.

| Modelo | Variável | Base | Produtos alternativos | Patentes por inventor | Preqin | P&D ES+gov |
|---|---|---|---|---|---|---|
| H5 conjunto | efetividade governamental | **−0,69 [−1,20; −0,21]** (144/38) | −0,22 [−0,74; 0,29] (85/35) | −0,29 [−0,71; 0,01] (152/39) | **−1,12 [−1,58; −0,13]** (136/38) | **−0,38 [−0,59; −0,12]** (128/34) |
| H5 sem piso | efetividade governamental | **−0,78 [−1,32; −0,17]** | −0,29 [−0,74; 0,17] | −0,26 [−0,66; 0,02] | **−1,11 [−1,60; −0,11]** | **−0,34 [−0,57; −0,07]** |
| H5 pesquisadores | log pesquisadores/milhão | 0,18 [−0,16; 0,43] | 0,16 [−0,24; 0,54] | **0,28 [0,01; 0,50]** | 0,09 [−0,29; 0,35] | **0,31 [0,05; 0,54]** |
| H5 talento | log média por gênero | −0,14 [−0,75; 0,61] | 0,13 [−0,55; 0,95] | **0,57 [0,31; 0,94]** | −0,29 [−1,09; 0,98] | 0,28 [−0,08; 0,73] |
| H6 patentes | crédito privado | **0,027 [0,001; 0,045]** | 0,028 [−0,004; 0,052] | 0,004 [−0,021; 0,023] | **0,029 [0,006; 0,050]** | **0,033 [0,003; 0,055]** |
| H6 patentes | capitalização de mercado | −0,008 [−0,021; 0,019] | −0,003 [−0,021; 0,035] | 0,000 [−0,010; 0,026] | −0,008 [−0,021; 0,012] | −0,015 [−0,025; 0,022] |
| H7 patentes | log PIB per capita | **−0,96 [−1,69; −0,25]** | **−0,83 [−1,83; −0,09]** | −0,02 [−0,54; 0,43] | **−1,15 [−1,87; −0,46]** | **−1,12 [−2,22; −0,10]** |
| H7 publicações | log PIB per capita | **−0,26 [−0,56; −0,01]** | 0,07 [−0,18; 0,32] | **−0,37 [−0,65; −0,14]** | **−0,34 [−0,70; −0,03]** | **−0,21 [−0,44; −0,00]** |

- Algoritmo 2 de Simar-Wilson (rDEA, fronteira agrupada, casos completos de contexto, escala de Farrell, sinal invertido, semente fixada no processo filho): base efetividade +17,1 [8,1; 25,5]*, crédito −0,26*; patentes por inventor +2,76 [0,75; 5,01]*; P&D executado +2,77 [1,25; 4,19]*; Preqin +54 [−12; 95] (n.s.); produtos alternativos: não concluído em 300 s (tabela anterior marcada como obsoleta). Tobit (base): −0,167 (ep 0,032).
- Leitura: a associação negativa entre efetividade governamental e eficiência medida é significativa na especificação principal em três variantes com produtos em contagem (base, Preqin, P&D executado), fica no limite na variante de patentes por inventor e deixa de ser distinguível de zero na variante de produtos alternativos; a seção 9 testa se essa diferença é de especificação. Pesquisadores por milhão e talento em IA só têm sinal positivo significativo nas variantes de patentes por inventor (ambos) e de P&D executado (só pesquisadores). Crédito bancário (não a capitalização) associa-se positivamente ao canal de patentes (H6 contrariada); PIB per capita é negativo ou nulo nos dois canais (H7 contrariada). Nenhum procedimento testa separabilidade; o segundo estágio é exploratório.

## 8. Checagens entre fornecedores (`R/12`, bootstrap em blocos de país)

- Investimento acumulado CSET × Quid (AI Index), transversal, 84 países: Spearman 0,93 [0,87; 0,96].
- Investimento por país-ano CSET (VC + PE + fusões, estimado) × Preqin (só VC), 2016–2023, 513 pares, 83 países: 0,83 [0,76; 0,89]. Os dois universos de transações diferem; a razão China CSET/Preqin de 0,35 reflete cobertura e definição.
- Publicações CSET × OECD.AI (OpenAlex), parcela mundial, 9 economias, 81 pares: 0,95 [0,80; 0,99]; Pearson 0,99.
- Patentes CSET (famílias pelo país de prioridade) × OCDE (famílias IP5 pelo país do inventor), 302 pares, 63 países: 0,75 [0,61; 0,85].

## 9. Comparações em amostra e fronteira comuns (`R/05`)

Metafronteira por grupo de renda, três estimativas por variante, na interseção das amostras admissíveis (`comparacao_metafronteira_amostra_comum.csv`):

| Variante | Base na amostra original (204) | Base na amostra comum | Variante na amostra comum |
|---|---|---|---|
| P&D ES+gov (184) | 0,61 / 0,93 | **0,93 / 0,80** | 0,91 / 0,81 |
| Produtos alternativos (117) | 0,61 / 0,93 | 0,59 / 0,87 | **0,94 / 0,83** |
| Patentes por inventor (203) | 0,61 / 0,93 | 0,61 / 0,93 | 0,70 / 0,88 |
| Preqin (191) | 0,61 / 0,93 | 0,60 / 0,95 | 0,78 / 0,84 |

- Na variante de P&D executado, a inversão já ocorre ao restringir a amostra aos 184 país-ano com a especificação base: **efeito de composição** (saem Brasil, Índia, Malásia, Filipinas e Ucrânia, de renda média, e a Arábia Saudita, de alta renda, que definiam a metafronteira). Na variante de produtos alternativos, a inversão não ocorre com a base na mesma amostra e ocorre com os produtos alternativos: **efeito de especificação**.
- Escores reestimados na amostra comum para as duas especificações (DEA anual VRS + bootstrap), regressões nas mesmas observações com contexto completo e diferença do coeficiente de efetividade governamental por bootstrap pareado por país (`comparacao_coeficiente_efetividade_amostra_comum.csv`, escala log): P&D executado −0,69 → −0,38 (diferença +0,32 [−0,01; 0,62]); **produtos alternativos −0,65 → −0,22 (diferença +0,43 [0,05; 0,75])**; patentes por inventor −0,71 → −0,37 (+0,34 [−0,09; 0,85]); Preqin −0,78 → −1,10 (−0,32 [−0,66; 0,28]). Com fronteira comum, a atenuação da associação negativa ao trocar os produtos por citações e famílias concedidas é distinguível de zero; nas demais variantes não é.
- Decomposição por país (`comparacao_escores_pais_amostra_comum.csv`, escores corrigidos médios): na variante de P&D executado, Israel vai de 0,16 (base, amostra original) a 0,22 (base, amostra comum) e a 0,47 (variante): +0,07 de composição e +0,24 de especificação; Irlanda vai de 0,20 a 0,38 e a 0,46: +0,18 de composição e +0,08 de especificação. Na variante de patentes por inventor, Israel vai de 0,16 a 0,16 e a 0,48, e os Estados Unidos de 0,58 a 0,58 e a 0,75: todo o efeito é de especificação (famílias atribuídas ao inventor).

## 9a. Variante de fonte: famílias de patentes por país do inventor (OCDE)

217 observações, 46 países. Ranking: Itália (5) 0,75, Rússia 0,74, **Estados Unidos 0,74**, Malásia 0,74, Croácia 0,72; base: Suíça 0,21, Bélgica 0,20, Noruega, África do Sul, Dinamarca (0,19). Canais 0,30 [0,04; 0,50], única variante que rejeita ρ ≥ 0,5. Metafronteira 0,68/0,89, diferença +0,21 [0,08; 0,32] (H3b não apoiada). Malmquist: M 0,95, TC 0,97, EC 0,98 [0,95; 1,01]; β +0,10 (p < 0,001). A China passa a DRS em todos os anos (SE 0,43), pois as famílias IP5 por inventor reduzem muito suas patentes em relação aos depósitos domésticos. Efetividade −0,29 [−0,71; 0,01]; pesquisadores (+0,28*) e talento (+0,57*) positivos.

## 9b. Variante de fonte: VC da Preqin como insumo (só estágio VC)

194 observações, 46 países. Troca de fornecedor **e** de universo de transações. Ranking: Malásia 0,81, Espanha 0,78, Japão 0,78, Itália 0,78, Turquia 0,76; base: Israel 0,16, Argentina 0,16, Irlanda 0,23. Canais 0,55; metafronteira 0,78/0,84, diferença +0,07 [−0,02; 0,16] (H3b não apoiada); Malmquist EC 1,10 [1,07; 1,13], renda média 1,038 [1,001; 1,082] (critério numérico de H4b atendido; descritivo). Efetividade −1,12 [−1,58; −0,13].

## 9c. Variante de insumo: P&D executado pelo ensino superior e pelo governo (MSTI + Eurostat)

184 observações, 41 países (sem Brasil, Índia, Malásia, Filipinas, Ucrânia e Arábia Saudita, sem fonte por setor). Ranking: Singapura 0,79, Itália 0,79, Espanha 0,79, Croácia 0,77, Rússia 0,76; base: Finlândia 0,35, Dinamarca 0,32, Chile 0,32, Noruega 0,27, África do Sul 0,26. Israel sobe de 0,16 para 0,47 e Irlanda de 0,20 para 0,46, mas a decomposição da seção 9 mostra que, para Irlanda, a maior parte da subida (+0,18 de +0,26) vem da composição da amostra, e só para Israel a maior parte (+0,24 de +0,31) vem do insumo. Metafronteira 0,91/0,81 (deslocamento p = 0,002; diferença de médias −0,10 [−0,20; +0,01]), inversão por composição. Pesquisadores por milhão positivos e significativos (+0,31 [0,05; 0,54]); efetividade −0,38 [−0,59; −0,12]. A escolha deste insumo como acadêmico se justifica pela mensuração (setor de execução), não pela inversão.

## 10. Implicações para o artigo

1. H1 não tem apoio conclusivo em nenhuma base: o teste global (tamanho ≈ 0,20 nas duas implementações) não fornece indício contra CRS no modelo base, e três grandes economias asiáticas estão em CRS; reescrever a hipótese sobre retornos de escala como heterogeneidade por país.
2. A troca de produtos por citações e famílias concedidas muda a metafronteira por especificação (não por amostra) e, com fronteira comum, atenua a associação negativa com instituições de forma distinguível de zero (+0,43 [0,05; 0,75]); a inversão na variante de P&D executado é composição da amostra.
3. A associação negativa entre efetividade governamental e eficiência medida é recorrente nas variantes em volume, mas nenhum procedimento testa separabilidade: tratar como padrão descritivo até o teste de Daraio, Simar e Wilson (2018).
4. Sem convergência da renda média pelo critério numérico, exceto na variante Preqin (limítrofe e descritiva); a mudança de eficiência varia mais que a técnica no painel; β-convergência nula ou positiva.
5. Rankings moderadamente robustos à fonte (ρ 0,87–0,91 em amostra e fronteira comuns; 0,78 com produtos alternativos); o canal de patentes é o mais sensível à atribuição (prioridade vs inventor).
6. Pendências metodológicas: SFA por canal com classes latentes (H2); teste de separabilidade; inferência de dois estágios para painel; bootstrap de Malmquist (Simar e Wilson, 1999); harmonização dos universos de investimento; limites alternativos de piso.
7. Sugestões do Prof. Peter Wanke na apresentação de 28/09/2026 (S01–S10 em `artigo/13_comentarios_apresentacao.md`): reexecutar com as variáveis da fronteira padronizadas (min-max, uma só transformação) antes de fechar qualquer conclusão; SFA em log; menos hipóteses, com H5–H7 como perguntas de pesquisa; discussão país a país com evidência contemporânea; dois níveis de evidência no segundo estágio.
8. Robustez à padronização (S01, 04/10/2026; detalhes em `artigo/14_padronizacao_minmax.md`): com min-max (ε = 0,01) em todas as variantes, resistem a base do ranking (Israel em 47º nas duas versões; Suíça e Noruega), H3b sem apoio no painel base (+0,24 [0,18; 0,30]) e os sinais de H5 (efetividade −0,57 [−0,88; −0,13]) e de H7 (PIB per capita negativo nos dois canais). Não resistem o topo do ranking (Spearman entre versões 0,59), H6 (o crédito privado no canal de patentes perde o efeito), a inversão da metafronteira nas variantes de qualidade e de P&D público e a diferença do coeficiente de efetividade entre qualidade e base em amostra comum (+0,43 [0,05; 0,75] → +0,16 [−0,07; 0,45]). Retornos de escala e Malmquist não podem ser checados por min-max, porque a origem muda. A mudança de escala pura (x / máx) reproduz todos os escores. A especificação principal continua em unidades originais até a decisão do autor com o professor.
