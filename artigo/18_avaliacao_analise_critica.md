# Avaliação dos 15 achados de `17_analise_critica_inconsistencias.md`

Avaliação feita em 04/10/2026 sobre o estado do repositório no commit `a1af12f`, o mesmo da auditoria. Cada achado foi reproduzido de forma independente antes do veredito: exemplos controlados, leitura do código e da documentação dos pacotes, conferência das tabelas e reestimações pontuais. Convenções, as mesmas de `artigo/10` e `artigo/12`:
- **Verdadeira:** divergência confirmada.
- **Verdadeira em parte:** a observação procede, mas parte da conclusão ou da justificativa do revisor não se sustenta.
- **Falsa:** descartada, com o motivo.

"Correção" diz se a sugestão do revisor foi adotada como está, adaptada (e por quê) ou substituída. "Estado" diz se a correção foi aplicada nesta rodada (código, reexecução e texto) ou se ficou pendente.

**Resumo dos vereditos:** os 15 achados são verdadeiros. Em 12, a sugestão do revisor era a melhor saída e foi adotada como estava ou com um complemento. Em três, foi adaptada:
- **A04:** antes de exigir convergência, investiguei por que os ajustes falhavam. Um reinício do otimizador resolve quase todos os casos, e o descarte das réplicas que falhavam não era neutro.
- **A11:** além do texto, a própria tabela de sensibilidade passou a mostrar o limite com ε minúsculo.
- **A14:** a fonte do deck não está no repositório, e o PDF é o registro da apresentação. Por isso a correção é uma errata slide a slide, e o deck corrigido depende do autor.

Todas as correções de código foram aplicadas e reexecutadas em 04/10/2026, entre 16h14 e 17h04, sem falhas:
- as cadeias 02 → 03 → 04 nas seis bases, nas unidades originais e em min-max (`zsh output/rodar_pipeline.sh cadeias`, com e sem `PADRONIZACAO=minmax`);
- o SFA nas seis bases (modo `sfa`);
- a checagem entre fontes (`R/12`);
- a comparação `R/05b`.

Status em `output/status_execucao.txt`, `status_execucao_minmax.txt`, `status_execucao_sfa.txt` e `status_execucao_minmax_05b.txt`. Fora as tabelas que as correções deveriam mudar, as demais saídas saíram idênticas às versionadas: fronteiras, bootstrap, ranking, canais, metafronteira, testes de RTS, comparações em amostra comum e o segundo estágio das cinco bases não afetadas por A06. As únicas outras diferenças são horários de execução, tempos de ajuste e, na decomposição da variância do Malmquist, arredondamento abaixo de 10⁻¹⁵. O apêndice confere as que mudaram.

**A correção com mais consequência é A01:** a leitura da dinâmica (RQ1) estava invertida desde o início do projeto. A fronteira avança, e a maioria dos países se afasta dela; o projeto dizia o contrário.

| ID | Veredito | Correção adotada | Estado |
|---|---|---|---|
| A01 | Verdadeira | Índices na convenção de Färe et al. (1994), recíprocos do `Benchmarking`, convertidos num único ponto (`IndicesMalmquist`) que confere a convenção do pacote a cada execução; identidades M = TC × EC e EC = razão de escores conferidas | Aplicada, reexecutada, textos revistos |
| A02 | Verdadeira | "Na fronteira em todos os anos" pelos escores CRS contemporâneos de todos os anos (tabela nova `malmquist_escores_crs`), conferidos contra a DEA anual; nomes distintos para índices anuais e médias por país | Aplicada, reexecutada |
| A03 | Verdadeira | Veredito de H2 pela especificidade relativa com direção (patentes > 0 e diferença > 0); padrão de significância por canal só como descrição; sem teste de equivalência (nenhuma margem definida antes dos resultados) | Aplicada, reexecutada |
| A04 | Verdadeira | Ajuste pontual válido nos dois canais e pelo menos 90% de réplicas convergentes antes de qualquer veredito; estados "não estimável" e "inconclusivo"; **adaptação:** reinício do otimizador do próprio ponto final, que resolve os dois ajustes pontuais com código 5 e quase todas as réplicas | Aplicada, reexecutada |
| A05 | Verdadeira | Soma das elasticidades calculada em cada réplica do bootstrap por país; classificação dos retornos só quando o IC exclui 1; Wald da hessiana mantido como diagnóstico identificado | Aplicada, reexecutada |
| A06 | Verdadeira | Escores dos canais por `left_join`; cada regressão usa os casos completos das próprias variáveis | Aplicada, reexecutada |
| A07 | Verdadeira | Bloco WGI com as quatro dimensões, o índice e a efetividade de referência da mesma cópia (cache do World Bank); H5 principal mantida com a cópia de cada base; tabela `wgi_original_vs_cache` | Aplicada, reexecutada |
| A08 | Verdadeira | Checagem principal com a coluna tratada de patentes (sem a Índia de 2019 em diante), com trava contra observações suspeitas; série bruta como sensibilidade identificada | Aplicada, reexecutada |
| A09 | Verdadeira | Truncada sobre log(escore) descrita como especificação exploratória própria; leitura de sinal, sem efeito percentual | Aplicada (comentários e textos) |
| A10 | Verdadeira | Diferença do desvio absoluto mediano entre metades com bootstrap de países (trajetórias completas) e Wilcoxon pareado por país como sensibilidade; inclinações só como descrição | Aplicada, reexecutada |
| A11 | Verdadeira | Frase corrigida; **complemento:** ε = 10⁻⁶ e 10⁻⁹ na tabela de sensibilidade, que mostra o limite diferente de zero | Aplicada, reexecutada |
| A12 | Verdadeira | Comparação M1 × M2 reescrita como propriedade da DEA, não como evidência de H2 | Aplicada (textos) |
| A13 | Verdadeira | Manifesto no `R/04` (e no `R/12`), com as figuras e os MD5 das tabelas lidas (`manifesto_entradas.csv`); cobertura delimitada no README; **adicional:** cabeçalho desalinhado do manifesto de execuções corrigido e trava contra a repetição | Aplicada |
| A14 | Verdadeira | **Adaptação:** fig4 vigente conferida contra a tabela do slide; errata slide a slide no `artigo/08`; PDF histórico preservado | Aplicada no brief; deck corrigido pendente (autor) |
| A15 | Verdadeira | IQR rotulado como dispersão absoluta; IQR relativo (IQR/mediana) e mediana acrescentados; conclusões restritas a cada referência anual | Aplicada, reexecutada |

## A01 — O sentido de melhora do Malmquist estava invertido

**Veredito: verdadeira.** Reproduzido com o `Benchmarking` 0.33 instalado:
- **Insumo constante e produto que dobra:** o pacote devolve M = TC = 0,5.
- **Fronteira fixa e unidade que sobe de 0,5 para 1:** devolve EC = 0,5. Com orientação a insumo, o mesmo caso dá EC = 2.

A documentação do pacote (`malmq`) confirma o motivo. Os índices são montados com medidas de Farrell, `ec = e11/e00` e `m = sqrt(e10/e00 × e11/e01)`. Na orientação a produto, o Farrell é um fator de expansão (F ≥ 1) que diminui quando a eficiência melhora. Logo, nessa orientação, **valor menor que 1 é melhora**. O projeto lia o contrário em todos os documentos e nos slides 11, 14, 15 e 18.

Exemplo nos dados: o escore CRS do Brasil no painel balanceado da Fase A cai de 1,000 (2016) para 0,284 (2019). O EC gravado era 1,52 e era lido como catch-up. Na convenção certa, o EC é 0,66: o Brasil se afasta da fronteira.

**Correção.** Adotada a sugestão do revisor (item 1), com dois complementos (itens 2 e 3):
1. **Convenção fixada:** índice maior que 1 = melhora, como em Färe et al. (1994), com distâncias de Shephard (D = 1/F). Os três índices gravados são os recíprocos dos devolvidos pelo pacote. Sob CRS, isso coincide com o Malmquist orientado a insumo; manter a orientação a produto e inverter deixa a escolha explícita.
2. **Um só ponto de conversão, com trava.** `IndicesMalmquist` (`R/funcoes.R`) converte e é usada pelo `R/02` e pelo cálculo direto do `R/05b`; quem só lê tabelas já recebe a convenção certa, sem dupla inversão. Antes de converter, `ConferirConvencaoMalmquist` roda o exemplo do produto que dobra e interrompe a execução se uma versão futura do pacote mudar a convenção.
3. **Conferências a cada execução:** a tabela `malmquist_m2` passa a trazer as medidas de Farrell originais (e00, e01, e10, e11) e os escores CRS contemporâneos (1/e00 e 1/e11). O script para se M ≠ TC × EC ou se EC ≠ escore do ano / escore do ano anterior (tolerância 10⁻⁸).

A β-convergência usa o EC convertido, e por isso a inclinação troca de sinal com o mesmo p-valor. Na Fase A, ela vai de +0,106 para −0,106 (p = 0,11). A decomposição da variância de log M não muda. O comentário do `R/02` registra também que parte de uma inclinação negativa é mecânica: o escore é limitado a 1, e quem começa na fronteira não pode se aproximar dela.

## A02 — "Sempre na fronteira" usava uma média que escondia a trajetória

**Veredito: verdadeira.** Reproduzido:
- No `summarise` de `R/04`, a média geométrica sobrescrevia `mudanca_eficiencia` antes do teste `all(abs(mudanca_eficiencia - 1) < 1e-6)`, que recebia um único número.
- A Argentina da Fase A, com EC de 2,39, 0,52 e 0,81 (média geométrica 1) e escore mínimo de 0,42, aparecia "na fronteira".
- O erro conceitual também procede: EC = 1 em todas as transições só quer dizer eficiência constante.

**Correção.** Adotada a sugestão do revisor:
- O `R/02` grava `malmquist_escores_crs`, com o escore CRS contemporâneo de cada país em todos os anos da janela, inclusive o primeiro.
- Cada ano é conferido contra uma DEA CRS refeita ano a ano no mesmo painel balanceado; se a diferença passar de 10⁻⁶, o script para.
- O `R/04` marca "na fronteira em todos os anos" só quando todos esses escores são iguais a 1 (tolerância 10⁻⁶) e não há ano faltando.
- As médias por país ganharam nomes próprios (`*_media_geom`), e a tabela traz os escores inicial, final e mínimo.

Não criei uma classe separada de "eficiência constante": a faixa "estável" do EC já a cobre, e os escores na tabela mostram a posição do país.

## A03 — Significância em um canal não demonstra exclusividade

**Veredito: verdadeira.** Conferido no código: o veredito "apoiada" exigia só patentes com IC fora do zero e publicações com IC contendo zero. O contraste entre canais era calculado, mas não entrava no veredito. Na variante por inventor, o modelo agrupado recebia "apoiada" com o IC da diferença em [−0,00105; 0,277]. A regra também aceitaria um efeito negativo em patentes como apoio.

**Correção.** Adotada a primeira opção do revisor, a especificidade relativa com direção, que é o que H2 afirma:
- **Apoiada:** elasticidade do investimento em patentes com IC 95% acima de zero **e** diferença patentes − publicações com IC 95% acima de zero.
- **Apoio parcial:** só uma das duas condições.
- **Contrariada:** diferença com IC abaixo de zero, ou patentes com IC abaixo de zero.
- **Não apoiada:** nenhuma das duas.

O padrão de significância de cada canal continua na tabela (`efeito_publicacoes`, `efeito_patentes`), só como descrição. Não fiz teste de equivalência para "sem efeito em publicações": ele exige uma margem substantiva definida antes dos resultados, e escolher uma agora seria ajustar o critério aos dados (o próprio revisor alerta para isso). Por isso o texto diz "não distinguível de zero", e não "sem efeito".

**Resultado, nas 18 combinações de base e modelo** (com o reinício de A04):
- **Apoiada em 3:** os dois modelos de painel da Fase A e o agrupado da variante por inventor.
- **Apoio parcial em 2:** os modelos de painel da variante de qualidade.
- **Não apoiada em 13**, entre elas todas as do painel base e todas as com o P&D público.
- **Contrariada em nenhuma.** Os sete casos antes chamados de "contrariada (efeito só em publicações)" não têm diferença distinguível entre canais.

**O caso apontado pelo revisor (inventor, agrupado).** A previsão do revisor ("não deve confirmar diferença positiva com o IC atual") valia para o IC gravado, [−0,001; 0,277]. Com as réplicas que antes falhavam e agora convergem pelo reinício (A04), o IC passa a [0,0008; 0,277]: exclui zero por margem mínima, e o veredito é "apoiada". O resultado é frágil. Repetindo o bootstrap desse modelo com 20 sementes, o limite inferior fica acima de zero em 17 (de −0,009 a 0,036), e o efeito em patentes, em todas. Os documentos o chamam de "apoiada no limite".

## A04 — H2 recebia veredito mesmo sem convergência do ajuste pontual

**Veredito: verdadeira.** Conferido: o bloco de H2 não usava `inferencia_valida`. A combinação Preqin/publicações/BC92 (código 5 do `frontier`) recebia "não apoiada (sem efeito nos dois canais)" com 249 réplicas, e uma ausência de IC era lida como "não significativo".

**Diagnóstico antes da correção** (passos 4 e 5 da sugestão). O código 5 do `frontier` significa que o otimizador não achou parâmetros com log-verossimilhança maior que a do passo anterior: pode estar no máximo ou ter parado antes dele. Testei um reinício a partir do próprio ponto final.
- **Nos dois ajustes pontuais com código 5** (Preqin/publicações/BC92 e painel/publicações/translog), o reinício converge com código 1, a mesma log-verossimilhança e as mesmas estimativas (na Preqin, elasticidade do investimento de 0,0277 antes e depois do reinício). Esses ajustes estavam no máximo.
- **Nas réplicas do bootstrap** da Fase A, entre 6% e 19% paravam com código 5. Com o reinício, sobram de 0 a 5 falhas em 300.
- **O descarte não era neutro.** Na maioria das réplicas o reinício só confirma o ponto (ganho de log-verossimilhança abaixo de 10⁻⁵). Mas nos modelos de painel de publicações algumas paradas estavam longe do máximo: o reinício ganhou até 83 de log-verossimilhança e mudou a elasticidade em até 0,086. Descartar essas réplicas, como antes, enviesava os intervalos.

**Correção.** A sugestão foi adotada, com o reinício como passo prévio:
1. **Reinício documentado (`SfaFrontier`).** Quando o `frontier` para sem convergir, o ajuste reinicia do próprio ponto final e só é aceito se então convergir sem perder log-verossimilhança. Vale para o ajuste pontual e para cada réplica. As tabelas registram quando houve reinício (`reinicio`, `replicas_com_reinicio`).
2. **Exigências antes do veredito:**
   - ajuste pontual com inferência válida nos dois canais;
   - pelo menos 90% de réplicas convergentes na diferença, o mesmo limiar de alerta que o segundo estágio já usava (`artigo/12`, R01).
3. **Estados separados:**
   - "estimável";
   - "não estimável", com o canal e a mensagem do otimizador; os intervalos não são mostrados;
   - "inconclusivo", com o número de réplicas.

   Uma combinação que não é estimável sai do denominador dos vereditos, e ausência de IC nunca vira "sem efeito".

**Resultado:**
- **Ajustes pontuais:** os dois com código 5 convergem no reinício. São 55 ajustes com inferência válida de 60 (antes, 53); os 5 inválidos são os exponenciais de publicações com assimetria errada.
- **Réplicas:** convergem de 294 a 300 em 300 por estimativa (antes, de 216 a 292), com 8 a 84 reinícios por base.
- **Vereditos:** todas as 18 combinações de H2 ficaram estimáveis.

## A05 — A inferência dos retornos no SFA não acompanhava a dependência por país

**Veredito: verdadeira.** Conferido: `TesteRetornos` usava a covariância da hessiana (observações independentes) e era chamado antes do bootstrap. O `artigo/15` afirmava retornos diferentes de 1 "sempre com p < 0,05" com esse Wald, embora justificasse o bootstrap por país justamente pela repetição dos países.

**Correção.** Adotada a sugestão do revisor:
- **Soma calculada na réplica.** Em cada réplica do bootstrap por país, a soma das elasticidades (investimento + P&D) é calculada no mesmo sorteio, o que preserva a covariância entre as duas. Os limites dos IC individuais não são somados.
- **Tabela nova `sfa_retornos`,** com ponto, IC 95% e 90%, réplicas e o método de cada linha:
  - "bootstrap em blocos de país" nos três modelos com bootstrap;
  - "Wald da hessiana (sem bootstrap; supõe observações independentes)" no exponencial e na translog.
- **Classificação:** decrescentes ou crescentes só quando o IC 95% exclui 1, sujeita aos mesmos controles de validade de A04.
- **Wald como diagnóstico:** continua na tabela `sfa_canais`, com nome explícito (`p_retornos_constantes_wald_hessiana`).

**Resultado.** Nos 18 casos com bootstrap (três modelos × seis bases):
- **publicações:** retornos decrescentes em todos, com o limite superior entre 0,70 e 0,89. A conclusão anterior se mantém, agora com a inferência adequada.
- **patentes:** retornos crescentes em 12, mas com o limite inferior entre 1,001 e 1,15, quase sempre colado em 1. Não distinguíveis de constantes em 6: as três da Fase A, os dois modelos de painel do inventor e o agrupado do P&D público.

A frase "sempre com p < 0,05" não se sustenta para patentes. A evidência de retornos crescentes no canal tecnológico é, no máximo, fraca, e o `artigo/15` e a H1 do `artigo/01` foram reescritos assim.

## A06 — Exclusões do canal de patentes alteravam o segundo estágio conjunto

**Veredito: verdadeira.** Reproduzido: na variante por inventor, CHL-2017 e BGR-2018 têm zero patente e saíam de todas as regressões do conjunto, por causa da interseção com os bootstraps dos canais (217 → 215 linhas). A H5 principal tinha 152 casos completos, em vez de 154. Nas outras cinco bases, o conjunto e os canais têm as mesmas observações, e nada muda.

**Correção.** Adotada a sugestão do revisor:
- Os escores dos canais entram por `left_join` e ficam ausentes onde o canal não é definido.
- Cada regressão já selecionava os casos completos das próprias variáveis (`TruncadaAgrupada`).
- Os testes por grupo de renda passaram a usar só as observações em que o escore existe e informam `n_obs`.

Resultado: a H5 por inventor volta a ter 154 casos completos, com efetividade −0,3034, o valor reestimado pelo revisor, e IC [−0,710; −0,002].
- **Significância:** passa de "bateu na trave" para significativa a 5%, por margem mínima.
- **Contagem de E5:** a efetividade tem sinal contrário em 23 de 23 especificações, agora com 13 significativas a 5%, 6 entre 5% e 10% e 4 sem significância (antes, 12/7/4).
- **Outras mudanças, pequenas:** pesquisadores 0,283 → 0,290 e PIB per capita em publicações −0,366 → −0,372 (217 observações).
- **Fora do inventor:** nada mudou nas outras bases.

## A07 — O bloco WGI da Fase A misturava cópias divergentes dos indicadores

**Veredito: verdadeira.** Reproduzido: a efetividade governamental e o controle da corrupção do dataset original diferem do cache do World Bank em todas as observações. Nas 191 observações da DEA, a maior diferença absoluta é de 0,525 e 0,305, e a mediana, de 0,13 e 0,07. Investiguei a origem:
- A correspondência é melhor no mesmo ano (correlação de 0,98 e 0,99) do que com defasagem de um ou dois anos para qualquer lado. Não é um deslocamento de ano.
- Os dados são compatíveis com safras diferentes do WGI, mas a causa exata não pôde ser confirmada.

**Correção.** Adotada a sugestão do revisor:
- **Uma só cópia no bloco WGI.** As quatro dimensões, o índice composto e a própria efetividade de referência vêm do cache, na mesma amostra. Assim, trocar de dimensão não troca também de fonte.
- **Referência explícita.** A linha de referência é rotulada "efetividade_governo do cache WGI", e a coluna `fonte_wgi` identifica a cópia.
- **H5 principal inalterada:** continua com a cópia de cada base (na Fase A, a do dataset original, para manter a replicação).
- **Sensibilidade entre cópias:** a tabela nova `wgi_original_vs_cache` traz, por dimensão, o número de diferenças, os desvios máximo e mediano e a correlação.
- **Painel:** as quatro dimensões já vinham do cache, e a tabela confirma zero diferença nas cinco bases do painel.

## A08 — A checagem entre fontes reutilizava patentes rejeitadas

**Veredito: verdadeira.** Reproduzido: `R/12` montava a comparação com `patentes_pedidos` (coluna bruta). Por isso, Índia 2019–2021 (12, 12 e 6 pedidos contra 303–476 famílias da OCDE) entravam na comparação, embora o projeto as trate como NA.

**Correção.** Adotada a sugestão do revisor:
- **Comparação principal:** usa a coluna tratada `patentes`, sem os anos incompletos e sem a Índia de 2019 em diante. Uma trava interrompe o script se alguma observação marcada como suspeita entrar.
- **Série bruta:** fica numa segunda linha da tabela de Spearman, rotulada "bruta (inclui Índia 2019–2021, suspeita)".
- **Resultado:**
  - 299 pares e ρ = 0,763 [0,623; 0,862] (antes: 302 e 0,753 [0,612; 0,852]);
  - Spearman por país: 0,836 → 0,838;
  - Índia: razão CSET/OCDE de 0,40 para 1,10.
- **O que não mudou:** a fig9 foi refeita, os arquivos de `data/processed/` regravados pelo `R/12` saíram idênticos, e as demais checagens (investimento e publicações) não mudaram.

## A09 — Transformar o escore não preserva o modelo de Simar e Wilson

**Veredito: verdadeira.** Se a medida de Farrell F tem distribuição normal truncada em 1 (Simar e Wilson, 2007), log(escore) = −log(F) não tem distribuição normal truncada: a transformação muda a densidade. Ser monótona não torna os dois modelos equivalentes. Além disso, o coeficiente da truncada se refere à média da normal latente, e não é a semi-elasticidade do escore observado.

**Correção.** Adotada a sugestão do revisor:
- **Descrição.** Comentários de `AjustarTruncada` e do `R/03` e textos de `artigo/01`, `05`, `06` e `08`: "regressão normal truncada do log do escore, com escores fixos e bootstrap por país, especificação exploratória própria". A escolha se justifica pelo suporte compatível e pela estabilidade numérica; o algoritmo 2 do `rDEA` continua separado.
- **Leitura:** de sinal, sem anunciar a magnitude como efeito percentual.

Não calculei efeitos marginais: nenhuma conclusão do projeto depende da magnitude. Se o manuscrito quiser interpretar magnitudes, eles devem ser calculados da distribuição truncada ajustada, com incerteza.

## A10 — O teste da dispersão ignorava a repetição dos países

**Veredito: verdadeira.** Conferido: o Mann-Whitney comparava desvios país-ano entre as metades do período como se fossem amostras independentes, e os mesmos países estão nas duas (por exemplo, 33 dos 35 países de alta renda no painel). Chamar o procedimento de versão não paramétrica do Brown-Forsythe também era impreciso.

**Correção.** Adotada a sugestão do revisor:
- **Alvo:** a diferença do desvio absoluto mediano (em relação à mediana de cada ano) entre a segunda e a primeira metade do período.
- **Incerteza:** reamostragem de países, com todos os anos de cada país juntos (2.000 réplicas). Em cada réplica as medianas anuais e os desvios são recalculados, e o p-valor bootstrap vem pela mesma regra do segundo estágio.
- **Sensibilidade pareada:** Wilcoxon de postos sinalizados sobre o desvio médio de cada país em cada metade, só com os países presentes nas duas.
- **Inclinações do CV e do IQR:** ficam como descrição de tendência (MQO com um ponto por ano).
- **Ressalva:** a tabela informa países, alvo e método, e o resultado é condicional às fronteiras anuais estimadas.

**Resultado:** nenhuma das dez comparações (cinco bases × dois grupos de renda) tem diferença entre as metades distinguível de zero. O p bootstrap vai de 0,30 a 0,995, e o Wilcoxon pareado, de 0,09 a 0,99. A conclusão anterior ("sem tendência significativa") se mantém, agora com a inferência adequada.

## A11 — Fazer ε tender a zero não elimina a translação

**Veredito: verdadeira.** No limite, a min-max vira (x − mín)/(máx − mín): a subtração do mínimo continua, e a orientação a produto não é invariante à translação dos produtos, nem sob VRS. Reproduzido no próprio pipeline (maior diferença absoluta do escore VRS para o original e Spearman país-ano):

| ε | Fase A: diferença | Fase A: Spearman | Painel: diferença | Painel: Spearman |
|---|---|---|---|---|
| 0,001 | 0,511 | 0,948 | 0,726 | 0,927 |
| 10⁻⁶ | 0,353 | 0,996 | 0,161 | 0,995 |
| 10⁻⁹ | 0,353 | 0,996 | 0,161 | 0,995 |

Os valores com ε = 10⁻⁶ e 10⁻⁹ coincidem com os do revisor até a 6ª casa.

A correlação de postos se aproxima de 1, mas os escores não convergem para os originais.

**Correção.** Adotada a sugestão do revisor, com um complemento:
- **Texto:** a frase do `artigo/14` foi corrigida, com as diferenças absolutas além das correlações.
- **Tabela:** `sensibilidade_padronizacao_epsilon.csv` passou a incluir ε = 10⁻⁶ e 10⁻⁹. O limite fica registrado no pipeline, ao lado da checagem de escala pura (x/máx), que continua reproduzindo tudo até 10⁻¹².
- **Decisão mantida:** as unidades originais continuam como especificação principal. A justificativa passa a distinguir escala pura (sem efeito) de translação (com efeito, e que não desaparece com ε pequeno).

## A12 — O aumento do escore ao acrescentar o GERD é mecânico

**Veredito: verdadeira.** Na DEA orientada a produto, com a mesma amostra e os mesmos produtos, acrescentar um insumo restringe as combinações de referência. O fator de expansão máximo não aumenta, e o escore não diminui, seja o insumo relevante ou não. Conferido nas seis bases: em nenhuma das 1.107 observações o escore M2 fica abaixo do M1, nem em VRS nem em CRS.

**Correção.** Adotada a sugestão do revisor:
- **Textos revistos** (`artigo/01`, `05`, `15` e o slide 14 no `artigo/08`): a comparação M1 × M2 passa a ser descrita como efeito de acrescentar uma restrição à tecnologia.
- **H2:** o teste de H2 é só o SFA.
- **Diagnóstico mantido:** a desigualdade continua sendo uma conferência de consistência da DEA, mas deixa de ser evidência.

## A13 — Tabelas do script de figuras ficavam fora do manifesto

**Veredito: verdadeira.** Conferido: `R/04` não chamava `RegistrarManifesto`. O registro de `SalvarTabela` vive só na memória do processo e se perde quando o `Rscript` termina. As figuras não eram registradas em nenhum script.

**Correção.** Adotada a sugestão do revisor:
1. **R/04 com manifesto:** `R/04` chama `RegistrarManifesto` no fim. As figuras gravadas por `SalvarFigura` (`R/04`), a fig11 (`R/05b`) e as figuras 8 a 10 (`R/12`) entram em `manifesto_saidas.csv` com o MD5.
2. **Entradas registradas:** as tabelas derivadas lidas pelo `R/04` e pelo `R/05b` ficam registradas, com o MD5 no momento da leitura, num arquivo novo, `manifesto_entradas.csv`. Assim cada figura fica ligada à versão dos resultados que ela representa.
3. **R/12 registrado:** passou a registrar a própria execução.
4. **Escopo no README.** Ficam fora os scripts de preparação e importação (`01`, `10`, `11`, `13` a `16`). Eles gravam bases em `data/`, cuja proveniência está em `data/README.md` e no `artigo/02`. Nesta rodada não foram reexecutados, e registrá-los exigiria rodá-los de novo.

**Defeito adicional, não apontado pelo revisor.** O cabeçalho de `manifesto_execucoes.csv` tinha 9 colunas desde 27/09, mas as linhas passaram a ter 10 em 28/09, quando `id_execucao` entrou só nas linhas. O `read.csv` lia o arquivo desalinhado: 202 "linhas" em vez de 140, com campos trocados de coluna.
- **Arquivo corrigido:** cabeçalho com `id_execucao`, e as 23 linhas anteriores a 28/09 com id vazio. Agora lê 140 linhas × 10 colunas.
- **Trava:** a gravação dos três manifestos passou por `AcrescentarCsv`, que interrompe o registro se o cabeçalho existente não tiver as mesmas colunas.
- **Saídas:** a trava foi acrescentada depois da reexecução e não altera nenhuma saída.

## A14 — O slide 12 combinava gráfico em escore com tabela em log do escore

**Veredito: verdadeira.** Conferido na página 12 do PDF, renderizada:
- o gráfico embutido é a fig4 de uma versão anterior, com título "dependente em (0,1]" e a efetividade em cerca de −0,137, destacada como significativa;
- a tabela e a nota ao lado estão em log do escore, com −0,58 [−1,31; 0,02], sem significância.

A declaração do `artigo/07` de que o PDF tinha as sete figuras da revisão 3 também não se confirma para essa página.

**Correção, adaptada.** A sugestão (trocar a imagem no deck) não pode ser executada no repositório, por dois motivos:
- o deck foi gerado no Claude Design a partir do `artigo/08`, e a fonte (PptxGenJS) não está versionada;
- o PDF é o registro do que foi apresentado em 28/09.

O que foi feito:
1. **fig4 conferida.** A fig4 vigente (`output/figures/fig4_segundo_estagio.png`) está em log do escore, e a efetividade do modelo conjunto da Fase A cruza zero, como na tabela do slide. Nesta rodada ela não mudou: o segundo estágio da Fase A não mudou.
2. **Errata slide a slide no `artigo/08` (seção 2a; desde a revisão 5 do brief, seção 2).** O slide 12 deve trocar a imagem pela fig4 vigente e retirar "(semi-elasticidade)", por A09. Os slides 11, 14, 15 e 18 devem inverter a leitura do Malmquist (A01), o 14 deve trocar a evidência de H2 (A12) e o 16, o número da checagem de patentes (A08). As seções 3 e 4 do brief foram corrigidas no lugar.
3. **artigo/07 corrigido.** A declaração do `artigo/07` foi corrigida, e o PDF histórico ficou intocado.

O deck corrigido depende de o autor regenerá-lo no Claude Design com o brief revisto.

## A15 — IQR absoluto era chamado de dispersão relativa

**Veredito: verdadeira.** IQR(c × escore) = c × IQR(escore): o IQR é dispersão absoluta. Além disso, uma fronteira anual nova pode mudar os escores de forma não proporcional, de modo que nem o CV garante comparabilidade entre anos.

**Correção.** Adotada a sugestão do revisor, nos itens 1, 2 e 4:
- **Medidas.** A tabela `dispersao_renda_ano` ganhou `mediana` e `iqr_relativo` (IQR/mediana). O IQR passa a ser descrito como dispersão absoluta, e o CV e o IQR relativo, como relativas ao centro.
- **Conclusões:** restritas à dispersão observada em cada referência anual, com a ressalva de composição e de fronteira, em `R/04`, `artigo/05`, `06` e `16`.
- **Pendente (opcional):** o item 3, uma análise com tecnologia de referência comum (fronteira agrupada, amostra estável), que é outro objeto em relação às fronteiras contemporâneas.


## O que mudou de substância após a reexecução

| Resultado | Antes | Depois | Achado |
|---|---|---|---|
| RQ1, Fase A: fronteira e posição dos países | "fronteira recua" (TC 0,91) e catch-up (EC 1,10) | a fronteira **avança** (TC 1,10 [1,02; 1,19]) e os países **se afastam** (EC 0,91 [0,84; 0,99]); produtividade estável (M 1,00) | A01 |
| RQ1, painel | TC 0,85; EC 1,08 [1,04; 1,12] | TC 1,17 [1,13; 1,21]; EC 0,93 [0,89; 0,96]; produtividade cresce (M 1,09 [1,05; 1,13]) | A01 |
| RQ1, variantes | fronteira recua em todas | fronteira avança em todas (TC 1,03 a 1,16); países se afastam, exceto no inventor (EC 1,02) e no P&D público (1,04) | A01 |
| Catch-up da renda média (H4b) | atendido só na Preqin (1,038 [1,001; 1,082]) | não atendido em nenhuma base; na Preqin, afastamento (0,964 [0,924; 0,999]); no ponto, a renda média se sai melhor que a alta renda nas seis bases | A01 |
| β-convergência | nula ou positiva ("divergência" no inventor e no P&D público) | negativa em cinco de seis bases, significativa no inventor (−0,100) e no P&D público (−0,115); descritiva e em parte mecânica | A01 |
| Malmquist por país | China com o "maior recuo" (0,65); Brasil ganha por catch-up (1,52); Argentina e Rússia "sempre na fronteira" | China com o maior avanço (1,54); Brasil se afasta (0,66); Argentina e Rússia fora da lista (escores de 0,42 e 0,62 em algum ano) | A01, A02 |
| Tese do platô | "confirmada em parte" | não confirmada: a fronteira avança mais onde estão os grandes investidores | A01 |
| H2 (SFA) | critério estrito em 2 de 18; "efeito só em publicações" (contrariada) em 7 | apoiada em 3 (uma no limite), apoio parcial em 2, não apoiada em 13, contrariada em nenhuma | A03, A04 |
| Retornos do SFA (H1, complementar) | decrescentes em publicações e crescentes em patentes, "sempre com p < 0,05" (Wald) | publicações decrescentes nas 18 combinações; patentes crescentes em 12, com limite inferior colado em 1, e não distinguíveis de constantes nas 6 restantes, entre elas toda a Fase A | A05 |
| Ajustes do SFA | 53 de 60 válidos; réplicas convergentes de 216 a 292 | 55 de 60 válidos; de 294 a 300 | A04 |
| H5, inventor | −0,29 [−0,71; 0,01], 152 casos | −0,303 [−0,710; −0,002], 154 casos; efetividade com sinal contrário a 5% em 13 de 23 especificações | A06 |
| WGI, Fase A | efetividade −0,58 (cópia original) comparada a dimensões do cache | efetividade −0,66 [−1,32; −0,04] na mesma cópia das outras dimensões; correlações de 0,93 a 0,96 | A07 |
| Patentes CSET × OCDE | ρ 0,753 [0,612; 0,852], 302 pares | ρ 0,763 [0,623; 0,862], 299 pares; Índia 0,40 → 1,10 | A08 |
| Dispersão por renda | nenhuma tendência significativa (Mann-Whitney) | nenhuma diferença entre metades distinguível de zero (bootstrap de países) | A10, A15 |
| Limite ε → 0 da min-max | "se aproxima da versão original" | diferença absoluta de 0,35 (Fase A) e 0,16 (painel) mesmo com ε = 10⁻⁹ | A11 |

**O que não mudou:**
- H1 pela DEA, H3a e H3b;
- o ranking e os resultados de robustez à padronização dos modelos VRS;
- o sinal das instituições e do PIB per capita no segundo estágio.

## Pendências e estado das entregas

1. **Deck (A14):** gerar de novo no Claude Design com a errata da seção 2a do `artigo/08` (desde a revisão 5 do brief, seção 2; fonte não versionada). O PDF de 28/09 fica como registro.
2. **Página do comparativo min-max (feito):** atualizada e republicada no mesmo endereço (versão 2), com o Malmquist na convenção correta, as contagens do segundo estágio e o limite de ε. Continua privada até ser compartilhada pelo menu Share.
3. **Malmquist (opcional, mas com peso maior agora):** o bootstrap de Simar e Wilson (1999). A RQ1 mudou de sentido, e os intervalos atuais seguem descritivos (reamostragem de países com índices fixos).
4. **Opcionais registrados:**
   - dispersão em tecnologia de referência comum (A15, item 3);
   - efeitos marginais da truncada, se o manuscrito interpretar magnitudes (A09);
   - equivalência em H2, só com margem fixada antes (A03);
   - manifesto dos scripts de preparação quando as bases forem reconstruídas (A13).

<a id="apendice"></a>

## Apêndice — Verificação do estado corrigido

O script abaixo confere, nas tabelas reexecutadas, cada correção aplicada; é o inverso do Apêndice A do `artigo/17`, que conferia o estado auditado. Ele só lê arquivos. Para repetir, salve o bloco em um arquivo e rode da raiz do projeto com `Rscript --vanilla`.

```r
# Verificação das correções da análise crítica 3 (artigo/17 -> artigo/18).
# Executar da raiz do projeto: Rscript --vanilla verificar_correcoes.R
# Só lê arquivos e imprime evidências; não grava nada nem instala pacotes.
# Os asserts verificam o estado corrigido (o inverso do apêndice A do
# artigo/17, que verificava o estado auditado).

stopifnot(requireNamespace("Benchmarking", quietly = TRUE))
source("R/funcoes.R")
options(digits = 6, width = 120)
Secao <- function(titulo) cat("\n", titulo, "\n", sep = "")
Ler <- function(nome) read.csv(file.path("output/tables", paste0(nome, ".csv")))
bases <- c(fase_a = "", painel = "_painel", qualidade = "_painel_qualidade",
           inventor = "_painel_fonte", preqin = "_painel_preqin",
           publico = "_painel_publico")

Secao("A01: exemplos controlados na convenção adotada (> 1 = melhora)")
x <- matrix(1, 1, 1)
i1 <- IndicesMalmquist(Benchmarking::malmq(x, x, X1 = x, Y1 = 2 * x,
                                           RTS = "crs", ORIENTATION = "out"))
print(i1)
x <- matrix(c(1, 1), 2, 1)
i2 <- IndicesMalmquist(Benchmarking::malmq(x, matrix(c(1, 0.5), 2, 1), X1 = x,
                                           Y1 = x, RTS = "crs",
                                           ORIENTATION = "out"))
print(i2)
stopifnot(abs(i1$malmquist - 2) < 1e-10, abs(i1$mudanca_tecnica - 2) < 1e-10,
          abs(i2$mudanca_eficiencia[2] - 2) < 1e-10)
for (pad in c("", "_minmax")) {
  for (b in names(bases)) {
    m <- Ler(paste0("malmquist_m2", bases[[b]], pad))
    e1 <- max(abs(m$malmquist - m$mudanca_tecnica * m$mudanca_eficiencia))
    e2 <- max(abs(m$mudanca_eficiencia - m$escore_crs / m$escore_crs_anterior))
    e3 <- max(abs(m$mudanca_eficiencia - m$farrell_e00 / m$farrell_e11))
    stopifnot(e1 < 1e-8, e2 < 1e-8, e3 < 1e-8)
  }
}
cat("Identidades M = TC x EC, EC = razão de escores e EC = e00/e11:",
    "conferidas nas 12 execuções\n")
b <- Ler("malmquist_m2")
print(b[b$pais == "Brazil", c("ano", "escore_crs_anterior", "escore_crs",
                              "mudanca_eficiencia")])
stopifnot(all(b$mudanca_eficiencia[b$pais == "Brazil"] < 1))

Secao("A02: 'na fronteira em todos os anos' pelos escores contemporâneos")
antes <- list(fase_a = "Argentina", painel = "Russia",
              inventor = c("Russia", "Japan", "Malaysia"), preqin = "Turkey",
              publico = "Russia")
for (b in names(bases)) {
  p <- Ler(paste0("malmquist_por_pais", bases[[b]]))
  e <- Ler(paste0("malmquist_escores_crs", bases[[b]]))
  marcados <- p$pais[p$sempre_na_fronteira]
  minimo <- vapply(marcados, function(k) min(e$escore_crs[e$pais == k]),
                   numeric(1))
  stopifnot(all(minimo >= 1 - 1e-6))
  stopifnot(!any(antes[[b]] %in% marcados))
  cat(b, ": na fronteira em todos os anos =", paste(marcados, collapse = ", "),
      "\n")
}

Secao("A03 e A04: vereditos de H2 só com IC na direção prevista e ajuste válido")
for (b in names(bases)) {
  h <- Ler(paste0("sfa_h2", bases[[b]]))
  apoiada <- h$veredito == "apoiada"
  stopifnot(all(h$ic_inf_patentes[apoiada] > 0),
            all(h$ic_inf_diferenca[apoiada] > 0))
  estimavel <- h$estado == "estimável"
  stopifnot(all(h$inferencia_valida_publicacoes[estimavel]),
            all(h$inferencia_valida_patentes[estimavel]),
            all(h$replicas_convergentes_diferenca[estimavel] >= 270))
  cat(b, ":", paste(h$modelo, h$veredito, sep = " = ", collapse = " | "), "\n")
}
h <- Ler("sfa_h2_painel_fonte")
print(h[h$modelo == "cobb_douglas", c("ic_inf_patentes", "ic_inf_diferenca",
                                      "ic_sup_diferenca", "veredito")])
s <- Ler("sfa_canais_painel_preqin")
print(s[s$canal == "publicacoes" & s$modelo == "painel_bc92",
        c("convergiu", "inferencia_valida", "reinicio", "mensagem")])

Secao("A05: retornos com IC por bootstrap de país e método identificado")
for (b in names(bases)) {
  r <- Ler(paste0("sfa_retornos", bases[[b]]))
  boot <- r$inferencia_retornos == "bootstrap em blocos de país"
  stopifnot(all(r$modelo[boot] %in% c("cobb_douglas", "painel_bc88",
                                      "painel_bc92")))
  dec <- grepl("^decrescentes", r$classificacao)
  cre <- grepl("^crescentes", r$classificacao)
  stopifnot(all(r$ic_sup[dec] < 1), all(r$ic_inf[cre] > 1))
}
cat("Classificação de retornos coerente com os IC nas seis bases\n")

Secao("A06: amostra do conjunto preservada na variante por inventor")
e <- Ler("escores_bc_conjunto_e_canais_painel_fonte")
t <- Ler("segundo_estagio_truncada_painel_fonte")
h5 <- t[t$modelo == "H5 truncada (M2)" & t$dependente == "log_escore" &
          t$termo == "efetividade_governo", ]
cat("linhas do conjunto =", nrow(e), "| sem escore de patentes =",
    sum(is.na(e$escore_bc_pat)), "| H5: n =", h5$n_obs, "| efetividade =",
    h5$coeficiente, "\n")
stopifnot(nrow(e) == 217, h5$n_obs == 154,
          abs(h5$coeficiente - (-0.3033973)) < 1e-6)

Secao("A07: bloco WGI com uma só cópia dos indicadores")
for (b in names(bases)) {
  w <- Ler(paste0("segundo_estagio_wgi", bases[[b]]))
  stopifnot(length(unique(w$fonte_wgi)) == 1,
            any(w$termo == "efetividade_governo"))
  o <- Ler(paste0("wgi_original_vs_cache", bases[[b]]))
  cat(b, ":", paste(o$dimensao, "diferentes =", o$diferentes,
                    collapse = "; "), "\n")
}

Secao("A08: checagem de patentes sem as observações suspeitas")
c8 <- Ler("checagem_patentes_cset_vs_oecd")
sp <- Ler("checagem_patentes_spearman")
print(sp)
stopifnot(nrow(c8) == 299, !any(c8$patentes_suspeitas),
          abs(sp$rho[1] - 0.7632863) < 1e-6)

Secao("A10 e A15: dispersão com bootstrap de países e IQR relativo")
d <- Ler("dispersao_renda_tendencia_painel")
stopifnot(all(c("p_boot_paises", "ic_inf_dif", "p_wilcoxon_pareado_paises") %in%
                names(d)), !"p_mann_whitney_desvios" %in% names(d))
a <- Ler("dispersao_renda_ano_painel")
stopifnot(all(abs(a$iqr_relativo - a$iqr / a$mediana) < 1e-12))
x <- c(0.2, 0.4, 0.6, 0.8)
print(data.frame(escala = c(1, 0.5), iqr = c(IQR(x), IQR(x / 2)),
                 iqr_relativo = c(IQR(x) / median(x), IQR(x / 2) / median(x / 2))))

Secao("A11: ε minúsculo não recupera os escores originais")
s11 <- Ler("sensibilidade_padronizacao_epsilon")
print(s11[s11$epsilon %in% c(1e-9, 1e-6, 0.001) | is.na(s11$epsilon),
          c("base", "transformacao", "epsilon", "max_dif_vrs",
            "spearman_vrs_pais_ano")])
stopifnot(all(s11$max_dif_vrs[s11$transformacao == "escala pura (x / máx)"] <
                1e-10),
          all(s11$max_dif_vrs[which(s11$epsilon == 1e-9)] > 0.1))

Secao("A12: escore M2 nunca abaixo do M1 (propriedade da DEA)")
violacoes <- 0
for (b in names(bases)) {
  m1 <- Ler(paste0("dea_ano_m1", bases[[b]]))
  m2 <- Ler(paste0("dea_ano_m2", bases[[b]]))
  i <- match(m1$id, m2$id)
  violacoes <- violacoes + sum(m2$escore_vrs[i] < m1$escore_vrs - 1e-8)
}
cat("Violações de M2 >= M1 nas seis bases:", violacoes, "\n")

Secao("A13: tabelas e figuras do R/04 no manifesto, com MD5 atual")
saidas <- Ler("manifesto_saidas")
ultimas <- saidas[!duplicated(saidas$arquivo, fromLast = TRUE), ]
for (arquivo in c("output/tables/malmquist_por_pais.csv",
                  "output/tables/dispersao_renda_ano_painel.csv",
                  "output/figures/fig4_segundo_estagio.png")) {
  linha <- ultimas[ultimas$arquivo == arquivo, ]
  stopifnot(nrow(linha) == 1,
            unname(tools::md5sum(arquivo)) == linha$md5)
  cat(arquivo, ": registrado por", linha$id_execucao, "\n")
}
entradas <- Ler("manifesto_entradas")
cat("Entradas registradas do R/04 e do R/05b:", nrow(entradas), "\n")
stopifnot(any(grepl("^04_figuras", entradas$id_execucao)))

Secao("VERIFICAÇÃO CONCLUÍDA")
```

Saída da execução de 04/10/2026, depois da reexecução:

```text
A01: exemplos controlados na convenção adotada (> 1 = melhora)
  malmquist mudanca_tecnica mudanca_eficiencia
1         2               2                  1
  malmquist mudanca_tecnica mudanca_eficiencia
1         1               1                  1
2         2               1                  2
Identidades M = TC x EC, EC = razão de escores e EC = e00/e11: conferidas nas 12 execuções
   ano escore_crs_anterior escore_crs mudanca_eficiencia
7 2017            1.000000   0.437158           0.437158
8 2018            0.437158   0.321657           0.735790
9 2019            0.321657   0.283999           0.882926

A02: 'na fronteira em todos os anos' pelos escores contemporâneos
fase_a : na fronteira em todos os anos = China, India, Greece 
painel : na fronteira em todos os anos = China, Malaysia, South Korea 
qualidade : na fronteira em todos os anos = China, South Korea, Singapore, Greece 
inventor : na fronteira em todos os anos = India 
preqin : na fronteira em todos os anos = China, South Korea, Russia 
publico : na fronteira em todos os anos = China, South Korea 

A03 e A04: vereditos de H2 só com IC na direção prevista e ajuste válido
fase_a : cobb_douglas = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc88 = apoiada | painel_bc92 = apoiada 
painel : cobb_douglas = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc88 = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc92 = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) 
qualidade : cobb_douglas = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc88 = apoio parcial (efeito positivo em patentes; diferença entre canais não distinguível de zero) | painel_bc92 = apoio parcial (efeito positivo em patentes; diferença entre canais não distinguível de zero) 
inventor : cobb_douglas = apoiada | painel_bc88 = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc92 = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) 
preqin : cobb_douglas = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc88 = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc92 = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) 
publico : cobb_douglas = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc88 = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) | painel_bc92 = não apoiada (efeito em patentes e diferença entre canais não distinguíveis de zero) 
  ic_inf_patentes ic_inf_diferenca ic_sup_diferenca veredito
1       0.0781694      0.000793589          0.27705  apoiada
  convergiu inferencia_valida reinicio                                          mensagem
5      TRUE              TRUE     TRUE frontier, código 1 (após reinício do ponto final)

A05: retornos com IC por bootstrap de país e método identificado
Classificação de retornos coerente com os IC nas seis bases

A06: amostra do conjunto preservada na variante por inventor
linhas do conjunto = 217 | sem escore de patentes = 2 | H5: n = 154 | efetividade = -0.303397 

A07: bloco WGI com uma só cópia dos indicadores
fase_a : efetividade_governo diferentes = 191; controle_corrupcao diferentes = 191 
painel : efetividade_governo diferentes = 0; qualidade_regulatoria diferentes = 0; estado_direito diferentes = 0; controle_corrupcao diferentes = 0 
qualidade : efetividade_governo diferentes = 0; qualidade_regulatoria diferentes = 0; estado_direito diferentes = 0; controle_corrupcao diferentes = 0 
inventor : efetividade_governo diferentes = 0; qualidade_regulatoria diferentes = 0; estado_direito diferentes = 0; controle_corrupcao diferentes = 0 
preqin : efetividade_governo diferentes = 0; qualidade_regulatoria diferentes = 0; estado_direito diferentes = 0; controle_corrupcao diferentes = 0 
publico : efetividade_governo diferentes = 0; qualidade_regulatoria diferentes = 0; estado_direito diferentes = 0; controle_corrupcao diferentes = 0 

A08: checagem de patentes sem as observações suspeitas
                                serie_cset      rho   ic_inf   ic_sup   n n_blocos
1                      tratada (principal) 0.763286 0.622763 0.862170 299       63
2 bruta (inclui Índia 2019-2021, suspeita) 0.752926 0.611892 0.852036 302       63

A10 e A15: dispersão com bootstrap de países e IQR relativo
  escala  iqr iqr_relativo
1    1.0 0.30          0.6
2    0.5 0.15          0.6

A11: ε minúsculo não recupera os escores originais
     base         transformacao epsilon max_dif_vrs spearman_vrs_pais_ano
1  Fase A    unidades originais      NA 0.00000e+00              1.000000
2  Fase A escala pura (x / máx)      NA 1.48814e-12              1.000000
3  Fase A               min-max   1e-09 3.52986e-01              0.995916
4  Fase A               min-max   1e-06 3.52886e-01              0.995916
5  Fase A               min-max   1e-03 5.10731e-01              0.947656
10 Painel    unidades originais      NA 0.00000e+00              1.000000
11 Painel escala pura (x / máx)      NA 1.26976e-12              1.000000
12 Painel               min-max   1e-09 1.60769e-01              0.994906
13 Painel               min-max   1e-06 1.60668e-01              0.994931
14 Painel               min-max   1e-03 7.25614e-01              0.927471

A12: escore M2 nunca abaixo do M1 (propriedade da DEA)
Violações de M2 >= M1 nas seis bases: 0 

A13: tabelas e figuras do R/04 no manifesto, com MD5 atual
output/tables/malmquist_por_pais.csv : registrado por 04_figuras_apresentacao@20261004170002 
output/tables/dispersao_renda_ano_painel.csv : registrado por 04_figuras_apresentacao_painel@20261004170010 
output/figures/fig4_segundo_estagio.png : registrado por 04_figuras_apresentacao@20261004170002 
Entradas registradas do R/04 e do R/05b: 393 

VERIFICAÇÃO CONCLUÍDA
```
