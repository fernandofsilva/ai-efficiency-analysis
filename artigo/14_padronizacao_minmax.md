# S01 — Padronização min-max das variáveis da fronteira: implementação, reexecução e comparação

Executado em 04/10/2026 sobre o commit `c780f89`, em resposta ao item S01 de `artigo/13_comentarios_apresentacao.md` (sugestão do Prof. Peter Wanke de padronizar as variáveis da fronteira antes de fechar qualquer conclusão). Todo o pipeline foi refeito com insumos e produtos padronizados (`PADRONIZACAO=minmax zsh output/rodar_pipeline.sh tudo`, das 08h37 às 08h58, sem falhas; status em `output/status_execucao_minmax.txt`): Fase A, painel e as quatro variantes, comparações em amostra comum (`R/05`) e testes de retornos de escala (`R/02b`). A validação por simulação do teste de RTS (`R/02c`) não usa os dados e não foi refeita. As saídas levam o sufixo `_minmax`. A comparação com as unidades originais está em `R/05b_comparacao_padronizacao.R`, nas tabelas `comparacao_padronizacao_*_minmax.csv` e `sensibilidade_padronizacao_epsilon.csv` e nas figuras `fig11_ranking_padronizacao_minmax.png` (Fase A) e `fig11_ranking_padronizacao_painel_minmax.png`.

## 1. Resumo

**A ordem de grandeza, sozinha, não muda a DEA.** Dividir cada variável pelo seu máximo (mudança de escala pura) reproduz todos os escores, a classificação de retornos de escala e o Malmquist, com diferença máxima abaixo de 4 × 10⁻¹². O solver não se perde com variáveis em milhões ao lado de variáveis em dezenas.

**A min-max muda os resultados por outro motivo:** além de mudar a escala, ela soma uma constante a cada variável. Com ε = 0,01, na Fase A, isso equivale a dar a todos os países mais US$ 1,5 bilhão de investimento, US$ 7,0 bilhões de GERD, 659 publicações e 854 patentes. A constante comprime as diferenças entre os países pequenos e desloca a origem. Por isso o tamanho do efeito depende de ε e dos dois maiores países da amostra (EUA e China em 2021).

| Resultado | Resiste à min-max? | Observação |
|---|---|---|
| Base do ranking (Israel; Suíça, Noruega) | Sim | Israel fica entre os cinco últimos em todas as execuções e em quase todos os valores de ε |
| Topo do ranking | Não | Já não era distinguível estatisticamente; muda de composição |
| Conjunto de unidades eficientes (VRS) | Sim | Igual por construção: a translação não muda quem está na fronteira VRS |
| H1 (retornos de escala), Malmquist CRS (H4) | Não se aplica | A min-max desloca a origem; retornos de escala e produtividade CRS perdem a leitura econômica (seção 3) |
| H3a (canais divergem) | Em parte | Correlação moderada nas duas versões; ficar abaixo de 0,5 depende da versão e de ε |
| H3b (metafronteira) | Sim | Continua sem apoio e com sinal contrário |
| H5 (efetividade governamental) | Sinal sim | Negativa nas 6 execuções e nas duas versões; a significância varia |
| H6 (finanças no canal de patentes) | Não | O crédito privado perde o efeito |
| H7 (PIB per capita nos canais) | Sim | Negativo nos dois canais |
| R1 (concordância entre estimadores) | Enfraquece | Spearman VRS × order-m: 0,51 → 0,20 na Fase A |

## 2. O que foi implementado

**Transformação.** z = ε + (1 − ε)(x − mín)/(máx − mín), com ε = 0,01. A fórmula é a mesma para insumos e produtos, e o insumo continua sendo insumo: é a opção (a) registrada no `artigo/13`, que preserva a leitura de tecnologia de produção. O piso ε evita insumo zero (unidade eficiente por construção) e produto zero. O valor 0,01 é o menor dos dois sugeridos no `artigo/13`; a sensibilidade cobre ε de 0,001 a 0,2 (seção 6).

**Uma só transformação por execução.** Mínimo e máximo de cada variável são calculados uma vez, sobre todas as observações completas de todos os anos, incluindo as de investimento zero: 208 na Fase A e 215 no painel base. Os mesmos parâmetros valem nas fronteiras anuais, na agrupada, na metafronteira, no Malmquist, no bootstrap, no algoritmo 2 e nas sensibilidades (sem piso, com zeros). Ficam gravados em `padronizacao_parametros<sufixo>_minmax.csv`.

**Mesma amostra.** A seleção de amostra continua nas unidades originais: investimento positivo, produto positivo nos canais e piso de 2,5 M US$. Assim as duas versões têm exatamente as mesmas observações (191 na Fase A, 204 no painel), e toda diferença vem da transformação. As variáveis de contexto do segundo estágio e o log do escore como dependente não foram padronizados: são outro objeto (regressores e dependente), e não variáveis da fronteira.

**Código.** Três funções novas em `R/funcoes.R`: `ConfigurarPadronizacao`, `ParametrosPadronizacao` e `MatrizFronteira`. Os scripts `R/02`, `R/02b`, `R/03`, `R/04` e `R/05` foram parametrizados com `PADRONIZACAO` e `EPSILON_PADRONIZACAO`. O `R/05b` é novo e o runner ganhou o modo `padronizacao`.

**Verificação.** No modo padrão, a Fase A (`R/02`, `R/02b`, `R/03`, `R/04`) e o `R/05` reproduzem as tabelas versionadas. As únicas diferenças são três:
- tempos de execução e um horário;
- as linhas de H6 em Farrell na Fase A, um modelo de comparação que não converge. A tabela versionada era de 15h58 de 28/09, anterior à regra que pula o bootstrap de modelos sem convergência (commit `f188559`). Agora as linhas vêm sem erro-padrão, coerentes com o código. O coeficiente já era NA.

## 3. Por que a min-max muda os resultados

**Escala.** Os modelos radiais (CCR e BCC) não mudam quando uma variável é multiplicada por uma constante positiva. A verificação numérica confirma: com cada variável dividida pelo seu máximo, a diferença máxima nos escores VRS e CRS é de 1,5 × 10⁻¹² na Fase A e de 1,8 × 10⁻¹² no painel, e no Malmquist é de 2,4 × 10⁻¹² e 3,8 × 10⁻¹². Mudar só a escala não afeta nada.

**Translação.** A min-max é uma mudança de escala seguida da soma de uma constante. Em unidades originais, equivale a somar a cada variável c = ε(máx − mín)/(1 − ε) − mín:

| Variável | Fase A: c | c em relação à mediana | Painel: c | c em relação à mediana | Unidade que define o máximo |
|---|---|---|---|---|---|
| Investimento (milhões de US$) | 1.525 | 17 vezes | 1.104 | 6,5 vezes | Estados Unidos (Fase A: 2021; painel: linha de 2020, valor defasado) |
| GERD (milhões de US$) | 7.035 | 80% | 6.446 | 65% | Estados Unidos (2021) |
| Publicações | 659 | 48% | 591 | 36% | China (2021) |
| Patentes | 854 | 71 vezes | 938 | 36 vezes | China (2021) |

O resultado é uma compressão: depois da transformação, 86% dos país-ano da Fase A têm investimento padronizado até 2ε (0,02), e 87% têm patentes até 2ε (78% e 88% no painel). Para a maioria dos países, investimento e patentes passam a ser quase constantes.

**Efeito nos modelos VRS orientados a produto** (ranking, canais, metafronteira, segundo estágio):
- A translação dos insumos não muda nada, porque a restrição Σλ = 1 a cancela.
- A dos produtos troca a razão que mede a ineficiência, de y_fronteira/y para (y_fronteira + c)/(y + c). Ela fica mais perto de 1 quanto menor for a produção do país. Por isso os países pequenos sobem: Croácia, Chile, Filipinas e Argentina vão para o topo.
- O conjunto de unidades eficientes não muda (19 supereficientes nas duas versões, na Fase A; 15 no painel). Muda só a distância dos demais até a fronteira.

**Efeito nos modelos CRS** (eficiência de escala, classificação e teste de retornos de escala, Malmquist): a translação desloca a origem. O zero da escala padronizada corresponde a um investimento de −US$ 1,5 bilhão e a −854 patentes. "Retornos constantes" passa a significar proporcionalidade a partir desse ponto, e não a partir de zero; uma tecnologia com retornos constantes nas unidades reais deixa de ter retornos constantes na escala padronizada.

Por isso o teste de RTS rejeita retornos constantes com p = 0,001 em todas as bases padronizadas. Nas unidades originais, nenhum p era menor que 0,05: Fase A M2 p = 0,091 e painel p = 0,44. A rejeição não é evidência sobre H1, é consequência da mudança de origem. Pelo mesmo motivo, com min-max a parcela de país-ano em retornos crescentes salta de 9% para 55% na Fase A e de 20% para 56% no painel. **H1 e o Malmquist (H4) só têm leitura nas unidades originais**, e a min-max não serve de checagem de robustez para eles.

## 4. Resultados comparados: Fase A e painel base

| Indicador | Fase A original | Fase A min-max | Painel original | Painel min-max |
|---|---|---|---|---|
| Escore VRS médio | 0,72 | 0,89 | 0,61 | 0,78 |
| Spearman país-ano do escore VRS entre versões | — | 0,84 | — | 0,78 |
| Spearman entre rankings (escore corrigido) | — | 0,45 [0,10; 0,73] | — | 0,59 [0,32; 0,78] |
| Base 5 do ranking | Suíça, Israel, Irlanda, Noruega, África do Sul | Israel, França, Reino Unido, Suíça, Holanda | Israel, Irlanda, África do Sul, Bélgica, Suécia | Israel, Suíça, Suécia, Alemanha, Bélgica |
| Topo 5 do ranking | Itália, Grécia, Malásia, Indonésia, Índia | Indonésia, Croácia, Chile, Grécia, Portugal | Itália, Malásia, Croácia, Sérvia, Ucrânia | Argentina, Filipinas, Luxemburgo, Chile, Colômbia |
| Supereficientes (no piso) | 19 (7) | 19 (7) | 15 (3) | 15 (3) |
| País-ano em DRS / CRS / IRS | 136 / 38 / 17 | 45 / 40 / 106 | 138 / 25 / 41 | 67 / 23 / 114 |
| H3a: Spearman entre canais | 0,52 [0,31; 0,69] | 0,46 [0,23; 0,66] | 0,48 [0,30; 0,63] | 0,34 [0,14; 0,51] |
| H3a: p unilateral de ρ ≥ 0,5 | 0,59 | 0,35 | 0,37 | 0,033 |
| H3b: TGR médio, renda média − alta | +0,32 [0,23; 0,40] | +0,27 [0,19; 0,35] | +0,33 [0,24; 0,40] | +0,24 [0,18; 0,30] |
| Kruskal-Wallis, canal de patentes (país-ano) | 0,0005 | 0,073 | 0,0002 | 0,0001 |
| R1: Spearman VRS × corrigido / × order-m | 0,93 / 0,51 | 0,71 / 0,20 | 0,96 / 0,63 | 0,88 / 0,42 |

**Ranking (S05).** A base é a parte estável:
- Israel fica em 35º/36º na Fase A e em 47º/47º no painel.
- Suíça (36º → 33º; 39º → 46º) e Noruega (33º → 30º; 40º → 40º) continuam no fim.
- Irlanda e África do Sul sobem com a min-max. O motivo é mecânico: produção pequena com GERD alto, e a constante somada aos produtos as aproxima da fronteira.

O topo muda bastante, como já se esperava: os postos do topo não se distinguiam na versão original (intervalos de postos de 1 a 13–18). Entre os candidatos a perfil, os mais estáveis são Itália (1º → 12º; 1º → 6º), Grécia (2º → 4º; 19º → 15º) e Malásia (3º → 13º; 2º → 9º). As figuras `fig11_ranking_padronizacao*_minmax.png` mostram, país a país, a posição nas duas versões.

**Retornos de escala por país (S04).** Mesmo sem leitura econômica com min-max, a classificação de alguns países coincide nas duas versões, e o Japão, não:

| País | Fase A original | Fase A min-max | Painel original | Painel min-max |
|---|---|---|---|---|
| Estados Unidos | DRS 9/9 | DRS 9/9 | DRS 5/5 | DRS 5/5 |
| China | CRS 9/9 | CRS 9/9 | CRS 5/5 | CRS 5/5 |
| Reino Unido | DRS 3/3 | DRS 3/3 | DRS 5/5 | DRS 5/5 |
| Japão | DRS 9/9 | IRS 8, CRS 1 | DRS 5/5 | DRS 2, CRS 2, IRS 1 |
| Índia | DRS 4, CRS 4 | CRS 8/8 | CRS 2/2 | CRS 2/2 |

A discussão de H1 deve usar as unidades originais.

**Malmquist (S06).** As médias gerais mantêm a regressão técnica (TC < 1): 0,91 → 0,85 na Fase A e 0,85 → 0,88 no painel. A decomposição por país muda muito: o Spearman do índice M por país entre versões é 0,33 na Fase A e 0,42 no painel, e o de TC no painel é 0,04. Como o Malmquist é CRS, vale a leitura em unidades originais. O único traço que coincide é China e Índia com mudança de eficiência igual a 1 (sobre a fronteira em todos os anos). O Brasil continua ganhando por aproximação da fronteira (EC 1,52 → 1,25), mas com min-max a fronteira não fica parada (TC 0,96 → 0,75).

**Segundo estágio (S07).** Truncada sobre log(escore), coeficiente e IC 95% (positivo = mais eficiente):

| Termo | Fase A original | Fase A min-max | Painel original | Painel min-max |
|---|---|---|---|---|
| Efetividade governamental (H5) | −0,58 [−1,31; 0,02] | −0,53 [−0,94; −0,08] | −0,69 [−1,20; −0,21] | −0,57 [−0,88; −0,13] |
| Crédito privado, canal de patentes (H6) | 0,01 [−0,02; 0,04] | 0,00 [−0,03; 0,02] | 0,03 [0,00; 0,05] | −0,00 [−0,01; 0,01] |
| log PIB per capita, canal de patentes (H7) | −0,53 [−1,80; 0,27] | −0,66 [−1,48; −0,02] | −0,96 [−1,69; −0,25] | −0,90 [−1,36; −0,47] |
| log PIB per capita, canal de publicações (H7) | −0,36 [−0,66; −0,02] | −0,27 [−0,55; −0,07] | −0,26 [−0,56; −0,01] | −0,28 [−0,49; −0,12] |

O sinal negativo da efetividade governamental aparece nas seis execuções, nas duas versões. O algoritmo 2 de Simar-Wilson (Farrell; positivo = menos eficiente) concorda: Fase A +10,1 [5,4; 15,3] → +3,6 [2,3; 5,3]; painel +17,1 [8,1; 25,5] → +5,0 [2,8; 7,3].

Somando todos os termos de todas as execuções, 139 de 188 coeficientes mantêm o sinal e 153 de 188 mantêm a conclusão a 5%. O que não resiste é H6: o crédito privado no canal de patentes era positivo e significativo no painel base, na Preqin e no P&D público, e com min-max fica em zero.

## 5. Variantes do painel e comparações em amostra comum

| Variante | Spearman entre rankings | Base 5 em comum | H3a: ρ canais | H3b: TGR renda média − alta | H5: efetividade |
|---|---|---|---|---|---|
| Qualidade | 0,79 | 2 | 0,42 → 0,42 | −0,11 [−0,21; −0,02] → −0,04 [−0,14; 0,02] | −0,22 → −0,39 (n.s. nas duas) |
| Patentes por inventor | 0,83 | 4 | 0,30 → 0,47 | +0,21 → +0,16 | −0,29 (n.s.) → −0,27 (sig.) |
| Preqin | 0,62 | 3 | 0,55 → 0,34 | +0,07 → +0,06 (n.s. nas duas) | −1,12 → −0,56 (sig. nas duas) |
| P&D público | 0,72 | 2 | 0,55 → 0,44 | −0,10 [−0,20; 0,01] → +0,04 [−0,02; 0,11] | −0,38 → −0,25 (sig. nas duas) |

Dois resultados do `artigo/06` (seção 9) não resistem:
- **A inversão da metafronteira nas variantes de qualidade e de P&D público.** Com min-max, o Mann-Whitney passa de p = 0,006 para 0,156 na qualidade e de 0,002 para 0,72 no P&D público. A direção da mudança entre a especificação base e a variante se mantém, mas com magnitude menor.
- **A diferença do coeficiente de efetividade entre qualidade e base em amostra comum.** Era +0,43 [0,05; 0,75] e agora é +0,16 [−0,07; 0,45]: deixa de se distinguir de zero.

A robustez dos rankings à fonte em amostra comum se mantém (Spearman base × variante de 0,78–0,91 para 0,71–0,88).

## 6. Sensibilidade a ε

DEA determinística (sem bootstrap), mesma amostra. Spearman em relação às unidades originais:

| Transformação | Fase A: ranking VRS | Fase A: % DRS / % IRS | Fase A: ρ canais | Painel: ranking VRS | Painel: % DRS / % IRS | Painel: ρ canais |
|---|---|---|---|---|---|---|
| Unidades originais | 1 | 71 / 9 | 0,52 | 1 | 68 / 20 | 0,48 |
| Escala pura (x / máx) | 1 | 71 / 9 | 0,52 | 1 | 68 / 20 | 0,48 |
| Min-max, ε = 0,001 | 0,94 | 34 / 39 | 0,39 | 0,95 | 54 / 35 | 0,30 |
| Min-max, ε = 0,01 | 0,76 | 24 / 55 | 0,46 | 0,84 | 33 / 56 | 0,34 |
| Min-max, ε = 0,05 | 0,68 | 23 / 59 | 0,54 | 0,74 | 10 / 85 | 0,47 |
| Min-max, ε = 0,1 | 0,68 | 23 / 59 | 0,55 | 0,71 | 10 / 85 | 0,52 |
| Min-max, ε = 0,2 | 0,67 | 22 / 59 | 0,56 | 0,69 | 10 / 85 | 0,55 |

As próprias conclusões da versão min-max dependem de ε. No painel, a correlação entre canais é 0,34 com ε = 0,01 (apoiaria H3a) e 0,52 com ε = 0,1 (não apoiaria). Conforme ε cresce, a base do ranking passa a ser ocupada pelas grandes economias (Estados Unidos, Reino Unido, França, Alemanha, Japão), porque a constante somada aos produtos só deixa longe da fronteira quem tem produção grande. Israel continua entre os cinco últimos em todos os casos, menos no painel com ε = 0,2.

Com ε → 0, a min-max VRS se aproxima da versão original (Spearman 0,94–0,95 com ε = 0,001). Nesse limite, porém, a unidade de menor investimento fica com insumo próximo de zero e vira eficiente por construção nos modelos CRS.

## 7. Leitura e decisão pendente

**O que pode ser afirmado (resiste às duas versões, às fontes e a ε ≤ 0,1):**
- a base do ranking: Israel e, com menos folga, Suíça e Noruega;
- H3b sem apoio e com sinal contrário;
- a associação negativa da efetividade governamental e do PIB per capita com a eficiência (no sinal);
- a correlação apenas moderada entre os canais.

**O que fica frágil:**
- o topo do ranking;
- a força de H3a (ρ acima ou abaixo de 0,5);
- H6;
- a inversão da metafronteira nas variantes;
- a diferença de coeficientes entre qualidade e base.

**O que não pode ser checado assim:** H1 e o Malmquist (H4), porque a min-max desloca a origem. Para esses, valem as unidades originais e as ressalvas já registradas: teste de RTS com tamanho de cerca de 0,20 e intervalos do Malmquist descritivos.

**Recomendação (a decidir com o professor):** manter as unidades originais como especificação principal e apresentar a min-max (ε = 0,01) como verificação de robustez dos resultados VRS, com a tabela da seção 6. Os motivos:
1. A preocupação levantada na aula, de que escalas muito diferentes atrapalham na prática, foi testada e não se confirma nesta base: a mudança de escala pura reproduz tudo.
2. A min-max acrescenta uma translação arbitrária, cujo tamanho depende de ε e dos dois maiores países.
3. Com min-max, retornos de escala e Malmquist perdem o sentido econômico, o que obrigaria a misturar especificações entre as hipóteses, e o próprio professor recomendou não misturar transformações.
4. É a prática padrão em DEA, apoiada na literatura sobre invariância a unidades e a translação (Ali e Seiford, 1990; Lovell e Pastor, 1995; Pastor, 1996).

**Efeito colateral.** Com min-max, todos os modelos do segundo estágio convergiram, inclusive os ajustes em Farrell que antes falhavam. O algoritmo 2 concluiu na variante de qualidade, que antes estourava o limite de 300 s, e a execução completa levou 21 minutos, contra 78 na original sem a validação por simulação. Isso vem da compressão da distribuição dos escores, que facilita a verossimilhança, e não é argumento para adotar a min-max: a especificação principal já é a truncada sobre log(escore), que converge em todas as execuções.

## 8. Pendências decorrentes

1. **Decisão do autor, com o professor:** especificação principal (recomendação acima). Depois disso, levar ao `artigo/05`, ao `artigo/06` e ao deck a tabela de robustez à padronização: seções 4 a 6 deste documento.
2. **S02 (SFA):** sem mudança de plano. O SFA em log já resolve a diferença de ordem de grandeza (o log transforma escala em constante aditiva, absorvida pelo intercepto) e é uma única transformação para todas as variáveis.
3. **S04 (H1 por país):** discutir em unidades originais. Estados Unidos e Reino Unido em DRS e China em CRS coincidem nas duas versões; o Japão, não.
4. **S05 (perfis do ranking):** preferir os países estáveis nas duas versões. No topo, Itália, Grécia e Malásia; na base, Israel, Suíça e Noruega. Irlanda e África do Sul só entram na base na versão original. A fig11 serve de apoio para a legibilidade pedida na fig1.
5. **S06 (Malmquist por país):** manter a leitura em unidades originais e registrar que a decomposição por país é sensível à especificação. O bootstrap de Malmquist de Simar e Wilson (1999) segue pendente.
6. **S07 (dois níveis de evidência):** usar a robustez à padronização como um critério a mais, ao lado do IC 95% e do IC 90%: o sinal de H5 e de H7 resiste; H6, não.
