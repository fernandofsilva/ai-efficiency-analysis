# Resultados no painel reconstruído (Fase B, primeira passagem)

Painel `data/processed/painel_ia.csv`: 47 países, 2016–2024 (CSET v1.12.0 + World Bank). Modelo conjunto com insumos defasados um ano (investimento privado em IA em US$ de 2021 e GERD, ambos em t−1) e produtos em contagem; janela 2017–2021 (pedidos de patente completos até 2021). Variante ajustada por qualidade: produtos = citações (até 2020) e patentes concedidas (até 2019), janela 2017–2019. Mesmo pipeline da Fase A (`R/02`–`R/04` com sufixos `_painel` e `_painel_qualidade`). Todos os escores em (0, 1], orientação a produto.

## 1. Amostras

| Variante | Observações | Países | Anos | Zeros/piso removidos |
|---|---|---|---|---|
| Volume (publicações + pedidos de patente) | 204 | 47 | 2017–2021 | 8 no piso (≤ 2,5 M) |
| Qualidade (citações + patentes concedidas) | 117 | 44 | 2017–2019 | 6 no piso |

Comparação com a Fase A: 37 a 44 países por ano (contra 16 a 27), Malmquist balanceado com 34 países (contra 16), e presença de Alemanha, Coreia do Sul, Canadá, nórdicos, Rússia, Turquia, Arábia Saudita e Sérvia.

## 2. Fronteiras e escala (H1)

- Volume: eficiência média VRS por ano entre 0,49 e 0,70; 7 a 13 países eficientes por ano; eficiência de escala média entre 0,46 e 0,85. Retornos decrescentes predominam (2019: 32 DRS, 6 IRS, 3 CRS; 2021: 36/2/6), com exceção de 2018 (14 DRS, 23 IRS).
- Qualidade: eficiência média entre 0,62 e 0,72; 9 a 14 eficientes; DRS predominante (2017: 28/4/5; 2019: 30/6/4).
- Viés médio do bootstrap: 0,13 (volume) e 0,13 (qualidade).
- Teste de retornos de escala com bootstrap (Simar-Wilson 2002, `R/02b`, mil réplicas, amostra agrupada de 204 observações, volume):

| Modelo | H0 | S | p-valor | Decisão |
|---|---|---|---|---|
| M2 | retornos constantes | 0,577 | < 0,001 | rejeita CRS |
| M2 | retornos não crescentes | 0,979 | 0,445 | não rejeita NIRS |
| M1 | retornos constantes | 0,347 | < 0,001 | rejeita CRS |

  Mesmo padrão do dataset original: retornos variáveis, compatíveis com retornos não crescentes (H1 apoiada no painel).

## 3. Rankings (Figura `fig1_ranking_m2_painel.png` e `_painel_qualidade`)

- Volume, topo (média 2017–2021 dos escores corrigidos): Itália 0,77; Malásia 0,76; Croácia 0,75; Rússia 0,72; Sérvia 0,72; Romênia 0,72; Ucrânia 0,72; Coreia do Sul 0,71; Índia 0,71; China 0,69. Base: Israel 0,16; Irlanda 0,20; África do Sul 0,23; Bélgica 0,23; Suécia 0,24; Dinamarca 0,25.
- Qualidade, topo: Índia 0,80; Grécia 0,80; Austrália 0,79; Malásia 0,78; Singapura 0,76; Reino Unido 0,75; Estados Unidos 0,75; Romênia 0,73; Coreia do Sul 0,72; China 0,72. Base: Israel 0,23; África do Sul 0,24; Dinamarca 0,25; Brasil 0,25; Irlanda 0,25; Noruega 0,25.
- Correlação de Spearman entre os rankings de país nas duas variantes: **0.80** (n = 44). Entre o ranking da Fase A (dataset original) e o do painel em volume: 0.82 (n = 34). A ordem geral se preserva (ρ = 0,80), mas com deslocamentos grandes: Estados Unidos, Reino Unido, Austrália e Singapura sobem para o topo com o ajuste por qualidade; Croácia, Sérvia, Ucrânia e Rússia caem.

## 4. Robustez entre estimadores (R1)

Spearman com o escore VRS (volume): corrigido 0,96 [0,94; 0,98]; M1 (insumo único) 0,82 [0,75; 0,88]; FDH 0,69 [0,61; 0,76]; order-α 0,65 [0,56; 0,72]; order-m 0,63 [0,54; 0,72]; order-m × order-α 0,94. Na variante de qualidade: 0,97; 0,79; 0,57; 0,59; 0,54; 0,87. Concordância maior que na Fase A (menos artefatos de piso).

## 5. Canais e metafronteira (H3)

| | Volume | Qualidade |
|---|---|---|
| Spearman entre canais (país-ano) | 0,48 [0,37; 0,59] | **0,42 [0,26; 0,54]** |
| TGR média, alta renda | 0,61 | 0,94 |
| TGR média, renda média | 0,93 | **0,84** |
| Mann-Whitney (TGR) | p < 0,001 | p = 0,011 |
| Kruskal-Wallis, canal publicações | p = 0,24 | p = 0,009 (alta 0,49 > média-alta 0,39) |
| Kruskal-Wallis, canal patentes | p < 0,001 (média-alta 0,22 > alta 0,11) | p = 0,067 |

- H3a (correlação fraca entre canais): apoiada nas duas variantes, com folga na de qualidade.
- H3b (gap tecnológico da renda média): **contrariada em volume e apoiada em qualidade**. Com contagens, o grupo de renda média define a metafronteira; com citações e patentes concedidas, a fronteira passa a ser definida pelos países de alta renda e a renda média opera abaixo dela (TGR 0,84). É o resultado mais sensível ao ajuste por qualidade (R3).

## 6. Dinâmica 2017–2021 (H4), 34 países balanceados, CRS

| Grupo | n | Malmquist | Mudança técnica | Mudança de eficiência |
|---|---|---|---|---|
| Alta renda | 27 | 0,94 | 0,85 | 1,11 |
| Renda média | 7 | 0,84 | 0,86 | 0,98 |
| Todos | 34 | 0,92 | 0,85 | 1,08 |

- A mudança técnica explica 38% da variância do índice (23% na variante de qualidade): o componente de fronteira domina menos do que na Fase A, e a fronteira continua a recuar em produtos por dólar (investimento cresce mais que os produtos).
- Catch-up: alta renda 1,11 contra renda média 0,98 — H4b (convergência) **não** é apoiada; a renda média não se aproxima da fronteira neste período. Maiores ganhos: Grécia (1,18), Tchéquia (1,14), Polônia (1,14), Argentina (1,12), Rússia (1,10); maiores perdas: Turquia (0,72), África do Sul (0,73), China (0,77, toda em mudança técnica), Malásia (0,81), Austrália (0,82).

## 7. Segundo estágio (H5, H6, H7) — regressão truncada, bootstrap agrupado por país

Dependente: eficiência corrigida em (0, 1]; positivo = mais eficiente.

| Modelo | Variável | Volume | Qualidade |
|---|---|---|---|
| H5 conjunto | efetividade governamental | **−0,180 [−0,298; −0,061]** | −0,076 [−0,257; 0,089] |
| H5 conjunto | crédito privado (% PIB) | **0,0026 [0,0003; 0,0047]** | 0,0019 [−0,0010; 0,0048] |
| H5 conjunto | exportações de alta tecnologia | 0,0035 [−0,0035; 0,0094] | 0,0044 [−0,0050; 0,0094] |
| H5 sem piso | efetividade governamental | **−0,190 [−0,311; −0,066]** | −0,079 [−0,248; 0,087] |
| H5 com pesquisadores | log pesquisadores por milhão | 0,063 [−0,040; 0,149] | 0,060 [−0,074; 0,184] |
| H6 canal patentes | capitalização de mercado | −0,0010 [−0,0019; 0,0006] | −0,0008 [−0,0019; 0,0012] |
| H6 canal patentes | crédito privado | **0,0023 [0,0002; 0,0041]** | **0,0023 [0,0001; 0,0040]** |
| H7 canal patentes | log PIB per capita | **−0,057 [−0,123; −0,005]** | −0,042 [−0,114; 0,016] |
| H7 canal publicações | log PIB per capita | −0,068 [−0,144; 0,002] | 0,015 [−0,074; 0,105] |

- Simar-Wilson algoritmo 2 (rDEA, escala de Farrell, sinal invertido; volume, n = 144 casos completos; na reexecução da variante de qualidade a rotina do rDEA não concluiu em 10 minutos e foi pulada, valendo os números da execução anterior): efetividade +16,3 [6,1; 24,6] (menos eficiente), comércio −7,3 [−11,5; −2,3] (mais eficiente), capitalização +0,07 [0,02; 0,13], crédito −0,25 [−0,37; −0,10]. Na variante de qualidade (n = 85): efetividade +1,15 [−0,80; 2,73], não significativa.
- Tobit (volume): efetividade −0,167 (p < 0,001), alta tecnologia +0,003 (p = 0,007), crédito +0,0024 (p < 0,001). Qualidade: efetividade −0,066 (p = 0,12), alta tecnologia +0,004 (p = 0,02).
- H5: com produtos em volume, a associação entre qualidade institucional e eficiência é **negativa e robusta** (três métodos, três amostras); com ajuste por qualidade, desaparece. Exportações de alta tecnologia passam a ter sinal positivo (Tobit) com qualidade.
- H6: crédito bancário (não a capitalização de mercado) associa-se positivamente à eficiência no canal de patentes nas duas variantes — o oposto do previsto (Hsu, Tian e Xu, 2014). A explicar: financiamento de P&D aplicado via crédito em economias bancarizadas (Europa, Ásia).
- H7: PIB per capita negativo no canal de patentes (volume), nulo com qualidade; no canal de publicações, negativo (limítrofe) em volume e nulo com qualidade.

## 8. Checagens entre fornecedores (fontes alternativas, `R/12`)

- **Investimento privado em IA, CSET (Crunchbase) × AI Index (Quid).** O AI Index não publica investimento por país e ano (só China, Europa e Estados Unidos), então a comparação é transversal: acumulado CSET 2016–2024 (estimado, nominal) contra acumulado Quid 2013–2024, 84 países em comum. Spearman = 0,93 [0,87; 0,96] (Figura `fig8_investimento_cset_vs_quid.png`). Os dois fornecedores ordenam os países de forma quase idêntica; as diferenças de nível vêm das janelas e da imputação de negócios não divulgados do CSET.
- **Publicações de IA, CSET × OECD.AI (OpenAlex).** Parcela mundial de artigos para as nove economias exportadas do OECD.AI (Canadá, China, Alemanha, França, Reino Unido, Índia, Japão, Coreia, Estados Unidos), 2016–2024, 81 pares país-ano: Spearman = 0,95 [0,91; 0,98], Pearson = 0,99. A razão CSET/OECD por país fica entre 0,88 (China) e 1,56 (França): o CSET atribui mais artigos a países europeus (coautorias) e menos à China (omissão de publicações só em chinês). A ordem entre países é preservada.
- **Patentes de IA, CSET (escritório de depósito) × OCDE (país do inventor, famílias IP5).** Spearman país-ano 0,75 [0,69; 0,81] (302 pares, 2016–2021); ver seção 9a.
- **Investimento por país-ano, CSET (Crunchbase) × OECD.AI (Preqin).** Spearman 0,83 [0,80; 0,87] (513 pares, 2016–2023); ver seção 9b.
- Conclusão para R1/R3: as fontes alternativas preservam a ordenação dos insumos (investimento) e das publicações; nas patentes a atribuição (escritório vs inventor) muda posições de países específicos (Estados Unidos, Japão, China, Suíça, Irlanda) sem alterar a ordem geral (ρ = 0,85 entre rankings de eficiência). O que mais altera os resultados é o ajuste por qualidade.

## 9. Talento em IA como variável de contexto (AI Index / LinkedIn)

Concentração de talento em IA (média simples das taxas feminina e masculina, 43 países, 2016–2024) juntada ao painel (`talento_ia_pct`). Regressão truncada com bootstrap agrupado, modelo conjunto em volume, subamostra com talento (161 obs., 35 países): efetividade governamental −0,127 [−0,231; −0,018]; log da concentração de talento 0,005 [−0,155; 0,213]; exportações de alta tecnologia e comércio não significativos. Na variante de qualidade (n = 93, 34 países): log da concentração de talento 0,056 [-0,183; 0,336]; efetividade governamental -0,055 [-0,205; 0,115]. O talento em IA não explica a eficiência medida além do que já capturam os insumos (o investimento privado e o GERD absorvem a escala do ecossistema); a associação negativa com instituições persiste na subamostra em volume e desaparece com qualidade.

## 9a. Variante de fonte: patentes por país do inventor (OCDE) no lugar do CSET

Mesmo pipeline com `PRODUTOS = publicacoes, patentes_inventor` (famílias IP5 de IA por residência do inventor, OECD Data Explorer, 2017–2021; DMUs com zero famílias saem do canal de patentes). 217 observações, 46 países; Malmquist balanceado com 38 países.

- Checagem prévia: pedidos CSET (escritório de depósito) × famílias OCDE (inventor), Spearman país-ano 0,75 [0,69; 0,81] (302 pares) e 0,84 entre médias por país. As razões CSET/OCDE variam de 0,05 (Suíça, Irlanda, Arábia Saudita) a 18 (China) e 11 (Austrália): países cujos inventores depositam no exterior aparecem pequenos no CSET, e países com muito depósito doméstico (China) aparecem grandes. Figura `fig9_patentes_cset_vs_oecd.png`.
- Ranking (média 2017–2021 dos escores corrigidos): Itália 0,74, Malásia 0,73, Rússia 0,73, **Estados Unidos 0,72**, Croácia, Índia, **Japão 0,70**, Romênia, China, Ucrânia; base: Dinamarca, África do Sul, Noruega, Bélgica, Suíça, Chile. Spearman com o ranking em volume (CSET) = 0,85: Estados Unidos e Japão sobem muito com a atribuição por inventor.
- Canais: Spearman 0,30 [0,16; 0,42] (H3a apoiada com folga). Metafronteira: TGR renda média 0,89 vs alta 0,68 (p < 0,001), como em volume. Canal de patentes agora mais eficiente na alta renda (0,29 vs 0,21, p < 0,001), invertendo o resultado do CSET.
- Malmquist 2017–2021: M 0,95, TC 0,97, EC 0,98 (TC explica 29% da variância); renda média EC 0,96.
- Segundo estágio: efetividade governamental −0,111 [−0,236; −0,028], mesmo sinal; **concentração de talento em IA passa a ser positiva e significativa** (0,170 [0,083; 0,304]); crédito e capitalização de mercado nulos no canal de patentes (H6 não apoiada); PIB per capita nulo no canal de patentes e negativo no de publicações (H7 não apoiada).
- Leitura: a atribuição por inventor corrige a subestimação dos países cujos inventores patenteiam no exterior, mas mantém a conclusão geral: rankings moderadamente robustos à fonte (ρ = 0,85), sinal negativo das instituições preservado em volume, e o canal de patentes é o mais sensível à escolha da fonte.

## 9b. Variante de fonte: VC da Preqin (OECD.AI) no lugar do investimento do CSET

Mesmo pipeline com `INSUMOS = investimento_preqin_l1, gerd_l1` (VC em IA por país, Preqin via OECD.AI, todas as indústrias, US$ de 2021) e produtos do CSET. 194 observações, 46 países, 2017–2021; Malmquist balanceado com 32 países.

- Checagem prévia: investimento estimado CSET × VC Preqin por país-ano (2016–2023, 513 pares), Spearman 0,83 [0,80; 0,87]; entre médias por país, 0,84. Razões CSET/Preqin nos maiores mercados: Estados Unidos 1,2, Reino Unido 1,5, Alemanha 1,4, Índia 2,2, Canadá 2,2, **China 0,35** (a Preqin registra muito mais VC chinês que o CSET). Figura `fig10_investimento_cset_vs_preqin.png`.
- Ranking (média 2017–2021 dos escores corrigidos): Malásia 0,81, Espanha 0,78, Japão 0,77, Itália 0,77, Turquia 0,74, Rússia, Romênia, Índia, Grécia, Eslovênia; base: Israel 0,16, Argentina 0,16, Irlanda 0,22, Suécia, Bélgica, Noruega. Spearman com o ranking baseado no CSET = 0,89.
- Canais: Spearman 0,55 [0,44; 0,65]. Metafronteira: TGR renda média 0,85 vs alta 0,78 (p = 0,012), gap menor que com o CSET. Canal de patentes mais eficiente na renda média-alta (0,25 vs 0,15, p = 0,002), como no CSET.
- Malmquist 2017–2021: M 0,95, TC 0,86, EC 1,10 (TC explica 43% da variância); renda média EC 1,04 vs alta 1,11.
- Segundo estágio: efetividade governamental −0,217 [−0,389; −0,047] (mesmo sinal, maior magnitude), robusta sem piso e com pesquisadores; talento em IA nulo; crédito positivo em ambos os canais (H6 não apoiada); PIB per capita negativo no canal de patentes (H7 contrariada).
- Leitura: trocar o fornecedor do insumo não muda as conclusões (ρ = 0,89 entre rankings; sinais do segundo estágio preservados); a diferença mais relevante é a China, que com a Preqin recebe muito mais investimento e perde eficiência medida.

## 9c. Variante de insumo público: HERD + GOVERD (OECD MSTI + Eurostat) no lugar do GERD total

Mesmo pipeline com `INSUMOS = investimento_l1, pd_publico_l1` (P&D executado pelo ensino superior e pelo governo, % do PIB × PIB; MSTI para 38 países e Eurostat para Bulgária, Croácia e Sérvia; interpolado por país; produtos do CSET). 184 observações, 41 países (sem fonte por setor: Brasil, Índia, Malásia, Filipinas, Arábia Saudita, Ucrânia); Malmquist balanceado com 32 países.

- Ranking (média 2017–2021 dos escores corrigidos): Singapura 0,79, Espanha 0,78, Itália 0,78, Croácia 0,75, Rússia 0,75, Polônia 0,75, Coreia do Sul 0,74, Colômbia 0,74; base: África do Sul 0,26, Noruega 0,27, Chile 0,31, Dinamarca 0,32, Finlândia 0,35, Suécia 0,35. Spearman com o ranking baseado no GERD total = 0,88 (41 países).
- O que muda: os sistemas com P&D empresarial pesado sobem — **Israel de 0,16 para 0,47 e Irlanda de 0,20 para 0,46**; Bulgária, Croácia e Sérvia (Eurostat) ficam praticamente iguais (0,67→0,73; 0,75; 0,72). A distorção prevista existe, mas os nórdicos e a Suíça continuam na base: mesmo com o insumo público, seus produtos de IA em contagem são pequenos em relação ao sistema de pesquisa.
- Canais: Spearman 0,55 [0,43; 0,65]. Metafronteira: TGR alta renda 0,92 vs renda média 0,82 (p = 0,003) — com o insumo público, **a renda média passa a operar abaixo da metafronteira (H3b apoiada)**, como na variante de qualidade. Canal de patentes segue mais eficiente na renda média-alta (0,24 vs 0,11, p = 0,004).
- Malmquist 2017–2021: M 0,91, TC 0,95, EC 0,96 (TC explica 22% da variância); renda média EC 0,92.
- Segundo estágio: efetividade governamental −0,143 [−0,245; −0,048], mesmo sinal; **pesquisadores por milhão positivos e significativos (0,117 [0,021; 0,198])** na subamostra com pesquisadores, a primeira variável de capacidade de absorção com o sinal previsto em H5; PIB per capita negativo nos dois canais (H7 contrariada); crédito e capitalização nulos (H6 não apoiada).
- Leitura para H2: trocar o GERD total pelo P&D público corrige a penalização dos sistemas de P&D empresarial (Israel, Irlanda), aproxima o resultado da metafronteira do obtido com produtos de qualidade e faz o capital humano aparecer com o sinal esperado, mas não muda o sinal das instituições. A especificação do artigo deve usar o P&D público como insumo acadêmico e reportar o GERD total como robustez.

## 10. Implicações para o artigo

1. O ajuste por qualidade dos produtos não é detalhe: desloca posições importantes do ranking (ρ = 0,80 entre as variantes), inverte o resultado da metafronteira e apaga a associação negativa com instituições. O insumo público (HERD + GOVERD) produz a mesma inversão na metafronteira e corrige Israel e Irlanda, sem mudar o sinal das instituições. R3 é um achado central, e a especificação de qualidade deve ser tratada como modelo principal ou, no mínimo, coigual.
2. Com produtos em volume, "eficiência" mede a intensidade de IA relativa ao tamanho do sistema de P&D; países pequenos e ricos com P&D amplo (Israel, Irlanda, nórdicos, Bélgica) ficam na base por construção. Discutir como limitação de medida, não como ineficiência.
3. A ausência de convergência (H4b) e a dominância da mudança técnica negativa (fronteira recuando em produtos por dólar) refletem o boom de investimento 2017–2021; o artigo deve reportar também um Malmquist com soma móvel de 3 anos e, se possível, com produtos de qualidade em janela mais longa quando o CSET completar 2022–2023.
4. Pendências metodológicas: SFA por canal com classes latentes (H2); teste de separabilidade formal; matriz de robustez completa estimador × defasagem × qualidade × fonte; exportar do OECD.AI as patentes por país do inventor e o VC (Preqin) para fechar a dimensão "fonte" também nos produtos de patentes.
