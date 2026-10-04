# S02 — Fronteira estocástica por canal (SFA em log) e teste de H2

Executado em 04/10/2026 sobre o commit `a8fbb21`, em resposta ao item S02 de `artigo/13_comentarios_apresentacao.md`. O script novo `R/06_sfa_canais.R` roda nas seis bases do projeto: Fase A, painel, qualidade, patentes por inventor, Preqin e P&D público. A execução usou `zsh output/rodar_pipeline.sh sfa`, das 10h31 às 11h08, sem falhas (status em `output/status_execucao.txt`). As tabelas são `sfa_canais<sufixo>.csv` (todos os modelos), `sfa_canais_bootstrap<sufixo>.csv` (intervalos), `sfa_h2<sufixo>.csv` (veredito) e `sfa_classes_latentes<sufixo>.csv`.

**H2** (`artigo/01`): controlando pelo P&D executado no país, o investimento privado em IA tem elasticidade significativa no canal de patentes e não no de publicações. No painel, o controle preferido é o P&D executado por ensino superior e governo (variante P&D público).

## 1. Resumo

1. **A estimação não é mais problema.** Em log, cada ajuste leva menos de meio segundo, e a demora de horas das tentativas anteriores não se repete. O log resolve a diferença de escala, como o professor antecipou. Dos 60 ajustes (5 modelos × 2 canais × 6 bases), 53 têm inferência válida. Os 7 restantes são:
   - os 5 modelos exponenciais de publicações em que o resíduo de MQO tem assimetria positiva (a hessiana degenera, embora o pacote informe convergência);
   - uma translog e um modelo de painel de 1992 em publicações, que não convergiram.
2. **H2 não se confirma.** Em 18 combinações de base e modelo, o critério estrito (efeito só em patentes) se cumpre em 2. O padrão oposto (efeito só em publicações) aparece em 7, nenhum efeito em 6 e efeito nos dois canais em 3. A especificidade relativa (elasticidade maior em patentes, com intervalo da diferença acima de zero) aparece só nos dois modelos de painel da Fase A. Na base do artigo (painel) e no controle preferido (P&D público), não há apoio.
3. **O que é robusto é o P&D.** A elasticidade do P&D é grande e significativa em todas as bases e modelos: 0,59 a 0,70 em publicações e 0,94 a 1,41 em patentes, no modelo principal. A soma das elasticidades fica abaixo de 1 em publicações (retornos decrescentes) e acima de 1 em patentes (crescentes), sempre com p < 0,05 contra retornos constantes.
4. **A ineficiência não é bem identificada no corte agrupado:**
   - Em publicações, o resíduo de MQO tem assimetria positiva nas seis bases (o sinal errado para uma fronteira de produção). O SFA recai no MQO, com γ = 0 em cinco das seis.
   - Em patentes, o teste de razão de verossimilhança só rejeita a ausência de ineficiência em duas bases (qualidade e Preqin).
   - Nos modelos de painel acontece o contrário: γ fica entre 0,93 e 1,00, porque qualquer diferença persistente entre países passa a contar como ineficiência.
5. **Classes latentes (exploratório):** identificadas em 4 de 12 ajustes. Só na Fase A, em publicações, as classes acompanham a renda: uma com 77% de alta renda, onde o investimento não tem efeito, e outra com 37%, onde a elasticidade é 0,34.

## 2. O que foi implementado

**Forma e variáveis.** log y = β0 + β1 log(investimento) + β2 log(P&D) + efeitos de ano + v − u, por canal, com:
- insumos em milhões de US$ (o log torna a unidade irrelevante, porque ela vai para o intercepto);
- os mesmos insumos e produtos da DEA de cada base, com o investimento defasado no painel;
- a mesma amostra da DEA (investimento positivo), e países-ano com produto zero fora do canal.

A padronização min-max do S01 não se aplica aqui: o log já é uma transformação única para todas as variáveis.

**Modelos.**
- Principal: Cobb-Douglas com ineficiência meia-normal, amostra agrupada (`frontier::sfa`).
- Robustez:
  - ineficiência exponencial (`sfaR::sfacross`);
  - translog com os logs centrados na média, em que os termos de primeira ordem são as elasticidades na média;
  - painel com ineficiência fixa no tempo (Battese e Coelli, 1988) e variável no tempo (Battese e Coelli, 1992).
- Exploratório: duas classes latentes (`sfaR::sfalcmcross`), com tendência linear no lugar dos efeitos de ano. Com efeitos de ano, a hessiana fica singular.

**Inferência.**
- Os erros-padrão da hessiana supõem observações independentes, mas o mesmo país aparece em vários anos. Por isso os intervalos de H2 vêm de bootstrap em blocos de país (300 réplicas, semente do projeto), no modelo principal e nos dois de painel.
- Os dois canais são ajustados no mesmo sorteio de países, o que dá o intervalo da diferença entre as elasticidades.
- As réplicas rodam em paralelo, com os sorteios feitos antes, em sequência. O resultado não depende do número de núcleos: na Fase A, a versão paralela reproduziu a sequencial byte a byte.
- Convergiram de 216 a 292 réplicas por estimativa (72% a 97%); as que não convergiram foram descartadas e estão contadas nas tabelas.

**Controle.** Cada ajuste grava:
- código de convergência, iterações e tempo;
- assimetria dos resíduos de MQO e correlação entre os insumos;
- uma marca `inferencia_valida`: convergiu, erros-padrão finitos e, no `sfaR`, gradiente finito.

O teste de razão de verossimilhança da ausência de ineficiência usa a mistura de qui-quadrados com 0 e 1 grau de liberdade.

## 3. H2: elasticidade do investimento por canal

Ponto e IC 95% por bootstrap em blocos de país:

| Base | Modelo | Publicações | Patentes | Patentes − publicações | Critério estrito |
|---|---|---|---|---|---|
| Fase A | Agrupado | 0,10 [−0,04; 0,25] | 0,09 [−0,13; 0,28] | −0,01 [−0,22; 0,20] | sem efeito |
| Fase A | Painel 1988 | 0,02 [−0,00; 0,08] | 0,14 [0,05; 0,21] | 0,12 [0,02; 0,21] | **apoiada** |
| Fase A | Painel 1992 | 0,02 [0,00; 0,04] | 0,15 [0,05; 0,24] | 0,13 [0,03; 0,22] | efeito nos dois |
| Painel | Agrupado | 0,03 [−0,07; 0,13] | −0,12 [−0,30; 0,10] | −0,15 [−0,33; 0,10] | sem efeito |
| Painel | Painel 1988 | 0,03 [0,01; 0,06] | 0,04 [−0,03; 0,14] | 0,01 [−0,07; 0,12] | contrariada |
| Painel | Painel 1992 | 0,03 [0,01; 0,06] | 0,05 [−0,04; 0,17] | 0,02 [−0,08; 0,14] | contrariada |
| Qualidade | Agrupado | 0,19 [0,04; 0,30] | −0,04 [−0,30; 0,16] | −0,23 [−0,46; 0,04] | contrariada |
| Qualidade | Painel 1988 | 0,09 [0,04; 0,14] | 0,14 [0,05; 0,26] | 0,05 [−0,05; 0,17] | efeito nos dois |
| Qualidade | Painel 1992 | 0,09 [0,04; 0,14] | 0,14 [0,05; 0,26] | 0,05 [−0,05; 0,18] | efeito nos dois |
| Inventor | Agrupado | 0,06 [−0,04; 0,15] | 0,21 [0,09; 0,33] | 0,15 [−0,00; 0,28] | **apoiada** |
| Inventor | Painel 1988 | 0,03 [0,01; 0,05] | 0,04 [−0,02; 0,11] | 0,02 [−0,04; 0,09] | contrariada |
| Inventor | Painel 1992 | 0,03 [0,01; 0,05] | 0,04 [−0,02; 0,11] | 0,01 [−0,06; 0,09] | contrariada |
| Preqin | Agrupado | 0,02 [−0,10; 0,14] | 0,25 [−0,01; 0,47] | 0,23 [−0,00; 0,44] | sem efeito |
| Preqin | Painel 1988 | 0,03 [0,00; 0,06] | 0,11 [−0,06; 0,22] | 0,08 [−0,09; 0,19] | contrariada |
| Preqin | Painel 1992 | 0,03 [−0,00; 0,06] | 0,11 [−0,06; 0,24] | 0,08 [−0,10; 0,20] | sem efeito |
| P&D público | Agrupado | 0,05 [−0,05; 0,15] | 0,04 [−0,18; 0,20] | −0,02 [−0,20; 0,15] | sem efeito |
| P&D público | Painel 1988 | 0,02 [0,00; 0,03] | 0,07 [−0,04; 0,17] | 0,05 [−0,06; 0,16] | contrariada |
| P&D público | Painel 1992 | 0,01 [−0,00; 0,03] | 0,05 [−0,06; 0,17] | 0,04 [−0,07; 0,15] | sem efeito |

**Leitura.** Quando o investimento privado tem efeito, ele é pequeno: elasticidade de 0,02 a 0,21 nos casos significativos, contra 0,6 a 1,4 do P&D. Em patentes, quase sempre o intervalo inclui zero. Nas especificações mais próximas da formulação de H2 no painel (P&D público como controle; famílias de patentes por país do inventor), só o modelo agrupado com inventor cumpre o critério, e mesmo assim o intervalo da diferença entre canais toca zero. Os sinais de especificidade da Fase A (dados de 2013–2021, investimento sem defasagem) não se repetem no painel (2017–2021, investimento defasado em um ano).

## 4. O que é robusto: o P&D e os retornos por canal

| Base | Elasticidade do P&D, publicações | Elasticidade do P&D, patentes | Retornos (soma), publicações | Retornos (soma), patentes |
|---|---|---|---|---|
| Fase A | 0,59 [0,38; 0,78] | 1,17 [0,77; 1,51] | 0,69 | 1,25 |
| Painel | 0,64 [0,51; 0,77] | 1,41 [0,98; 1,75] | 0,67 | 1,29 |
| Qualidade | 0,61 [0,42; 0,79] | 1,40 [0,96; 1,64] | 0,79 | 1,36 |
| Inventor | 0,60 [0,48; 0,75] | 0,94 [0,70; 1,15] | 0,67 | 1,16 |
| Preqin | 0,67 [0,50; 0,81] | 1,01 [0,64; 1,39] | 0,68 | 1,26 |
| P&D público | 0,70 [0,54; 0,84] | 1,36 [0,94; 1,80] | 0,75 | 1,40 |

Modelo principal, IC 95% por bootstrap em blocos de país. Nos 53 ajustes com inferência válida, a soma das elasticidades fica:
- entre 0,37 e 0,79 em publicações;
- entre 1,12 e 1,45 em patentes;
- sempre com p < 0,05 contra retornos constantes (Wald, erros-padrão da hessiana).

**Para H1 (S04).** A fronteira paramétrica sugere retornos decrescentes no canal acadêmico e crescentes no tecnológico. Isso não se confunde com a classificação da DEA conjunta (dois produtos, retornos locais por país) e deve ser apresentado como evidência complementar, com a ressalva de que a Cobb-Douglas impõe elasticidades constantes.

## 5. Identificação e convergência

**Assimetria dos resíduos de MQO** (negativa = esperada numa fronteira de produção):
- publicações: +0,18 (Fase A), +0,32 (painel), +0,40 (qualidade), +0,59 (inventor), +0,36 (Preqin) e +0,01 (P&D público);
- patentes: −0,14, −0,21, −0,58, +0,01, −0,35 e −0,04.

Em publicações, os desvios acima da fronteira média são tão comuns quanto os abaixo, e o modelo agrupado não encontra um componente de ineficiência (γ = 0, teste de razão de verossimilhança com p ≈ 0,5). Em patentes, a ineficiência só é significativa a 5% em qualidade (p < 0,001) e Preqin (p = 0,013).

**Modelos de painel.** A ineficiência é sempre significativa, com γ entre 0,93 e 1,00 e eficiência média entre 0,16 e 0,42. Esses modelos tratam toda diferença persistente entre países (estrutura produtiva, especialização, cobertura dos dados) como ineficiência: é a crítica de Greene (2005) aos modelos de efeitos aleatórios sem heterogeneidade separada. Por isso os níveis de eficiência deles não devem ser comparados com os da DEA.

**Colinearidade.** A correlação entre log do investimento e log do P&D vai de 0,74 a 0,82 (VIF entre 2,2 e 3,1). Não impede a estimação, mas explica parte da imprecisão do coeficiente do investimento.

**Tempo.** Cada ajuste leva entre 0,003 e 0,43 segundo. Com o bootstrap, a execução das seis bases levou 37 minutos em 9 núcleos.

## 6. Classes latentes (exploratório; robustez de H3)

Duas classes, cada uma com sua fronteira. As que ficaram identificadas:

| Base, canal | Parcela de alta renda por classe | Elasticidade do investimento por classe |
|---|---|---|
| Fase A, publicações | 0,77 (153 obs.) e 0,37 (38 obs.) | −0,05 (n.s.) e 0,34 (p < 0,001) |
| Painel, publicações | 0,76 (17 obs.) e 0,78 (187 obs.) | −0,26 e 0,10 |
| Inventor, publicações | 0,81 (207 obs.) e 0,00 (10 obs.) | 0,01 (n.s.) e 0,50 |
| Inventor, patentes | 0,82 (49 obs.) e 0,75 (166 obs.) | 0,03 (n.s.) e 0,31 |

Os outros 8 ajustes (todos os de patentes, menos inventor, e as publicações de qualidade, Preqin e P&D público) têm hessiana singular ou erros-padrão inválidos e não são interpretados. Só na Fase A as classes acompanham os grupos de renda. Isso dá apoio fraco à ideia de tecnologias distintas por renda e não muda a leitura de H3b, que segue sem apoio na metafronteira.

## 7. Leitura para o artigo

- **H2 não é apoiada** na base do artigo (painel), nem com o controle preferido (P&D público). Os sinais de especificidade aparecem só na Fase A e só nos modelos de painel. Explicações a discutir:
  1. o investimento da CSET é capital privado captado (VC, PE e fusões e aquisições), e não gasto em P&D, e o país onde o capital é captado nem sempre é o país de prioridade da patente;
  2. a defasagem de um ano pode ser curta para patentes;
  3. a colinearidade com o P&D;
  4. a pouca variação dentro de cada país em cinco anos.

  Fica a decisão do S03: manter H2 como hipótese com resultado negativo, já que ela tem ancoragem na literatura (Furman, Porter e Stern, 2002; Cohen e Levinthal, 1990), ou transformá-la em pergunta de pesquisa.
- **O P&D é o insumo que importa nos dois canais.** Isso é coerente com a DEA, em que acrescentar o GERD ao investimento (M1 → M2) aumenta a eficiência média (`artigo/05`).
- **Limitação a registrar na DEA.** No corte agrupado, o SFA não encontra ineficiência unilateral em publicações. A DEA, determinística, atribui todo desvio à ineficiência. Isso reforça a leitura cautelosa dos escores e o uso das fronteiras robustas (order-m e order-α) como checagem.

## 8. Pendências decorrentes

1. **S03:** decidir o status de H2 (hipótese com resultado negativo ou pergunta de pesquisa), com a discussão da seção 7.
2. **S04:** incluir na discussão de H1 os retornos por canal da seção 4, como evidência paramétrica complementar.
3. **Extensões não feitas:**
   - painel com determinantes da ineficiência (Battese e Coelli, 1995), que serviria a H5;
   - defasagem de dois anos do investimento;
   - modelos com heterogeneidade separada da ineficiência (Greene, 2005).

   Ficam como robustez opcional para a versão final.
