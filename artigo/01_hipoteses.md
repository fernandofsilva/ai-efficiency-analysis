# Hipóteses do trabalho

**Título provisório:** Eficiência dos países na conversão de investimento em inteligência artificial em produção científica e tecnológica: uma análise de fronteira com DEA, fronteiras robustas e SFA

## 1. Questão de pesquisa

Quais países são mais eficientes em converter investimento em inteligência artificial (IA) e esforço de P&D em produção científica (publicações em IA) e tecnológica (pedidos de patente em IA), e que características do sistema nacional de inovação explicam as diferenças de eficiência entre eles?

## 2. Enquadramento teórico

A conversão de recursos em conhecimento é tratada pela literatura como uma **função de produção de conhecimento** (Griliches, 1979; Pakes e Griliches, 1984): insumos de P&D (gastos, pesquisadores, capital) geram produtos codificados (artigos, patentes). Furman, Porter e Stern (2002) estendem essa lógica ao nível nacional com o conceito de **capacidade inovadora nacional**, em que a produtividade do esforço de P&D depende de infraestrutura comum de inovação, do ambiente de inovação dos clusters industriais e da qualidade das ligações entre ciência e indústria. Cohen e Levinthal (1990) mostram que a **capacidade de absorção** condiciona quanto conhecimento externo um sistema consegue transformar em resultados próprios, o que justifica o papel de capital humano, instituições e abertura comercial como variáveis de contexto.

Em IA, o antecedente direto é Ernst e Mishra (2021), que constroem um *AI Efficiency Index* por meio de Análise Envoltória de Dados (DEA) para 27 países em 2015–2018 e relacionam os escores a regulação de mercados de produto, subsídios fiscais a P&D e direitos de propriedade. Holý e Šafr (2018) mostram, para a União Europeia, que a eficiência da pesquisa aplicada (patentes) está mais associada ao nível de desenvolvimento do que a eficiência da pesquisa básica (citações). Hsu, Tian e Xu (2014) documentam que mercados de capitais desenvolvidos favorecem a inovação em indústrias intensivas em tecnologia, enquanto o crédito bancário não o faz.

Este trabalho contribui com (i) um painel mais amplo e mais recente do que o de Ernst e Mishra (2021); (ii) inferência estatística sobre os escores (bootstrap de Simar e Wilson, 1998; fronteiras robustas order-*m* e order-α); (iii) decomposição dinâmica da produtividade (índice de Malmquist); (iv) tratamento da heterogeneidade tecnológica (metafronteira por grupo de renda e classes latentes); e (v) um segundo estágio que incorpora variáveis institucionais e financeiras com o procedimento de Simar e Wilson (2007).

Duas evidências do próprio dataset moldam as hipóteses. Primeiro, países com investimento privado em IA registrado igual a zero (por exemplo, Ucrânia em 2013–2017) produzem centenas de publicações por ano: o investimento privado não é o único insumo relevante, e o gasto público em P&D precisa entrar na função de produção. Segundo, a China domina os Estados Unidos em ambos os produtos com cerca de um sexto do insumo em 2021, o que exige ajuste por qualidade (citações, patentes concedidas) como verificação de robustez.

## 3. Hipóteses

### H1 — Retornos variáveis de escala e ineficiência de escala dos grandes investidores

A tecnologia de produção de conhecimento em IA exibe retornos variáveis de escala. Os maiores investidores (Estados Unidos, China, Índia) operam na região de retornos decrescentes, e a maior parte de seu distanciamento da fronteira é ineficiência de escala, não ineficiência técnica pura.

*Fundamentação.* Há duas predições concorrentes. A inflação de custos de talento e de computação nos grandes polos de IA e a saturação do número de pesquisadores sugerem retornos decrescentes; economias de aglomeração e efeitos de rede sugerem retornos crescentes. A hipótese assume a primeira, mas o desenho permite identificar a segunda.

*Teste.* Teste de retornos de escala com bootstrap (Simar e Wilson, 2002), rotina própria sobre `Benchmarking` com a mesma construção da implementação de referência (`rDEA::rts.test`, estatística 4.6, banda de Silverman) — H0 de retornos constantes e, em seguida, H0 de retornos não crescentes; eficiência de escala como razão entre escores CRS e VRS; direção dos retornos comparando modelos DRS e IRS, país a país. O tamanho do teste foi medido por simulação nas duas implementações (`R/02c`): ambas rejeitam retornos constantes verdadeiros em cerca de 20% das amostras ao nível nominal de 5%, com 40 ou 191 unidades; os p-valores são, portanto, diagnósticos exploratórios, sem controle do erro tipo I.

*Critério.* Indício contra retornos constantes (p-valor abaixo de 0,05 em um teste cujo tamanho real está em torno de 0,20, ou seja, sem afirmação de rejeição com erro tipo I controlado) **e** eficiência de escala média inferior a 0,8 para cada grande investidor, avaliada país a país (`rts_por_pais`). Os dois critérios são reportados separadamente: o teste global não demonstra o comportamento individual, e a heterogeneia por país é a evidência descritiva principal.

### H2 — Especificidade dos insumos por canal de produção

Controlando pelo P&D executado no país — o GERD total, que inclui o setor empresarial, no dataset original; e, preferencialmente, o P&D executado pelo ensino superior e pelo governo (HERD + GOVERD) no painel reconstruído, soma que identifica dois setores de execução e não esgota todo o P&D não empresarial —, o investimento privado em IA tem produto marginal significativo para famílias de patentes, mas não para publicações.

*Fundamentação.* Publicações são produzidas majoritariamente em universidades e institutos; patentes, em empresas. Os insumos medem setor de execução do P&D e captação de capital privado, não fontes de financiamento mutuamente exclusivas (Manual de Frascati, cap. 4): a hipótese trata da complementaridade entre os dois insumos, não de "dinheiro público" versus "dinheiro privado".

*Teste.* Fronteira estocástica (SFA) com dois insumos por canal, com elasticidades e testes de razão de verossimilhança; DEA com e sem GERD, comparando escores e pares de referência.

*Critério.* Elasticidade do investimento privado significativa apenas no canal de patentes.

### H3 — Divergência entre canais e heterogeneidade tecnológica

A eficiência no canal acadêmico (publicações) e no canal tecnológico (patentes) são fracamente correlacionadas (H3a: ρ < 0,5). Países de renda média operam sob uma tecnologia menos favorável que a dos países de alta renda: em uma metafronteira por grupo de renda (O'Donnell, Rao e Battese, 2008), a distribuição da razão de gap tecnológico (TGR) do grupo de renda média está deslocada para baixo em relação à da alta renda, e o TGR médio do grupo é menor (H3b). A comparação entre grupos substitui o enunciado original "TGR < 1" por interesse substantivo, e não por impossibilidade lógica: um parâmetro limitado por 1 pode ser testado contra uma nula na fronteira do suporte, mas isso exigiria uma distribuição nula que respeite a estimação das fronteiras, o que não foi implementado.

*Fundamentação.* Sistemas nacionais de inovação orientados à ciência e sistemas orientados à comercialização convertem os mesmos recursos em produtos diferentes. A correlação bruta entre publicações e patentes no dataset é de apenas 0,47.

*Teste.* DEA por canal e correlação de Spearman entre os escores com bootstrap em blocos de país e p-valor unilateral de H0: ρ ≥ 0,5; metafronteira por grupo de renda com dois alvos explícitos: (i) deslocamento de distribuição, por Mann-Whitney unilateral (teste de postos) em país-ano e em médias por país; (ii) diferença de TGR médio (renda média menos alta renda) com IC 95% por bootstrap em blocos de país; ambos condicionais às fronteiras estimadas (a dependência entre TGRs pela fronteira compartilhada não é modelada). Decomposição amostra × especificação em amostra e fronteira comuns ao comparar variantes; classes latentes em SFA como robustez.

*Critério.* H3a: p-valor unilateral de ρ ≥ 0,5 inferior a 0,05. H3b: Mann-Whitney unilateral com p inferior a 0,05 nas duas unidades amostrais **e** IC 95% da diferença de TGR médio inteiramente abaixo de zero.

### H4 — Dinâmica: a fronteira domina e a renda média converge

No período analisado, a variação de produtividade medida pelo índice de Malmquist é dominada pelo componente de mudança de fronteira (progresso técnico), e a mudança de eficiência (aproximação da fronteira) é superior a um para os países de renda média-alta, indicando convergência.

*Fundamentação.* Difusão internacional do conhecimento (Färe et al., 1994; Barro e Sala-i-Martin, 1992): o progresso técnico em IA (aprendizagem profunda, ferramentas abertas, queda do custo de computação) desloca a fronteira para todos, enquanto quem está longe dela tem mais a aprender e se aproxima mais rápido.

*Em palavras simples.* A produtividade de um país pode subir porque os campeões avançaram (todo o mundo aprendeu a fazer IA melhor) ou porque o país se aproximou dos campeões. O índice de Malmquist separa os dois pedaços. A hipótese aposta que o primeiro pedaço é o maior para quase todos, e que os países de renda média se aproximaram dos campeões mais do que os ricos.

*Cuidado metodológico.* Uma fronteira que parece recuar quando medida com fluxos anuais de capital de risco reflete o crescimento explosivo do denominador (no dataset original, a mediana do investimento cresceu cerca de 26 vezes entre 2013 e 2021 e a de publicações apenas 1,4 vez). Por isso o insumo entra defasado ou como soma móvel de três anos, e o Malmquist é calculado sob retornos constantes, evitando distâncias intertemporais inviáveis sob retornos variáveis.

*Teste.* Índice de Malmquist com decomposição em mudança de eficiência e mudança técnica no painel balanceado (2016–2019 no dataset original; 2017–2021 no painel reconstruído); intervalos por reamostragem de países com os índices mantidos fixos (descrevem a variação de composição entre trajetórias, condicionais às fronteiras estimadas; não propagam a incerteza da estimação das fronteiras, que exigiria o bootstrap de Malmquist de Simar e Wilson, 1999); regressão da mudança de eficiência média no escore CRS inicial medido contra a mesma fronteira do painel balanceado (β-convergência, MQO descritivo).

*Critério.* H4a: parcela da mudança técnica na variância de log M superior a 0,5, com a covariância entre componentes rateada simetricamente (Var log M = Var log TC + Var log EC + 2 Cov). H4b, critério numérico: média geométrica da mudança de eficiência do grupo de renda média superior a um, com o intervalo por reamostragem de países excluindo um, avaliado com valores não arredondados; como esse intervalo não propaga a incerteza das fronteiras, atender ao critério é evidência descritiva de catch-up, não confirmação inferencial. A comparação com a alta renda e a β-convergência são reportadas em separado.

### H5 — Instituições e capacidade de absorção

A eficiência é positivamente associada à efetividade governamental (ou a um índice composto dos indicadores de governança WGI), à intensidade de P&D, ao número de pesquisadores per capita e à participação das exportações de alta tecnologia.

*Fundamentação.* Furman, Porter e Stern (2002) e Cohen e Levinthal (1990). Efetividade governamental e controle da corrupção são quase colineares no dataset e entram como um único indicador. Quando o GERD é usado como insumo (H2), ele não pode reaparecer como variável de contexto; usa-se então pesquisadores per capita.

*Teste.* Regressão truncada sobre o logaritmo do escore corrigido de viés (log s em (−∞, 0), truncada em 0: o modelo de Simar e Wilson, 2007, aplicado ao logaritmo da medida de Farrell, com suporte compatível com o escore e numericamente estável), com escores fixos e bootstrap agrupado por país, verificação de convergência do ajuste pontual e de cada réplica, até cinco variáveis de contexto e dummies de ano; as parametrizações em escore truncado só em 1 e em Farrell truncado em 1 entram como comparação; algoritmo 2 de Simar e Wilson (2007) na fronteira agrupada, com semente fixada no processo filho; Tobit apenas como comparação com a prática anterior. A condição de separabilidade (Daraio, Simar e Wilson, 2018) não é testada: associações descritivas Z × escore são reportadas e o segundo estágio é exploratório.

*Critério.* Sinais previstos com intervalos de 95% que excluem zero em pelo menos duas especificações.

### H6 — Finanças de mercado versus finanças bancárias no canal de patentes

A capitalização do mercado acionário está positivamente associada à eficiência no canal de patentes; o crédito bancário ao setor privado não está. A fragilidade bancária (empréstimos inadimplentes, Z-score) entra como controle único.

*Fundamentação.* Hsu, Tian e Xu (2014): mercados acionários financiam projetos de inovação de alto risco e longo prazo; o crédito bancário, avesso a risco e dependente de garantias, não.

*Teste.* Segundo estágio do canal de patentes com capitalização de mercado e crédito privado como variáveis de contexto.

*Critério.* Coeficiente da capitalização de mercado positivo e significativo; crédito não significativo ou negativo.

### H7 — Assimetria por nível de desenvolvimento

O PIB per capita está positivamente associado à eficiência no canal de patentes, mas não no canal de publicações.

*Fundamentação.* Extensão de Holý e Šafr (2018), que encontram relação positiva entre desenvolvimento econômico e eficiência apenas na pesquisa aplicada, para o caso da IA.

*Teste.* Comparação dos sinais dos segundos estágios por canal (o PIB per capita não entra no modelo completo por sua correlação de cerca de 0,8 com os indicadores de governança); teste de Kruskal-Wallis por grupo de renda em cada canal.

*Critério.* Efeito positivo apenas no canal de patentes.

## 4. Proposições de robustez

Reportadas como resultados, não como hipóteses:

- **R1.** Os rankings são estáveis entre estimadores (DEA com bootstrap, FDH, order-*m*, order-α, SFA), com correlação de Spearman superior a 0,7 e intervalo de confiança.
- **R2.** Os rankings são estáveis à estrutura de defasagem (t, t−1, t−2) e ao uso de soma móvel de três anos em vez de fluxo anual.
- **R3.** Os rankings são sensíveis ao ajuste por qualidade (citações no lugar de contagens de artigos; patentes concedidas no lugar de pedidos). Essa sensibilidade é um achado a ser declarado, não um problema a ser escondido.

## 5. Quadro-resumo

| Hipótese | Método principal | Função em R | Critério |
|---|---|---|---|
| H1 retornos de escala | Teste de RTS com bootstrap (tamanho ≈ 0,20 por simulação); SE = CRS/VRS por país | `TesteRtsBootstrap` (rotina própria alinhada a `rDEA::rts.test`), `Benchmarking::dea` | indício contra CRS (p < 0,05, teste liberal); SE < 0,8 nos grandes |
| H2 insumos por canal | SFA dois insumos; DEA com/sem GERD | `Benchmarking::sfa`, `frontier::sfa` | elasticidade só em patentes |
| H3 canais e metafronteira | DEA por canal; TGR por grupo de renda (Mann-Whitney e diferença de médias por blocos de país); classes latentes | `Benchmarking::dea`, `wilcox.test`, `sfaR::sfalcmcross` | p(ρ ≥ 0,5) < 0,05; TGR média < alta (postos e média) |
| H4 dinâmica | Malmquist CRS, painel balanceado; intervalos por reamostragem de países (índices fixos) | `Benchmarking::malmquist` | parcela de TC > 0,5 (covariância rateada); EC > 1 na renda média (critério numérico, descritivo) |
| H5 instituições | Truncada sobre log(escore), escores fixos, bootstrap por país; Simar-Wilson alg. 2 | `truncreg::truncreg`, `rDEA::dea.env.robust` | sinais previstos, IC exclui 0 (exploratório: separabilidade não testada) |
| H6 finanças | Segundo estágio do canal de patentes | idem | market cap > 0; crédito ≤ 0 |
| H7 desenvolvimento | Sinais por canal; Kruskal-Wallis (3 grupos) e Mann-Whitney (2 grupos), em país-ano e em médias por país | `kruskal.test`, `wilcox.test` | positivo só em patentes |

## Referências

- Banker, R. D.; Charnes, A.; Cooper, W. W. (1984). Some models for estimating technical and scale inefficiencies in Data Envelopment Analysis. *Management Science*, 30(9), 1078–1092.
- Barro, R. J.; Sala-i-Martin, X. (1992). Convergence. *Journal of Political Economy*, 100(2), 223–251.
- Battese, G. E.; Coelli, T. J. (1995). A model for technical inefficiency effects in a stochastic frontier production function for panel data. *Empirical Economics*, 20, 325–332.
- Bogetoft, P.; Otto, L. (2011). *Benchmarking with DEA, SFA, and R*. Springer.
- Cazals, C.; Florens, J.-P.; Simar, L. (2002). Nonparametric frontier estimation: a robust approach. *Journal of Econometrics*, 106(1), 1–25.
- Charnes, A.; Cooper, W. W.; Rhodes, E. (1978). Measuring the efficiency of decision making units. *European Journal of Operational Research*, 2(6), 429–444.
- Cohen, W. M.; Levinthal, D. A. (1990). Absorptive capacity: a new perspective on learning and innovation. *Administrative Science Quarterly*, 35(1), 128–152.
- Daraio, C.; Simar, L. (2005). Introducing environmental variables in nonparametric frontier models: a probabilistic approach. *Journal of Productivity Analysis*, 24, 93–121.
- Daraio, C.; Simar, L.; Wilson, P. W. (2018). Central limit theorems for conditional efficiency measures and tests of the "separability" condition in non-parametric, two-stage models of production. *The Econometrics Journal*, 21(2), 170–191.
- Deprins, D.; Simar, L.; Tulkens, H. (1984). Measuring labor-efficiency in post offices. In: *The Performance of Public Enterprises*. North-Holland.
- Ernst, E.; Mishra, S. (2021). AI Efficiency Index: identifying regulatory and policy constraints for resilient national AI ecosystems. *SSRN Working Paper* 3800783.
- Färe, R.; Grosskopf, S.; Norris, M.; Zhang, Z. (1994). Productivity growth, technical progress, and efficiency change in industrialized countries. *American Economic Review*, 84(1), 66–83.
- Furman, J. L.; Porter, M. E.; Stern, S. (2002). The determinants of national innovative capacity. *Research Policy*, 31(6), 899–933.
- Griliches, Z. (1979). Issues in assessing the contribution of research and development to productivity growth. *Bell Journal of Economics*, 10(1), 92–116.
- Holý, V.; Šafr, K. (2018). Are economically advanced countries more efficient in basic and applied research? *Central European Journal of Operations Research*, 26, 933–950.
- Hsu, P.-H.; Tian, X.; Xu, Y. (2014). Financial development and innovation: cross-country evidence. *Journal of Financial Economics*, 112(1), 116–135.
- O'Donnell, C. J.; Rao, D. S. P.; Battese, G. E. (2008). Metafrontier frameworks for the study of firm-level efficiencies and technology ratios. *Empirical Economics*, 34, 231–255.
- Olesen, O. B.; Petersen, N. C.; Podinovski, V. V. (2015). Efficiency analysis with ratio measures. *European Journal of Operational Research*, 245(2), 446–462.
- Pakes, A.; Griliches, Z. (1984). Patents and R&D at the firm level: a first look. In: Griliches, Z. (ed.), *R&D, Patents, and Productivity*. University of Chicago Press.
- Simar, L.; Wilson, P. W. (1998). Sensitivity analysis of efficiency scores: how to bootstrap in nonparametric frontier models. *Management Science*, 44(1), 49–61.
- Simar, L.; Wilson, P. W. (1999). Estimating and bootstrapping Malmquist indices. *European Journal of Operational Research*, 115(3), 459–471.
- Simar, L.; Wilson, P. W. (2002). Non-parametric tests of returns to scale. *European Journal of Operational Research*, 139(1), 115–132.
- Simar, L.; Wilson, P. W. (2007). Estimation and inference in two-stage, semi-parametric models of production processes. *Journal of Econometrics*, 136(1), 31–64.
- Wilson, P. W. (1993). Detecting outliers in deterministic nonparametric frontier models with multiple outputs. *Journal of Business & Economic Statistics*, 11(3), 319–323.
