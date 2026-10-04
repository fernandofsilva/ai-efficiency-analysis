# S02 — Fronteira estocástica por canal (SFA em log) e teste de H2

Executado em 04/10/2026 sobre o commit `a8fbb21`, em resposta ao item S02 de `artigo/13_comentarios_apresentacao.md`. O script novo `R/06_sfa_canais.R` roda nas seis bases do projeto: Fase A, painel, qualidade, patentes por inventor, Preqin e P&D público. A execução usou `zsh output/rodar_pipeline.sh sfa`, das 10h31 às 11h08, sem falhas (status em `output/status_execucao.txt`). As tabelas são `sfa_canais<sufixo>.csv` (todos os modelos), `sfa_canais_bootstrap<sufixo>.csv` (intervalos), `sfa_h2<sufixo>.csv` (veredito) e `sfa_classes_latentes<sufixo>.csv`.

**H2** (`artigo/01`): controlando pelo P&D executado no país, o investimento privado em IA tem elasticidade significativa no canal de patentes e não no de publicações. No painel, o controle preferido é o P&D executado por ensino superior e governo (variante P&D público).

**Revisão de 04/10/2026, após a análise crítica 3 (`artigo/17` → `artigo/18`, A03, A04, A05 e A12).** O SFA foi refeito nas seis bases (`STATUS_ARQUIVO=output/status_execucao_sfa.txt zsh output/rodar_pipeline.sh sfa`, das 16h14 às 17h04, sem falhas), com quatro mudanças:
1. reinício do otimizador quando o `frontier` para sem convergir;
2. veredito de H2 pela especificidade relativa com direção, só com ajuste pontual válido e réplicas suficientes;
3. IC dos retornos de escala por bootstrap de país, calculado na própria réplica;
4. retirada da comparação M1 × M2 da DEA como evidência.

As seções 1 a 5 e 7 foram refeitas; o texto anterior está no histórico do git.

## 1. Resumo

1. **A estimação não é mais problema.** Em log, cada ajuste leva menos de meio segundo, e a demora de horas das tentativas anteriores não se repete. O log resolve a diferença de escala, como o professor antecipou.
   - **Ajustes válidos:** dos 60 ajustes (5 modelos × 2 canais × 6 bases), 55 têm inferência válida. Os 5 restantes são os modelos exponenciais de publicações em que o resíduo de MQO tem assimetria positiva: a hessiana degenera, embora o pacote informe convergência.
   - **Paradas com código 5.** A translog de publicações do painel e o BC92 de publicações da Preqin pararam com código 5 do `frontier`. Reiniciados do próprio ponto final, convergem no mesmo máximo.
   - **Réplicas:** convergem de 294 a 300 em 300 (98% a 100%), em parte depois do reinício.
2. **H2 tem apoio fraco e localizado.** O critério agora é a especificidade relativa com direção: elasticidade do investimento em patentes com IC acima de zero **e** diferença patentes − publicações com IC acima de zero. Em 18 combinações de base e modelo:
   - **apoiada em 3:** os dois modelos de painel da Fase A e o agrupado da variante por inventor, este no limite;
   - **apoio parcial em 2:** os modelos de painel da variante de qualidade, com efeito em patentes, mas sem diferença distinguível entre canais;
   - **não apoiada em 13**, entre elas todas as do painel base e todas as com o P&D público como controle.
3. **O que é robusto é o P&D.** A elasticidade do P&D é grande e significativa em todas as bases e modelos: 0,59 a 0,70 em publicações e 0,94 a 1,41 em patentes, no modelo principal.
4. **Retornos de escala, com IC por bootstrap de país:**
   - **publicações:** decrescentes nas 18 combinações (limite superior entre 0,70 e 0,89);
   - **patentes:** crescentes em 12, quase sempre com o limite inferior colado em 1 (1,001 a 1,05), e não distinguíveis de constantes em 6, entre elas as três da Fase A.

   A versão anterior dizia "sempre com p < 0,05", com o Wald da hessiana, que supõe observações independentes.
5. **A ineficiência não é bem identificada no corte agrupado:**
   - Em publicações, o resíduo de MQO tem assimetria positiva nas seis bases, o sinal errado para uma fronteira de produção (quase nula, +0,01, na de P&D público). O SFA recai no MQO, com γ = 0 em cinco das seis.
   - Em patentes, o teste de razão de verossimilhança só rejeita a ausência de ineficiência em duas bases (qualidade e Preqin).
   - Nos modelos de painel acontece o contrário: γ fica entre 0,93 e 1,00, porque qualquer diferença persistente entre países passa a contar como ineficiência.
6. **Classes latentes (exploratório):** identificadas em 4 de 12 ajustes. Só na Fase A, em publicações, as classes acompanham a renda: uma com 77% de alta renda, onde o investimento não tem efeito, e outra com 37%, onde a elasticidade é 0,34.

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
- **Reinício (desde 04/10/2026, `artigo/18`, A04).** Quando o `frontier` para sem convergir (quase sempre com o código 5: não acha parâmetros com log-verossimilhança maior que a do passo anterior), o ajuste reinicia do próprio ponto final e só é aceito se então convergir sem perder log-verossimilhança. Vale para o ajuste pontual e para cada réplica.
  - **Efeito no diagnóstico da Fase A.** Entre 6% e 19% das réplicas paravam com código 5. A maioria já estava no máximo, mas nos modelos de painel de publicações algumas estavam longe dele: o reinício ganhou até 83 de log-verossimilhança.
  - **Antes:** convergiam de 216 a 292 réplicas por estimativa (72% a 97%), e as que falhavam eram descartadas.
  - **Agora:** convergem de 294 a 300 (98% a 100%). As tabelas contam as réplicas convergentes e as que precisaram de reinício.
- **Retornos de escala:** a soma das elasticidades (investimento + P&D) é calculada em cada réplica, no mesmo sorteio, o que dá um IC por bootstrap de país para os retornos (`sfa_retornos<sufixo>.csv`). O Wald da hessiana fica só como diagnóstico, com o nome explícito na tabela `sfa_canais`.

**Controle.** Cada ajuste grava:
- código de convergência, iterações e tempo;
- assimetria dos resíduos de MQO e correlação entre os insumos;
- uma marca `inferencia_valida`: convergiu, erros-padrão finitos e, no `sfaR`, gradiente finito;
- uma marca `reinicio`, quando o ajuste precisou ser reiniciado do próprio ponto final.

**Veredito de H2 (`sfa_h2<sufixo>.csv`, desde 04/10/2026).** A tabela traz um `estado` antes do `veredito`:
- **"não estimável":** ajuste pontual sem inferência válida num dos canais (os intervalos não são mostrados);
- **"inconclusivo":** menos de 90% de réplicas convergentes na diferença;
- **"estimável":** só neste caso há veredito, que pode ser:
  - "apoiada": patentes com IC acima de zero **e** diferença com IC acima de zero;
  - "apoio parcial": só uma das duas;
  - "contrariada": diferença ou patentes com IC abaixo de zero;
  - "não apoiada": nenhum dos casos acima.

As colunas `efeito_publicacoes` e `efeito_patentes` descrevem o IC de cada canal (positiva, negativa ou não distinguível de zero), sem entrar no veredito.

O teste de razão de verossimilhança da ausência de ineficiência usa a mistura de qui-quadrados com 0 e 1 grau de liberdade.

## 3. H2: elasticidade do investimento por canal

Ponto e IC 95% por bootstrap em blocos de país; veredito pelo critério de especificidade relativa com direção (seção 2). Todas as combinações são estimáveis, com 294 a 300 réplicas convergentes:

| Base | Modelo | Publicações | Patentes | Patentes − publicações | Veredito |
|---|---|---|---|---|---|
| Fase A | Agrupado | 0,10 [−0,05; 0,25] | 0,09 [−0,14; 0,27] | −0,01 [−0,22; 0,20] | não apoiada |
| Fase A | Painel 1988 | 0,02 [−0,001; 0,07] | 0,14 [0,05; 0,21] | 0,12 [0,03; 0,20] | **apoiada** |
| Fase A | Painel 1992 | 0,02 [−0,001; 0,04] | 0,15 [0,05; 0,24] | 0,13 [0,03; 0,23] | **apoiada** |
| Painel | Agrupado | 0,03 [−0,07; 0,13] | −0,12 [−0,30; 0,10] | −0,15 [−0,34; 0,09] | não apoiada |
| Painel | Painel 1988 | 0,03 [0,01; 0,06] | 0,04 [−0,03; 0,15] | 0,01 [−0,07; 0,12] | não apoiada |
| Painel | Painel 1992 | 0,03 [0,01; 0,06] | 0,05 [−0,04; 0,17] | 0,02 [−0,08; 0,14] | não apoiada |
| Qualidade | Agrupado | 0,19 [0,05; 0,30] | −0,04 [−0,31; 0,17] | −0,23 [−0,46; 0,04] | não apoiada |
| Qualidade | Painel 1988 | 0,09 [0,04; 0,14] | 0,14 [0,05; 0,26] | 0,05 [−0,05; 0,16] | apoio parcial |
| Qualidade | Painel 1992 | 0,09 [0,04; 0,14] | 0,14 [0,05; 0,26] | 0,05 [−0,05; 0,18] | apoio parcial |
| Inventor | Agrupado | 0,06 [−0,04; 0,16] | 0,21 [0,08; 0,35] | 0,15 [0,001; 0,28] | **apoiada** (no limite) |
| Inventor | Painel 1988 | 0,03 [0,01; 0,04] | 0,04 [−0,02; 0,11] | 0,02 [−0,05; 0,09] | não apoiada |
| Inventor | Painel 1992 | 0,03 [0,01; 0,05] | 0,04 [−0,02; 0,11] | 0,01 [−0,06; 0,09] | não apoiada |
| Preqin | Agrupado | 0,02 [−0,10; 0,14] | 0,25 [−0,01; 0,47] | 0,23 [−0,003; 0,45] | não apoiada |
| Preqin | Painel 1988 | 0,03 [0,003; 0,06] | 0,11 [−0,06; 0,22] | 0,08 [−0,09; 0,19] | não apoiada |
| Preqin | Painel 1992 | 0,03 [−0,001; 0,06] | 0,11 [−0,06; 0,24] | 0,08 [−0,10; 0,20] | não apoiada |
| P&D público | Agrupado | 0,05 [−0,05; 0,15] | 0,04 [−0,17; 0,20] | −0,02 [−0,20; 0,16] | não apoiada |
| P&D público | Painel 1988 | 0,02 [0,004; 0,03] | 0,07 [−0,04; 0,17] | 0,05 [−0,05; 0,16] | não apoiada |
| P&D público | Painel 1992 | 0,01 [0,0001; 0,03] | 0,05 [−0,06; 0,17] | 0,04 [−0,08; 0,16] | não apoiada |

**O que mudou em relação ao critério anterior** ("estrito": efeito significativo só em patentes):
- **Qualidade e painel.** Os 7 casos antes chamados de "contrariada (efeito só em publicações)" passam a "não apoiada". Um efeito em publicações sem diferença distinguível entre canais não contraria H2; ele só deixa de apoiá-la.
- **Fase A, painel de 1992.** Antes era "efeito nos dois canais"; agora é "apoiada", porque o efeito em patentes é maior, com IC da diferença acima de zero. Com as réplicas recuperadas pelo reinício, o efeito em publicações passou a conter zero, mas isso não entra no veredito.
- **Qualidade, modelos de painel.** Antes eram "efeito nos dois canais"; agora são "apoio parcial": efeito positivo em patentes, sem diferença distinguível entre canais.
- **Inventor, agrupado.** Já era "apoiada" pelo critério antigo, sem o IC da diferença excluir zero ([−0,001; 0,277]). Agora o IC exclui zero por uma margem mínima ([0,0008; 0,277]), porque as réplicas antes descartadas voltaram. O resultado é sensível ao sorteio: com 20 sementes, o limite inferior fica acima de zero em 17 (de −0,009 a 0,036), e o efeito em patentes, em todas. É apoio no limite.
- **Preqin, agrupado.** Fica fora por pouco (limite inferior da diferença −0,003; patentes −0,01).

**Leitura.** Quando o investimento privado tem efeito, ele é pequeno: elasticidade de 0,01 a 0,21 nos casos significativos, contra 0,6 a 1,4 do P&D.
- **Especificações mais próximas de H2 no painel.** Com o P&D público como controle, não há efeito em patentes em nenhum modelo. Com as famílias de patentes por país do inventor, o agrupado dá apoio no limite, e os modelos de painel, nenhum.
- **Fase A.** Os sinais de especificidade (dados de 2013–2021, investimento sem defasagem) não se repetem no painel (2017–2021, investimento defasado em um ano).
- **Publicações.** Onde o efeito em publicações não é distinguível de zero, isso não demonstra efeito nulo: nenhuma margem de equivalência foi fixada antes dos resultados.

## 4. O que é robusto: o P&D e os retornos por canal

Modelo principal (Cobb-Douglas agrupada); elasticidades e retornos com IC 95% por bootstrap em blocos de país. Desde 04/10/2026, os retornos são calculados na própria réplica (`artigo/18`, A05):

| Base | Elasticidade do P&D, publicações | Elasticidade do P&D, patentes | Retornos (soma), publicações | Retornos (soma), patentes |
|---|---|---|---|---|
| Fase A | 0,59 [0,39; 0,78] | 1,17 [0,79; 1,49] | 0,69 [0,55; 0,79] | 1,25 [0,92; 1,45] |
| Painel | 0,64 [0,51; 0,77] | 1,41 [0,99; 1,74] | 0,67 [0,56; 0,75] | 1,29 [1,003; 1,53] |
| Qualidade | 0,61 [0,43; 0,79] | 1,40 [0,96; 1,65] | 0,79 [0,70; 0,89] | 1,36 [1,02; 1,49] |
| Inventor | 0,60 [0,47; 0,75] | 0,94 [0,69; 1,16] | 0,67 [0,56; 0,75] | 1,16 [1,001; 1,29] |
| Preqin | 0,67 [0,51; 0,81] | 1,01 [0,65; 1,39] | 0,68 [0,57; 0,77] | 1,26 [1,01; 1,47] |
| P&D público | 0,70 [0,55; 0,85] | 1,36 [0,94; 1,80] | 0,75 [0,56; 0,85] | 1,40 [0,9997; 1,76] |

**Retornos nos três modelos com bootstrap** (agrupado e os dois de painel, seis bases):
- **Publicações:** decrescentes nas 18 combinações, com o limite superior entre 0,70 e 0,89. É o resultado firme: dobrar os dois insumos menos que dobra as publicações.
- **Patentes:** crescentes em 12 e não distinguíveis de constantes em 6, entre elas as três da Fase A, os dois modelos de painel do inventor e o agrupado do P&D público. Nos 12 casos, o limite inferior fica entre 1,001 e 1,15, quase sempre colado em 1. É indício fraco de retornos crescentes.

Nos modelos sem bootstrap (exponencial e translog), o Wald da hessiana classifica publicações como decrescentes e patentes como crescentes em todos os ajustes válidos. Ele supõe observações independentes e por isso é só diagnóstico. A versão anterior deste documento apoiava "sempre com p < 0,05" nesse Wald.

**Para H1 (S04).** A fronteira paramétrica indica retornos decrescentes no canal acadêmico, com segurança, e, no máximo, levemente crescentes no tecnológico. Isso não se confunde com a classificação da DEA conjunta (dois produtos, retornos locais por país). Deve ser apresentado como evidência complementar, com a ressalva de que a Cobb-Douglas impõe elasticidades constantes.

## 5. Identificação e convergência

**Assimetria dos resíduos de MQO** (negativa = esperada numa fronteira de produção):
- publicações: +0,18 (Fase A), +0,32 (painel), +0,40 (qualidade), +0,59 (inventor), +0,36 (Preqin) e +0,01 (P&D público);
- patentes: −0,14, −0,21, −0,58, +0,01, −0,35 e −0,04.

Em publicações, os desvios acima da fronteira média são tão comuns quanto os abaixo, e o modelo agrupado não encontra um componente de ineficiência (γ = 0, teste de razão de verossimilhança com p ≈ 0,5). Em patentes, a ineficiência só é significativa a 5% em qualidade (p < 0,001) e Preqin (p = 0,013).

**Modelos de painel.** A ineficiência é sempre significativa, com γ entre 0,93 e 1,00 e eficiência média entre 0,16 e 0,42. Esses modelos tratam toda diferença persistente entre países (estrutura produtiva, especialização, cobertura dos dados) como ineficiência: é a crítica de Greene (2005) aos modelos de efeitos aleatórios sem heterogeneidade separada. Por isso os níveis de eficiência deles não devem ser comparados com os da DEA.

**Colinearidade.** A correlação entre log do investimento e log do P&D vai de 0,74 a 0,82 (VIF entre 2,2 e 3,1). Não impede a estimação, mas explica parte da imprecisão do coeficiente do investimento.

**Convergência (desde 04/10/2026, `artigo/18`, A04).**
- **Ajustes pontuais com código 5.** A translog de publicações do painel e o BC92 de publicações da Preqin pararam com código 5. Reiniciados do próprio ponto final, convergem (código 1) com a mesma log-verossimilhança e as mesmas estimativas: já estavam no máximo, e a marca `reinicio` registra a nova tentativa.
- **Réplicas.** Em cada base, de 8 a 84 das 300 precisaram de reinício; depois dele, falham no máximo 6 por estimativa.
- **O que mudou na Preqin.** O BC92 de publicações, antes "sem convergência" e mesmo assim com veredito, agora é estimável.

**Tempo.** Cada ajuste leva entre 0,003 e 0,43 segundo. Com o bootstrap e os reinícios, a execução das seis bases levou 50 minutos em 5 núcleos, em paralelo com outras execuções (37 minutos em 9 núcleos, sem reinício, na primeira versão).

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

- **H2 não é apoiada** na base do artigo (painel), nem com o controle preferido (P&D público). O apoio aparece em três de 18 combinações: nos dois modelos de painel da Fase A e, no limite, no agrupado da variante por inventor. Explicações a discutir para a ausência no painel:
  1. o investimento da CSET é capital privado captado (VC, PE e fusões e aquisições), e não gasto em P&D, e o país onde o capital é captado nem sempre é o país de prioridade da patente;
  2. a defasagem de um ano pode ser curta para patentes;
  3. a colinearidade com o P&D;
  4. a pouca variação dentro de cada país em cinco anos.

  Decisão do S03 (04/10/2026): H2 continua como hipótese, com resultado majoritariamente negativo, por ter ancoragem na literatura (Furman, Porter e Stern, 2002; Cohen e Levinthal, 1990).
- **O P&D é o insumo que importa nos dois canais.** É o resultado do próprio SFA: elasticidade do P&D grande e significativa em todas as bases e modelos. A DEA não acrescenta evidência a isso. Na orientação a produto, acrescentar o GERD ao investimento (M1 → M2) nunca reduz um escore, seja o insumo relevante ou não, e de fato nenhum dos 1.107 país-ano tem escore menor em M2 (`artigo/18`, A12). A versão anterior desta seção usava esse aumento como coerência adicional, o que não procede.
- **Limitação a registrar na DEA.** No corte agrupado, o SFA não encontra ineficiência unilateral em publicações. A DEA, determinística, atribui todo desvio à ineficiência. Isso reforça a leitura cautelosa dos escores e o uso das fronteiras robustas (order-m e order-α) como checagem.

## 8. Pendências decorrentes

1. **S03:** decidido em 04/10/2026 (H2 continua como hipótese; `artigo/01`).
2. **S04:** incluir na discussão de H1 os retornos por canal da seção 4, como evidência paramétrica complementar. A evidência é decrescente com segurança em publicações e, no máximo, levemente crescente em patentes.
3. **Equivalência (opcional):** afirmar "sem efeito em publicações" exigiria um teste de equivalência com uma margem substantiva fixada antes dos resultados. Sem isso, o texto fica em "não distinguível de zero".
4. **Extensões não feitas:**
   - painel com determinantes da ineficiência (Battese e Coelli, 1995), que serviria a H5;
   - defasagem de dois anos do investimento;
   - modelos com heterogeneidade separada da ineficiência (Greene, 2005).

   Ficam como robustez opcional para a versão final.
