# Análise crítica de inconsistências — terceira revisão

Revisão de **04/10/2026**, sobre o estado do projeto no commit `a1af12f`. Complementa [11_reanalise_critica_inconsistencias.md](11_reanalise_critica_inconsistencias.md) e [12_avaliacao_reanalise.md](12_avaliacao_reanalise.md), considerando também os acréscimos registrados nos documentos 14, 15 e 16. Foram identificadas **15 inconsistências**, reunidas neste documento, com evidências, impacto, correção proposta e critérios de verificação. As correções estão **propostas, não aplicadas**: esta entrega documenta a análise solicitada e preserva código, bases, resultados e apresentação existentes.

O problema prioritário é **A01**: a interpretação do Malmquist está invertida em relação à convenção efetivamente retornada por `Benchmarking` 0.33 com orientação a produto. Isso altera a interpretação econômica dos resultados de dinâmica. **A02** acrescenta um erro independente na classificação dos países que permaneceriam na fronteira.

## Quadro de achados

| ID | Prioridade | Inconsistência |
|---|---|---|
| [A01](#a01) | Crítica | Malmquist, mudança técnica e catch-up interpretados no sentido inverso |
| [A02](#a02) | Alta | Média de EC igual a 1 classificada como presença permanente na fronteira |
| [A03](#a03) | Alta | Significância em apenas um canal usada como evidência de exclusividade |
| [A04](#a04) | Alta | Veredito de H2 produzido apesar de ajuste pontual sem convergência |
| [A05](#a05) | Alta | Conclusões sobre retornos no SFA usam inferência diferente da adotada para as elasticidades |
| [A06](#a06) | Média | Exclusões do canal de patentes contaminam a amostra do modelo conjunto |
| [A07](#a07) | Média | Comparação de dimensões do WGI mistura cópias divergentes dos indicadores |
| [A08](#a08) | Média | Patentes suspeitas da Índia reaparecem na checagem entre fontes |
| [A09](#a09) | Média | Normal truncada do log do escore apresentada como transformação equivalente do modelo de Simar–Wilson |
| [A10](#a10) | Média | Teste da dispersão trata observações repetidas por país como independentes |
| [A11](#a11) | Média | Reduzir ε a zero não recupera necessariamente a DEA em unidades originais |
| [A12](#a12) | Média | Aumento mecânico do escore ao adicionar insumo usado como evidência do papel do P&D |
| [A13](#a13) | Média | Tabelas produzidas pelo script de figuras ficam fora do manifesto |
| [A14](#a14) | Alta | Gráfico e tabela do slide 12 representam especificações diferentes |
| [A15](#a15) | Média | IQR absoluto tratado como dispersão relativa comparável entre fronteiras anuais |

## Escopo e verificações

Foram examinados os scripts de preparação, importação, DEA, SFA, segundo estágio, comparações e figuras; hipóteses e documentos de resultados; revisões anteriores; bases e tabelas pertinentes; manifesto e runner. O texto das 20 páginas do PDF foi extraído, com inspeção visual das páginas 9–12, especialmente do slide 12. Não foi feita validação bibliográfica completa nem recálculo integral de todos os bootstraps.

As verificações incluíram exemplos controlados, recálculo determinístico do Malmquist nas seis bases em unidades originais, reestimação pontual de H5 na variante por inventor, comparação dos indicadores WGI, checagem de patentes suspeitas, sensibilidade de ε e conferência de hashes. O Malmquist reproduziu as tabelas existentes com diferença máxima inferior a `5e-15`: o problema A01 é de convenção/interpretação, não de arquivos que deixaram de reproduzir o código.

O script incluído no [Apêndice A](#apendice-a) reproduz as verificações numéricas principais sem gravar em `data/`, `R/` ou `output/`, sem baixar dados e sem instalar pacotes. A saída da execução feita nesta revisão está no [Apêndice B](#apendice-b). Para repetir, salve o bloco R do Apêndice A em `/tmp/verificar_achados.R` e execute, a partir da raiz do projeto:

```bash
Rscript --vanilla /tmp/verificar_achados.R
```

Os 15 achados distinguem erro demonstrado de alcance ainda não quantificado. Limitações já declaradas — como separabilidade não testada, ausência de bootstrap completo do Malmquist, cobertura parcial do TOP500 e diferenças entre universos de investimento — não foram reapresentadas como descobertas novas.

## Ordem recomendada para corrigir

1. Corrigir A01 e A02 e regenerar a dinâmica, as classificações e os textos dependentes.
2. Rever os critérios e a validade inferencial do SFA, A03–A05.
3. Corrigir seleção de amostra e consistência das fontes, A06–A08, antes de reexecutar o segundo estágio e as checagens.
4. Ajustar as interpretações metodológicas A09–A12 e A15.
5. Completar o manifesto A13 e, com os resultados finais estabilizados, substituir o gráfico do slide 12, A14.

Datas e números deste documento descrevem o estado auditado; não representam resultados finais após correção.

<a id="a01"></a>

## A01 — O sentido de melhora do Malmquist está invertido

**Prioridade:** crítica. **Estado:** confirmado por execução; correção proposta.

### Evidência

Em `R/02_fronteiras_dataset_atual.R:470`, `Benchmarking::malmquist` é chamado com `ORIENTATION = "out"`. As linhas seguintes exportam `m`, `tc` e `ec` diretamente. O script `R/04_figuras_apresentacao.R:95` e os documentos 01, 05, 06 e 16 interpretam valores acima de 1 como melhora. O slide 11 repete essa leitura.

Na versão instalada, `Benchmarking` 0.33, as distâncias retornadas são fatores de expansão de Farrell, e `ec = e11/e00`. Se a eficiência melhora, o fator de expansão diminui. Dois exemplos executados comprovam o sentido:

| Experimento | Retorno da função | Interpretação correta |
|---|---|---|
| Insumo constante, produção dobra de 1 para 2 | M = 0,5; TC = 0,5; EC = 1 | Produtividade e fronteira dobram |
| Fronteira fixa; unidade passa de produzir 0,5 para 1 | M = 0,5; TC = 1; EC = 0,5 | Unidade alcança a fronteira |

A convenção foi conferida no código da biblioteca instalada e na interface documentada pelo [manual do Benchmarking](https://cran.r-project.org/web/packages/Benchmarking/Benchmarking.pdf), seções `malmq` e `malmquist`.

Nos dados reais, a eficiência CRS do Brasil no painel balanceado da Fase A cai de **1,000 em 2016 para 0,284 em 2019**. O EC exportado é aproximadamente 1,52, chamado de catch-up no trabalho. Na convenção de melhora acima de 1, EC é aproximadamente **0,657**: afastamento da fronteira.

O recálculo das seis bases reproduziu os índices gravados com erro máximo inferior a `5e-15`.

### Impacto

A afirmação de que a fronteira recua em produtos por dólar e a identificação dos países que ganham por catch-up precisam ser revistas. Na média geral do painel, converter a convenção dá aproximadamente **M = 1,086; TC = 1,174; EC = 0,925**, em vez de 0,921; 0,852; 1,081.

Também muda o sinal da regressão de β-convergência: substituir `log(EC)` por `-log(EC)` inverte os coeficientes, preservando os p-valores do mesmo MQO. Por exemplo, a inclinação da variante por inventor passa de +0,1003 para −0,1003. Isso continua sendo evidência descritiva, sujeita às limitações já registradas.

A decomposição de variância de log M mantém suas parcelas quando os três logaritmos são simultaneamente negados; a direção econômica dos movimentos muda.

### Como resolver

1. Fixar explicitamente a convenção desejada: **índice maior que 1 = melhora**.
2. Na exportação de `R/02`, usar `1/malm$m`, `1/malm$tc` e `1/malm$ec`. Preservar as distâncias originais para conferência e classificação de fronteira.
3. Fazer a mesma conversão nos cálculos diretos de `R/05b_comparacao_padronizacao.R:581`. Evitar dupla inversão quando a comparação apenas lê tabelas já corrigidas.
4. Regenerar resumos, intervalos, β-convergência, classificações, figuras e comparações. Ao converter um intervalo já existente, a ordem é `[1/limite_superior; 1/limite_inferior]`; para resultados finais, repetir a agregação/bootstrap na convenção escolhida.
5. Rever RQ1, documentos 05, 06, 08, 14 e 16 e os slides 11, 14, 15 e 18. Revisões históricas devem receber uma nota de superação, preservando seu caráter de registro.

### Como verificar a correção

Os dois experimentos acima devem produzir índices de melhora iguais a 2. Deve valer `M = TC × EC` e `EC = escore_CRS_t / escore_CRS_t_anterior` no mesmo painel balanceado. O Brasil da Fase A deve ser classificado como afastamento, e não catch-up.

<a id="a02"></a>

## A02 — A classificação “sempre na fronteira” usa uma média que esconde a trajetória

**Prioridade:** alta. **Estado:** confirmado por execução; correção proposta.

### Evidência

Em `R/04_figuras_apresentacao.R:116`, o `summarise` substitui `mudanca_eficiencia` por sua média geométrica. Na expressão seguinte, `all(abs(mudanca_eficiencia - 1) < 1e-6)` recebe esse único número, e não os valores anuais.

Para a Argentina, na Fase A, os EC gravados são **2,3881804; 0,5181078; 0,8081887**. A média geométrica é 1 e o país aparece como “na fronteira: só deslocamento da fronteira”. Contudo, seu menor escore CRS no painel balanceado é **0,4187288**.

O mesmo erro afeta sete combinações de país e base nas unidades originais:

| Base | Países indevidamente marcados |
|---|---|
| Fase A | Argentina |
| Painel | Rússia |
| Patentes por inventor | Rússia, Japão, Malásia |
| Preqin | Turquia |
| P&D público | Rússia |

Há ainda um erro conceitual independente da sobrescrita: mesmo **EC = 1 em cada transição** só significa eficiência constante. Um país que permanece com escore 0,5 não está na fronteira.

### Impacto

As contagens e interpretações por país em `malmquist_por_pais*.csv`, `artigo/05`, `artigo/06` e `artigo/16` atribuem permanência na fronteira a países que tiveram períodos de ineficiência. Corrigir somente a orientação do Malmquist, A01, não resolve este problema.

### Como resolver

1. Exportar de `R/02` os escores CRS contemporâneos `1/e00` e `1/e11` calculados no mesmo painel balanceado do Malmquist.
2. Definir `sempre_na_fronteira` pela proximidade de **todos os escores contemporâneos** a 1, incluindo o primeiro ano, com tolerância explícita e sem dados faltantes.
3. Usar nomes diferentes para variáveis anuais e agregadas, como `ec_anual` e `ec_media_geometrica`, evitando sobrescrita dentro de `summarise`.
4. Se for útil, criar outra classificação para “eficiência constante”; não a confundir com estar na fronteira.
5. Regenerar as tabelas e a discussão por país após A01.

### Como verificar a correção

Uma trajetória com EC 2 e 0,5 não deve ser classificada como permanente na fronteira. Uma trajetória de escores 0,5; 0,5; 0,5 também não. Argentina na Fase A e Rússia no painel devem perder a classificação atual. China, com escores unitários nas bases correspondentes, deve mantê-la.

<a id="a03"></a>

## A03 — Significância em um canal não demonstra exclusividade do efeito

**Prioridade:** alta. **Estado:** inconsistência metodológica confirmada; correção proposta.

### Evidência

`artigo/01_hipoteses.md`, seção H2, propõe que o investimento privado importa para patentes e não para publicações. Em `R/06_sfa_canais.R:318`, H2 é considerada “apoiada” quando o intervalo de patentes exclui zero e o de publicações inclui zero. O contraste entre canais é calculado, mas não integra esse veredito.

Exemplo observado em `sfa_h2_painel_fonte.csv`, modelo agrupado:

| Quantidade | Estimativa | IC 95% |
|---|---|---|
| Elasticidade em publicações | 0,0608 | [−0,0420; 0,1481] |
| Elasticidade em patentes | 0,2138 | [0,0871; 0,3343] |
| Diferença patentes − publicações | 0,1530 | [−0,00105; 0,2772] |

A tabela informa `veredito_estrito = "apoiada"`, embora o próprio contraste não exclua zero. O intervalo de publicações admite efeitos positivos relevantes; ausência de significância não demonstra ausência de efeito. Esse é o problema formal discutido por [Gelman e Stern (2006)](https://stat.columbia.edu/~gelman/research/published/signif4.pdf).

### Impacto

A contagem de “2 de 18 combinações” não deve ser apresentada como duas confirmações da especificidade do investimento. A conclusão geral de que H2 não recebeu apoio robusto pode permanecer, mas o critério que sustenta as exceções é inadequado.

O código também aceita significância negativa em patentes como apoio, pois `Significativo` verifica qualquer intervalo que exclua zero. Isso não ocorreu nas duas linhas atualmente chamadas de apoiadas, mas a regra não exige a direção econômica proposta.

### Como resolver

Escolher e enunciar o alvo antes de reclassificar os resultados:

1. Para **especificidade relativa**, exigir diferença patentes − publicações positiva com intervalo acima de zero e, se a hipótese prevê contribuição positiva, elasticidade positiva em patentes.
2. Para **efeito praticamente ausente em publicações**, definir uma margem substantiva de equivalência e verificar se o intervalo adequado fica dentro dessa margem. Não escolher a margem para acomodar os resultados já observados.
3. Sem equivalência, substituir “sem efeito” por “efeito não distinguível de zero”. Tratar o padrão de significância de cada canal como descrição, sem convertê-lo em teste da diferença.
4. Reclassificar `sfa_h2*.csv` e atualizar os documentos 01 e 15. Resolver A04 antes de contar modelos válidos.

### Como verificar a correção

A linha agrupada por inventor não deve confirmar diferença positiva a 5% pelo IC 95% atualmente gravado. Modelos sem intervalo ou com efeito negativo em patentes não podem receber automaticamente o rótulo de apoio à hipótese positiva.

<a id="a04"></a>

## A04 — H2 recebe veredito mesmo quando o ajuste pontual não converge

**Prioridade:** alta. **Estado:** confirmado nas tabelas; correção proposta.

### Evidência

`R/06_sfa_canais.R:170` calcula `inferencia_valida`, mas o bloco de H2, nas linhas 308–347, não usa esse indicador. O bootstrap e os vereditos seguem para todos os modelos listados.

Em `sfa_canais_painel_preqin.csv`, publicações no modelo `painel_bc92` têm:

- `convergiu = FALSE`;
- `inferencia_valida = FALSE`;
- mensagem `frontier, código 5`;
- elasticidade do investimento 0,02770809.

Apesar disso, `sfa_h2_painel_preqin.csv` reproduz o ponto e informa “não apoiada (sem efeito nos dois canais)”, com 249 réplicas convergentes para a diferença. Essa combinação entra no total de 18 reportado no documento 15.

Além disso, `Significativo` transforma ausência de IC em `FALSE`. Assim, um canal sem inferência pode ser confundido com um efeito não significativo, inclusive permitindo “apoio” se o outro canal for significativo.

### Impacto

Réplicas que convergem não validam um ponto original sem convergência. “Não estimável” e “não significativo” são estados distintos. A tabela de vereditos deixa de respeitar o controle de qualidade que o próprio script implementou.

### Como resolver

1. Exigir ajuste pontual válido nos dois canais antes de emitir qualquer veredito de H2 ou interpretar a diferença.
2. Transportar para `sfa_h2` os indicadores de convergência e validade de cada canal e uma razão explícita de indisponibilidade.
3. Separar os estados `estimavel`, `sem_convergencia`, `replicas_insuficientes` e `inconclusivo`.
4. Definir uma exigência mínima de réplicas válidas e investigar falhas sistemáticas; não presumir que apenas descartar réplicas seja suficiente.
5. Tentar novo ajuste pontual com diagnóstico documentado. Se a falha persistir, retirar essa combinação do denominador de vereditos válidos e reportá-la separadamente.

### Como verificar a correção

A combinação Preqin/publicações/BC92 deve aparecer como não estimável enquanto persistir o código 5. Forçar um IC ausente deve produzir status de indisponibilidade, nunca “sem efeito” nem apoio à H2.

<a id="a05"></a>

## A05 — A inferência dos retornos no SFA não acompanha a dependência por país

**Prioridade:** alta. **Estado:** método confirmado no código; efeito sobre os novos intervalos ainda não quantificado.

### Evidência

O documento `artigo/15_sfa_canais.md` justifica bootstrap em blocos de país porque os erros-padrão da Hessiana do modelo agrupado não acomodam a repetição de países. Entretanto, sua seção 4 afirma que a soma das elasticidades difere de 1 em todos os 53 ajustes válidos, usando justamente os testes de Wald da Hessiana.

Em `R/06_sfa_canais.R:74`, `TesteRetornos` calcula o erro-padrão da soma com `vcov_m`. A função é chamada antes do bootstrap. `BootstrapPais` exporta intervalos para cada elasticidade e para a diferença entre canais, mas não para a soma das elasticidades dentro do canal.

No modelo principal agrupado, há, portanto, dois tratamentos da mesma dependência: as elasticidades individuais recebem bootstrap por país; a conclusão de retornos crescentes/decrescentes usa a inferência convencional. A necessidade de considerar agrupamentos na inferência é discutida por [Cameron e Miller (2015)](https://cameron.econ.ucdavis.edu/research/Cameron_Miller_JHR_2015_February.pdf).

### Impacto

Os valores pontuais das somas continuam sendo os calculados, mas a afirmação universal de significância e seu uso como evidência complementar de H1 não têm a mesma proteção inferencial adotada para H2. Não se demonstrou nesta revisão que todos esses resultados perderiam significância; isso exige recalcular os intervalos adequados.

Os modelos de painel representam dependência sob suas hipóteses específicas; o problema mais direto é o modelo agrupado, apresentado como principal.

### Como resolver

1. Em cada réplica já usada no bootstrap, calcular `retornos = beta_investimento + beta_pd` para cada canal. Isso preserva a covariância entre as duas estimativas.
2. Exportar o ponto, IC por país, número de réplicas e status de validade para essa soma. Não somar os limites dos intervalos individuais.
3. Basear a leitura de retornos abaixo/acima de 1 no intervalo da soma, sujeito aos mesmos controles de convergência de A04.
4. Manter o Wald da Hessiana como diagnóstico identificado, se útil, e reescrever a frase “sempre com p < 0,05” após a comparação.

### Como verificar a correção

As tabelas devem identificar o método de inferência de cada conclusão. Retornos só devem ser classificados como inferiores ou superiores a 1 com evidência inferencial quando o intervalo correspondente exclui 1. Modelos inválidos ficam fora da classificação.

<a id="a06"></a>

## A06 — Exclusões de um canal alteram indevidamente o segundo estágio conjunto

**Prioridade:** média. **Estado:** confirmado por reestimação pontual; correção proposta.

### Evidência

Em `R/03_segundo_estagio_dataset_atual.R:162`, `dados` é substituído pela interseção com os bootstraps de publicações e patentes. Como o canal de patentes exclui produto zero, essas observações desaparecem também das regressões conjuntas de H5, do Tobit e das comparações WGI.

Na variante por inventor, **CHL-2017 e BGR-2018** têm zero patente, mas publicações, insumos e contexto válidos. Estão entre as 217 observações da DEA conjunta, porém desaparecem de `escores_bc_conjunto_e_canais_painel_fonte.csv`, que tem 215 linhas.

Reestimando H5 com os mesmos escores conjuntos e covariáveis:

| Amostra | Observações completas | Coeficiente de efetividade |
|---|---|---|
| Conjunto antes da interseção dos canais | 154 | −0,3033973 |
| Interseção dos canais, como no script atual | 152 | −0,2876400 |

Ambas as observações excluídas têm contexto completo. Não se trata, portanto, da seleção de casos completos da própria fórmula.

### Impacto

A amostra de uma regressão sobre eficiência conjunta passa a depender da viabilidade de um modelo que não é seu objeto. H5 sem piso é construído separadamente a partir da base e não sofre exatamente o mesmo filtro, dificultando atribuir diferenças apenas à retirada do piso.

### Como resolver

Preservar `dados_conjunto` antes das junções. Fazer `left_join` dos canais, deixando seus escores ausentes onde não são definidos. Cada regressão deve selecionar casos completos apenas das variáveis que usa; comparações entre canais podem ter uma amostra comum explícita e separada. Reexecutar o segundo estágio da variante afetada e as saídas dependentes.

### Como verificar a correção

H5 principal por inventor deve ter 154 casos completos na base auditada. CHL-2017 e BGR-2018 permanecem no conjunto e continuam excluídos do canal de patentes. Mudanças de intervalos e significância exigem novo bootstrap; não foram estimadas nesta revisão.

<a id="a07"></a>

## A07 — O bloco WGI da Fase A mistura cópias divergentes dos indicadores

**Prioridade:** média. **Estado:** divergência numérica confirmada; origem exata das diferenças não determinada.

### Evidência

`R/01_prep_dataset_atual.R` mantém efetividade governamental e controle da corrupção do dataset original. Em `R/03_segundo_estagio_dataset_atual.R:312`, apenas dimensões ausentes são buscadas no cache WGI. Na Fase A, qualidade regulatória e estado de direito vêm do cache, enquanto as outras duas dimensões permanecem na cópia original.

A comparação pela mesma chave ISO3/ano mostra divergências em **todas as 208 observações**:

| Indicador | Maior diferença absoluta entre base original e cache |
|---|---|
| Efetividade governamental | 0,5252298 |
| Controle da corrupção | 0,3047194 |

O índice composto calculado em `R/03:317` faz a média dessas quatro colunas heterogêneas em proveniência. A correlação elevada entre as cópias não elimina suas diferenças.

### Impacto

O exercício de trocar uma dimensão pela outra não varia apenas o conceito institucional: também muda a cópia dos dados. Não é possível atribuir integralmente as diferenças de coeficientes à dimensão do WGI. Esta revisão não presume qual cópia é a correta nem que as diferenças sejam exclusivamente revisão histórica do fornecedor.

### Como resolver

1. Preservar os indicadores originais em colunas explicitamente identificadas, para manter a replicação da Fase A.
2. Para a comparação das dimensões e o índice composto, carregar as quatro dimensões do mesmo conjunto WGI, com data de obtenção e proveniência registradas.
3. Reestimar também a referência de efetividade governamental nessa cópia comum e na mesma amostra; não compará-la silenciosamente com a referência original.
4. Reportar uma sensibilidade original × cache para separar mudança de fonte/cópia de mudança de dimensão.

### Como verificar a correção

As quatro dimensões utilizadas no exercício harmonizado devem coincidir, chave a chave, com seus respectivos arquivos de origem declarados. O índice composto deve ser calculado apenas dessas colunas harmonizadas. As regressões originais podem permanecer, desde que identificadas como outra especificação de dados.

<a id="a08"></a>

## A08 — A checagem entre fontes reutiliza patentes que o projeto rejeitou

**Prioridade:** média. **Estado:** confirmado nos dados; correção proposta.

### Evidência

`R/11_import_cset.R` marca as patentes da Índia a partir de 2019 como suspeitas e define `patentes = NA`. Entretanto, `R/12_import_fontes_alternativas.R:281` monta a comparação com a OCDE a partir de `patentes_pedidos`, a coluna bruta, filtrando apenas a flag de completude do fornecedor.

Em `checagem_patentes_cset_vs_oecd.csv` reaparecem:

| País/ano | CSET bruto | OCDE por inventor | Patentes tratadas no painel |
|---|---|---|---|
| IND-2019 | 12 | 303,4030 | NA |
| IND-2020 | 12 | 409,5460 | NA |
| IND-2021 | 6 | 475,9855 | NA |

Excluir essas três linhas altera a correlação pontual de Spearman de **0,7529258 para 0,7632863**, e o número de pares passa de 302 para 299.

### Impacto

A comparação usada para avaliar concordância entre fontes não respeita o tratamento de qualidade adotado na análise principal. A média e a razão CSET/OCDE da Índia são particularmente afetadas.

### Como resolver

Usar a coluna tratada `patentes` e excluir valores ausentes na comparação principal, ou aplicar explicitamente `!patentes_suspeitas`. Se a intenção for diagnosticar a quebra, manter uma comparação bruta separada e rotulada. Regenerar resumo por país, IC por bootstrap, figura 9 e referências numéricas em `artigo/06` e no deck.

### Como verificar a correção

A comparação principal deve conter 299 pares na base auditada e nenhuma linha marcada como suspeita. A correlação pontual deve ser aproximadamente 0,7632863. O IC precisa ser recalculado; não basta conservar os limites do cálculo anterior.

<a id="a09"></a>

## A09 — Transformar o escore não preserva o modelo probabilístico de Simar–Wilson

**Prioridade:** média. **Estado:** inconsistência de especificação e descrição confirmada.

### Evidência

`artigo/01_hipoteses.md:176` e `R/funcoes.R:388` descrevem a regressão normal truncada de `log(escore)` como o modelo de Simar e Wilson (2007) aplicado a uma transformação monótona da medida de Farrell.

O código ajusta uma **normal truncada à direita em zero** para `log(s)`. No procedimento de referência, a regressão se refere à medida `F = 1/s`, no suporte a partir de 1, conforme o [manual do rDEA, seção dea.env.robust](https://cran.r-project.org/web/packages/rDEA/rDEA.pdf). Se F tem distribuição normal truncada, `log(s) = −log(F)` não tem distribuição normal truncada. A transformação altera a densidade, sua forma e o jacobiano; ser monótona não torna equivalentes esses modelos probabilísticos.

O projeto já informa corretamente que o bootstrap da regressão principal mantém escores fixos. O problema adicional aqui é atribuir equivalência probabilística à mudança de escala.

### Impacto

Suporte compatível e convergência numérica são vantagens práticas, mas não transferem automaticamente a fundamentação inferencial do procedimento original. Também exige cuidado a descrição do coeficiente como semi-elasticidade direta do escore observado: numa regressão truncada, a média condicional contém a correção da truncagem.

### Como resolver

1. Descrever a principal como **regressão normal truncada do log do escore, com bootstrap por país e escores fixos**, uma especificação exploratória própria.
2. Explicar a hipótese distributiva escolhida, sua adequação empírica e suas limitações. Manter o algoritmo 2 do rDEA claramente separado.
3. Trocar a afirmação de equivalência por uma motivação de suporte e estabilidade, sem atribuir à transformação garantias não demonstradas.
4. Se forem reportados efeitos marginais no escore ou em sua média condicional, calculá-los a partir da distribuição truncada ajustada, com incerteza, em vez de equipará-los automaticamente ao coeficiente.

### Como verificar a correção

Texto, comentários e tabelas devem identificar a distribuição e o procedimento efetivamente empregados. O sinal do coeficiente pode ser usado na leitura direcional apropriada; sua magnitude não deve ser anunciada como efeito percentual direto sem explicitar o alvo e calcular o efeito correspondente.

<a id="a10"></a>

## A10 — O teste da dispersão ignora a repetição dos países

**Prioridade:** média. **Estado:** confirmado no código e nas amostras.

### Evidência

Em `R/04_figuras_apresentacao.R:263`, o teste `wilcox.test(desvio ~ periodo)` compara desvios país-ano entre metades do período como se fossem duas amostras independentes. Os mesmos países estão presentes em ambas:

| Base/grupo | Linhas usadas | Países distintos | Países nas duas metades |
|---|---|---|---|
| Fase A, alta renda | 132 | 24 | 19 |
| Fase A, renda média-alta | 50 | 10 | 7 |
| Painel, alta renda | 159 | 35 | 33 |
| Painel, renda média-alta | 43 | 11 | 9 |

O segundo estágio já trata a repetição por país por meio de blocos, mas este novo bloco S08 não a incorpora. O problema de inferência com observações agrupadas é discutido por [Cameron e Miller (2015)](https://cameron.econ.ucdavis.edu/research/Cameron_Miller_JHR_2015_February.pdf).

### Impacto

Os p-valores de `p_mann_whitney_desvios` não representam uma comparação que respeite a estrutura longitudinal observada. Chamá-los de exploratórios limita a interpretação, mas não corrige a hipótese de independência.

O comentário também chama o procedimento de versão não paramétrica de Brown–Forsythe. O cálculo executado é uma comparação por postos das distribuições de desvios absolutos; essa distinção deve constar do texto.

### Como resolver

Definir o alvo — por exemplo, diferença do desvio absoluto mediano entre metades — e obter sua incerteza reamostrando trajetórias completas por país, recalculando as medianas anuais e os desvios em cada réplica. Como sensibilidade, comparar resumos por país em painel comum, respeitando o pareamento. Se as fronteiras não forem reestimadas, explicitar que o resultado permanece condicional aos escores existentes.

Com apenas cinco anos no painel, tratar também as regressões anuais de CV/IQR como descrições de tendência, sem transformar ausência de significância em prova de estabilidade.

### Como verificar a correção

O sorteio deve levar todos os anos de um país conjuntamente. Os metadados precisam informar número de países, alvo e método. As tabelas e o documento 16 devem substituir os p-valores e a nomenclatura atuais após a reestimação.

<a id="a11"></a>

## A11 — Fazer ε tender a zero não elimina a translação min-max

**Prioridade:** média. **Estado:** confirmado algebricamente e por recálculo.

### Evidência

`artigo/14_padronizacao_minmax.md:144` afirma que, com ε tendendo a zero, a DEA min-max VRS se aproxima da versão original. A fórmula implementada é:

```text
z = ε + (1 − ε) × (x − mínimo) / (máximo − mínimo)
```

No limite, obtém-se `(x − mínimo)/(máximo − mínimo)`. A subtração do mínimo permanece. Se o mínimo dos produtos é positivo, isso não equivale a uma simples mudança de unidade e pode alterar o escore radial orientado a produto, mesmo sob VRS.

Recalculando as DEA anuais, com a mesma amostra e os mesmos parâmetros de referência:

| Base | ε | Maior diferença absoluta para o escore original |
|---|---|---|
| Fase A | 0,000001 | 0,3528856 |
| Fase A | 0,000000001 | 0,3529861 |
| Painel | 0,000001 | 0,1606677 |
| Painel | 0,000000001 | 0,1607688 |

Correlação elevada de postos não significa igualdade dos escores. A redução de ε testada no documento não demonstra o limite alegado.

### Impacto

O argumento de que a especificação original seria recuperada ao reduzir o piso é incorreto em geral e não se verifica nestes dados. A decisão de usar unidades originais como principal continua defensável; sua justificativa deve distinguir escala pura de translação.

### Como resolver

Substituir a afirmação por: “ε menor reduz a parcela de deslocamento introduzida pelo piso, mas permanece a subtração do mínimo; a aproximação à DEA original não é garantida”. Para uma transformação que preserve unidades sem translação, usar divisão por uma constante positiva, como `x/máximo`, já testada pelo projeto.

### Como verificar a correção

Manter uma checagem de invariância por escala pura e uma checagem separada de sensibilidade a ε. O texto deve refletir as diferenças absolutas, além das correlações, e não prometer convergência dos escores originais quando ε tende a zero.

<a id="a12"></a>

## A12 — O aumento do escore após adicionar GERD é mecânico

**Prioridade:** média. **Estado:** inconsistência de interpretação confirmada.

### Evidência

`artigo/15_sfa_canais.md:131` usa o aumento da eficiência média de M1 para M2 como coerência adicional para a conclusão de que P&D é o insumo que importa. O slide 14 apresenta esse aumento como evidência de H2.

Os modelos de `R/02_fronteiras_dataset_atual.R` usam a mesma amostra e produtos; M2 acrescenta GERD às restrições de insumos. Na DEA orientada a produto, isso restringe as combinações de referência admissíveis: o máximo fator de expansão não aumenta e o escore `1/F` não diminui. A propriedade vale independentemente de o novo insumo ser substantivamente relevante.

Na Fase A, as **191 observações** obedecem a `escore_M2 >= escore_M1`, dentro da tolerância numérica. Esse resultado não é um teste de relevância do GERD.

### Impacto

A elevação dos escores pode refletir apenas a menor capacidade discriminatória de uma DEA com mais dimensões. Ela não demonstra contribuição produtiva nem complementaridade dos insumos. O SFA oferece outro tipo de evidência, sujeito a A03–A05, e deve ser discutido por seus próprios resultados.

### Como resolver

Reescrever a comparação M1/M2 como efeito da inclusão de uma restrição/insumo e da especificação tecnológica. Justificar GERD pela teoria e pela mensuração, e avaliar sua contribuição com procedimentos explicitamente adequados ao alvo, sem interpretar o aumento do escore como confirmação. Se for desejado um teste de relevância em DEA, selecionar e validar um procedimento próprio para isso antes de apresentar significância.

### Como verificar a correção

Os textos devem distinguir “o escore subiu ao adicionar o insumo” de “o insumo contribui para o produto”. A desigualdade observada pode permanecer como diagnóstico de consistência da DEA, mas deixa de ser usada como evidência empírica independente para H2.

<a id="a13"></a>

## A13 — Tabelas do script de figuras não entram no manifesto

**Prioridade:** média. **Estado:** confirmado por conferência dos registros.

### Evidência

`R/04_figuras_apresentacao.R` grava, entre outras, `ranking_paises_m2`, `malmquist_por_pais`, `dispersao_renda_ano` e `dispersao_renda_tendencia` usando `SalvarTabela`. Porém, termina em `Registrar("FIM figuras Fase A")` e não chama `RegistrarManifesto`.

O registro de `SalvarTabela` fica no ambiente em memória `.registro_saidas`; ele só é persistido quando `RegistrarManifesto` é chamado. Como cada etapa do runner usa um processo `Rscript` separado, o registro de R/04 se perde ao terminar.

No estado auditado, por exemplo, `output/tables/malmquist_por_pais.csv` e `output/tables/dispersao_renda_ano_painel.csv` não têm linha em `manifesto_saidas.csv`. O README afirma que cada execução e suas tabelas ficam registradas.

Os últimos hashes dos arquivos efetivamente registrados foram conferidos e **não apresentaram divergências**. O achado é de cobertura do mecanismo, não evidência de adulteração ou mistura já demonstrada nesses arquivos.

### Impacto

As novas tabelas S06/S08 e o ranking derivado não têm a rastreabilidade prometida. Um status “OK” no runner não informa quais versões dos CSVs de entrada foram usadas nas figuras e tabelas derivadas.

### Como resolver

1. Registrar a execução de R/04 e persistir sua lista de saídas antes de terminar.
2. Registrar também os hashes dos CSVs lidos por R/04, pois sua entrada efetiva são tabelas derivadas, não apenas a base bruta.
3. Se a promessa de cobertura incluir imagens, ampliar o registro para os PNGs gerados por `SalvarFigura`; hoje a função não os registra.
4. Delimitar no README quais etapas são cobertas. Scripts de preparação e importação também precisam de registro se a intenção for rastrear o pipeline inteiro.

### Como verificar a correção

Após uma execução de R/04, suas tabelas e, se incluídas no escopo, figuras devem ter `id_execucao` e hash atuais. Os hashes dos insumos devem permitir ligar a figura à versão dos resultados que ela representa.

<a id="a14"></a>

## A14 — O slide 12 combina gráfico em escore com tabela em log do escore

**Prioridade:** alta. **Estado:** confirmado por extração de texto e inspeção visual do PDF.

### Evidência

Na página 12 de `AI Effiency Analysis.pdf`:

- a tabela e a nota à direita apresentam a dependente **log do escore**, com efetividade governamental **−0,58 [−1,31; 0,02]**, sem evidência a 5%;
- o gráfico à esquerda informa no título e no eixo que a dependente é **eficiência corrigida em (0,1]**;
- o ponto de efetividade do modelo conjunto está próximo de **−0,137** e é destacado como significativo pela legenda `IC 95% exclui zero`.

São os dois modelos que o próprio slide distingue na nota de comparação. A figura embutida é da especificação anterior, enquanto a tabela descreve a principal em log.

`artigo/07_registro_de_trabalho.md` informa que o PDF contém as sete figuras da revisão 3, mas a inspeção da página 12 não confirma isso para a figura do segundo estágio. O texto das 20 páginas pôde ser extraído com PyMuPDF nesta revisão.

### Impacto

O slide transmite simultaneamente duas conclusões sobre significância e duas escalas de coeficiente sem identificar o gráfico como comparação. Esta é uma inconsistência interna da página, não apenas a ausência no deck das análises acrescentadas em outubro.

### Como resolver

1. Substituir a imagem embutida pela figura 4 correspondente à especificação principal e à execução escolhida.
2. Conferir coeficientes, limites, escala e legenda contra a mesma tabela que fornece o quadro à direita.
3. Identificar a data/versão da apresentação. Se o deck histórico de setembro precisar ser preservado, criar uma versão corrigida e registrar a errata, em vez de alterar silenciosamente o registro histórico.
4. Atualizar a declaração de conferência no documento 07. Atualizações posteriores de H2 e RQ1/RQ2 são outra questão de versão; a mistura dentro do slide deve ser corrigida mesmo no deck histórico.

### Como verificar a correção

Renderizar novamente a página 12 do PDF final, não apenas conferir o PNG solto. Título, eixo, tabela e nota devem usar log do escore, e o intervalo de efetividade do modelo conjunto deve cruzar zero na versão atualmente citada. Incorporar também os resultados corrigidos dos demais achados quando a nova apresentação for atualizada.

<a id="a15"></a>

## A15 — IQR absoluto é chamado de dispersão relativa e presumido comparável entre anos

**Prioridade:** média. **Estado:** inconsistência matemática e interpretativa confirmada.

### Evidência

`R/04_figuras_apresentacao.R:234` e `artigo/16_acrescimos_s06_s07_s08.md:130` afirmam que apenas a dispersão relativa “CV, IQR” pode ser comparada entre fronteiras anuais. Entretanto, o cálculo é `stats::IQR(escore_bc)`, sem normalização.

O IQR é uma dispersão **absoluta**. Para uma constante positiva c:

```text
IQR(c × escore) = c × IQR(escore)
CV(c × escore) = CV(escore)
```

Por exemplo, multiplicar todos os escores 0,2; 0,4; 0,6; 0,8 por 0,5 reduz o IQR de 0,3 para 0,15, embora preserve todas as proporções. Além disso, fronteiras anuais distintas podem alterar os escores de forma não proporcional; nem mesmo o CV elimina automaticamente esse efeito.

### Impacto

As tendências de IQR podem ser descritas como variação da dispersão dos escores contemporâneos, mas não como medida relativa imune à mudança de referência. A frase atual oferece uma justificativa de comparabilidade que as estatísticas não asseguram.

### Como resolver

1. Rotular IQR como dispersão absoluta do escore e CV como dispersão relativa à média.
2. Se houver interesse em uma medida interquartil relativa, definir explicitamente uma normalização, por exemplo IQR/mediana quando a mediana for positiva. Isso não corrige, por si só, mudanças não proporcionais de fronteira.
3. Para estudar alteração temporal comparável da heterogeneidade, acrescentar uma análise em amostra estável e tecnologia de referência comum, deixando claro que é outro objeto em relação às fronteiras contemporâneas.
4. Enquanto essa análise não for feita, restringir a conclusão à dispersão observada em cada referência anual, com a ressalva de composição e referência tecnológica. Resolver separadamente o problema inferencial de A10.

### Como verificar a correção

Um exemplo de multiplicação uniforme deve alterar o IQR e preservar o CV. Os textos não devem apresentar IQR como relativo nem qualquer dessas medidas como automaticamente comparável entre tecnologias anuais diferentes.

<a id="apendice-a"></a>

## Apêndice A — Script de verificação

Conteúdo integral do script de verificação, com o caminho de execução adaptado à consolidação neste Markdown. Requer execução a partir da raiz do projeto e os pacotes já instalados.

```r
# Verificações da auditoria de 04/10/2026.
# Executar da raiz: Rscript --vanilla /tmp/verificar_achados.R
# Apenas lê arquivos e imprime evidências. Não executa o pipeline, não
# instala pacotes e não grava resultados nos diretórios da análise.

necessarios <- c("Benchmarking", "dplyr", "truncreg")
stopifnot(all(vapply(necessarios, requireNamespace, logical(1), quietly = TRUE)))
source("R/funcoes.R")
options(digits = 9, width = 120)

Secao <- function(titulo) cat("\n", titulo, "\n", sep = "")
Ler <- function(nome, sufixo = "") {
  read.csv(paste0("output/tables/", nome, sufixo, ".csv"))
}

Secao("AMBIENTE")
cat(R.version.string, "\n")
for (p in necessarios) cat(p, as.character(utils::packageVersion(p)), "\n")
cat("Data da auditoria: 2026-10-04; estado analisado: a1af12f\n")

Secao("A01: exemplos controlados da orientação do Malmquist")
x <- matrix(1, 1, 1)
m <- Benchmarking::malmq(x, x, X1 = x, Y1 = 2 * x,
                         RTS = "crs", ORIENTATION = "out")
print(unlist(m[c("m", "tc", "ec")]))
stopifnot(abs(m$m - 0.5) < 1e-10, abs(m$tc - 0.5) < 1e-10)
x <- matrix(c(1, 1), 2, 1)
m <- Benchmarking::malmq(x, matrix(c(1, 0.5), 2, 1), X1 = x, Y1 = x,
                         RTS = "crs", ORIENTATION = "out")
print(data.frame(unidade = c("referencia", "alcanca_fronteira"),
                 M = m$m, TC = m$tc, EC = m$ec, e00 = m$e00, e11 = m$e11))
stopifnot(abs(m$ec[2] - 0.5) < 1e-10)

variantes <- list(
  fase_a = list("", "base_atual", c("investimento", "gerd"),
                 c("publicacoes", "patentes"), 2016:2019),
  painel = list("_painel", "painel_ia", c("investimento_l1", "gerd_l1"),
                 c("publicacoes", "patentes"), 2017:2021),
  qualidade = list("_painel_qualidade", "painel_ia",
                    c("investimento_l1", "gerd_l1"),
                    c("citacoes_ok", "patentes_concedidas_ok"), 2017:2019),
  inventor = list("_painel_fonte", "painel_ia",
                   c("investimento_l1", "gerd_l1"),
                   c("publicacoes", "patentes_inventor"), 2017:2021),
  preqin = list("_painel_preqin", "painel_ia",
                 c("investimento_preqin_l1", "gerd_l1"),
                 c("publicacoes", "patentes"), 2017:2021),
  publico = list("_painel_publico", "painel_ia",
                  c("investimento_l1", "pd_publico_l1"),
                  c("publicacoes", "patentes"), 2017:2021))

Secao("A01/A02: reprodução das seis bases e falsos rótulos de fronteira")
falsos <- list()
for (nome in names(variantes)) {
  v <- variantes[[nome]]
  d <- read.csv(paste0("data/processed/", v[[2]], ".csv"))
  d <- d[complete.cases(d[, c(v[[3]], v[[4]])]) &
           d[[v[[3]][1]]] > 0 & d$ano %in% v[[5]], ]
  contagem <- table(d$pais)
  d <- d[d$pais %in% names(contagem[contagem == length(v[[5]])]), ]
  d <- d[order(d$pais, d$ano), ]
  invisible(capture.output(m <- Benchmarking::malmquist(
    as.matrix(d[, v[[3]]]) / 1e6, as.matrix(d[, v[[4]]]),
    ID = d$pais, TIME = d$ano, RTS = "crs", ORIENTATION = "out")))
  gravado <- Ler("malmquist_m2", v[[1]])
  idx <- match(paste(gravado$pais, gravado$ano), paste(m$id, m$time))
  erro <- max(abs(gravado$malmquist - m$m[idx]))
  cat(nome, ": diferença máxima contra CSV =", erro, "\n")
  stopifnot(erro < 1e-10)
  escore <- 1 / m$e11 # Inclui o primeiro ano, preenchido pela biblioteca.
  resumo <- Ler("malmquist_por_pais", v[[1]])
  marcados <- resumo$pais[resumo$sempre_na_fronteira]
  diagnostico <- data.frame(
    base = nome, pais = marcados,
    menor_escore = vapply(marcados, function(p) min(escore[m$id == p]),
                           numeric(1)))
  falsos[[nome]] <- diagnostico[diagnostico$menor_escore < 1 - 1e-6, ]
  if (nome %in% c("fase_a", "painel")) {
    cat("Brasil: escore contemporâneo no painel balanceado\n")
    print(data.frame(ano = m$time, escore = escore, EC_bruto = m$ec)[
      m$id == "Brazil", ])
    s <- Ler("malmquist_resumo", v[[1]])
    print(data.frame(grupo = s$grupo_renda2, M_convertido = 1 / s$malmquist,
                       TC_convertido = 1 / s$mudanca_tecnica,
                       EC_convertido = 1 / s$mudanca_eficiencia))
  }
}
falsos <- do.call(rbind, falsos)
rownames(falsos) <- NULL
print(falsos)
stopifnot(nrow(falsos) == 7)
cat("Sobrescrita no summarise: EC = 2 e 0,5\n")
d <- data.frame(mudanca_eficiencia = c(2, 0.5))
print(dplyr::summarise(d,
  mudanca_eficiencia = MediaGeometrica(mudanca_eficiencia),
  sempre_na_fronteira = all(abs(mudanca_eficiencia - 1) < 1e-6)))

Secao("A03: apoio estrito sem diferença entre canais distinguível de zero")
h <- Ler("sfa_h2", "_painel_fonte")
print(h[h$modelo == "cobb_douglas",
        c("modelo", "ic_inf_diferenca", "ic_sup_diferenca",
          "veredito_estrito", "especificidade_relativa")])

Secao("A04: H2 apesar de ajuste pontual inválido")
s <- Ler("sfa_canais", "_painel_preqin")
print(s[s$canal == "publicacoes" & s$modelo == "painel_bc92",
        c("canal", "modelo", "convergiu", "inferencia_valida", "mensagem")])
h <- Ler("sfa_h2", "_painel_preqin")
print(h[h$modelo == "painel_bc92",
        c("modelo", "veredito_estrito", "replicas_convergentes_diferenca")])

Secao("A06: exclusões do modelo conjunto e reestimação pontual de H5")
b <- read.csv("data/processed/painel_ia.csv")
e <- Ler("boot_ano_m2", "_painel_fonte")
canais <- Ler("escores_bc_conjunto_e_canais", "_painel_fonte")
removidos <- setdiff(e$id, canais$id)
print(removidos)
stopifnot(setequal(removidos, c("CHL-2017", "BGR-2018")))
d <- merge(b, e[, c("id", "escore_bc")], by = "id", sort = FALSE)
d$log_escore_bc <- log(d$escore_bc)
d$ano_f <- factor(d$ano)
f <- log_escore_bc ~ efetividade_governo + alta_tec_export + log_comercio +
  market_cap + credito_privado + ano_f
d <- d[complete.cases(d[, all.vars(f)]), ]
inteiro <- AjustarTruncada(f, d)
restrito <- AjustarTruncada(f, d[!d$id %in% removidos, ])
stopifnot(inteiro$convergiu, restrito$convergiu)
print(data.frame(amostra = c("conjunto", "intersecao_canais"),
                 n = c(nrow(d), sum(!d$id %in% removidos)),
                 beta_efetividade = c(inteiro$coeficientes["efetividade_governo"],
                                       restrito$coeficientes["efetividade_governo"])))

Secao("A07: diferenças entre indicadores da Fase A e cache WGI")
b <- read.csv("data/processed/base_atual.csv")
codigos <- c(efetividade_governo = "GOV_WGI_GE.EST",
              controle_corrupcao = "GOV_WGI_CC.EST")
for (v in names(codigos)) {
  w <- read.csv(paste0("data/wgi/", codigos[[v]], ".csv"))
  idx <- match(b$id, paste(w$iso3c, w$ano, sep = "-"))
  dif <- b[[v]] - w$valor[idx]
  cat(v, ": máximo absoluto =", max(abs(dif)),
      "; diferenças > 1e-6 =", sum(abs(dif) > 1e-6), "\n")
}

Secao("A08: observações suspeitas na checagem de patentes")
c <- Ler("checagem_patentes_cset_vs_oecd")
b <- read.csv("data/processed/cset_long.csv")
d <- merge(c, b[, c("iso3c", "ano", "patentes", "patentes_suspeitas")],
            by = c("iso3c", "ano"))
print(d[d$patentes_suspeitas,
        c("iso3c", "ano", "patentes_cset", "patentes_inventor", "patentes")])
ok <- !d$patentes_suspeitas
cat("Pares atuais:", nrow(d), "; tratados:", sum(ok), "\n")
cat("rho atual =", cor(c$patentes_cset, c$patentes_inventor, method = "spearman"),
    "; tratado =", cor(d$patentes_cset[ok], d$patentes_inventor[ok],
                         method = "spearman"), "\n")

Secao("A10: países repetidos entre as duas metades")
for (s in c("", "_painel")) {
  b <- Ler("boot_ano_m2", s)
  for (g in c("Alta renda", "Renda média-alta")) {
    d <- b[b$grupo_renda == g, ]
    freq <- table(d$ano)
    anos <- as.numeric(names(freq[freq >= 3]))
    d <- d[d$ano %in% anos, ]
    corte <- median(anos)
    comuns <- intersect(d$pais[d$ano <= corte], d$pais[d$ano > corte])
    cat(s, g, ": linhas =", nrow(d), "; países =", length(unique(d$pais)),
        "; em ambas as metades =", length(comuns), "\n")
  }
}

Secao("A11: ε muito pequeno não recupera escores originais")
for (nome in c("base_atual", "painel_ia")) {
  b <- read.csv(paste0("data/processed/", nome, ".csv"))
  ins <- if (nome == "base_atual") c("investimento", "gerd") else
    c("investimento_l1", "gerd_l1")
  prod <- c("publicacoes", "patentes")
  b <- b[complete.cases(b[, c(ins, prod)]), ]
  a <- b[b[[ins[1]]] > 0, ]
  Calcular <- function(par) {
    unlist(lapply(sort(unique(a$ano)), function(ano) {
      d <- a[a$ano == ano, ]
      1 / as.numeric(Benchmarking::dea(
        MatrizFronteira(d, ins, par, 1e6), MatrizFronteira(d, prod, par),
        RTS = "vrs", ORIENTATION = "out", FAST = TRUE))
    }))
  }
  ref <- Calcular(NULL)
  for (eps in c(1e-6, 1e-9)) {
    par <- ParametrosPadronizacao(b, c(ins, prod),
                                  list(metodo = "minmax", epsilon = eps))
    cat(nome, ": epsilon =", eps, "; diferença máxima =",
        max(abs(ref - Calcular(par))), "\n")
  }
}

Secao("A12: aumento mecânico dos escores com insumo adicional")
a <- Ler("dea_ano_m1")
b <- Ler("dea_ano_m2")
idx <- match(a$id, b$id)
cat("Violações de M2 >= M1:", sum(b$escore_vrs[idx] < a$escore_vrs - 1e-8),
    "em", nrow(a), "observações\n")

Secao("A13: cobertura do manifesto e integridade das saídas registradas")
reg <- Ler("manifesto_saidas")
for (arquivo in c("output/tables/malmquist_por_pais.csv",
                   "output/tables/dispersao_renda_ano_painel.csv")) {
  cat(arquivo, ": registrado =", arquivo %in% reg$arquivo, "\n")
}
ultimos <- reg[!duplicated(reg$arquivo, fromLast = TRUE), ]
presentes <- file.exists(ultimos$arquivo)
hashes <- unname(tools::md5sum(ultimos$arquivo[presentes]))
cat("Arquivos registrados ausentes =", sum(!presentes),
    "; últimos hashes divergentes =", sum(hashes != ultimos$md5[presentes]), "\n")

Secao("A15: IQR absoluto versus CV")
x <- c(0.2, 0.4, 0.6, 0.8)
print(data.frame(escala = c(1, 0.5), iqr = c(IQR(x), IQR(x * 0.5)),
                 cv = c(sd(x) / mean(x), sd(x * 0.5) / mean(x * 0.5))))

Secao("VERIFICAÇÃO CONCLUÍDA")
cat("A05, A09 e A14 têm evidência adicional no código, na descrição dos modelos\n",
    "e na inspeção do PDF, conforme os relatórios individuais.\n",
    "Os asserts verificam o estado auditado; deverão mudar após as correções.\n", sep = "")
```

<a id="apendice-b"></a>

## Apêndice B — Evidências da execução

Saída integral da verificação realizada na revisão de 04/10/2026:

```text

AMBIENTE
R version 4.5.2 (2025-10-31) 
Benchmarking 0.33 
dplyr 1.1.4 
truncreg 0.2.5 
Data da auditoria: 2026-10-04; estado analisado: a1af12f

A01: exemplos controlados da orientação do Malmquist
  m  tc  ec 
0.5 0.5 1.0 
            unidade   M TC  EC e00 e11
1        referencia 1.0  1 1.0   1   1
2 alcanca_fronteira 0.5  1 0.5   2   1

A01/A02: reprodução das seis bases e falsos rótulos de fronteira
fase_a : diferença máxima contra CSV = 4.88498131e-15 
Brasil: escore contemporâneo no painel balanceado
    ano      escore   EC_bruto
9  2016 1.000000000         NA
10 2017 0.437158392 2.28750041
11 2018 0.321656770 1.35908345
12 2019 0.283998983 1.13259832
        grupo M_convertido TC_convertido EC_convertido
1  Alta renda  1.004414580    1.11357773   0.901970782
2 Renda média  0.999881837    1.07398048   0.931005592
3       Todos  1.002712399    1.09856051   0.912751178
painel : diferença máxima contra CSV = 4.88498131e-15 
Brasil: escore contemporâneo no painel balanceado
    ano      escore    EC_bruto
21 2017 0.317138853          NA
22 2018 0.338399063 0.937174148
23 2019 0.298342804 1.134262528
24 2020 0.301257568 0.990324678
25 2021 0.194238475 1.550967530
        grupo M_convertido TC_convertido EC_convertido
1  Alta renda   1.06181032    1.17551189   0.903274839
2 Renda média   1.18537730    1.16665252   1.016050005
3       Todos   1.08615075    1.17368242   0.925421333
qualidade : diferença máxima contra CSV = 4.88498131e-15 
inventor : diferença máxima contra CSV = 4.88498131e-15 
preqin : diferença máxima contra CSV = 4.6629367e-15 
publico : diferença máxima contra CSV = 4.6629367e-15 
      base      pais menor_escore
1   fase_a Argentina  0.418728828
2   painel    Russia  0.615988495
3 inventor    Russia  0.634344125
4 inventor     Japan  0.701748758
5 inventor  Malaysia  0.828781572
6   preqin    Turkey  0.622790325
7  publico    Russia  0.700798015
Sobrescrita no summarise: EC = 2 e 0,5
  mudanca_eficiencia sempre_na_fronteira
1                  1                TRUE

A03: apoio estrito sem diferença entre canais distinguível de zero
        modelo ic_inf_diferenca ic_sup_diferenca veredito_estrito especificidade_relativa
1 cobb_douglas   -0.00104992384      0.277188108          apoiada                   FALSE

A04: H2 apesar de ajuste pontual inválido
        canal      modelo convergiu inferencia_valida           mensagem
5 publicacoes painel_bc92     FALSE             FALSE frontier, código 5
       modelo                         veredito_estrito replicas_convergentes_diferenca
3 painel_bc92 não apoiada (sem efeito nos dois canais)                             249

A06: exclusões do modelo conjunto e reestimação pontual de H5
[1] "CHL-2017" "BGR-2018"
            amostra   n beta_efetividade
1          conjunto 154     -0.303397306
2 intersecao_canais 152     -0.287639985

A07: diferenças entre indicadores da Fase A e cache WGI
efetividade_governo : máximo absoluto = 0.525229759 ; diferenças > 1e-6 = 208 
controle_corrupcao : máximo absoluto = 0.304719448 ; diferenças > 1e-6 = 208 

A08: observações suspeitas na checagem de patentes
    iso3c  ano patentes_cset patentes_inventor patentes
127   IND 2019            12         303.40302       NA
128   IND 2020            12         409.54599       NA
129   IND 2021             6         475.98550       NA
Pares atuais: 302 ; tratados: 299 
rho atual = 0.75292584 ; tratado = 0.763286304 

A10: países repetidos entre as duas metades
 Alta renda : linhas = 132 ; países = 24 ; em ambas as metades = 19 
 Renda média-alta : linhas = 50 ; países = 10 ; em ambas as metades = 7 
_painel Alta renda : linhas = 159 ; países = 35 ; em ambas as metades = 33 
_painel Renda média-alta : linhas = 43 ; países = 11 ; em ambas as metades = 9 

A11: ε muito pequeno não recupera escores originais
base_atual : epsilon = 1e-06 ; diferença máxima = 0.352885568 
base_atual : epsilon = 1e-09 ; diferença máxima = 0.352986117 
painel_ia : epsilon = 1e-06 ; diferença máxima = 0.160667748 
painel_ia : epsilon = 1e-09 ; diferença máxima = 0.160768791 

A12: aumento mecânico dos escores com insumo adicional
Violações de M2 >= M1: 0 em 191 observações

A13: cobertura do manifesto e integridade das saídas registradas
output/tables/malmquist_por_pais.csv : registrado = FALSE 
output/tables/dispersao_renda_ano_painel.csv : registrado = FALSE 
Arquivos registrados ausentes = 0 ; últimos hashes divergentes = 0 

A15: IQR absoluto versus CV
  escala  iqr          cv
1    1.0 0.30 0.516397779
2    0.5 0.15 0.516397779

VERIFICAÇÃO CONCLUÍDA
A05, A09 e A14 têm evidência adicional no código, na descrição dos modelos
e na inspeção do PDF, conforme os relatórios individuais.
Os asserts verificam o estado auditado; deverão mudar após as correções.
```
