# Reanálise crítica após as correções

Revisão concluída em **28/09/2026**, sobre o estado do repositório no commit `91ee83c`, incluindo a revisão 2 do brief. Complementa [09_analise_critica_inconsistencias.md](09_analise_critica_inconsistencias.md) e avalia as correções relatadas em [10_avaliacao_inconsistencias.md](10_avaliacao_inconsistencias.md).

**Resultado:** ainda existem inconsistências de implementação, interpretação e documentação. As correções anteriores resolveram problemas importantes, mas não permitem declarar o trabalho livre de inconsistências. Abaixo são registrados 13 achados, com evidências, impacto e sugestão de resolução, além de duas pendências já reconhecidas. Uma limitação metodológica explicitamente aceita não é tratada como erro novo; o problema remanescente é identificado quando a conclusão ultrapassa essa limitação ou o procedimento não executa a correção descrita.

Foram confrontados scripts, bases processadas, tabelas, logs, hipóteses, resultados e apresentação. As verificações incluíram reestimações pontuais de DEA, regressões e bootstrap do segundo estágio, sem sobrescrever saídas do projeto. Não foi reexecutado todo o pipeline, nem demonstrada a cobertura estatística de todos os procedimentos. Ambiente das verificações: R 4.5.2, Benchmarking 0.33 e truncreg 0.2-5.

## Correções confirmadas

- O filtro sem piso agora usa o insumo efetivamente selecionado. As seis amostras verificadas coincidem com a regra de exclusão: Fase A 169; painel 186; qualidade 107; fonte 199; Preqin 190; P&D executado por ensino superior e governo 168. O valor 198 ainda escrito para a variante de fonte é erro de relato, não do filtro.
- A China passou a ser corretamente descrita como CRS nos resultados principais em volume; existem tabelas de RTS por país.
- A comparação da metafronteira com GERD nos mesmos 184 país-ano da variante de P&D por setor confirma que a inversão já ocorre pela composição da amostra.
- As regressões truncadas informam casos completos por fórmula. Os escores conjuntos usados pelo segundo estágio coincidem com os arquivos de bootstrap atuais nas seis variantes verificadas.
- A decomposição da variância do Malmquist passou a incluir a covariância. O bootstrap das correlações passou a reamostrar países.
- Foram acrescentadas distinções importantes sobre setor executor de P&D, média de talento por gênero, famílias de patentes e universo CSET versus Preqin. O resultado antigo do algoritmo 2 na variante de qualidade está identificado como obsoleto.

Essas correções não devem ser desfeitas ao tratar os achados seguintes.

## Quadro de achados

| ID | Prioridade | Situação | Inconsistência |
|---|---|---|---|
| R01 | Crítica | Nova, confirmada | Ajustes que não convergiram são publicados e contados como réplicas válidas |
| R02 | Alta | Correção incompleta de I15 | Comparação de coeficientes usa a mesma amostra na regressão, mas fronteiras de amostras diferentes |
| R03 | Alta | Nova, confirmada | Amostra comum Preqin da metafronteira inclui três zeros excluídos pelo modelo base |
| R04 | Alta | Nova, confirmada | β-convergência mistura eficiência inicial da amostra completa com Malmquist da amostra balanceada |
| R05 | Alta | Remanescente de I12 | Conclusão sobre todas as variantes contradiz o IC não arredondado da Preqin |
| R06 | Média | Nova, confirmada | Mann–Whitney com dois grupos é apresentado como Kruskal–Wallis com três grupos |
| R07 | Alta | Remanescente de I04 | Separação ordinal entre base e restante do ranking continua sem demonstração |
| R08 | Alta | Limitação de I09 com interpretação excessiva | Teste de RTS sem tamanho controlado sustenta decisões e afirmação de robustez |
| R09 | Alta | Correção incompleta de I08 | Modelo principal continua admitindo eficiência negativa; problema é material em patentes |
| R10 | Alta | Correção incompleta de I13 | H3b enuncia diferença de médias, mas usa teste de postos; justificativa sobre a fronteira do suporte é incorreta |
| R11 | Alta | Nova aplicação da limitação de inferência | ICs do Malmquist reamostram índices fixos e são usados como inferência da eficiência |
| R12 | Média | Remanescente de I18/I23 | Documentos ainda divergem sobre definições, amostras e resultados |
| R13 | Média | Remanescente de rastreabilidade | Runner pode anunciar conclusão e terminar com sucesso após falhas |

## R01 — Regressões sem convergência são aceitas como resultados válidos

**Localização:** [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R), funções `AjustarTruncada`, `TruncadaAgrupada` e `TruncadaDupla`; [segundo_estagio_truncada.csv](../output/tables/segundo_estagio_truncada.csv); seção 8 de [05_resultados_fase_a.md](05_resultados_fase_a.md).

**Evidência.** Reestimar H5 em Farrell com os mesmos dados e opções reproduz o coeficiente de efetividade **57,27218**, mas o ajuste informa `est.stat$message = "iteration limit exceeded "`. O código captura exceções e valores ausentes, mas não verifica a convergência do otimizador. Assim, um objeto retornado normalmente pode ser exportado mesmo sem ajuste concluído.

Reproduzindo as 300 reamostragens com semente 2026 e a ordem de países da base usada pelo script, **149 atingem o limite de iterações e somente 151 informam convergência**. A tabela, porém, informa `replicas_validas = 300` e apresenta o IC [0,03887; 82,42742] como significativo. Uma checagem inicial com países em outra ordem encontrou 145 falhas; o número 149 corresponde à reprodução na ordem original. O ajuste pontual também falha, independentemente dessa ordem. A checagem em escore para H5 da Fase A convergiu, inclusive nas 300 réplicas verificadas.

**Impacto.** O coeficiente +57 e seu intervalo não podem funcionar como confirmação da robustez do sinal. A expressão “instável nos canais” não descreve todo o problema: ele também ocorre no modelo conjunto da Fase A. Falhas semelhantes apareceram nos ajustes pontuais em Farrell de vários canais.

**Sugestão.** Registrar convergência, log-verossimilhança, gradiente e diagnóstico da Hessiana em cada ajuste, antes de extrair coeficientes. Tentar ajustes numericamente adequados, com escala das covariáveis, critérios e limites explícitos; conferir estabilidade da solução. Se o ajuste pontual não convergir, marcar o modelo como não estimado. Reportar separadamente réplicas tentadas, convergentes e descartadas; uma taxa de falha próxima de metade exige investigar o procedimento, e não apenas recalcular o IC com as sobreviventes. Aplicar a mesma proteção a `AjustarEfetividade` em `R/05`. O objeto de `truncreg` fornece informações de estimação em `est.stat` e gradiente. [Manual do truncreg](https://cran.r-project.org/web/packages/truncreg/truncreg.pdf).

## R02 — Amostra comum no segundo estágio não significa fronteira comum

**Localização:** [R/05_comparacoes_amostra_comum.R](../R/05_comparacoes_amostra_comum.R), seção 2; seções 9 e 9c de [06_resultados_painel.md](06_resultados_painel.md); I15 de [10_avaliacao_inconsistencias.md](10_avaliacao_inconsistencias.md).

**Evidência.** A comparação lê os escores já existentes em `boot_ano_m2_painel.csv` e nas tabelas de cada variante. Depois restringe as linhas da regressão por `inner_join`. Não reestima as fronteiras anuais nem seus bootstraps em um conjunto de referência comum. O segundo estágio compara os mesmos países-ano, mas suas variáveis dependentes ainda refletem conjuntos diferentes de unidades de referência.

Isso altera resultados de fato: reestimar a especificação base VRS nos 184 identificadores da variante de P&D por setor muda **115 escores anuais**, com diferença máxima de **0,6797**. Portanto, o bootstrap pareado de coeficientes não isolou integralmente a troca de insumo.

A atribuição da subida de Israel e Irlanda exclusivamente ao “efeito do insumo” também permanece na seção 9c. Uma decomposição pontual, **sem correção de viés**, evidencia ambos os componentes:

| País | GERD, referência original | GERD, referência de 184 observações | HERD + GOVERD, mesma referência de 184 |
|---|---:|---:|---:|
| Israel | 0,1737 | 0,2456 | 0,5186 |
| Irlanda | 0,2351 | 0,4232 | 0,5122 |

São médias dos escores anuais nos anos disponíveis desses países. Não são substitutos diretos dos escores corrigidos de viés 0,16/0,47 e 0,20/0,46 citados no texto.

**Impacto.** O teste da diferença de coeficientes existe e representa uma melhoria, mas continua misturando efeitos de composição da fronteira e de especificação. A interpretação como decomposição completa é incorreta.

**Sugestão.** Definir um conjunto comum de referência DEA por comparação; reestimar nele as duas especificações e seus escores corrigidos, preservando anos e desenho de reamostragem comparáveis. Só então ajustar as regressões nas mesmas observações com contexto completo. Distinguir explicitamente amostra de referência DEA e amostra da regressão. Refazer também a decomposição dos rankings citados como efeito do insumo. A seção 1 de `R/05` já reestima as metafronteiras; o problema aqui é a seção 2 e a atribuição das mudanças individuais.

## R03 — A comparação Preqin altera também a regra sobre investimento zero

**Localização:** [R/05_comparacoes_amostra_comum.R](../R/05_comparacoes_amostra_comum.R), seleção `ids_v` e `complete.cases`; [comparacao_metafronteira_amostra_comum.csv](../output/tables/comparacao_metafronteira_amostra_comum.csv).

**Evidência.** A amostra Preqin tem 194 observações, mas sua interseção com a amostra base tem **191**. Os identificadores `COL-2019`, `LUX-2017` e `SVN-2019` têm `investimento_l1 = 0` no CSET e investimento positivo na Preqin. Entram na comparação da metafronteira porque `R/05` exige completude, mas não positividade do investimento CSET.

**Impacto.** A linha “base na amostra da variante” não é apenas uma restrição da amostra base: inclui unidades que o modelo principal exclui expressamente por mensuração. Assim, a decomposição muda simultaneamente composição, especificação e regra de admissibilidade dos zeros. Usar zero em M2 não é matematicamente proibido; a inconsistência é mudar a política de seleção sem declarar essa mudança.

**Sugestão.** Para isolar a troca de medida sob as regras principais, usar `intersect(ids_base, ids_v)` e verificar admissibilidade em ambas as especificações. Manter os 194 como sensibilidade adicional, explicitando os três casos e a política de zeros. Regenerar a linha Preqin da tabela e o texto correspondente; não presumir que os TGR permanecerão iguais.

## R04 — A regressão de β-convergência usa outra eficiência inicial

**Localização:** [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R), seção 8, construção de `painel`, `ec_pais` e `inicial`.

**Evidência.** O Malmquist é calculado apenas com os países presentes em todos os anos da janela. Entretanto, `inicial <- dea_m2[...]` busca o escore CRS inicial na DEA anual estimada com todos os países disponíveis naquele ano. O país é o mesmo, mas a fronteira de referência é diferente da usada para obter EC.

Reestimei a eficiência CRS inicial com os países efetivamente usados no Malmquist e mantive a mesma regressão OLS, apenas para isolar essa diferença:

| Amostra | Eficiências iniciais alteradas | β atual; p | β com referência balanceada; p |
|---|---:|---|---|
| Fase A | 13 de 16 | +0,04268; 0,4722 | +0,10571; 0,1142 |
| Painel base | 31 de 34 | −0,00811; 0,7255 | +0,00142; 0,9595 |
| Patentes por inventor | 21 de 38 | +0,04528; 0,1397 | +0,10030; 0,00072 |

**Impacto.** Os valores publicados de β não correspondem à regressão da aproximação à fronteira sobre a distância inicial à mesma fronteira. Na variante de fonte, o diagnóstico OLS passa a indicar associação positiva, incompatível com chamar genericamente a β-convergência de “nula”. Os novos p-valores acima são apenas a comparação OLS sob a mesma regra do código, não uma validação da inferência de fronteira.

**Sugestão.** Extrair a eficiência inicial do cálculo correspondente ao Malmquist ou recalculá-la com exatamente o painel balanceado, seus insumos, produtos e RTS. Verificar a identidade entre EC e a razão das eficiências contemporâneas de períodos consecutivos. Regerar as tabelas `malmquist_beta_convergencia*` e atualizar os textos, mantendo separadas β-convergência, catch-up e convergência entre grupos.

## R05 — O IC da Preqin exclui 1 antes do arredondamento

**Localização:** seções 6, 9b e 10 de [06_resultados_painel.md](06_resultados_painel.md); [malmquist_resumo_painel_preqin.csv](../output/tables/malmquist_resumo_painel_preqin.csv); critério de H4b em [01_hipoteses.md](01_hipoteses.md).

**Evidência.** Para os seis países de renda média na variante Preqin, EC é **1,037753476**, com intervalo **[1,001232494; 1,081986670]**. O limite inferior é maior que 1. O texto arredonda para [1,00; 1,08], chama o resultado de limítrofe e conclui “Sem convergência da renda média em nenhuma variante”.

**Impacto.** Pelo critério operacional declarado — EC > 1 e IC excluindo 1 — essa variante satisfaz H4b nos resultados atualmente armazenados. A conclusão universal não segue o próprio critério. Isso não prova convergência relativa aos países ricos, nem resolve a limitação dos intervalos descrita em R11.

**Sugestão.** Decidir hipóteses com valores não arredondados. Escrever que a Preqin apresenta evidência limítrofe de catch-up pelo procedimento descritivo utilizado, enquanto o painel base não apresenta esse apoio. Mostrar ao menos quatro casas no limite próximo de 1 e avaliar a estabilidade Monte Carlo, sem selecionar sementes até obter uma decisão desejada. Reservar conclusões inferenciais de eficiência ao procedimento validado de R11.

## R06 — Os testes por país estão identificados incorretamente

**Localização:** `TesteGrupos` em [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R); seção 6 de [05_resultados_fase_a.md](05_resultados_fase_a.md); tabela da seção 5 de [06_resultados_painel.md](06_resultados_painel.md); [08_brief_deck.md](08_brief_deck.md).

**Evidência.** `p_kruskal` corresponde a Kruskal–Wallis com os **três** grupos de renda, usando país-ano. Já `p_mann_whitney_medias_pais` é Mann–Whitney com **dois** grupos, alta renda versus renda média agregada, usando uma média por país. Ambos são apresentados sob o rótulo “Kruskal-Wallis (país-ano / médias por país)”.

No canal de patentes do painel base, o valor por país publicado é **0,01020**. Recalcular de fato Kruskal–Wallis nas médias por país dos três grupos resulta em **0,03967**. Na variante de qualidade, os valores são **0,09608** para Mann–Whitney e **0,24351** para Kruskal–Wallis. Não se trata apenas de arredondamento.

**Sugestão.** Identificar cada teste, número de grupos e unidade amostral. Para avaliar especificamente o efeito de remover a repetição temporal, comparar o mesmo teste com os mesmos grupos antes e depois da agregação. Não atribuir toda a mudança do p-valor ao agrupamento por país quando o contraste também foi alterado.

## R07 — As barras não demonstram separação entre a base e todos os demais países

**Localização:** seção 4 dos documentos [05](05_resultados_fase_a.md) e [06](06_resultados_painel.md); slide 8 e roteiro de edição de [08_brief_deck.md](08_brief_deck.md); I04 de [10_avaliacao_inconsistencias.md](10_avaliacao_inconsistencias.md).

**Evidência.** A média dos limites anuais foi substituída por um bootstrap da média, mas a frase “Só a separação base × restante é ordinalmente defensável” permanece. No painel, o intervalo de Itália **[0,0852; 0,7266]** e o de Malásia **[0; 0,7415]** se sobrepõem ao de Israel **[0,1285; 0,1611]**. Na Fase A, o intervalo da Índia **[0; 0,6851]** também cobre o de Israel **[0,1360; 0,1857]**. Não foram estimados contrastes pareados ou intervalos de postos.

Há ainda uma diferença de construção a explicitar: `RankingComBootstrap` calcula o IC básico diretamente na escala inversa das réplicas, enquanto o ponto é a média dos inversos de Farrell corrigido de viés. No painel, seis dos 47 pontos ficam fora das respectivas barras, incluindo Itália. **Um ponto corrigido fora do IC não prova, isoladamente, que o intervalo é inválido**; exige, porém, clareza sobre a estatística e o método, sobretudo quando a construção é chamada de intervalo de Simar–Wilson sem validação específica da agregação. A independência entre anos continua sendo uma hipótese da adaptação.

**Sugestão.** Retirar a afirmação de separação ordinal geral. Apresentar o ranking como ordenação pontual, com anos disponíveis e hipóteses das barras. Para sustentar separações, estimar diferenças entre países ou incerteza de postos com dependência conjunta adequada e anos comparáveis. Sobreposição de ICs marginais tampouco prova igualdade: a conclusão correta é ausência do teste necessário. O manual distingue estimativa corrigida, intervalos e réplicas disponibilizadas por `dea.boot`; a agregação temporal é uma etapa adicional do projeto. [Benchmarking, seção dea.boot](https://cran.r-project.org/web/packages/Benchmarking/Benchmarking.pdf).

## R08 — A validação detectou um problema de tamanho, não certificou o teste de RTS

**Localização:** [validacao_teste_rts.csv](../output/tables/validacao_teste_rts.csv); [R/02c_validacao_rts.R](../R/02c_validacao_rts.R); H1 e sínteses dos documentos 01, 05, 06 e 08.

**Evidência.** Em 100 simulações sob CRS verdadeiro, o procedimento rejeitou 20 vezes ao nível nominal de 5%. O IC binomial exato de 95% dessa frequência é aproximadamente **[0,127; 0,292]**, distante de 0,05. A ressalva “teste liberal” foi acrescentada, mas a rejeição a 5% ainda sustenta “H1 parcialmente apoiada”. No painel, a seção 3 afirma que a não rejeição “é robusta” por o teste ser liberal.

**Impacto.** O nível nominal não é controlado no cenário examinado. A frequência de 20% também não pode ser extrapolada como tamanho exato para os dados reais: a simulação usa 40 DMUs, dois insumos, dois produtos e observações independentes; o teste aplicado usa observações repetidas de países e outros tamanhos, e M1 tem um único insumo. A não rejeição de um procedimento mal calibrado não ganha garantia de robustez por esse motivo.

**Sugestão.** Manter as estatísticas e p-valores como diagnósticos exploratórios, sem afirmar rejeição com erro de tipo I controlado a 5%. Preservar a evidência descritiva de heterogeneidade de RTS por país. Comparar a implementação com uma referência em pequenas amostras e avaliar tamanho em cenários próximos dos modelos efetivos, inclusive NIRS e dependência temporal. A implementação de referência e seus parâmetros estão documentados em [rDEA, seção rts.test](https://cran.r-project.org/web/packages/rDEA/rDEA.pdf).

Também corrigir a explicação de I09 no documento 10: o corte `pmax(d, 1e-4)` altera valores positivos menores que `1e-4`, que pertencem ao suporte `(0,1]`; portanto, não afeta “apenas valores fora do suporte”. Sua frequência e efeito precisam ser medidos antes de defendê-lo como irrelevante.

## R09 — A parametrização adicional não resolveu o suporte do modelo principal

**Localização:** `AjustarTruncada` e chamadas em [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R); seção 8 de [05](05_resultados_fase_a.md), seção 7 de [06](06_resultados_painel.md), Figura 4 e I08 de [10](10_avaliacao_inconsistencias.md).

**Evidência.** A regressão normal truncada apenas à direita em 1 continua sendo o resultado principal nos textos e figuras. Seu suporte é `(-Inf, 1)`, embora a eficiência observada seja positiva. A versão Farrell foi acrescentada como sensibilidade, mas não substitui esse modelo nem corrige sua distribuição.

O problema é material no H6 de patentes da Fase A: utilizando os parâmetros ajustados, a probabilidade condicional atribuída a valores negativos é, na mediana das observações, **15,8%**, chegando a **45,9%**. A conta é `pnorm(-mu/sigma) / pnorm((1-mu)/sigma)`, para a normal condicionada a ser menor que 1. Isso não significa que os dados observados contenham escores negativos; é uma incompatibilidade da distribuição assumida.

**Sugestão.** Usar como principal uma especificação compatível com o suporte, com ajuste numericamente validado, ou limitar explicitamente as regressões atuais a uma aproximação descritiva e suspender decisões por significância que dependam de sua validade. Não considerar I08 integralmente resolvido apenas por rodar as duas escalas. Modelos com dois limites são discutidos em [Badunenko e Tauchmann (2019)](https://journals.sagepub.com/doi/abs/10.1177/1536867X19893640). O algoritmo 2 do rDEA opera na medida recíproca com suporte de um a infinito. [Manual do rDEA, seção dea.env.robust](https://cran.r-project.org/web/packages/rDEA/rDEA.pdf).

## R10 — H3b ainda não coincide exatamente com o teste usado

**Localização:** H3 de [01_hipoteses.md](01_hipoteses.md); seção 7 de [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R); I13 de [10_avaliacao_inconsistencias.md](10_avaliacao_inconsistencias.md).

**Evidência.** A hipótese e o critério agora se referem à **média** do TGR de cada grupo. Entretanto, o Mann–Whitney opera sobre postos/distribuições e não é, em geral, um teste da diferença de médias. Aplicá-lo às médias temporais por país não o transforma em teste da média entre grupos. Seria necessária uma justificativa adicional sobre a forma das distribuições para identificar esses alvos. [Documentação de wilcox.test, Details](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/wilcox.test.html).

Também é incorreta a justificativa “TGR ≤ 1 por construção torna TGR < 1 não testável”. Um parâmetro limitado por 1 pode ser testado contra uma hipótese nula na fronteira, por exemplo, ausência de gap versus gap positivo; o suporte não torna o teste logicamente impossível. A dificuldade é obter uma distribuição nula apropriada e respeitar a estimação das fronteiras.

**Sugestão.** Escolher explicitamente o alvo: diferença de TGR médio, diferença de localização ou ordenação estocástica. Para médias, estimar diretamente o contraste e sua incerteza sob um procedimento adequado à fronteira e ao painel; para postos, reescrever a hipótese e limitar a interpretação ao objeto efetivamente testado. Justificar a troca da pergunta original por interesse substantivo, e não pela alegada impossibilidade de testar um parâmetro na fronteira. A dependência entre TGRs estimados por fronteiras compartilhadas permanece uma limitação mesmo após reduzir a uma linha por país.

## R11 — Os novos ICs do Malmquist não propagam a incerteza das fronteiras

**Localização:** `BootMalm` em [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R); tabelas `malmquist_resumo*`; interpretações de catch-up nos documentos 05, 06 e 08.

**Evidência.** `BootMalm` seleciona países e calcula médias geométricas dos valores de M, TC e EC já estimados. Não gera pseudodados nem recalcula as fronteiras contemporâneas e intertemporais. Os ICs quantificam a variação de composição entre trajetórias com **índices fixos**, mas são usados para afirmar “catch-up significativo” e decidir uma hipótese sobre eficiência.

**Impacto.** O agrupamento por país trata a repetição das observações dentro de cada trajetória, mas não a incerteza nem a dependência criada pela estimação da fronteira comum. É a mesma distinção já reconhecida para o segundo estágio em I07, aplicada agora aos novos intervalos da dinâmica. Isso não demonstra que os resultados necessariamente mudarão; demonstra que a cobertura para o alvo inferencial não foi estabelecida.

**Sugestão.** Rotular os resultados como intervalos descritivos de reamostragem de países, condicionados aos índices estimados. Enquanto não houver procedimento validado para o desenho, distinguir o atendimento numérico do critério de H4b da confirmação inferencial da hipótese. Para esta última, adotar bootstrap de produtividade/fronteira que reproduza a construção de M, TC e EC e justifique o tratamento do painel. Reamostrar linhas e simplesmente refazer uma DEA não deve ser presumido suficiente.

## R12 — Permanecem divergências documentais após a declaração de atualização

**Localização:** documentos 01, 06, 07, 08 e 10.

| Trecho atual | Evidência / correção necessária |
|---|---|
| Documento 06, quadro de amostras; documento 10, resumo: fonte sem piso = **198/45** | O CSV contém **199 observações e 45 países**, compatíveis com 217 menos 18 observações no piso. |
| Documentos 08 e 10: saem “seis países de renda média” na variante de P&D por setor | A própria base classifica **Arábia Saudita como alta renda**. São cinco países de renda média e um de alta renda; não atribuir a mudança exclusivamente à remoção de um grupo. |
| Documento 06, seções 5 e 9c: TGR do P&D por setor **0,92/0,82** | Valores atuais são 0,9148048 e 0,8147483: a duas casas, **0,91/0,81**, como já aparece na seção 9. |
| Documento 06, interpretação conjunta de pesquisadores e talento | Separar os resultados: talento em P&D por setor é **0,088 [−0,055; 0,274]**, não significativo; pesquisadores nessa variante têm intervalo positivo. |
| H2 do documento 01: “P&D executado fora das empresas (GERD total ou...)” | **GERD total inclui o setor empresarial**. Distinguir GERD de HERD + GOVERD já na frase da hipótese; a soma destes dois setores também não esgota todo P&D não empresarial. |
| Quadro-resumo do documento 01: H3 com critério **TGR < 1** e H1 com `rDEA::rts.test` | O corpo de H3 passou a comparar grupos; o teste implementado de RTS é a rotina adaptada. Atualizar o quadro para o método e o alvo efetivos. |
| Documento 07, seção 4: painel rejeita CRS e Fase A tem p < 0,001 | O mesmo documento registra adiante a correção: painel p ≈ 0,10 e Fase A p = 0,025. Separar resultados históricos dos vigentes. |
| Documento 07, seção 1: “Nada foi commitado ainda” | Há commits do pipeline, correções e revisão do brief. O cabeçalho e partes do guia de retomada continuam representando estados anteriores. |
| Documento 10: “22 verdadeiras (das quais 6 em parte)” | O quadro contém 24 itens e somente **I09 e I16** explicitamente classificados “em parte”. Separar contagem de vereditos de contagem de correções concluídas, parciais e pendentes. |

**Impacto.** Esses desencontros dificultam saber qual especificação e qual resultado são vigentes. A revisão 2 do brief já corrigiu outras diferenças, como os ICs do algoritmo 2 e o TGR da Fase A; essas correções foram consideradas nesta reanálise.

**Sugestão.** Gerar valores, decisões e quadros de amostra diretamente das tabelas, com precisão definida. Manter histórico em seção datada e uma síntese única do estado atual. Corrigir conjuntamente documentos 01, 05, 06, 07, 08 e 10, sem marcar como resolvidas limitações que apenas receberam uma ressalva.

## R13 — A execução pode falhar e ainda anunciar conclusão

**Localização:** [output/rodar_tudo.sh](../output/rodar_tudo.sh), `run_chain` e sequência principal; [output/rodar_rankings.sh](../output/rodar_rankings.sh); `RegistrarManifesto` em [R/funcoes.R](../R/funcoes.R).

**Evidência.** Os blocos usam `... && echo "OK" || echo "FALHOU"`. O `echo` de falha normalmente retorna sucesso, e a execução continua até `echo "TUDO CONCLUIDO"`. Falhas em etapas anteriores podem deixar saídas antigas disponíveis para etapas seguintes. O manifesto registra conclusões de scripts, mas não impede essa reutilização. Além disso, `rodar_rankings.sh` reexecuta o script 02 inteiro, alterando potencialmente entradas do segundo estágio, sem executar 03.

**Impacto.** “Pipeline concluído” não garante que todas as saídas pertençam à mesma execução. **Não foi observada divergência atual entre o escore conjunto do segundo estágio e o bootstrap nas seis variantes**; este achado identifica o comportamento do controle de execução, não afirma que essas tabelas estejam hoje desatualizadas.

**Sugestão.** Propagar explicitamente falhas com `return`/`exit` não zero e decidir quais etapas independentes podem continuar. Distinguir execução completa de parcial; gravar status por etapa e impedir leitura de artefatos anteriores como resultado da execução atual. Para atualizar apenas rankings, separar sua geração do recálculo integral das fronteiras, ou reexecutar os consumidores afetados. Registrar configurações e identificadores dos artefatos usados, além do hash da base.

## Pendências já reconhecidas, ainda abertas

**P01 — Apresentação.** O documento 10 já deixa I05 pendente, e a revisão 2 do brief oferece um roteiro de edição. O PDF disponível continua sendo o deck antigo; a inspeção da página 8 confirma o espaço reservado no lugar do ranking. Incorporar os sete gráficos atualizados, revisar as conclusões afetadas por este relatório e conferir visualmente a nova exportação. A atualização do brief, por si só, não atualiza o PDF. [Arquivo da apresentação](../AI%20Effiency%20Analysis.pdf).

**P02 — Semente do algoritmo 2.** O registro de trabalho passou a documentar que `parallel::mcparallel` executa o algoritmo sem uma semente explicitamente definida no processo filho. A correção ainda está pendente no código. Fixar e registrar a estratégia de RNG no filho, reexecutar as variantes necessárias e atualizar seus intervalos. Não confundir a existência de `set.seed(2026)` no processo principal com uma garantia de reprodução dos resultados desse processo separado.

## Ordem sugerida para resolução

1. Tratar a convergência numérica (R01) e definir o suporte do segundo estágio (R09) antes de interpretar suas sensibilidades.
2. Corrigir as amostras de referência e a eficiência inicial (R02–R04); reestimar as saídas dependentes.
3. Alinhar hipótese, teste e alcance da inferência (R05–R11), incluindo as limitações de calibração e fronteira.
4. Corrigir o controle de execução e a semente, consolidar os documentos e reexportar o deck (R12–R13, P01–P02).

## Verificações reproduzíveis

Os blocos abaixo podem ser executados em R a partir da raiz do projeto. Leem os arquivos atuais e não sobrescrevem resultados. Os valores de diagnóstico não substituem a reanálise metodológica sugerida.

### Ajuste H5 em Farrell e convergência das réplicas

```r
p <- read.csv("data/processed/base_atual.csv")
b <- read.csv("output/tables/boot_ano_m2.csv")
canais <- read.csv("output/tables/escores_bc_conjunto_e_canais.csv")
d <- p[p$id %in% canais$id, ]  # preserva a ordem da base
d$farrell_bc <- b$farrell_bc[match(d$id, b$id)]
d$ano_f <- factor(d$ano)
f <- farrell_bc ~ efetividade_governo + alta_tec_export +
  log_comercio + market_cap + credito_privado + ano_f
d <- d[complete.cases(d[, all.vars(f)]), ]
ajustar <- function(z) {
  truncreg::truncreg(f, data = z, point = 1, direction = "left")
}
m <- ajustar(d)
coef(m)["efetividade_governo"]
m$est.stat

set.seed(2026)
paises <- unique(d$pais)
status <- replicate(300, {
  escolhidos <- sample(paises, replace = TRUE)
  db <- do.call(rbind, lapply(escolhidos, function(p) d[d$pais == p, ]))
  tryCatch(trimws(ajustar(db)$est.stat$message),
           error = function(e) "erro")
})
table(status)  # 149 no limite de iterações; 151 convergências
```

### Eficiência inicial coerente com o painel do Malmquist

```r
comparar_beta <- function(sufixo, arquivo, insumos, produtos) {
  ler <- function(nome) read.csv(paste0("output/tables/", nome,
                                        sufixo, ".csv"))
  base <- read.csv(arquivo)
  dea <- ler("dea_ano_m2")
  malm <- ler("malmquist_m2")
  inicial <- base[base$ano == min(malm$ano) - 1 &
                   base$pais %in% malm$pais, ]
  modelo <- Benchmarking::dea(
    as.matrix(inicial[, insumos]) / 1e6,
    as.matrix(inicial[, produtos]), RTS = "crs", ORIENTATION = "out")
  e_balanceada <- 1 / as.numeric(Benchmarking::eff(modelo))
  e_atual <- dea$escore_crs[match(inicial$id, dea$id)]
  log_ec <- tapply(log(malm$mudanca_eficiencia), malm$pais, mean)
  log_ec <- unname(log_ec[inicial$pais])
  rbind(atual = summary(lm(log_ec ~ log(e_atual)))$coef[2, ],
        balanceada = summary(lm(log_ec ~ log(e_balanceada)))$coef[2, ])
}
comparar_beta("_painel", "data/processed/painel_ia.csv",
              c("investimento_l1", "gerd_l1"),
              c("publicacoes", "patentes"))
comparar_beta("_painel_fonte", "data/processed/painel_ia.csv",
              c("investimento_l1", "gerd_l1"),
              c("publicacoes", "patentes_inventor"))
```

### IC da Preqin, interseção de amostras e identificação dos testes

```r
ler <- function(nome) read.csv(paste0("output/tables/", nome, ".csv"))
m <- ler("malmquist_resumo_painel_preqin")
m[m$grupo_renda2 == "Renda média",
  c("mudanca_eficiencia", "mudanca_eficiencia_ic_inf",
    "mudanca_eficiencia_ic_sup")]

base <- ler("dea_ano_m2_painel")
preqin <- ler("dea_ano_m2_painel_preqin")
length(intersect(base$id, preqin$id))  # 191
setdiff(preqin$id, base$id)  # COL-2019, LUX-2017, SVN-2019

e <- ler("escores_bc_conjunto_e_canais_painel")
g <- aggregate(escore_bc_pat ~ pais + grupo_renda, data = e, FUN = mean)
kruskal.test(escore_bc_pat ~ grupo_renda, data = g)$p.value  # 0,03967
g$grupo2 <- ifelse(g$grupo_renda == "Alta renda", "Alta", "Média")
wilcox.test(escore_bc_pat ~ grupo2, data = g)$p.value  # 0,01020
```
