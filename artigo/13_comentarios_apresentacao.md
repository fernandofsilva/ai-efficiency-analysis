# Comentários do Prof. Peter Wanke na apresentação de 28/09/2026 e pendências decorrentes

**Fonte.** Transcrição automática da apresentação em aula (arquivo `comentarios.txt`, fornecido pelo autor; não versionado no repositório por ser transcrição literal e informal, com falas de terceiros). As falas abaixo estão parafraseadas; os trechos entre aspas são citações curtas da transcrição. A transcrição troca alguns nomes: "Ricardo Calil" é Ricardo Kalil Moraes (S06); "Sejor" é o *Central European Journal of Operations Research*, CEJOR (S09); o indicador "Bloomberg" de efetividade governamental é o WGI do Banco Mundial (S07).

**Como ler.** Cada item traz o que foi dito, o estado atual no projeto (conferido nas tabelas de `output/tables/` e no código em 28/09/2026), a pendência e a prioridade. Os identificadores S01–S10 são usados em `artigo/07_registro_de_trabalho.md` (seção 6). Nenhum cálculo do pipeline foi refeito aqui: os números citados são os vigentes (`artigo/05`, reexecução de 28/09/2026) ou derivados diretamente das tabelas indicadas, sem reestimação.

## 1. Quadro-resumo

| Id | Tema | Tipo | Prioridade | Onde mexer |
|---|---|---|---|---|
| S01 | Padronização min-max das variáveis da fronteira e reexecução completa | cálculo | alta (primeira) | `R/02`, `R/02b`, `R/03`, `R/04`, `R/05`, `output/rodar_pipeline.sh` |
| S02 | SFA de H2 com variáveis reescalonadas | cálculo | alta | novo `R/06_sfa_canais.R` |
| S03 | Menos hipóteses; hipótese × pergunta de pesquisa; fechar cada uma na discussão | decisão e texto | alta (antes de escrever) | `artigo/01`, manuscrito |
| S04 | H1: discutir a heterogeneidade dos retornos de escala com evidência contemporânea | texto | média | manuscrito (discussão) |
| S05 | Ranking: perfis de três países do topo e três ou quatro da base | texto | média (após S01) | manuscrito, fig1 |
| S06 | Malmquist: frontier shift × catch-up por país; tese do platô; Moraes e Wanke (2019) | cálculo leve e texto | média | `R/04`, `artigo/05`, deck (slide 11), manuscrito |
| S07 | Segundo estágio: "bateu na trave" e confirmação de sinal; o que mede a efetividade governamental | cálculo leve e texto | média | `R/03`, `R/04`, `artigo/05`, `artigo/06` |
| S08 | Eficiência por renda e ano: heterogeneidade e sua evolução | cálculo leve e texto | média | `R/02` ou `R/04`, `artigo/05` |
| S09 | Revisão de literatura por hipótese, evidência contemporânea e periódico-alvo | texto e decisão | média | `artigo/01`, manuscrito |
| S10 | Ordem de execução acordada ao final da apresentação | organização | — | `artigo/07` |

## 2. Itens

### S01 — Padronização das variáveis da fronteira (min-max) e reexecução

**O que foi dito.** O professor perguntou se as variáveis foram transformadas antes da DEA (min-max, z-score, log). Resposta: só log, e só no segundo estágio. Ele ponderou que, embora a DEA seja em teoria indiferente à ordem de grandeza, "na prática acaba afetando" quando as variáveis estão em escalas muito diferentes (investimento em milhões, patentes em centenas, artigos em milhares). Sugeriu a transformação min-max: para produto (quanto maior, melhor), (x − mín)/(máx − mín); para insumo, (máx − x)/(máx − mín), "que aí você troca o sentido". Pediu para não misturar transformações (uma variável em log, outra em min-max, outra em z-score) e descreveu o processo como tentativa e erro ("martelinho de ouro das transformações"), sem regra de livro. Consequências que ele antecipou: os rankings "talvez mudem"; a não convergência do SFA (S02) provavelmente vem daí; e ele "só bateria a mão conclusiva" nos resultados depois de rodar com as variáveis transformadas. Na síntese final: "você tem que revisar minimamente a coisa dessa padronização de variáveis".

**Estado atual.** `R/02_fronteiras_dataset_atual.R` usa as unidades originais: insumos em milhões de US$ (`inv_mi`, `gerd_mi`) e produtos em contagem; nenhuma padronização em nenhum script; o log aparece só nas variáveis de contexto (PIB per capita, comércio, pesquisadores, talento) e no dependente do segundo estágio (log do escore). Amplitudes na base (`descritiva_base_atual.csv`): investimento de 0 a 1,5 × 10^11 US$ (mediana 6,6 × 10^7; em milhões, de 0 a 151 mil), GERD de 2,7 × 10^8 a 7,2 × 10^11 US$, publicações de 119 a 77,2 mil (mediana 1,2 mil), patentes de 1 a 84,6 mil (mediana 10). Cada variável cobre de três a cinco ordens de grandeza, com medianas em escalas distintas.

**Pendência.**

1. Implementar a padronização como variante parametrizada do pipeline (variável de ambiente, por exemplo `PADRONIZACAO=minmax`, sufixo de saída `_minmax`), aplicada de forma idêntica a todas as variáveis da fronteira em `R/02`, `R/02b` e `R/03` (o segundo estágio usa os escores resultantes), com figuras em `R/04` e modo próprio em `output/rodar_pipeline.sh`; reexecutar a Fase A e o painel; comparar com a versão em unidades originais em amostra e fronteira comuns, com a decomposição já disponível em `R/05` (ranking, RTS por país, canais, metafronteira, Malmquist, segundo estágio).
2. Decisões de implementação a registrar (e confirmar com o professor quando houver dúvida):
   - *Sentido do insumo.* A fórmula (máx − x)/(máx − mín) inverte o sentido: o menor insumo vira o maior valor transformado. Em um modelo DEA padrão, o insumo já entra com "quanto menor, melhor"; se a variável invertida for tratada como insumo, o modelo passa a premiar quem mais gasta. Duas leituras compatíveis com a fala: (a) usar (x − mín)/(máx − mín) também no insumo, preservando o sentido e mantendo-o como insumo; (b) usar a fórmula invertida e tratar a variável como produto (modelo só de produtos, como em índices compostos). Confirmar a intenção antes de implementar; a opção (a) é a que mantém a interpretação atual de tecnologia de produção.
   - *Zeros criados no mínimo.* A unidade com o menor valor de cada variável fica com 0 após o min-max; um insumo zero torna a unidade eficiente por construção (o mesmo problema dos zeros de investimento, `artigo/05`, seção 1) e um produto zero exclui a unidade do canal. Deslocar a escala para [ε, 1] (por exemplo ε = 0,01 ou 0,1) e testar a sensibilidade a ε; Sarkis (2007) discute a normalização e o tratamento de zeros por deslocamento ao preparar dados para DEA.
   - *Mín e máx por ano ou na amostra agrupada.* Fronteiras contemporâneas admitem normalização por ano, mas a fronteira agrupada (supereficiência, metafronteira, teste de RTS, algoritmo 2) e o Malmquist exigem os mesmos parâmetros em todos os anos; caso contrário as distâncias intertemporais deixam de ser comparáveis. Usar mín e máx da amostra completa para tudo (uma única transformação), ou documentar por que não.
   - *Invariância.* Os modelos CCR e BCC são invariantes a mudança de unidade (multiplicação por constante positiva), mas não à translação: sob CRS, subtrair o mínimo altera os escores; sob VRS orientado a produto (o modelo usado aqui), a translação dos insumos não altera os escores, mas a dos produtos altera (Ali e Seiford, 1990; Lovell e Pastor, 1995; Pastor, 1996). O min-max é translação mais reescalonamento, logo é uma especificação diferente, e não um reescalonamento neutro: escores CRS, eficiência de escala, classificação de RTS e Malmquist CRS devem mudar. Reportar como variante, explicar a origem das diferenças e não apresentar a versão padronizada como "a mesma DEA em outra escala".
   - *Uma só transformação.* Seguir a recomendação de não misturar transformações entre as variáveis da fronteira. O log das variáveis de contexto e do escore no segundo estágio é outro objeto (regressores e dependente), mas a escolha deve ficar explícita na metodologia.
3. Só depois da reexecução: revisar as conclusões de ranking (S05), H1 (S04), H3, H4 (S06) e segundo estágio (S07), como o professor pediu ("só bateria a mão conclusiva rodando as coisas com as variáveis transformadas").

### S02 — SFA de H2 com variáveis reescalonadas

**O que foi dito.** O SFA de H2 rodou por horas sem terminar. O professor: o SFA maximiza a verossimilhança; se o não paramétrico já distorce com escalas diferentes, no paramétrico, com variáveis em milhões, "vai ficar rodando infinito até convergir"; com 208 linhas, horas de execução são indício disso ("essa não é uma base monstruosa de milhares de observações"). Sugestão: rodar com as variáveis padronizadas.

**Estado atual.** Não há chamada a SFA no repositório (`frontier::sfa`, `sfaR::sfacross`, `sfaR::sfalcmcross` ou `Benchmarking::sfa`); os pacotes `frontier`, `sfaR` e `npsf` estão listados em `R/00_setup.R`. As tentativas relatadas na aula não foram versionadas. H2 está como "a testar com SFA" em `artigo/05` (seção 10) e como pendência em `artigo/06` (seção 10, item 6) e `artigo/07` (seção 6, item 5).

**Pendência.** Criar `R/06_sfa_canais.R` (numeração após `R/05`), no padrão dos demais scripts (variáveis de ambiente, `Registrar`, manifesto), com:

1. Variáveis em log (forma Cobb-Douglas, e translog como robustez): log das publicações ou das patentes sobre log do investimento e log do GERD, por canal; o log já resolve a diferença de ordem de grandeza e é a forma padrão do SFA. Se S01 adotar min-max para a DEA, registrar que o SFA usa log: a recomendação do professor foi não misturar transformações entre variáveis de um mesmo modelo, e o SFA em log é uma única transformação para todas.
2. Zeros: unidades com produto zero saem do canal (como na DEA por canal) ou usa-se log(1 + y) com análise de sensibilidade; o insumo zero já está excluído.
3. Controle da estimação: valores iniciais por MQO (padrão de `frontier::sfa`), limite de iterações, verificação do código de convergência e do tempo de execução gravados na tabela, como se faz nas truncadas (`AjustarTruncada`). Com 191 observações em log, a convergência deve levar segundos; se não levar, o problema é outro (colinearidade entre log do investimento e log do GERD, ou assimetria do resíduo de MQO no sentido contrário ao da ineficiência): testar e reportar.
4. Saídas de H2: elasticidades do investimento privado e do GERD por canal com erro-padrão, teste de razão de verossimilhança da presença de ineficiência e comparação entre canais (critério de H2: elasticidade do investimento privado significativa só em patentes); painel com efeitos de ineficiência (Battese e Coelli, 1995) como extensão.
5. Classes latentes (`sfaR::sfalcmcross`) como robustez de H3, somente depois que o SFA simples convergir.

### S03 — Menos hipóteses; hipótese × pergunta de pesquisa; fechar cada uma na discussão

**O que foi dito.** À pergunta de uma colega sobre quantas hipóteses um trabalho deve ter, o professor respondeu que não há número fechado ("já vi de tudo; paper com duas, três hipóteses"), mas que cada hipótese aberta exige ancoragem na revisão de literatura (resultados confirmados, resultados antagônicos, correntes que apontam para lados diferentes, problemas ainda não tratados) ou, na ausência de literatura, uma indução explícita (exemplo dele para H1: se prevalece a lógica microeconômica de uma função de produção, em algum ponto surge uma fase de retornos decrescentes). Quando a base teórica é insuficiente ou o estudo é exploratório, tratar o ponto como pergunta de pesquisa (RQ), não como hipótese: hipótese é reservada ao que recebe tratamento estatístico falseável. E "aquilo que você abrir de hipótese, quando for escrever, você vai ter que justificar uma a uma": bateu, não bateu, por que não bateu, com um pouco de teorização na discussão. O autor reconheceu que abriu sete hipóteses para achar uma linha de raciocínio e que não usaria sete no texto.

**Estado atual.** `artigo/01` tem H1–H7 (H3 e H4 desdobradas em a/b), mais as proposições de robustez R1–R3; H5–H7 dependem de um segundo estágio declarado exploratório (separabilidade não testada). A síntese por hipótese (`artigo/05`, seção 10) já fecha cada uma com status, mas sem a discussão teórica do "por quê".

**Pendência.**

1. Decidir o conjunto de hipóteses do manuscrito. Sugestão a validar pelo autor: manter como hipóteses H1 (retornos de escala, com indução explícita pela função de produção), H3 (canais e metafronteira) e H4 (dinâmica), e H2 se o SFA convergir (S02); converter H5, H6 e H7 em perguntas de pesquisa (RQ1–RQ3, ou uma única RQ sobre determinantes da eficiência), coerente com o caráter exploratório do segundo estágio; manter R1–R3 como robustez.
2. Reescrever a seção de hipóteses com a ancoragem exigida: para cada hipótese, o que a literatura confirma, o que contradiz e qual lacuna ela ataca (ver S09), ou a indução explícita quando não houver literatura.
3. Na discussão de resultados, um fechamento por hipótese e por RQ: resultado, direção, por que (ou por que não), evidência contemporânea (S04–S08).

### S04 — H1: discutir a heterogeneidade dos retornos de escala com evidência contemporânea

**O que foi dito.** Sobre H1 ter dado resultados diferentes por país: "nem toda hipótese tem que ser aceita"; o trabalho é discutir se faz sentido "à luz da heterogeneidade" e buscar evidência empírica contemporânea: o polo manufatureiro migrando para a China ("se a China tem retorno crescente, está tudo indicando que vai ter muita lenha para queimar nas próximas décadas"), a estagnação de décadas do Japão e o platô do Reino Unido, a desindustrialização dos Estados Unidos e sua aposta em IA como deslocamento de fronteira e difusão de produtividade "do chapeiro do McDonald's à empresa de consultoria", e a Índia como novo player que "vai ter que nichar". Observação geral: "os países estão nichando; menos a China".

**Estado atual.** `rts_por_pais_m2.csv` e `artigo/05` (seção 3): 15 dos 36 países em retornos decrescentes em todos os anos (Estados Unidos, eficiência de escala média 0,35; Japão 0,67; Reino Unido 0,41); China em CRS com eficiência de escala 1 em todos os nove anos; Índia alterna (4 anos CRS, 4 DRS, eficiência de escala média 0,93); teste global sem indício contra CRS (tamanho ≈ 0,20). Atenção: na apresentação a China foi descrita como "retorno crescente"; no resultado vigente (rotina alinhada ao `rDEA`, reexecução de 28/09) ela está em CRS, sobre o raio de produtividade máxima, e não em IRS. A discussão deve usar a classificação vigente e ser refeita após S01.

**Pendência.** Escrever a subseção de discussão de H1 país a país (Estados Unidos, Japão, Reino Unido, China, Índia), ligando cada classificação de RTS a evidência verificável (relatórios da OCDE e do AI Index, Banco Mundial, imprensa econômica com data de acesso): platô e envelhecimento no Japão; desindustrialização e aposta em IA nos Estados Unidos; ascensão chinesa (manufatura, escala do sistema de pesquisa) e indiana; ligar ao Malmquist (S06: Estados Unidos e Japão com mudança técnica abaixo de 1). Manter a ressalva de que o teste global é exploratório.

### S05 — Ranking: perfis de três países do topo e três ou quatro da base

**O que foi dito.** Sobre o ranking (Itália, Grécia, Malásia, Indonésia, Bulgária e Índia no topo; Suíça, Israel, Irlanda, Noruega e África do Sul na base): a estratégia é "pegar três do topo, paradigmáticos, e três ou quatro da base" e estudar a especificidade de cada um, porque há "país nichado" que aposta em um ou dois setores. Pistas do professor: Itália (defesa, automotiva, máquinas de precisão em Turim); Grécia (ajuste fiscal "brutal", que "cortou gordura", e hoje se financia a juros menores que a França; turismo, azeite, navegação); Indonésia em catch-up, subindo no ranking do PIB; Israel (pesquisa militar, dessalinização, agricultura) e Irlanda (polo de tecnologia) podem estar "gastando demais" em relação ao que produzem em IA; Noruega "pode viver de renda" (fundo soberano). O autor lembrou a indústria de apostas grega (Kaizen Gaming). Ressalvas: o ranking "talvez mude" com a padronização (S01), e a figura estava pequena demais para ler.

**Estado atual.** `ranking_paises_boot.csv` e `artigo/05` (seção 4): topo Itália (2 anos) 0,80, Grécia (7) 0,78, Malásia (4) 0,77, Indonésia (2) 0,77, Índia (8) 0,77, Bulgária (3) 0,76, Romênia (4) 0,76, China (9) 0,76; base Filipinas (1) 0,36, África do Sul (5) 0,25, Noruega (6) 0,24, Irlanda (2) 0,22, Israel (9) 0,19, Suíça (1) 0,15. A ordem no topo não é distinguível (postos de 1 a 13–18); a base se separa por contrastes pareados. Explicação já registrada: GERD total alto (P&D empresarial intenso) com produtos de IA em contagem pequenos; o escore mede em parte a intensidade de IA do sistema de pesquisa.

**Pendência.**

1. Após S01, escolher três do topo e três ou quatro da base (candidatos: Itália, Grécia, Índia ou Malásia; Suíça, Israel, Irlanda, Noruega) e escrever perfis curtos com fontes: estrutura produtiva e nichos de P&D, GERD/PIB, tamanho do sistema de IA (publicações e patentes), anos disponíveis na base; explicar a base pela intensidade de IA do sistema de P&D e o topo pela combinação de GERD baixo com produção em contagem.
2. Deck e relatório: aumentar a legibilidade da fig1 (dois painéis, topo e base, ou fonte maior e menos rótulos).

### S06 — Malmquist: frontier shift × catch-up por país; tese do platô; Moraes e Wanke (2019)

**O que foi dito.** O Malmquist apresentado pareceu agregado; "só faltaria separar o que é frontier shift e catch-up, entender os componentes". Expectativas do professor: catch-up menor na China, porque a liderança tecnológica dela é deslocamento de fronteira; Brasil "jogando no lado do catch-up", com frontier shift "bem caidinho", como em um trabalho de doutorado que ele orientou no COPPEAD sobre setores financiados pelo BNDES (autor citado de memória como "Ricardo Calil"), e o caso da FINEP e da indústria de defesa. Sobre renda média com Malmquist melhor que alta renda: "economicamente não é estranho"; os países chegam ao platô ("é possível ficar pobre para sempre; enriquecer para sempre é muito difícil"); quem está na fronteira gasta mais para deslocá-la e com retorno menor; quem está atrás tem mais espaço (o exemplo de JK, "50 anos em 5").

**Estado atual.** A decomposição existe: `malmquist_m2.csv` (por país e par de anos), `malmquist_resumo.csv` (por grupo, com intervalos por reamostragem de países e índices fixos) e fig2 (`fig2_malmquist_decomposicao.png`, barras de mudança técnica e de eficiência por país). O slide 11 e a fala, porém, destacaram o índice agregado por grupo e o índice total por país ("maiores ganhos e perdas"). Médias geométricas 2016–2019 por país, calculadas de `malmquist_m2.csv` (M = TC × EC):

| País | M | Mudança técnica (TC) | Mudança de eficiência (EC) | Leitura |
|---|---|---|---|---|
| Brasil | 1,45 | 0,96 | 1,52 | ganho quase todo por catch-up, fronteira parada |
| Áustria | 1,27 | 0,78 | 1,63 | catch-up, com fronteira recuando |
| Polônia | 1,25 | 1,00 | 1,25 | catch-up |
| Noruega | 1,15 | 0,92 | 1,26 | catch-up |
| México | 1,07 | 0,93 | 1,15 | catch-up |
| Estados Unidos | 0,82 | 0,68 | 1,21 | catch-up, mas a fronteira recua mais |
| Japão | 0,82 | 0,76 | 1,07 | idem |
| Grécia | 1,23 | 1,23 | 1,00 | na fronteira: só deslocamento |
| Argentina | 1,20 | 1,20 | 1,00 | idem |
| Índia | 0,95 | 0,95 | 1,00 | idem |
| China | 0,65 | 0,65 | 1,00 | na fronteira CRS nos quatro anos: todo o movimento é deslocamento de fronteira, negativo em produtos por dólar |
| Espanha | 0,95 | 0,99 | 0,97 | perde pouco nos dois |
| Singapura | 0,91 | 0,96 | 0,94 | idem |
| Israel | 0,90 | 0,95 | 0,94 | idem |
| Hungria | 0,81 | 0,83 | 0,98 | perde nos dois |
| África do Sul | 0,87 | 0,99 | 0,88 | perde eficiência |

A expectativa do professor confirma-se nos dados vigentes: a China não tem catch-up (ela é a fronteira) e o Brasil ganha por catch-up com fronteira quase parada. A parcela da mudança técnica na variância de log M já é reportada (0,60).

**Referência localizada.** Moraes, R. K.; Wanke, P. F. (2019). Impacto do BNDES na eficiência da indústria siderúrgica: aplicação do modelo Malmquist de dois estágios. *Cadernos EBAPE.BR*, 17(2), 229–246. DOI 10.1590/1679-395172140. Segundo o resumo, o financiamento do BNDES teve coeficiente negativo sobre o catch-up e nenhum efeito sobre o deslocamento de fronteira na siderurgia (2010–2015); a evidência é, portanto, mais matizada do que a fala sugeriu: ler o artigo antes de citar.

**Pendência.**

1. Levar a tabela acima (com os pares de anos) para `artigo/05` (seção 7) e para o deck ou relatório (slide 11), em lugar do índice agregado por país.
2. Reescrever a leitura de H4 país a país: China, Índia, Grécia e Argentina só se movem com a fronteira; Brasil, Áustria, Polônia, Noruega, México, Estados Unidos e Japão ganham eficiência relativa; a fronteira recua em produtos por dólar durante o boom de investimento (já registrado).
3. Discutir a tese do platô para a alta renda e a intuição "quem está na fronteira precisa gastar mais para deslocá-la", ligando a H1 (Estados Unidos e Japão em DRS e com TC < 1).
4. Citar Moraes e Wanke (2019) com o achado correto (catch-up e financiamento estatal na siderurgia) e, se houver fonte, evidência sobre FINEP e a indústria de defesa; manter a ressalva sobre os intervalos (reamostragem com índices fixos; bootstrap de Simar e Wilson, 1999, pendente).

### S07 — Segundo estágio: "bateu na trave" e confirmação de sinal; o que mede a efetividade governamental

**O que foi dito.** Para os coeficientes não significativos do segundo estágio, distinguir dois níveis: (a) "bateu na trave" (não está nos 5%, mas está, por exemplo, em 7% de significância); (b) confirmação do sinal previsto, independentemente da significância ("nível de evidência mais fraco, mas pode ajudar a compor a discussão"). Sobre a efetividade governamental com sinal negativo: ver o que o indicador mede (o professor o chamou de indicador "Bloomberg" e citou voice and accountability, que é uma das seis dimensões dos Worldwide Governance Indicators do Banco Mundial); um governo "efetivo" pode ser efetivo em regular e travar ("137 licenças ambientais" para uma ferrovia): "é regramento? rule of law? o que está dentro?". Sobre o coeficiente de publicações: "não adianta só publicar". E, de novo, bater o martelo só depois da reexecução com variáveis transformadas.

**Estado atual.** `segundo_estagio_truncada.csv` traz coeficiente, erro-padrão bootstrap, IC 95% percentílico e a coluna `significativo_5pct`; não há p-valor bootstrap nem IC 90%. Casos: efetividade governamental −0,58 [−1,31; 0,02] (é exatamente o "bateu na trave"); log do PIB per capita em publicações −0,36 [−0,66; −0,02] (significativo, sinal contrário ao previsto em H7); H6 nula. Na Fase A a efetividade vem da base original (`Government_Effectiveness`, WGI); o painel (`R/13_build_painel.R`) já traz as quatro dimensões baixadas em `data/wgi/`: efetividade governamental (GE), controle da corrupção (CC), estado de direito (RL) e qualidade regulatória (RQ), mas RL e RQ ainda não entram como variáveis de contexto.

**Pendência.**

1. Em `R/03`: acrescentar às tabelas do segundo estágio (truncada, Tobit, algoritmo 2) o p-valor bootstrap bicaudal e o IC 90%, e uma coluna `sinal_previsto_confirmado`; classificar cada coeficiente em quatro níveis: significativo a 5%; "bateu na trave" (p entre 0,05 e 0,10); sinal confirmado, não significativo; sinal contrário. Levar a classificação para a tabela-síntese das hipóteses (`artigo/05`, seção 10; `artigo/06`) e para a fig4.
2. Descrever o que o WGI de efetividade governamental mede (qualidade dos serviços públicos e da burocracia, independência de pressões políticas, formulação e implementação de políticas, credibilidade do compromisso do governo; Kaufmann, Kraay e Mastruzzi, 2010) e testar qualidade regulatória, estado de direito e um índice composto como variáveis de contexto alternativas, para verificar a leitura do professor de que o sinal negativo capta capacidade regulatória que trava, e não qualidade institucional. Registrar que efetividade e controle da corrupção são quase colineares (já anotado em `artigo/01`).
3. Reavaliar tudo após S01; só então redigir a discussão de H5–H7 (ou das RQs, S03).

### S08 — Eficiência por grupo de renda e ano: heterogeneidade e sua evolução

**O que foi dito.** Sobre a figura de eficiência por grupo de renda e ano (fig5): a renda média-baixa parece a menos heterogênea ("você pode ser pobre para sempre; teu cenário não vai mudar"), mas só tem um ano com mais de um país (2018) e o autor citou as Filipinas; entender essa "abertura" de 2018 (crise financeira? país específico?). A renda média-alta parece ter heterogeneidade crescente: "quem são esses países? É o BRICS+, eles não são homogêneos; na realidade, BRICS é só China"; a China se descolou; Indonésia, Malásia e Peru sobem ("o Peru daqui a pouco está com PIB maior que o da Argentina, exporta mais que o Chile, portos virados para o Pacífico"); México com crescimento orgânico atrelado aos Estados Unidos; Ucrânia (o último ano da base é anterior à guerra de 2022). A alta renda parece homogênea na dispersão ("G7 e escandinavos"), mas com velocidades diferentes dentro do G7 e da União Europeia (Itália norte e sul).

**Estado atual.** Grupos na base (`base_atual.csv`): alta renda, 25 países; renda média-alta, 10 (Argentina, Brasil, China, Colômbia, Indonésia, Malásia, México, Peru, África do Sul, Ucrânia); renda média-baixa, 2 (Índia, 2013–2020; Filipinas, só 2018). A "abertura" de 2018 na renda média-baixa é composição: a Índia é eficiente em todos os anos e em 2018 entra a única observação das Filipinas (escore corrigido 0,36), a menor do grupo; não há crise a explicar. Dispersão do escore VRS (não corrigido) por grupo e ano, calculada de `dea_ano_m2.csv`: renda média-alta com desvio-padrão 0,15 em 2013 (n = 5) e 0,27–0,34 em 2016–2020 (n = 6–7), coeficiente de variação de 0,16 para 0,31–0,47; alta renda com CV entre 0,30 e 0,54, sem tendência (n = 10–18). A leitura do professor é compatível com os dados, mas com n pequeno e composição que muda a cada ano. A nota vigente do slide 13 ("sem tendência clara; dispersão maior nos anos com menos países") precisa ser revista.

**Pendência.**

1. Em `R/02` ou `R/04`: tabela de dispersão por grupo e ano (n, média, desvio-padrão, IQR, CV) com o escore corrigido de viés; verificar a tendência da dispersão da renda média-alta (regressão do CV ou do IQR no ano, ou teste de homogeneidade de variâncias entre 2013–2016 e 2017–2021), com a ressalva do n; identificar quem abre a distribuição em cada ano (China contra os demais; África do Sul; Ucrânia).
2. Texto de discussão com evidência contemporânea: Indonésia, Malásia e Peru em ascensão; México atrelado aos Estados Unidos; Ucrânia pré-guerra; China descolada; heterogeneidade dentro da União Europeia e do G7. Cuidado: os escores vêm de fronteiras contemporâneas e não são comparáveis em nível entre anos; comparar dispersões relativas (CV, IQR), não níveis.

### S09 — Revisão de literatura por hipótese, evidência contemporânea e periódico-alvo

**O que foi dito.** As referências clássicas dos métodos estão adequadas. O professor destacou o *Central European Journal of Operations Research* (CEJOR) como "gancho para poder mandar para lá" ("é o EJOR da Europa Central, dos Balcãs, o primo pobre da Europa"); *American Economic Review* e *Econometrica* estão fora de alcance; o *Journal of Productivity Analysis* exigiria um método novo. Para o artigo, "valeria a pena mais literatura, se tiver, ou evidência empírica": a revisão precisa ancorar cada hipótese (S03) e a discussão precisa de evidência contemporânea dos países (busca em jornais ou com auxílio de IA): crescimento de Malásia e Indonésia; BRICS+ com fraquezas estruturais que "continuam puxando a máquina"; potências de nicho na renda média (Brasil: Embrapa, exploração de petróleo em águas profundas, indústria de defesa com FINEP); Grécia (ajuste fiscal); Israel e Irlanda (gasto alto). Seguir para artigo depende do interesse de carreira do autor (mestrado no MPA em fase de defesa).

**Estado atual.** `artigo/01` tem enquadramento teórico geral (Griliches; Furman, Porter e Stern; Cohen e Levinthal; Ernst e Mishra; Holý e Šafr; Hsu, Tian e Xu), mas não uma revisão organizada por hipótese com resultados a favor e contra; o periódico-alvo está indefinido ("Qualis"). Holý e Šafr (2018), já citado, foi publicado no CEJOR.

**Pendência.**

1. Revisão de literatura por hipótese ou RQ (duas a quatro referências cada: apoio, contradição, lacuna). Candidatas a verificar antes de citar: Wang e Huang (2007), Sharma e Thomas (2008), Guan e Chen (2012) e Cullmann, Schmidt-Ehmcke e Zloczysti (2012), sobre eficiência de P&D entre países com DEA e segundo estágio; literatura de Malmquist aplicada a sistemas de inovação; função de produção de conhecimento e retornos de escala (indução para H1).
2. Dossiê de evidência contemporânea por país citado nas discussões (S04, S05, S06, S08), com fontes verificáveis (OCDE, Banco Mundial, AI Index, imprensa econômica) e data de acesso; nenhuma afirmação sem fonte.
3. Decidir o periódico-alvo: CEJOR como candidato principal (conferir escopo, classificação Qualis vigente e exigências de formato); alternativas a avaliar: *Socio-Economic Planning Sciences*, *Technological Forecasting and Social Change*, *Journal of the Knowledge Economy*.
4. Decisão do autor sobre seguir para artigo (condiciona o esforço de 1 a 3).

### S10 — Ordem de execução acordada

Ao final, o autor propôs e o professor concordou: (1) fazer o SFA funcionar (S02), aplicando a padronização sugerida; (2) fazer os ajustes de transformação (S01) e reexecutar; (3) fazer a revisão teórica para explicar os resultados, se eles não mudarem depois de arrumar a base; (4) terminar o relatório final. Ordem recomendada aqui, respeitando as dependências:

1. S01 (padronização e reexecução), porque condiciona S02, S04, S05, S06 e S07.
2. S02 (SFA) em paralelo, já com variáveis em log.
3. S07 (níveis de evidência), S06 (tabela por país) e S08 (dispersão): acréscimos leves ao pipeline, feitos junto com a reexecução.
4. S03 (conjunto de hipóteses e RQs) antes de escrever.
5. S04, S05, S06 e S08 (discussões) com o dossiê de S09.
6. Relatório final e, se decidido, manuscrito (periódico de S09).

## 3. Pontos da transcrição sem pendência nova

- Zeros de investimento e piso de 1 milhão (fala do autor sobre a falta do dicionário de dados): já tratados por exclusão dos zeros e bloco de sensibilidade ao piso (`artigo/05`, seção 1; `artigo/10`, I01).
- Volume não é qualidade (contagens favorecem China e Estados Unidos): já tratado na variante de produtos alternativos (`_painel_qualidade`; `artigo/06`).
- Referências clássicas dos métodos: aprovadas; sem ação além de S09.
- Pergunta da colega sobre o número de hipóteses: respondida em S03.
- Comentários de contexto sobre países (Índia, Peru, Grécia, Noruega, Israel etc.) sem indicação de fonte: entram como hipóteses de discussão a verificar em S09, não como fatos.

## 4. Referências citadas neste documento (conferir os dados bibliográficos antes de incorporar a `artigo/01`)

- Ali, A. I.; Seiford, L. M. (1990). Translation invariance in data envelopment analysis. *Operations Research Letters*, 9(6), 403–405.
- Battese, G. E.; Coelli, T. J. (1995). A model for technical inefficiency effects in a stochastic frontier production function for panel data. *Empirical Economics*, 20, 325–332.
- Cullmann, A.; Schmidt-Ehmcke, J.; Zloczysti, P. (2012). R&D efficiency and barriers to entry: a two stage semi-parametric DEA approach. *Oxford Economic Papers*, 64(1), 176–196.
- Dyson, R. G.; Allen, R.; Camanho, A. S.; Podinovski, V. V.; Sarrico, C. S.; Shale, E. A. (2001). Pitfalls and protocols in DEA. *European Journal of Operational Research*, 132(2), 245–259.
- Guan, J.; Chen, K. (2012). Modeling the relative efficiency of national innovation systems. *Research Policy*, 41(1), 102–115.
- Kaufmann, D.; Kraay, A.; Mastruzzi, M. (2010). The Worldwide Governance Indicators: methodology and analytical issues. *World Bank Policy Research Working Paper* 5430.
- Lovell, C. A. K.; Pastor, J. T. (1995). Units invariant and translation invariant DEA models. *Operations Research Letters*, 18(3), 147–151.
- Moraes, R. K.; Wanke, P. F. (2019). Impacto do BNDES na eficiência da indústria siderúrgica: aplicação do modelo Malmquist de dois estágios. *Cadernos EBAPE.BR*, 17(2), 229–246. DOI 10.1590/1679-395172140.
- Pastor, J. T. (1996). Translation invariance in data envelopment analysis: a generalization. *Annals of Operations Research*, 66, 93–102.
- Sarkis, J. (2007). Preparing your data for DEA. In: Zhu, J.; Cook, W. D. (eds.), *Modeling Data Irregularities and Structural Complexities in Data Envelopment Analysis*. Springer.
- Sharma, S.; Thomas, V. J. (2008). Inter-country R&D efficiency analysis: an application of data envelopment analysis. *Scientometrics*, 76(3), 483–501.
- Wang, E. C.; Huang, W. (2007). Relative efficiency of R&D activities: a cross-country study accounting for environmental factors in the DEA approach. *Research Policy*, 36(2), 260–273.
