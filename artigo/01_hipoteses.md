# Hipóteses e perguntas de pesquisa

**Título provisório:** Eficiência dos países na conversão de investimento em inteligência artificial em produção científica e tecnológica: uma análise de fronteira com DEA, fronteiras robustas e SFA

**Estrutura decidida em 04/10/2026 (S03 de `artigo/13`, opção B):**
- **Três hipóteses (H1 a H3):** os pontos com teste estatístico capaz de refutá-los e com base na literatura ou numa dedução explícita.
- **Duas perguntas de pesquisa exploratórias (RQ1 e RQ2):** os pontos cuja inferência atual não permite refutação formal.
- **Proposições de robustez (R1 a R4).**

Correspondência com a numeração anterior (que continua nos rótulos de código e tabelas): H1 a H3 sem mudança; a antiga H4 passou a ser a RQ1; as antigas H5, H6 e H7 viraram as expectativas E5, E6 e E7 da RQ2.

## 1. Questão de pesquisa

Quais países são mais eficientes em converter investimento em inteligência artificial (IA) e esforço de P&D em produção científica (publicações em IA) e tecnológica (pedidos de patente em IA), e que características do sistema nacional de inovação se associam às diferenças de eficiência entre eles?

## 2. Enquadramento teórico

A conversão de recursos em conhecimento é tratada pela literatura como uma **função de produção de conhecimento** (Griliches, 1979; Pakes e Griliches, 1984): insumos de P&D (gastos, pesquisadores, capital) geram produtos codificados (artigos, patentes). Furman, Porter e Stern (2002) estendem essa lógica ao nível nacional com o conceito de **capacidade inovadora nacional**, em que a produtividade do esforço de P&D depende:
- da infraestrutura comum de inovação;
- do ambiente de inovação dos clusters industriais;
- da qualidade das ligações entre ciência e indústria.

Cohen e Levinthal (1990) mostram que a **capacidade de absorção** condiciona quanto conhecimento externo um sistema consegue transformar em resultados próprios, o que justifica o papel de capital humano, instituições e abertura comercial como variáveis de contexto.

Em IA, o antecedente direto é Ernst e Mishra (2021), que constroem um *AI Efficiency Index* por meio de Análise Envoltória de Dados (DEA) para 27 países em 2015–2018 e relacionam os escores a regulação de mercados de produto, subsídios fiscais a P&D e direitos de propriedade. Holý e Šafr (2018) mostram, para a União Europeia, que a eficiência da pesquisa aplicada (patentes) está mais associada ao nível de desenvolvimento do que a eficiência da pesquisa básica (citações). Hsu, Tian e Xu (2014) documentam que mercados de capitais desenvolvidos favorecem a inovação em indústrias intensivas em tecnologia, enquanto o crédito bancário não o faz. A literatura de eficiência de P&D entre países com DEA é o ponto de partida da revisão por hipótese, ainda a fazer (S09): Wang e Huang (2007), Sharma e Thomas (2008), Guan e Chen (2012) e Cullmann, Schmidt-Ehmcke e Zloczysti (2012).

Este trabalho contribui com:
1. um painel mais amplo e mais recente do que o de Ernst e Mishra (2021);
2. inferência estatística sobre os escores (bootstrap de Simar e Wilson, 1998; fronteiras robustas order-*m* e order-α);
3. uma fronteira estocástica por canal, que estima as elasticidades de cada insumo;
4. a decomposição dinâmica da produtividade (índice de Malmquist);
5. o tratamento da heterogeneidade tecnológica (metafronteira por grupo de renda e classes latentes);
6. um segundo estágio exploratório com variáveis institucionais e financeiras.

Duas evidências do próprio dataset moldam o desenho:
- Países com investimento privado em IA registrado igual a zero (por exemplo, Ucrânia em 2013–2017) produzem centenas de publicações por ano: o investimento privado não é o único insumo relevante, e o gasto em P&D precisa entrar na função de produção.
- A China domina os Estados Unidos em ambos os produtos com cerca de um sexto do insumo em 2021, o que exige ajuste por qualidade (citações, patentes concedidas) como verificação de robustez.

## 3. Hipóteses

### H1 — Retornos variáveis de escala e ineficiência de escala dos grandes investidores

**Enunciado.** A tecnologia de produção de conhecimento em IA exibe retornos variáveis de escala. Os maiores investidores (Estados Unidos, China, Índia) operam na região de retornos decrescentes, e a maior parte de seu distanciamento da fronteira é ineficiência de escala, não ineficiência técnica pura.

**Fundamentação.** Duas predições concorrentes:
- **Dedução pela função de produção** (o argumento sugerido pelo professor na apresentação): se a produção de conhecimento segue uma função de produção com fatores difíceis de expandir na mesma proporção (talento especializado, capacidade de computação, dados), a partir de algum ponto o produto cresce menos que os insumos. Isso leva a retornos decrescentes nos maiores investidores, reforçados pela inflação de custos de talento e de computação nos grandes polos de IA.
- **Predição oposta:** economias de aglomeração e efeitos de rede sugerem retornos crescentes.

A hipótese assume a primeira, mas o desenho permite identificar a segunda. A literatura de eficiência de P&D entre países discute retornos de escala na produção de patentes e publicações (Wang e Huang, 2007; Sharma e Thomas, 2008); o que ela confirma e o que contradiz será registrado no S09. A lacuna atacada é o teste formal de retornos de escala com bootstrap na produção de conhecimento em IA, com o investimento privado como insumo.

**Teste.**
- Teste de retornos de escala com bootstrap (Simar e Wilson, 2002), rotina própria sobre `Benchmarking` com a mesma construção da implementação de referência (`rDEA::rts.test`, estatística 4.6, banda de Silverman): H0 de retornos constantes e, em seguida, H0 de retornos não crescentes.
- Eficiência de escala como razão entre escores CRS e VRS, e direção dos retornos comparando modelos DRS e IRS, país a país.
- Como evidência paramétrica complementar, a soma das elasticidades da fronteira estocástica por canal (`artigo/15`).

O tamanho do teste foi medido por simulação nas duas implementações (`R/02c`): ambas rejeitam retornos constantes verdadeiros em cerca de 20% das amostras ao nível nominal de 5%, com 40 ou 191 unidades. Os p-valores são, portanto, diagnósticos exploratórios, sem controle do erro tipo I. Os retornos de escala só têm leitura econômica nas unidades originais: a padronização min-max desloca a origem (`artigo/14`).

**Critério.** São dois, reportados separadamente, porque o teste global não demonstra o comportamento individual e a heterogeneidade por país é a evidência descritiva principal:
1. indício contra retornos constantes: p-valor abaixo de 0,05, num teste cujo tamanho real está em torno de 0,20, ou seja, sem afirmação de rejeição com erro tipo I controlado;
2. eficiência de escala média inferior a 0,8 para cada grande investidor, avaliada país a país (`rts_por_pais`).

**Situação em 04/10/2026 (fechamento na discussão: S04).** Sem apoio conclusivo:
- o teste global não dá indício contra retornos constantes (Fase A p = 0,09; painel p = 0,44);
- Estados Unidos e Reino Unido estão em retornos decrescentes, a China em constantes e a Índia alterna;
- no SFA, os retornos são decrescentes no canal de publicações e crescentes no de patentes.

### H2 — Especificidade dos insumos por canal de produção

**Enunciado.** Controlando pelo P&D executado no país, o investimento privado em IA tem produto marginal significativo para patentes, mas não para publicações. O controle é o GERD total, que inclui o setor empresarial, no dataset original; no painel reconstruído, de preferência o P&D executado pelo ensino superior e pelo governo (HERD + GOVERD), soma que identifica dois setores de execução e não esgota todo o P&D não empresarial.

**Fundamentação.**
- Na função de produção de ideias de Furman, Porter e Stern (2002), o esforço de P&D é o insumo central da produção de patentes.
- Publicações são produzidas majoritariamente em universidades e institutos; patentes, em empresas.
- O capital privado captado por empresas de IA deveria, portanto, complementar a pesquisa aplicada e se refletir em patentes, e não em artigos.
- Os insumos medem setor de execução do P&D e captação de capital privado, não fontes de financiamento mutuamente exclusivas (Manual de Frascati, cap. 4): a hipótese trata da complementaridade entre os dois insumos, não de "dinheiro público" versus "dinheiro privado".

A lacuna atacada é a separação, por canal de produção, do papel do capital privado em IA e do P&D, que a literatura de capacidade inovadora trata de forma agregada. A verificação na literatura de IA fica para o S09.

**Teste.** Fronteira estocástica com dois insumos por canal, em log, nas seis bases (`R/06`, `artigo/15`):
- modelo principal: Cobb-Douglas agrupada;
- robustez: ineficiência exponencial, translog e painel (Battese e Coelli, 1988 e 1992);
- elasticidades com intervalos por bootstrap em blocos de país;
- testes de razão de verossimilhança da presença de ineficiência;
- diferença entre canais estimada no mesmo sorteio.

Complementarmente, a DEA com e sem GERD (M1 × M2).

**Critério.** Estrito: elasticidade do investimento privado significativa apenas no canal de patentes. Especificidade relativa: elasticidade maior em patentes que em publicações, com o IC da diferença acima de zero.

**Situação em 04/10/2026.** Não apoiada:
- o critério estrito vale em 2 de 18 combinações de base e modelo, e o padrão oposto (efeito só em publicações) em 7;
- a especificidade relativa aparece só nos modelos de painel da Fase A;
- o P&D é o insumo que importa nos dois canais.

### H3 — Divergência entre canais e heterogeneidade tecnológica

**Enunciado.**
- **H3a:** a eficiência no canal acadêmico (publicações) e no canal tecnológico (patentes) são fracamente correlacionadas (ρ < 0,5).
- **H3b:** países de renda média operam sob uma tecnologia menos favorável que a dos países de alta renda. Numa metafronteira por grupo de renda (O'Donnell, Rao e Battese, 2008), a distribuição da razão de gap tecnológico (TGR) do grupo de renda média está deslocada para baixo em relação à da alta renda, e o TGR médio do grupo é menor.

A comparação entre grupos substitui o enunciado original "TGR < 1" por interesse substantivo, e não por impossibilidade lógica. Um parâmetro limitado por 1 pode ser testado contra uma nula na fronteira do suporte, mas isso exigiria uma distribuição nula que respeite a estimação das fronteiras, o que não foi implementado.

**Fundamentação.**
- Sistemas nacionais de inovação orientados à ciência e sistemas orientados à comercialização convertem os mesmos recursos em produtos diferentes. A correlação bruta entre publicações e patentes no dataset é de apenas 0,47.
- Holý e Šafr (2018) encontram relações diferentes entre desenvolvimento e eficiência na pesquisa básica e na aplicada.
- Guan e Chen (2012) separam as etapas de produção de conhecimento e de comercialização em sistemas nacionais de inovação. Os resultados deles devem ser conferidos no S09.
- A metafronteira formaliza a ideia de que grupos de países operam sob tecnologias distintas.

A lacuna atacada é a comparação dos dois canais, e da tecnologia por grupo de renda, na produção de conhecimento em IA.

**Teste.**
- **H3a:** DEA por canal e correlação de Spearman entre os escores, com bootstrap em blocos de país e p-valor unilateral de H0: ρ ≥ 0,5.
- **H3b:** metafronteira por grupo de renda, com dois alvos explícitos, ambos condicionais às fronteiras estimadas (a dependência entre TGRs pela fronteira compartilhada não é modelada):
  - deslocamento de distribuição, por Mann-Whitney unilateral (teste de postos), em país-ano e em médias por país;
  - diferença de TGR médio (renda média menos alta renda), com IC 95% por bootstrap em blocos de país.
- Decomposição amostra × especificação em amostra e fronteira comuns, ao comparar variantes.
- SFA de classes latentes como robustez exploratória (`artigo/15`).

**Critério.**
- **H3a:** p-valor unilateral de ρ ≥ 0,5 inferior a 0,05.
- **H3b:** Mann-Whitney unilateral com p inferior a 0,05 nas duas unidades amostrais **e** IC 95% da diferença de TGR médio inteiramente abaixo de zero.

**Situação em 04/10/2026.**
- **H3a inconclusiva** na Fase A e no painel base (ρ = 0,52 e 0,48). Só rejeitam ρ ≥ 0,5 a variante de patentes por inventor (ρ = 0,30) e o painel base com padronização min-max (ρ = 0,34).
- **H3b não apoiada** na Fase A e no painel base, com sinal contrário: o grupo de renda média define a metafronteira.
- **H3b apoiada** na variante de produtos ajustados por qualidade, onde os dois critérios são atendidos. Na de P&D público, só o deslocamento de distribuição, por efeito de composição da amostra.
- Essas inversões não resistem à padronização min-max (`artigo/14`).
- As classes latentes só acompanham a renda na Fase A.

## 4. Perguntas de pesquisa (exploratórias)

### RQ1 — Dinâmica (antiga H4)

**Pergunta.** A mudança de produtividade dos países na conversão de investimento em IA vem do deslocamento da fronteira ou da aproximação dela (catch-up)? Os países de renda média se aproximam da fronteira mais depressa que os de alta renda?

**Por que é pergunta, e não hipótese.** Os intervalos do índice de Malmquist são descritivos: a reamostragem de países com os índices fixos não propaga a incerteza da estimação das fronteiras, e o bootstrap de Malmquist de Simar e Wilson (1999) não foi implementado. Não há, portanto, teste capaz de refutar uma predição.

**Expectativa da literatura (guia de leitura, não critério de teste).** Difusão internacional do conhecimento e convergência (Färe et al., 1994; Barro e Sala-i-Martin, 1992):
- o progresso técnico em IA (aprendizagem profunda, ferramentas abertas, queda do custo de computação) desloca a fronteira para todos;
- quem está longe dela tem mais a aprender e se aproxima mais rápido.

Em palavras simples, a produtividade de um país pode subir porque os campeões avançaram ou porque o país se aproximou deles; o Malmquist separa os dois pedaços. Duas referências numéricas, mantidas como leitura descritiva:
- parcela da mudança técnica na variância de log M acima de 0,5, com a covariância rateada simetricamente;
- mudança de eficiência média da renda média acima de 1, com o intervalo por reamostragem excluindo 1.

**Cuidado metodológico.** Uma fronteira que parece recuar quando medida com fluxos anuais de capital de risco reflete o crescimento explosivo do denominador: no dataset original, a mediana do investimento cresceu cerca de 26 vezes entre 2013 e 2021, e a de publicações apenas 1,4 vez. Por isso o insumo entra defasado e o Malmquist é calculado sob retornos constantes, evitando distâncias intertemporais inviáveis sob retornos variáveis. Pela mesma razão de origem, o Malmquist só tem leitura nas unidades originais (`artigo/14`).

**Como responder.**
- Índice de Malmquist com decomposição em mudança de eficiência e mudança técnica no painel balanceado (2016–2019 no dataset original; 2017–2021 no painel reconstruído).
- Leitura país a país (`malmquist_por_pais`, S06).
- β-convergência: regressão da mudança de eficiência média no escore CRS inicial medido contra a mesma fronteira do painel balanceado (MQO descritivo).

**Situação em 04/10/2026.**
- A fronteira recua em produtos por dólar, e a maior parte dos países melhora a posição relativa porque a fronteira desce até eles.
- A mudança técnica domina a variância só na Fase A (parcela 0,60; 0,26 no painel).
- O catch-up da renda média não supera o da alta renda.
- China, Índia, Grécia e Argentina (Fase A) só se movem com a fronteira; o Brasil ganha por catch-up (`artigo/16`).

### RQ2 — Determinantes da eficiência (antigas H5, H6 e H7)

**Pergunta.** Como a qualidade institucional, o sistema financeiro e o nível de desenvolvimento se associam à eficiência de cada canal?

**Por que é pergunta, e não hipótese.** O segundo estágio é exploratório:
- a condição de separabilidade (Daraio, Simar e Wilson, 2018) não é testada;
- os escores são tratados como fixos;
- as variáveis de contexto são correlacionadas entre si (as quatro dimensões do WGI têm correlação de 0,91 a 0,96, e o PIB per capita, de cerca de 0,8 com elas).

As associações são descritas com níveis de evidência, sem tratamento de teste de hipótese.

**Expectativas da literatura**, usadas só para classificar o nível de evidência de cada coeficiente (S07; coluna `sinal_previsto` das tabelas):
- **E5 (instituições e capacidade de absorção; antiga H5):** associação positiva com a efetividade governamental (ou outra dimensão do WGI), os pesquisadores per capita, a concentração de talento em IA e as exportações de alta tecnologia (Furman, Porter e Stern, 2002; Cohen e Levinthal, 1990). Há uma expectativa concorrente: a regulação pode travar a inovação, o que motivou testar a qualidade regulatória e as outras dimensões. Cullmann, Schmidt-Ehmcke e Zloczysti (2012) estudam o efeito do ambiente regulatório sobre a eficiência de P&D; o resultado deles deve ser conferido no S09. O que cada dimensão do WGI mede está em Kaufmann, Kraay e Mastruzzi (2010) e no `artigo/16`. Quando o GERD é insumo, ele não reaparece como variável de contexto; usam-se pesquisadores per capita.
- **E6 (finanças no canal de patentes; antiga H6):** capitalização do mercado acionário positiva; crédito bancário ao setor privado não positivo (Hsu, Tian e Xu, 2014: mercados acionários financiam projetos de inovação de alto risco e longo prazo, e o crédito bancário, avesso a risco e dependente de garantias, não). A fragilidade bancária (empréstimos inadimplentes) entra como controle.
- **E7 (desenvolvimento; antiga H7):** PIB per capita positivo no canal de patentes e não positivo no de publicações, por extensão de Holý e Šafr (2018) à IA.

**Como responder.**
- Especificação principal: regressão truncada sobre o logaritmo do escore corrigido de viés (log s em (−∞, 0), truncada em 0), com escores fixos, bootstrap agrupado por país e verificação de convergência do ajuste pontual e de cada réplica. É o modelo de Simar e Wilson (2007) aplicado ao logaritmo da medida de Farrell, com suporte compatível com o escore.
- Comparações: algoritmo 2 de Simar e Wilson (2007) e Tobit.
- Dimensões alternativas do WGI no lugar da efetividade.
- Níveis de evidência por coeficiente: significativo a 5%, "bateu na trave" (5–10%), só o sinal, ou sinal contrário (`artigo/16`, seção 2).
- Kruskal-Wallis e Mann-Whitney por grupo de renda em cada canal.

**Situação em 04/10/2026.**
- **Instituições:** sinal contrário ao esperado em todas as 23 especificações (12 significativas a 5%), igual em todas as dimensões do WGI. Isso é coerente com sistemas de P&D grandes e ricos que produzem menos IA por dólar, e não com governança que "atrapalha".
- **Pesquisadores e exportações de alta tecnologia:** sinal esperado, raramente significativo.
- **Crédito no canal de patentes:** positivo, contra E6.
- **PIB per capita:** negativo em patentes (contra E7) e em publicações (compatível com E7).

## 5. Proposições de robustez

Reportadas como resultados, não como hipóteses:

- **R1.** Os rankings são estáveis entre estimadores (DEA com bootstrap, FDH, order-*m*, order-α, SFA), com correlação de Spearman superior a 0,7 e intervalo de confiança.
- **R2.** Os rankings são estáveis à estrutura de defasagem (t, t−1, t−2) e ao uso de soma móvel de três anos em vez de fluxo anual.
- **R3.** Os rankings são sensíveis ao ajuste por qualidade (citações no lugar de contagens de artigos; patentes concedidas no lugar de pedidos) e à fonte (patentes por país do inventor; VC da Preqin; P&D executado por ensino superior e governo). Essa sensibilidade é um achado a ser declarado, não um problema a ser escondido.
- **R4.** Os resultados VRS (ranking, canais, metafronteira, segundo estágio) são comparados com a padronização min-max das variáveis da fronteira (S01, `artigo/14`). A mudança de escala pura não altera nada; a min-max altera por translação. A escolha da especificação principal depende da decisão do autor com o professor.

## 6. Quadro-resumo

| | Método principal | Função em R | Critério ou referência de leitura |
|---|---|---|---|
| H1 retornos de escala | Teste de RTS com bootstrap (tamanho ≈ 0,20 por simulação); SE = CRS/VRS por país; soma das elasticidades do SFA | `TesteRtsBootstrap` (rotina própria alinhada a `rDEA::rts.test`), `Benchmarking::dea`, `frontier::sfa` | indício contra CRS (p < 0,05, teste liberal); SE < 0,8 nos grandes |
| H2 insumos por canal | SFA em log por canal, seis bases, bootstrap por país; DEA com/sem GERD | `frontier::sfa`, `sfaR::sfacross` | elasticidade só em patentes (estrito); diferença patentes − publicações > 0 (relativo) |
| H3 canais e metafronteira | DEA por canal; TGR por grupo de renda (Mann-Whitney e diferença de médias por blocos de país); classes latentes | `Benchmarking::dea`, `wilcox.test`, `sfaR::sfalcmcross` | p(ρ ≥ 0,5) < 0,05; TGR média < alta (postos e média) |
| RQ1 dinâmica | Malmquist CRS, painel balanceado, por grupo e por país; intervalos por reamostragem de países (descritivos) | `Benchmarking::malmquist` | parcela de TC > 0,5; EC > 1 na renda média (referências descritivas) |
| RQ2 determinantes | Truncada sobre log(escore), escores fixos, bootstrap por país; algoritmo 2; Tobit; dimensões do WGI; Kruskal-Wallis e Mann-Whitney por renda | `truncreg::truncreg`, `rDEA::dea.env.robust`, `AER::tobit` | níveis de evidência em relação às expectativas E5–E7 (exploratório) |

## Referências

Marcadas com (S09): dados bibliográficos e conteúdo a conferir na revisão por hipótese antes de entrar no manuscrito.

- Ali, A. I.; Seiford, L. M. (1990). Translation invariance in data envelopment analysis. *Operations Research Letters*, 9(6), 403–405.
- Banker, R. D.; Charnes, A.; Cooper, W. W. (1984). Some models for estimating technical and scale inefficiencies in Data Envelopment Analysis. *Management Science*, 30(9), 1078–1092.
- Barro, R. J.; Sala-i-Martin, X. (1992). Convergence. *Journal of Political Economy*, 100(2), 223–251.
- Battese, G. E.; Coelli, T. J. (1988). Prediction of firm-level technical efficiencies with a generalized frontier production function and panel data. *Journal of Econometrics*, 38(3), 387–399.
- Battese, G. E.; Coelli, T. J. (1992). Frontier production functions, technical efficiency and panel data: with application to paddy farmers in India. *Journal of Productivity Analysis*, 3, 153–169.
- Battese, G. E.; Coelli, T. J. (1995). A model for technical inefficiency effects in a stochastic frontier production function for panel data. *Empirical Economics*, 20, 325–332.
- Bogetoft, P.; Otto, L. (2011). *Benchmarking with DEA, SFA, and R*. Springer.
- Cazals, C.; Florens, J.-P.; Simar, L. (2002). Nonparametric frontier estimation: a robust approach. *Journal of Econometrics*, 106(1), 1–25.
- Charnes, A.; Cooper, W. W.; Rhodes, E. (1978). Measuring the efficiency of decision making units. *European Journal of Operational Research*, 2(6), 429–444.
- Cohen, W. M.; Levinthal, D. A. (1990). Absorptive capacity: a new perspective on learning and innovation. *Administrative Science Quarterly*, 35(1), 128–152.
- Cullmann, A.; Schmidt-Ehmcke, J.; Zloczysti, P. (2012). Innovation, R&D efficiency and the impact of the regulatory environment: a two-stage semi-parametric DEA approach. *Oxford Economic Papers*, 64(1), 176–196. (S09)
- Daraio, C.; Simar, L. (2005). Introducing environmental variables in nonparametric frontier models: a probabilistic approach. *Journal of Productivity Analysis*, 24, 93–121.
- Daraio, C.; Simar, L.; Wilson, P. W. (2018). Central limit theorems for conditional efficiency measures and tests of the "separability" condition in non-parametric, two-stage models of production. *The Econometrics Journal*, 21(2), 170–191.
- Deprins, D.; Simar, L.; Tulkens, H. (1984). Measuring labor-efficiency in post offices. In: *The Performance of Public Enterprises*. North-Holland.
- Ernst, E.; Mishra, S. (2021). AI Efficiency Index: identifying regulatory and policy constraints for resilient national AI ecosystems. *SSRN Working Paper* 3800783.
- Färe, R.; Grosskopf, S.; Norris, M.; Zhang, Z. (1994). Productivity growth, technical progress, and efficiency change in industrialized countries. *American Economic Review*, 84(1), 66–83.
- Furman, J. L.; Porter, M. E.; Stern, S. (2002). The determinants of national innovative capacity. *Research Policy*, 31(6), 899–933.
- Greene, W. (2005). Reconsidering heterogeneity in panel data estimators of the stochastic frontier model. *Journal of Econometrics*, 126(2), 269–303.
- Griliches, Z. (1979). Issues in assessing the contribution of research and development to productivity growth. *Bell Journal of Economics*, 10(1), 92–116.
- Guan, J.; Chen, K. (2012). Modeling the relative efficiency of national innovation systems. *Research Policy*, 41(1), 102–115. (S09)
- Holý, V.; Šafr, K. (2018). Are economically advanced countries more efficient in basic and applied research? *Central European Journal of Operations Research*, 26, 933–950.
- Hsu, P.-H.; Tian, X.; Xu, Y. (2014). Financial development and innovation: cross-country evidence. *Journal of Financial Economics*, 112(1), 116–135.
- Kaufmann, D.; Kraay, A.; Mastruzzi, M. (2010). The Worldwide Governance Indicators: methodology and analytical issues. *World Bank Policy Research Working Paper* 5430.
- Lovell, C. A. K.; Pastor, J. T. (1995). Units invariant and translation invariant DEA models. *Operations Research Letters*, 18(3), 147–151.
- Moraes, R. K.; Wanke, P. F. (2019). Impacto do BNDES na eficiência da indústria siderúrgica: aplicação do modelo Malmquist de dois estágios. *Cadernos EBAPE.BR*, 17(2), 229–246.
- O'Donnell, C. J.; Rao, D. S. P.; Battese, G. E. (2008). Metafrontier frameworks for the study of firm-level efficiencies and technology ratios. *Empirical Economics*, 34, 231–255.
- Olesen, O. B.; Petersen, N. C.; Podinovski, V. V. (2015). Efficiency analysis with ratio measures. *European Journal of Operational Research*, 245(2), 446–462.
- Pakes, A.; Griliches, Z. (1984). Patents and R&D at the firm level: a first look. In: Griliches, Z. (ed.), *R&D, Patents, and Productivity*. University of Chicago Press.
- Pastor, J. T. (1996). Translation invariance in data envelopment analysis: a generalization. *Annals of Operations Research*, 66, 93–102.
- Sharma, S.; Thomas, V. J. (2008). Inter-country R&D efficiency analysis: an application of data envelopment analysis. *Scientometrics*, 76(3), 483–501. (S09)
- Simar, L.; Wilson, P. W. (1998). Sensitivity analysis of efficiency scores: how to bootstrap in nonparametric frontier models. *Management Science*, 44(1), 49–61.
- Simar, L.; Wilson, P. W. (1999). Estimating and bootstrapping Malmquist indices. *European Journal of Operational Research*, 115(3), 459–471.
- Simar, L.; Wilson, P. W. (2002). Non-parametric tests of returns to scale. *European Journal of Operational Research*, 139(1), 115–132.
- Simar, L.; Wilson, P. W. (2007). Estimation and inference in two-stage, semi-parametric models of production processes. *Journal of Econometrics*, 136(1), 31–64.
- Wang, E. C.; Huang, W. (2007). Relative efficiency of R&D activities: a cross-country study accounting for environmental factors in the DEA approach. *Research Policy*, 36(2), 260–273. (S09)
- Wilson, P. W. (1993). Detecting outliers in deterministic nonparametric frontier models with multiple outputs. *Journal of Business & Economic Statistics*, 11(3), 319–323.
