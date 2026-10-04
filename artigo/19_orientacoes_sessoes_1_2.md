# Orientações das sessões de laboratório (14 e 21/09/2026) e exigências do programa da disciplina

Registro feito em 04/10/2026. As duas sessões de laboratório com o professor aconteceram antes deste repositório existir: o trabalho começou num repositório anterior, `~/Projects/investimentos_ia` (https://github.com/fernandofsilva/investimentos_ia, de 19 a 21/09/2026). Este repositório foi aberto em 27/09 com um plano novo e não trouxe essas orientações, nem remetia àquele repositório. Este documento as resume, diz a situação de cada uma aqui e registra as pendências.

**Fontes no repositório anterior:**
- `documentos/analise_critica.md` (19/09): comentários da sessão 1 lidos contra as propostas v1 e v2.
- `documentos/orientacao_sessao_2.md` (21/09): orientações da sessão 2 e o que mudou.
- `STATUS.md`: identificação da disciplina, avaliação, exigências do programa e decisões.

As datas das sessões são as do programa da disciplina (laboratórios de 14 e 21/09). As transcrições (`material_disciplina/comments.txt` e `comments_sessao_2.txt`) ficam lá e não foram copiadas para cá, pela mesma regra do `artigo/13`: são transcrições literais e informais, com falas de terceiros. As falas abaixo estão parafraseadas. O programa da disciplina está em `others/`.

## 1. O que o programa da disciplina exige

Disciplina *Introdução à Análise de Eficiência em R*, Escola de Métodos, Prof. Peter Wanke, 30 horas, em português.

**Avaliação:**
- **Manuscrito** submetido a periódico Qualis até a data-limite de lançamento das notas. Pode ser em grupo e deve refletir, de forma aplicada, as metodologias do curso.
- **Apresentação em PowerPoint** de 20 minutos, com diagnóstico setorial (feita em 28/09).

Nas sessões de laboratório, o programa pede que o aluno escolha uma base própria e "replique as análises desenvolvidas nas sessões anteriores". Técnica por técnica:

| Técnica do programa | Situação neste repositório |
|---|---|
| FDH | feita (`R/02`) |
| DEA CCR e BCC, cálculo de eficiências | feita (`R/02`) |
| Folgas | calculadas (`folga_insumos_vrs`, `folga_produtos_vrs` em `dea_ano_*`), mas não analisadas em nenhum documento |
| Ganhos potenciais com fusões | **não feita** |
| Índice de Malmquist | feita (`R/02`; convenção corrigida em `artigo/18`) |
| TOPSIS | **não feita** |
| Bootstrap | feito (Simar e Wilson, 1998; `R/02`) |
| SFA | feita (`R/06`) |
| Order-m e order-α | feitas (`R/02`) |
| Classes latentes | feitas na forma de SFA de duas classes (`sfaR`, `R/06`); o material de aula usa `poLCA` sobre decis de insumos e produtos |
| Variáveis contextuais e testes não paramétricos | feitos (Kruskal-Wallis e Mann-Whitney, `R/03`); o material de aula usa também Kolmogorov-Smirnov |
| Teste de separabilidade de Daraio e Simar | **não feito** (já pendente no `artigo/07`) |
| Tobit e regressão truncada com bootstrap | feitos (`R/03`) |
| Apresentação em PowerPoint | apresentada como PDF gerado no Claude Design; a nova versão (errata no `artigo/08`, seção 2a) pode ser exportada em `.pptx` |

## 2. Sessão 1 (14/09/2026)

| Orientação (parafraseada) | Situação neste repositório |
|---|---|
| Produtos: publicações e patentes. Insumos: o investimento em IA e o gasto em P&D | seguida |
| Rodar CCR e BCC para ter o contrafactual de retornos de escala | seguida (H1) |
| Variáveis de sociodemografia e governança como contextuais, no segundo estágio, inclusive *voice and accountability* | em parte: o bloco WGI usa efetividade, qualidade regulatória, estado de direito e controle da corrupção; *voice and accountability* não entra |
| **Base industrial:** uma proxy de indústria, como a manufatura em % do PIB ou a participação das exportações industriais no comércio. A pesquisa só vira patente se há base industrial; sem ela, fica na universidade (exemplos: Petrobras e a exploração em águas profundas; biocombustíveis) | **não está aqui.** Era a hipótese central do trabalho anterior. O plano de 27/09 reformulou a pergunta, e a única variável próxima é a exportação de alta tecnologia (% das manufaturadas), que não é a proxy pedida |
| Pode deixar os zeros de investimento; se preciso, transformação com deslocamento | superada pela sessão 2 ("zero é zero"; ver seção 3) |
| Não precisa de painel balanceado; o segundo estágio seria um modelo de efeitos aleatórios | painel desbalanceado, seguido; o segundo estágio é uma truncada com bootstrap por país, sem efeitos aleatórios |
| Há quanto tempo cada país começou a investir em IA | não está aqui. No trabalho anterior, a variável se confundia com o primeiro ano observado (28 de 36 países), e com o CSET a partir de 2016 o problema se repete |
| Explorar o tema pela DEA; não se prender às ideias iniciais | seguida |
| A escolha do periódico importa: alguns preferem modelos de mediação e moderação a DEA | aberta: o CEJOR é o candidato desde 28/09 (`artigo/13`, S09); falta o parágrafo "por que fronteira, e não mediação ou moderação" |
| O grupo do professor já explorou a base com econometria | ver seção 3, item 8 |

## 3. Sessão 2 (21/09/2026)

1. **O painel desbalanceado justifica tratar a fronteira agrupada como metafronteira.** No trabalho anterior, isso levou à fronteira global (intertemporal), à razão de lacuna tecnológica por ano e a um Malmquist global (Pastor e Lovell, 2005), que cobre todos os países com pelo menos dois anos, sem exigir painel balanceado.
   - *Situação aqui:* os escores usam fronteiras anuais. A fronteira agrupada serve à supereficiência, à metafronteira por renda, ao teste de RTS e ao algoritmo 2. O Malmquist é o adjacente, no painel balanceado.
   - *Pendência opcional:* o Malmquist global ganhou interesse depois da correção de sentido da RQ1 (`artigo/18`, A01).
2. **"Zero é zero; célula em branco é que é ausência de informação."** Para o professor, o zero de investimento é um zero de verdade: o país não teve investimento privado em IA naquele ano. Ausência de informação é a célula em branco. Tratar o zero como "talvez abaixo de meio milhão" seria análise de ponto de corte. Observações de insumo mínimo que definem a fronteira devem ser interpretadas e discutidas como casos, não excluídas.
   - *Situação aqui:* **conflito.** O `artigo/05` (seção 1) e o `R/02` excluem os zeros do modelo principal e os leem como falha de registro ("negócio não registrado"), ou seja, como dado ruim, e não como zero de verdade. A sensibilidade com os zeros existe (`sensibilidade_zeros_m2*.csv`): as unidades com zero saem quase eficientes (escore VRS médio de 0,83 a 1,00) e rebaixam as demais (na Fase A, de 0,73 para 0,68). No painel, os zeros são poucos (11 na base).
   - *Pendência:* decidir com o professor entre duas saídas:
     - manter a exclusão, com a justificativa reescrita: sob retornos variáveis, uma unidade sem investimento só é comparada a outras sem investimento e sai eficiente por construção; os zeros ficam como sensibilidade discutida;
     - trazer os zeros de volta à especificação principal, discutindo-os como casos.

     Nas duas, retirar a expressão "negócio não registrado".
3. **"Trabalho de cirurgião" na base:** o máximo de observações e de variáveis com o mínimo de faltantes, ranking por país só com pelo menos três anos observados, e uma robustez sem os países com um ou dois anos.
   - *Situação aqui:* o ranking inclui todos os países, com os anos entre parênteses.
     - Na Fase A, 8 dos 36 países têm menos de três anos, entre eles o primeiro (Itália, 2 anos) e o último (Suíça, 1 ano).
     - No painel, 7 dos 47, entre eles o 3º, o 4º e o 5º (Croácia, Sérvia e Ucrânia) e o 46º (Irlanda).
   - *Pendência:* aplicar a regra ao ranking e à escolha dos perfis do S05 (`artigo/13`), ou justificar não aplicá-la.
4. **No manuscrito, a tabela de regressões**, com os modelos lado a lado e as mesmas contextuais. A discussão deve se apoiar nas diferenças entre modelos. A figura de coeficientes serve como síntese, não como substituta.
   - *Situação aqui:* as estimativas estão nos CSVs e na fig4. A tabela no formato de periódico fica para o manuscrito.
5. **Casos que quebram o padrão:** três do topo e três da base, com a hipótese das potências regionais de nicho (México, Brasil e outros). Corresponde ao S05 do `artigo/13`.
   - *Cautela herdada:* unidades que ficam no topo por serem âncoras da fronteira (investimento zero ou mínimo) não devem ser lidas como nicho.
6. **A base de publicações é um subconjunto** (artigos de IA). O professor sugeriu verificar a participação de STEM na produção total de cada país, como argumento adicional na discussão.
   - *Situação aqui:* não feita (opcional).
7. **Capital humano.** Uma colega da turma ofereceu literatura de economia da educação sobre formandos em ciência e tecnologia e patentes. A série de formandos cobre menos da metade das observações e não entra no painel.
   - *Situação aqui:* fica para a revisão de literatura (S09).
8. **Trabalho correlato do grupo.** O professor confirmou que a base foi explorada pelo grupo com econometria, num estudo submetido com um coautor, e disse que verificaria se podia disponibilizar o texto.
   - **Referência identificada:** Fukuyama, Tan e Wanke (2025), *Socio-Economic Planning Sciences*, 100, 102248: DEA para 2013–2021, com ineficiências de trabalho, capital, energia, patentes, PIB e emissões. Segundo o resumo, a ineficiência em patentes predomina na América Latina, no Caribe e nos países de renda média, e o controle da corrupção a reduz.
   - **Por que importa:** o controle da corrupção reduzir a ineficiência em patentes contrasta com a associação negativa entre instituições e eficiência encontrada aqui (RQ2).
   - *Situação aqui:* incluída nas referências do `artigo/01`, marcada S09. Falta ler o texto e confirmar com o professor se é esse o trabalho mencionado.

## 4. Pendências decorrentes

Consolidadas no `artigo/07`, seção 6:

1. **Zeros (seção 3, item 2):** decidir com o professor entre manter a exclusão, com a justificativa reescrita, ou trazer os zeros de volta à especificação principal. Nos dois casos, sai a expressão "negócio não registrado".
2. **Técnicas do programa que faltam:** ganhos com fusões (por exemplo, blocos regionais como consórcios hipotéticos, com `Benchmarking::dea.merge`), TOPSIS para agregar os estimadores num ranking final e a análise das folgas. Opcionais: classes latentes com `poLCA` e o teste de Kolmogorov-Smirnov, como no material de aula. O teste de separabilidade já estava pendente.
3. **Base industrial (sessão 1):** decidir se a manufatura (% do PIB) e a participação das exportações de manufaturados entram como contextuais na RQ2 ou se a omissão é justificada no manuscrito.
4. **Regra dos três anos no ranking (sessão 2, item 3)**, com efeito sobre os perfis do S05.
5. **Manuscrito:**
   - tabela de regressões no formato de periódico;
   - parágrafo "por que fronteira, e não mediação ou moderação";
   - posicionamento contra Fukuyama, Tan e Wanke (2025) e, se o professor disponibilizar, contra o estudo econométrico do grupo.
6. **Opcionais:**
   - *voice and accountability* no bloco WGI;
   - participação de STEM na produção científica;
   - Malmquist global;
   - tempo desde o primeiro investimento;
   - modelo de conversão de publicações em patentes (DEA em rede), que ficou em aberto no trabalho anterior.

**Literatura levantada no trabalho anterior e ainda não incorporada** (para o S09): Kontolaimou, Giotopoulos e Tsakanikas (2016), *Economic Modelling*; Carayannis, Goletsis e Grigoroudis (2015), *Operational Research*.

**Periódicos considerados no trabalho anterior** (o CEJOR, candidato atual, veio depois, na apresentação de 28/09):
- internacionais: *Socio-Economic Planning Sciences*, *Technological Forecasting & Social Change* e *Journal of the Knowledge Economy*;
- nacionais: BAR, RAUSP e BJOPM.
