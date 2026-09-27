# Análise crítica: inconsistências e sugestões de correção

Revisão realizada em **27/09/2026**, sobre os arquivos presentes no repositório.

Foram confrontados hipóteses, documentação, scripts R, bases processadas, tabelas, logs e páginas da apresentação `AI Effiency Analysis.pdf`. As verificações numéricas usaram os dados locais; algumas fronteiras foram reestimadas pontualmente para isolar diferenças de amostra. Não foi reexecutado todo o pipeline de bootstrap. Os arquivos originais não foram alterados.

**Avaliação geral:** há erros verificáveis de implementação e de relato que precisam ser corrigidos antes de sustentar as conclusões. Os mais importantes são o filtro incorreto de valores-piso, a classificação da China narrada de forma contrária às tabelas, a atribuição da inversão da metafronteira ao P&D público e os intervalos do ranking. Outros achados são limitações de inferência ou de mensuração; nesses casos, a revisão indica a análise necessária, sem presumir qual será o novo resultado.

**Prioridades:** crítica = compromete um resultado central ou a apresentação; alta = exige reanálise ou mudança substantiva de interpretação; média = compromete rastreabilidade ou precisão do relato. “Confirmado” identifica uma divergência diretamente observada; “metodológico” identifica uma conclusão cujo suporte é insuficiente.

| ID | Prioridade | Natureza | Inconsistência |
|---|---|---|---|
| I01 | Crítica | Confirmado | Filtro “sem piso” usa o ano e, na Preqin, também a fonte errados |
| I02 | Crítica | Confirmado | China descrita como DRS, mas classificada como CRS nas tabelas |
| I03 | Crítica | Confirmado | Inversão da metafronteira atribuída ao P&D público já ocorre pela mudança de amostra |
| I04 | Crítica | Confirmado/metodológico | Médias de limites anuais apresentadas como IC de 95% do ranking |
| I05 | Crítica | Confirmado | PDF contém espaços reservados no lugar dos sete gráficos |
| I06 | Alta | Confirmado | Tamanhos das amostras das regressões são superestimados |
| I07 | Alta | Metodológico | Bootstrap do segundo estágio mantém fixos os escores estimados |
| I08 | Alta | Confirmado/metodológico | Regressão truncada permite valores negativos para eficiência e não equivale à inversão de Farrell |
| I09 | Alta | Metodológico | Adaptação do teste de RTS não demonstra equivalência ao procedimento citado |
| I10 | Alta | Confirmado/metodológico | Fronteiras anuais e agrupadas são usadas como se estimassem o mesmo objeto |
| I11 | Alta | Confirmado | “Variância explicada” pelo componente técnico omite a covariância |
| I12 | Alta | Confirmado/metodológico | Conclusão de ausência de convergência não segue o critério de H4 |
| I13 | Alta | Confirmado/metodológico | Testes e decisões de H3 não correspondem às hipóteses declaradas |
| I14 | Alta | Metodológico | Inferência de correlações e grupos ignora observações repetidas por país |
| I15 | Alta | Metodológico | Comparações de qualidade/fonte confundem mudanças de medida, amostra e significância |
| I16 | Alta | Confirmado | Exclusão de zeros é justificada por uma impossibilidade que não vale para M2 |
| I17 | Alta | Confirmado | Supereficiência não se restringe às observações no piso |
| I18 | Alta | Conceitual | GERD e HERD + GOVERD não identificam diretamente financiamento público |
| I19 | Alta | Confirmado | Média simples de taxas por gênero é tratada como concentração total de talento |
| I20 | Alta | Conceitual/documental | Produtos de patentes e de “qualidade” precisam de definição mais precisa |
| I21 | Alta | Metodológico | Correlação entre contexto e escore não diagnostica separabilidade |
| I22 | Alta | Confirmado | Resultado antigo do Simar–Wilson pode sobreviver a uma execução que falhou |
| I23 | Média | Confirmado | Documentos divergem sobre amostras, pendências e resultados disponíveis |
| I24 | Alta | Conceitual/documental | Investimento CSET e VC Preqin não diferem apenas pelo fornecedor |

## I01 — O filtro “sem piso” seleciona as observações erradas

**Localização:** [R/13_build_painel.R](../R/13_build_painel.R), linhas 84–97; [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R), linhas 43–49 e 320; resultados de sensibilidade em [06_resultados_painel.md](06_resultados_painel.md).

**Inconsistência e evidência.** `inv_piso` é construído a partir de `investimento` em **t**, mas os modelos da Fase B usam `investimento_l1`, em **t−1**. O script 02 só calcula o indicador se a coluna ainda não existir; portanto, reutiliza a marca incompatível com o insumo escolhido. Na variante Preqin, reutiliza ainda uma marca baseada no CSET.

Conferência nas amostras efetivamente usadas, aplicando o mesmo limite de US$ 2,5 milhões ao insumo correto:

| Variante | N inicial | Remoções atuais | Observações realmente no piso do insumo usado | Removidas indevidamente | No piso, mas mantidas |
|---|---:|---:|---:|---:|---:|
| Volume | 204 | 8 | 18 | 6 | 16 |
| Qualidade | 117 | 6 | 10 | 5 | 9 |
| Patentes por inventor | 217 | 9 | 18 | 6 | 15 |
| Preqin | 194 | 7 | 4 | 6 | 3 |
| HERD + GOVERD | 184 | 7 | 16 | 5 | 14 |

Exemplo: `ARG-2017` usa investimento defasado de aproximadamente US$ 1,129 milhão, mas permanece na amostra “sem piso”. `ARG-2018` usa aproximadamente US$ 5,527 milhões, mas é excluída.

**Impacto.** As alegações de robustez “sem piso” na Fase B não foram testadas como descritas. Isso afeta fronteiras, bootstrap, canais, metafronteiras e H5 nessa sensibilidade.

**Sugestão.** Construir sempre uma marca específica a partir de `amostra[[insumos[1]]]`; manter a marca original apenas como informação de proveniência. Reexecutar todas as saídas `_sem_piso` e seus segundos estágios. Justificar o limite por fonte e testar limites alternativos; um mesmo valor monetário não implica igual granularidade em CSET e Preqin.

## I02 — A narrativa de H1 contradiz os resultados da China

**Localização:** [01_hipoteses.md](01_hipoteses.md), H1; [05_resultados_fase_a.md](05_resultados_fase_a.md), seção 3; [08_brief_deck.md](08_brief_deck.md), slide 7; PDF, página 7; [dea_ano_m2.csv](../output/tables/dea_ano_m2.csv) e [dea_ano_m2_painel.csv](../output/tables/dea_ano_m2_painel.csv).

**Inconsistência e evidência.** O texto afirma que Estados Unidos e China aparecem em DRS em todos os anos. Nas tabelas M2, a China é **CRS com eficiência de escala igual a 1 em todos os nove anos da Fase A e nos cinco anos do painel**. A Índia também é CRS em 2017 e 2018 no painel. Os Estados Unidos são DRS nas observações verificadas.

**Impacto.** H1 exige eficiência de escala inferior a 0,8 para os grandes investidores, incluindo China e Índia. O teste global de CRS, ainda que validado, não demonstra essa afirmação individual. A classificação de H1 como integralmente “apoiada” é incorreta.

**Sugestão.** Separar H1 em tecnologia global e comportamento dos países selecionados. Publicar uma tabela por país/ano com RTS e eficiência de escala. Corrigir o relato para apoio parcial: a evidência sobre os EUA não se estende à China. Não rejeitar NIRS também não prova que cada país opera em DRS.

## I03 — A inversão da metafronteira não pode ser atribuída ao P&D público

**Localização:** [06_resultados_painel.md](06_resultados_painel.md), seções 9c e 10; [metafronteira_resumo_painel_publico.csv](../output/tables/metafronteira_resumo_painel_publico.csv).

**Inconsistência e evidência.** A interpretação compara 204 observações do modelo GERD com 184 da variante HERD + GOVERD, que exclui seis países. Reestimei a mesma metafronteira VRS agrupada mantendo os **184 identificadores país-ano da variante pública**, mas recolocando o GERD original:

| Especificação e amostra | N | TGR alta renda | TGR renda média |
|---|---:|---:|---:|
| GERD, amostra original | 204 | 0,6065 | 0,9316 |
| GERD, amostra da variante pública | 184 | **0,9271** | **0,7975** |
| HERD + GOVERD, mesma amostra | 184 | 0,9148 | 0,8147 |

A inversão já aparece na segunda linha, **antes de trocar o insumo**. A terceira reproduz os valores armazenados, com diferença numérica inferior a `1e-12`. Estes são resultados pontuais, sem nova inferência bootstrap.

**Impacto.** A mudança de composição basta para produzir a inversão. O resultado disponível não sustenta a atribuição dessa inversão à separação do P&D público. Isso não demonstra que a troca de insumo seja irrelevante para todos os países ou coeficientes.

**Sugestão.** Apresentar as três linhas acima e decompor cada comparação em efeito da amostra e efeito da especificação na amostra comum. Rever a recomendação de modelo principal com base em justificativa de mensuração e resultados comparáveis.

## I04 — Os intervalos do ranking não são ICs demonstrados para as médias

**Localização:** [R/04_figuras_apresentacao.R](../R/04_figuras_apresentacao.R), linhas 33–55; tabelas `ranking_paises_m2*.csv`; seção 4 de [05_resultados_fase_a.md](05_resultados_fase_a.md).

**Inconsistência e evidência.** O código calcula `escore_bc = mean(escore_bc)`, `ic_inf = mean(ic_inf)` e `ic_sup = mean(ic_sup)`, mas rotula as barras como “IC 95%”. A média dos limites de intervalos marginais anuais não tem, em geral, cobertura de 95% para a média temporal. A dependência entre anos e entre unidades que compartilham a fronteira não é incorporada.

Além disso, países são ranqueados sobre anos diferentes: Itália e Indonésia têm dois anos no ranking da Fase A, enquanto China e Polônia têm nove. A ordenação mistura desempenho e composição temporal.

**Impacto.** A afirmação de diferenças ordinais defensáveis por intervalos disjuntos não está amparada pelas barras construídas. O problema é a interpretação inferencial; não implica que todos os escores pontuais estejam errados.

**Sugestão.** Estimar a distribuição da estatística agregada em réplicas coerentes com o desenho de painel e a estimação de fronteira; usar diferenças pareadas ou incerteza de postos para comparações. Enquanto isso, retirar o rótulo “IC 95% da média” e apresentar resultados anuais e `n_anos`. Comparar rankings também em janela e conjunto de países comuns. O objeto `boot` de `Benchmarking::dea.boot` disponibiliza réplicas, cuja dependência precisa ser preservada na agregação. [Manual do Benchmarking, seção dea.boot](https://cran.r-project.org/web/packages/Benchmarking/Benchmarking.pdf).

## I05 — O PDF da apresentação não contém os gráficos indicados

**Localização:** [AI Effiency Analysis.pdf](../AI%20Effiency%20Analysis.pdf), páginas 8–13; [08_brief_deck.md](08_brief_deck.md), slides 8–13.

**Inconsistência e evidência.** A inspeção visual mostra retângulos cinza com ícone de imagem, caminho do arquivo e indicação de dimensões, em vez dos gráficos. São sete imagens: ranking, estimadores, canais, metafronteira, Malmquist, segundo estágio e renda/ano. As páginas 8, 9, 11, 12 e 13 têm um espaço reservado cada; a página 10 tem dois.

**Impacto.** A apresentação cita evidências visuais que não estão no arquivo exportado.

**Sugestão.** Incorporar os PNGs de `output/figures/` no documento de origem do deck e exportar novamente. Conferir visualmente todas as páginas do novo PDF e a legibilidade dos gráficos. Usar as figuras recalculadas quando dependerem das correções desta revisão.

## I06 — O N informado nas regressões não corresponde aos casos usados

**Localização:** [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R), `TruncadaAgrupada`, linhas 90–113; tabelas `segundo_estagio_truncada*.csv`.

**Inconsistência e evidência.** A tabela usa `nrow(d)` e `length(unique(d$pais))`, antes da exclusão de ausências nas variáveis da fórmula. Para H5 principal:

| Variante | N informado | Casos completos da fórmula | Países informados | Países com casos completos |
|---|---:|---:|---:|---:|
| Volume | 204 | **144** | 47 | **38** |
| Qualidade | 117 | **85** | 44 | **35** |

Esses casos completos são os que a regressão pode utilizar, após a omissão de valores ausentes. O código reconhece o problema explicitamente para `dados_sw`, mas não corrige o N exportado pela truncada.

**Impacto.** A cobertura do segundo estágio é apresentada como superior à real, ocultando seleção por disponibilidade de contexto. O mesmo mecanismo pode afetar outros modelos, cada qual com sua fórmula.

**Sugestão.** Formar a amostra completa por fórmula antes do ajuste e da reamostragem. Registrar N e países do efetivo quadro de modelagem, além de uma tabela de exclusões. Comparar especificações na mesma amostra quando a intenção for avaliar mudança de método ou de variável.

## I07 — O bootstrap agrupado não reproduz a incerteza da primeira etapa

**Localização:** [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R), linhas 90–106; [01_hipoteses.md](01_hipoteses.md), H5.

**Inconsistência e evidência.** As réplicas sorteiam países de uma tabela de escores já calculados e refazem somente a regressão truncada. O bootstrap DEA anterior corrige os escores, mas suas réplicas não entram no segundo estágio. Assim, a inferência trata a variável dependente gerada como fixa nessa etapa e não reproduz a estimação compartilhada da fronteira.

**Impacto.** O procedimento pode servir como sensibilidade descritiva, mas não herda automaticamente a validade do algoritmo 2 de Simar–Wilson. Concordância de sinais com Tobit também não valida os intervalos. A dependência entre eficiências estimadas é precisamente uma motivação para o procedimento específico de duas etapas. [Simar e Wilson (2007)](https://www.sciencedirect.com/science/article/abs/pii/S0304407605001594).

**Sugestão.** Definir o modelo estatístico e adotar inferência de fronteira compatível com ele e com o painel. Validar uma extensão que trate dependência temporal e incerteza das etapas; apenas reestimar uma DEA em bootstrap ingênuo também não garante validade. Até essa validação, distinguir claramente “truncada com escores fixos e reamostragem de países” do algoritmo Simar–Wilson.

## I08 — A distribuição da truncada não respeita o suporte da eficiência

**Localização:** [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R), linhas 81–86.

**Inconsistência e evidência.** A dependente é `1 / Farrell`, em `(0,1]`, mas a regressão normal é truncada apenas à direita em 1. Seu suporte permite valores negativos. O comentário sugere que modelar Farrell ou seu inverso seria uma troca de escala: porém, se `F = Zβ + ε`, então `1/F = 1/(Zβ + ε)`, que não é uma regressão linear com erro normal truncado equivalente.

**Impacto.** O modelo usado requer justificativa própria. Inverter o sentido dos coeficientes ajuda a ler a associação, mas não torna magnitudes, verossimilhança e inferência equivalentes às do algoritmo 2 em Farrell.

**Sugestão.** Usar Farrell com truncamento inferior em 1 no procedimento correspondente, ou definir explicitamente um modelo para a eficiência limitada a `(0,1]`, com tratamento dos dois limites e inferência adequada. Badunenko e Tauchmann discutem extensões para medidas limitadas e a necessidade de respeitar o suporte. [Badunenko e Tauchmann (2019), seção 2.3](https://journals.sagepub.com/doi/abs/10.1177/1536867X19893640).

## I09 — O teste de RTS foi adaptado sem validação de equivalência

**Localização:** [R/02b_teste_rts.R](../R/02b_teste_rts.R), linhas 41–76; [teste_rts.csv](../output/tables/teste_rts.csv) e [teste_rts_painel.csv](../output/tables/teste_rts_painel.csv).

**Inconsistência e evidência.** A rotina própria é apresentada como o teste de Simar–Wilson (2002), mas muda elementos substantivos em relação à implementação instalada `rDEA` 1.2.8: suaviza diretamente distâncias em `(0,1]`, aplica corte artificial em `1e-4`, usa média da amostra sorteada na correção de variância e reavalia os próprios pseudoprodutos. Em `rDEA::rts.test`, a suavização ocorre na medida inversa; a rotina de DEA distingue observações avaliadas e conjunto de referência reamostrado.

Há ainda um problema de controle: `na.rm = TRUE` nas duas médias pode produzir uma estatística finita com subconjuntos diferentes após falhas de LP. Nesse caso a réplica seria contada como válida, embora o comentário prometa descartá-la.

**Impacto.** Os p-valores não estão certificados como os do procedimento citado. Esta revisão identifica a falta de validação, **não demonstra que a decisão CRS/VRS necessariamente se inverterá**.

**Sugestão.** Comparar a rotina com uma implementação de referência em pequenas amostras e simulações com RTS conhecido, verificando tamanho e poder. Preservar exatamente o mecanismo de geração e avaliação de pseudodados; descartar a réplica inteira se uma distância necessária falhar. O manual do Benchmarking contém um exemplo de teste com réplicas CRS/VRS sincronizadas. [Benchmarking, exemplo de teste em dea.boot](https://cran.r-project.org/web/packages/Benchmarking/Benchmarking.pdf), [Simar e Wilson (2002)](https://www.sciencedirect.com/science/article/abs/pii/S0377221701001679).

## I10 — As análises não usam a mesma definição temporal de fronteira

**Localização:** [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R), `DeaPorAno` e seção 7; [R/02b_teste_rts.R](../R/02b_teste_rts.R), seleção da amostra; [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R), bloco Simar–Wilson.

**Inconsistência e evidência.** Rankings e truncada principal usam escores de fronteiras anuais. Metafronteira, teste global de RTS e algoritmo 2 usam todas as observações conjuntamente. No algoritmo 2, a fronteira ainda é estimada apenas nos casos completos de contexto. Dummies de ano na regressão não tornam essa fronteira agrupada igual à contemporânea.

**Impacto.** A comparação “três métodos concordam” muda método, fronteira e conjunto de referência simultaneamente. Uma fronteira agrupada também permite que anos posteriores sirvam de referência aos anteriores, enquanto o Malmquist pressupõe fronteiras que mudam no tempo.

**Sugestão.** Definir qual tecnologia cada análise pretende medir. Se ambas forem relevantes, apresentar fronteira contemporânea e fronteira global como especificações diferentes. Fazer comparações de estimadores com amostra e tecnologia temporal fixas; não usar um teste agrupado como validação automática de cada fronteira anual.

## I11 — A parcela de “variância explicada” do Malmquist está mal definida

**Localização:** [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R), linhas 311–315; seções de H4 em [05_resultados_fase_a.md](05_resultados_fase_a.md) e [06_resultados_painel.md](06_resultados_painel.md).

**Inconsistência e evidência.** O código usa `Var(log TC) / [Var(log TC) + Var(log EC)]` e chama o resultado de parcela da variância do índice explicada por TC. Como `M = TC × EC`, a identidade correta é:

```text
Var(log M) = Var(log TC) + Var(log EC) + 2 Cov(log TC, log EC).
```

No painel em volume: `Var(log M) = 0,064675`, `Var(log TC) = 0,047935`, `Var(log EC) = 0,078818` e `2 Cov = −0,062078`. Logo, o denominador usado, aproximadamente `0,126754`, é quase o dobro da variância do índice. Os **37,82%** reportados não têm o significado atribuído.

**Impacto.** O critério de H4a não foi implementado como escrito. A expressão “dominância” na seção 10 do painel também não acompanha nem o indicador atualmente usado, que fica abaixo de 50%.

**Sugestão.** Reportar a identidade completa e definir previamente a convenção de atribuição da covariância. Como ilustração, repartir a covariância igualmente entre TC e EC resulta em contribuição de TC de **26,12%** no painel; isso é uma convenção contábil, não uma explicação causal. Alternativamente, renomear a estatística atual como participação de TC na soma das variâncias dos componentes, sem afirmar que mede variância explicada de M.

## I12 — “Não há convergência” usa um critério diferente do declarado

**Localização:** [01_hipoteses.md](01_hipoteses.md), H4; [05_resultados_fase_a.md](05_resultados_fase_a.md), seção 7; [06_resultados_painel.md](06_resultados_painel.md), seção 6.

**Inconsistência e evidência.** O critério formal exige EC médio da renda média superior a 1, com IC excluindo 1. Na Fase A, EC da renda média é **1,074**, mas a hipótese é descartada porque o valor é menor que o da alta renda, **1,109**. Esses são critérios diferentes: aproximação da própria fronteira e aproximação relativa entre grupos. Os ICs de EC e a regressão de β-convergência previstos não foram produzidos.

Também há alternância entre “renda média-alta” e a agregação de todas as rendas médias. Comparar médias pontuais de grupos não resolve essa mudança de população.

**Impacto.** O resultado permite descrição das médias, mas não a decisão inferencial apresentada. No painel, EC abaixo de 1 tampouco substitui o teste e seu intervalo.

**Sugestão.** Separar aproximação da fronteira, convergência relativa entre grupos e β-convergência. Fixar o grupo-alvo, estimar incerteza com procedimento adequado ao painel e executar o teste prometido. Até lá, escrever “a estimativa pontual de EC foi X; a convergência não foi formalmente testada”.

## I13 — H3 é julgada com testes que não correspondem ao seu enunciado

**Localização:** [01_hipoteses.md](01_hipoteses.md), H3; [06_resultados_painel.md](06_resultados_painel.md), seção 5; [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R), linhas 269–271.

**Inconsistência e evidência.** H3a exige `ρ < 0,5`, mas é descrita como apoiada “com folga” com `ρ = 0,42 [0,26; 0,54]`; o intervalo inclui 0,5. O intervalo do volume, `0,48 [0,37; 0,59]`, também inclui o limiar. Há estimativas pontuais compatíveis, mas não evidência conclusiva pelo intervalo exibido.

H3b exige TGR da renda média significativamente abaixo de 1. O código testa diferença entre grupos com Mann–Whitney, outra hipótese. Uma TGR de 0,93 na renda média pode ser inferior a 1 e simultaneamente superior à TGR de 0,61 na alta renda; por isso “contrariada” não decorre diretamente do critério escrito. Além disso, TGR ≤ 1 resulta da inclusão da fronteira de grupo na metafronteira.

**Sugestão.** Definir se a pergunta é `TGR_média < 1` ou `TGR_média < TGR_alta`, e usar inferência apropriada para a estatística e seu limite. Para H3a, testar unilateralmente o limiar, com incerteza compatível com o painel. Ajustar os status para “compatível no ponto, inconclusivo” quando o teste não sustentar a decisão.

## I14 — Correlações e testes por renda tratam país-ano como observações independentes

**Localização:** [R/funcoes.R](../R/funcoes.R), `SpearmanComIc`, linhas 137–156; [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R), testes TGR; [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R), `TesteGrupos`.

**Inconsistência e evidência.** `SpearmanComIc` sorteia índices de linhas; não recebe país. Mann–Whitney e Kruskal–Wallis também recebem todas as linhas país-ano sem tratar repetição. Isso ocorre nas correlações dos canais, dos estimadores e de fornecedores em painel, embora a regressão principal reconheça o agrupamento por país.

**Impacto.** Intervalos e p-valores podem ficar mal calibrados; o número de linhas não é o número de unidades independentes. Para escores DEA, existe adicionalmente dependência pela fronteira compartilhada. A crítica não se aplica da mesma forma à comparação transversal Quid com uma linha por país.

**Sugestão.** Para correlações de dados observados, preservar trajetórias completas de país na reamostragem, justificando também o tratamento de choques comuns. Para escores estimados, incorporar a estimação da fronteira em um procedimento validado. Apresentar agregações por país como sensibilidade descritiva, sem confundir isso com solução geral da inferência DEA.

## I15 — Troca de significância não demonstra mudança de efeito; correlação de rankings não prova robustez de todas as conclusões

**Localização:** [06_resultados_painel.md](06_resultados_painel.md), seções 3, 7, 8, 9a e 10; [08_brief_deck.md](08_brief_deck.md), slides 15–16.

**Inconsistência e evidência.** Volume usa 204 observações de 2017–2021; qualidade usa 117 de 2017–2019. O coeficiente de governo passa de `−0,180 [−0,298; −0,061]` para `−0,076 [−0,257; 0,089]`. A passagem de significativo a não significativo é descrita como desaparecimento da associação, sem teste da diferença entre coeficientes e com amostras distintas.

A frase “o que altera os resultados é a qualidade, não o fornecedor” também é excessiva: na própria seção 9a, trocar patentes CSET por OCDE inverte a comparação de eficiência do canal de patentes por renda e muda a significância de talento e crédito. Uma correlação de rankings de 0,85 não impede essas alterações.

**Conferência adicional.** Na amostra comum de 117 observações, reestimar a metafronteira com produtos em volume dá TGR de **0,5930/0,8675** para alta/média renda; com os produtos alternativos, **0,9438/0,8349**. Portanto, a inversão pontual de qualidade persiste nesse controle. Isso fortalece esse achado específico, mas não valida automaticamente rankings, coeficientes ou p-valores.

**Sugestão.** Reestimar variantes no mesmo conjunto país-ano, separar depois o ganho de cobertura e testar diretamente diferenças de coeficientes/estatísticas com réplicas pareadas adequadas. Trocar “desaparece” por “deixa de ser estatisticamente distinguível de zero nesta especificação”. O princípio de que diferença de significância não é teste da diferença é discutido por [Gelman e Stern (2006)](https://sites.stat.columbia.edu/gelman/research/unpublished/signif3.pdf).

## I16 — Zeros de investimento não tornam necessariamente M2 inviável

**Localização:** [02_dados_externos.md](02_dados_externos.md), seção 1; [R/02_fronteiras_dataset_atual.R](../R/02_fronteiras_dataset_atual.R), linhas 41–44; [R/02b_teste_rts.R](../R/02b_teste_rts.R), linhas 25–26.

**Inconsistência e evidência.** A justificativa “insumo zero inviabiliza CRS” é estendida a todos os modelos. Para M1, uma unidade com único insumo zero e produto positivo cria um problema importante. Em M2, o GERD positivo pode limitar a expansão; zero em uma coordenada não é automaticamente inviabilidade.

Reestimei DEA CRS M2 nos anos da Fase A que contêm zeros, **incluindo todas as respectivas observações**: 2013, 2014, 2015, 2016, 2017 e 2018 produziram escores de Farrell finitos. A existência de uma solução não resolve, por si só, a qualidade da medida zero.

**Impacto.** A regra comum elimina 17 observações e toda a participação da Eslovênia na DEA da Fase A, sem a necessidade matemática alegada para M2. Isso seleciona justamente sistemas cuja produção pode depender de outros recursos.

**Sugestão.** Separar amostra comum M1/M2, útil para comparação, de amostra elegível de M2. Testar M2 incluindo zeros e justificar a interpretação do zero como ausência de transação registrada. Não substituir zeros por constantes pequenas arbitrárias.

## I17 — A supereficiência não ocorre “exatamente” nas observações-piso

**Localização:** [05_resultados_fase_a.md](05_resultados_fase_a.md), seção 1; [08_brief_deck.md](08_brief_deck.md), slide 4; PDF, página 4; [supereficiencia_m2_pooled.csv](../output/tables/supereficiencia_m2_pooled.csv).

**Inconsistência e evidência.** Há **19 observações** com Farrell de supereficiência finito e inferior a 1; apenas **7** têm `inv_piso = TRUE`. Exemplos fora do piso incluem China 2013, com investimento de aproximadamente US$ 140,7 milhões; Índia 2019, com US$ 981,5 milhões; e Índia 2020, com US$ 26,6 bilhões. Os zeros nem entram nessa estimação.

**Impacto.** Um problema real de granularidade é usado como explicação total dos pontos extremos, sem correspondência com os próprios dados.

**Sugestão.** Apresentar a tabela cruzando supereficiência, investimento, marca de piso e influência sobre a fronteira. Substituir “exatamente essas” por uma descrição quantificada. Avaliar influência individual e sensibilidade à retirada de unidades, preservando a distinção entre ponto extremo válido e erro de medida.

## I18 — P&D executado em certos setores não equivale a financiamento público

**Localização:** [01_hipoteses.md](01_hipoteses.md), H2; [03_codebook.md](03_codebook.md), `gerd`, `pd_publico` e `pd_publico_pct_pib`; [06_resultados_painel.md](06_resultados_painel.md), seção 9c.

**Inconsistência e evidência.** H2 identifica GERD com gasto público, embora GERD seja o total de P&D interno, inclusive empresarial. HERD + GOVERD muda para setores de execução, mas não identifica exclusivamente a origem pública dos recursos: ensino superior pode receber financiamento privado, e governo pode financiar P&D executado em empresas. A distinção entre execução e financiamento é explícita no [Manual de Frascati, capítulo 4](https://www.oecd.org/content/dam/oecd/en/publications/reports/2015/10/frascati-manual-2015_g1g57dcb/9789264239012-en.pdf).

**Impacto.** Os modelos não separam de forma limpa “dinheiro público” e “dinheiro privado”. Além disso, financiamento captado por empresas e gasto realizado em P&D são conceitos diferentes, potencialmente sobrepostos; os dados usados não permitem quantificar essa sobreposição.

**Sugestão.** Renomear a proxy como “P&D executado pelo ensino superior e governo”. Se H2 tratar da origem do financiamento, buscar GERD discriminado por fonte de recursos. Explicitar que os insumos não são duas parcelas aditivas e mutuamente exclusivas do custo de IA; não interpretar seus coeficientes como elasticidades de dois financiamentos perfeitamente separados.

## I19 — A concentração total de talento foi substituída por média não ponderada

**Localização:** [R/12_import_fontes_alternativas.R](../R/12_import_fontes_alternativas.R), linhas 49–60; [03_codebook.md](03_codebook.md), `talento_ia_pct`; [06_resultados_painel.md](06_resultados_painel.md), seção 9.

**Inconsistência e evidência.** A média simples das concentrações feminina e masculina é rotulada como concentração de talento no país. Uma taxa total exige os pesos dos denominadores, além de tratamento compatível de membros sem gênero identificado. O próprio repositório contém uma taxa total publicada para 2024 que diverge da construção:

| País | Média simples usada | Total publicado em `fig_4.2.17` |
|---|---:|---:|
| Israel | 2,240% | 1,980% |
| Grécia | 1,000% | 0,830% |
| Finlândia | 1,235% | 1,130% |
| Alemanha | 1,015% | 1,090% |

**Impacto.** O índice responde à composição e às definições por gênero; não é intercambiável com a taxa total. As diferenças não permitem reconstruir os pesos sem metadados adicionais.

**Sugestão.** Usar a série total publicada, se disponível, ou ponderar pelos denominadores compatíveis. Sem esses dados, renomear para “média não ponderada das taxas por gênero”, justificar seu uso e analisar as taxas separadamente como sensibilidade. Rever conclusões de ausência/presença de associação de talento.

## I20 — “Patentes” e “ajuste por qualidade” não estão definidos com precisão suficiente

**Localização:** [02_dados_externos.md](02_dados_externos.md), seção 2; [03_codebook.md](03_codebook.md); [R/11_import_cset.R](../R/11_import_cset.R), linhas 60–71; [06_resultados_painel.md](06_resultados_painel.md), variantes de qualidade e fonte.

**Inconsistência e evidência.** A documentação metodológica atual do CSET descreve patentes em termos de famílias, atribuição à primeira jurisdição de depósito e ano de prioridade; para concedidas, a tabela anual se refere ao ano do depósito de patentes posteriormente concedidas. Portanto, os rótulos genéricos “pedidos por escritório” e “patentes concedidas por ano” não esclarecem unidade e coorte. É necessário confirmar a definição da versão efetivamente baixada. [Documentação do CSET/ETO, seção patents](https://eto.tech/dataset-docs/country-ai-activity-metrics/).

**Impacto.** Trocar para famílias IP5 por inventor envolve mais dimensões que o país de atribuição. Na variante de qualidade, citações totais continuam combinando volume e impacto, e patentes concedidas continuam combinando volume e seleção administrativa. Cortar citações em 2020 reduz exposição aos anos mais recentes, mas não iguala janelas de citação nem controla composição de áreas. A metafronteira agrupada e o Malmquist são especialmente sensíveis à comparação entre coortes com maturação diferente.

**Sugestão.** Arquivar metadados da safra e registrar unidade, data de referência, regra de contagem e relação entre pedidos/concedidas. Rotular a variante como “produtos alternativos: citações e famílias posteriormente concedidas” até justificar a expressão “ajuste por qualidade”. Buscar janelas fixas e normalização por área/coorte; se indisponíveis, declarar que a qualidade não foi isolada de volume e maturação.

## I21 — O diagnóstico de separabilidade não testa separabilidade

**Localização:** [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R), linhas 266–278; [01_hipoteses.md](01_hipoteses.md), H5; [06_resultados_painel.md](06_resultados_painel.md), seção 7.

**Inconsistência e evidência.** O bloco chamado “Separabilidade (diagnóstico simples)” calcula correlações entre Z e eficiência. Essas correlações podem existir tanto quando Z afeta a distribuição da ineficiência quanto quando desloca as possibilidades de produção; não distinguem as duas situações.

O teste formal é reconhecido como pendente, mas o resultado institucional é descrito como associação “negativa e robusta” sem essa condição resolvida. Separabilidade diz respeito ao suporte produtivo condicionado em Z, não à ausência de correlação Z–escore. [Daraio, Simar e Wilson (2018)](https://academic.oup.com/ectj/article/21/2/170/5078970).

**Sugestão.** Renomear a tabela como diagnóstico descritivo de associação. Implementar o teste pertinente ou usar fronteiras condicionais com hipótese explícita. Até lá, tratar o segundo estágio como exploratório e evitar interpretar o sinal de instituições como efeito sobre uma mesma tecnologia acessível a todos.

## I22 — Um resultado antigo permanece disponível quando o novo algoritmo 2 falha

**Localização:** [R/03_segundo_estagio_dataset_atual.R](../R/03_segundo_estagio_dataset_atual.R), linhas 194–214; [log_03_painel_qualidade.txt](../output/log_03_painel_qualidade.txt); [06_resultados_painel.md](06_resultados_painel.md), seção 7.

**Inconsistência e evidência.** Se `sw` for `NULL`, o script registra a falha, mas não invalida um CSV anterior. O log da qualidade registra interrupção após 600 segundos e, em seguida, conclusão do script. O texto informa que usa os números da execução anterior. Há transparência narrativa, porém falta um vínculo verificável entre essa saída antiga e a base/configuração atual.

**Impacto.** Uma execução pode parecer completa e deixar uma mistura de resultados novos e antigos sob o mesmo sufixo. Uma reanálise após corrigir o filtro ou a amostra pode reutilizar indevidamente uma tabela obsoleta.

**Sugestão.** Produzir um manifesto por execução com status de cada etapa, identificador, configuração e hashes dos insumos. Em falha, marcar a saída corrente como indisponível; arquivar resultados anteriores sob o identificador original. Exigir compatibilidade de manifesto antes de gerar sínteses e figuras. Preservar o resultado antigo para auditoria, sem apresentá-lo como recém-reproduzido.

## I23 — Os documentos descrevem estados diferentes do projeto

**Localização:** [05_resultados_fase_a.md](05_resultados_fase_a.md), seção 9; [06_resultados_painel.md](06_resultados_painel.md), seções 1, 9c e 10; [07_registro_de_trabalho.md](07_registro_de_trabalho.md), seções 2, 4 e 6; [02_dados_externos.md](02_dados_externos.md), seção 5.

**Inconsistências confirmadas.**

- A seção 9 dos resultados da Fase A ainda informa **45 países e 37–42 observações/ano**, enquanto o painel atual tem **47 países e 37–44** no modelo conjunto.
- `07_registro_de_trabalho.md` ainda chama VC Preqin de pendente e solicita conferir/concluir a variante de fonte, embora sua própria seção 6 e `06_resultados_painel.md` registrem essas análises concluídas.
- A seção 10 de `06_resultados_painel.md` pede exportações de patentes e VC já utilizadas nas seções 9a e 9b.
- A coluna “Zeros/piso removidos” da seção 1 apresenta **204 e 117 observações**, que são as amostras com piso; as saídas atuais sem piso têm **196 e 111**, ainda com o erro I01.
- Na variante pública, o texto arredonda TGR para **0,92 e 0,82**, mas a tabela atual tem **0,9148048 e 0,8147483**, cujo arredondamento usual a duas casas é **0,91 e 0,81**.
- O slide de dados diz “sem nórdicos”, mas Noruega está no dataset original e no ranking. O título com 37 países descreve a base bruta; a DEA principal usa 36 após a exclusão dos zeros.

**Sugestão.** Definir uma versão de referência, gerar automaticamente os números e status usados na redação e manter um único quadro de amostras: base bruta, DEA, sensibilidade, Malmquist e cada regressão. Separar claramente plano futuro de resultado executado. Atualizar brief e PDF a partir dessa mesma versão.

## I24 — CSET e Preqin não medem apenas duas versões do mesmo VC

**Localização:** [01_hipoteses.md](01_hipoteses.md), H4; [06_resultados_painel.md](06_resultados_painel.md), seções 8 e 9b; [R/12_import_fontes_alternativas.R](../R/12_import_fontes_alternativas.R), filtro `STAGE == "VC"`; [data/README.md](../data/README.md), metadados OECD.AI.

**Inconsistência e evidência.** A metodologia CSET inclui equity em empresas fechadas abrangendo VC, private equity e fusões/aquisições, e exclui empresas listadas. A exportação Preqin usada pelo código restringe-se ao estágio `VC`. Assim, há mudança de universo de transações, além de fornecedor. [Documentação CSET/ETO, seção AI company and investment metrics](https://eto.tech/dataset-docs/country-ai-activity-metrics/).

O arquivo `vc_metadata.txt` contém apenas uma descrição genérica da Preqin; não documenta unidade, filtros e momento de extração. Para publicações, `data/README.md` informa que `metadata.txt` foi reconstruído após sobrescrita. Isso enfraquece a auditoria de equivalência das medidas, sem demonstrar que os valores estejam errados.

**Impacto.** Diferenças de nível, como a razão China CSET/Preqin de 0,35, não podem ser atribuídas exclusivamente à cobertura dos fornecedores. Correlação alta também não comprova equivalência conceitual.

**Sugestão.** Descrever a variante como “troca de fornecedor e de universo de investimento”, a menos que os tipos de negócio sejam harmonizados. Arquivar o ZIP/exportação original, filtros, unidade e data; guardar metadados reconstruídos separadamente dos originais. Evitar chamar toda a série CSET de capital de risco ou inferir que todo o financiamento captado foi gasto em produção científica no ano seguinte.

## Ordem sugerida de resolução

1. **Corrigir os erros verificáveis:** I01, I02, I03, I04, I06, I11 e I17. Atualizar o status das hipóteses e incorporar as figuras no PDF (I05).
2. **Estabilizar o desenho:** fixar amostra comum, definição temporal da fronteira, tratamento dos zeros, grupos de renda e conceitos dos insumos/produtos; depois refazer as comparações.
3. **Validar a inferência:** RTS, segundo estágio, dependência do painel, diferenças entre variantes e testes de H3/H4. Registrar resultados ainda inconclusivos como tais.
4. **Regenerar resultados e documentação:** usar um identificador de execução e conferir se texto, tabelas, figuras e PDF correspondem à mesma versão.

SFA por canal, classes latentes, separabilidade formal e robustez de defasagens são explicitamente declaradas como pendências em partes do projeto. Sua ausência não foi tratada aqui, isoladamente, como erro; o problema é apresentar conclusões como se a evidência necessária já estivesse disponível. Também não foi considerado erro, por si só, usar bases monetárias 2015 e 2021 em colunas distintas da DEA: mudanças constantes de unidade por variável não invalidam o modelo. O problema de mensuração relevante é a comparabilidade econômica dos insumos e sua correspondência com os produtos.

## Conferências reproduzíveis

O trecho abaixo pode ser executado na raiz do projeto. Apenas lê arquivos e imprime resultados; não chama `R/00_setup.R`, não baixa dados e não sobrescreve saídas. Requer `Benchmarking` já instalado. Reproduz os principais diagnósticos de piso, RTS da China, composição da metafronteira e decomposição de variância.

```r
source("R/funcoes.R")
painel <- read.csv("data/processed/painel_ia.csv")
LerTabela <- function(nome) {
  read.csv(paste0("output/tables/", nome, ".csv"))
}

# I01: comparar a marca usada com o piso do efetivo insumo.
for (s in c("_painel", "_painel_qualidade", "_painel_fonte",
            "_painel_preqin", "_painel_publico")) {
  d <- merge(LerTabela(paste0("dea_ano_m2", s)), painel, by = "id")
  insumo <- if (s == "_painel_preqin") {
    "investimento_preqin_l1"
  } else "investimento_l1"
  piso <- d[[insumo]] > 0 & d[[insumo]] <= 2.5e6
  print(data.frame(variante = s, n = nrow(d),
    removidas = sum(d$inv_piso), piso_correto = sum(piso),
    remocao_indevida = sum(d$inv_piso & !piso),
    piso_mantido = sum(!d$inv_piso & piso)))
}

# I02: confrontar a afirmação sobre a China com a tabela M2.
for (s in c("", "_painel")) {
  d <- LerTabela(paste0("dea_ano_m2", s))
  print(d[grepl("^CHN-", d$id), c("id", "rts", "eficiencia_escala")])
}

# I03 e I15: mesma amostra, antes e depois de mudar a especificação.
for (s in c("_painel", "_painel_publico", "_painel_qualidade")) {
  ids <- LerTabela(paste0("dea_ano_m2", s))$id
  d <- painel[painel$id %in% ids, ]
  g <- ifelse(d$grupo_renda == "Alta renda", "Alta", "Média")
  for (variante in c(FALSE, TRUE)) {
    insumos <- c("investimento_l1",
      if (variante && s == "_painel_publico") "pd_publico_l1" else "gerd_l1")
    produtos <- if (variante && s == "_painel_qualidade") {
      c("citacoes_ok", "patentes_concedidas_ok")
    } else c("publicacoes", "patentes")
    x <- as.matrix(d[, insumos]) / 1e6
    y <- as.matrix(d[, produtos])
    meta <- CalcularDea(x, y, d$id)$escore
    grupo <- numeric(nrow(d))
    for (categoria in unique(g)) {
      i <- g == categoria
      grupo[i] <- CalcularDea(x[i, ], y[i, ], d$id[i])$escore
    }
    print(list(amostra = s, usa_variante = variante,
               tgr = tapply(meta / grupo, g, mean)))
  }
}

# I11: verificar a identidade, incluindo a covariância.
d <- LerTabela("malmquist_m2_painel")
t <- log(d$mudanca_tecnica)
e <- log(d$mudanca_eficiencia)
print(c(var_m = var(log(d$malmquist)), var_tc = var(t),
        var_ec = var(e), duas_cov = 2 * cov(t, e),
        indicador_atual = var(t) / (var(t) + var(e)),
        rateio_simetrico = (var(t) + cov(t, e)) / var(t + e)))
```

As referências externas estão vinculadas aos achados que sustentam. As verificações algébricas e as divergências entre arquivos são resultados desta revisão; não foram atribuídas aos artigos citados.
