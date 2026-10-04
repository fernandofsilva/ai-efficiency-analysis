# Brief para o deck — usar no Claude Design

**Revisão 5, de 04/10/2026: deck atualizado depois da apresentação de 28/09.** Este brief gera um deck novo com:
- a estrutura de hipóteses decidida no S03: três hipóteses e duas perguntas de pesquisa;
- os resultados das rodadas S01, S02 e S06 a S08, feitas a pedido do professor (`artigo/13`);
- as correções da análise crítica 3 (`artigo/18`).

O deck apresentado em 28/09 (`AI Effiency Analysis.pdf`, 20 páginas) fica como registro. A seção 2 lista o que está errado nele.

**Como usar:**
- Gerar o deck novo no Claude Design com as seções 3 e 4.
- Exportar em PowerPoint (`.pptx`), o formato que o programa da disciplina pede, e em PDF.
- Salvar os dois na raiz como `AI Efficiency Analysis - revisado.pptx` e `.pdf`, sem apagar o PDF de 28/09.

| Revisão | Data e commit | O que é |
|---|---|---|
| 1 | 27/09, `ae6c878` | gerou o primeiro PDF (19 páginas, sem figuras embutidas) |
| 2 | 27/09, `91ee83c` | roteiro de edição; não chegou ao PDF |
| 3 | 28/09, `f188559` | base do deck apresentado em 28/09 (20 páginas) |
| 4 | 04/10, `61c274f` | errata do deck apresentado (seção 2) |
| 5 | 04/10 | este brief: deck atualizado |

Os roteiros de edição das revisões 1 a 3 (página a página, da revisão 1 para a 3) saíram deste documento e continuam no histórico do git (versão do commit `61c274f`).

## 1. O que muda em relação ao deck de 28/09

| Tema | Deck de 28/09 | Deck atualizado | Origem |
|---|---|---|---|
| Estrutura | sete hipóteses (H1 a H7) | três hipóteses (H1 a H3) e duas perguntas de pesquisa: RQ1 (dinâmica, antiga H4) e RQ2 (determinantes, antigas H5 a H7, agora expectativas E5 a E7) | S03, `artigo/01` |
| Padronização | não testada | min-max testada em todo o pipeline; a escala pura não muda nada; decisão: unidades originais na análise principal e min-max como robustez (R4) | S01, `artigo/14` |
| H2 | "GERD eleva a eficiência média (M1 → M2) / a testar com SFA" | SFA em log por canal, seis bases; a comparação M1 × M2 da DEA não é teste (acrescentar insumo nunca baixa o escore) | S02, `artigo/15`; A03, A12 |
| Dinâmica | lida ao contrário: "a fronteira recua", "catch-up" | convenção maior que 1 = melhora: a fronteira avança e a maioria dos países se afasta dela; leitura por país | S06, `artigo/16`; A01, A02 |
| Segundo estágio | significância a 5% | níveis de evidência (5%, entre 5% e 10%, só o sinal, sinal contrário); quatro dimensões do WGI e um índice, todos da mesma cópia dos dados | S07, `artigo/16`; A07 |
| Dispersão por renda | "sem tendência clara" | comparação entre as metades do período com bootstrap de países; IQR relativo | S08; A10, A15 |
| Slide 12 | fig4 de uma versão anterior, em escore | fig4 vigente, em log do escore | A14 |
| Checagem de patentes | ρ = 0,75 | ρ = 0,76, sem os anos quebrados da Índia | A08 |
| Zeros de investimento | "zero = negócio não registrado" | tratamento em aberto: o professor recomendou ler o zero como zero (21/09); a sensibilidade com os zeros está pronta | `artigo/19` |
| Formato | PDF | PowerPoint (`.pptx`) e PDF | programa da disciplina |

## 2. Errata do deck apresentado em 28/09 (revisão 4)

Achados de `artigo/17`, com vereditos e correções em `artigo/18`. A conferência foi feita na página renderizada do PDF. Vale para quem for consultar o PDF de 28/09; o deck novo já sai correto.

**Os índices de Malmquist estavam lidos no sentido inverso (A01).** Na orientação a produto, o `Benchmarking` devolve índices em que valor menor que 1 é melhora. O projeto passou a gravar os recíprocos (convenção de Färe et al., 1994: maior que 1 = melhora), e as leituras se invertem:
- onde se lia "a fronteira recua", a fronteira avança;
- onde se lia "catch-up", o país se afasta da fronteira.

| Página | Está no deck apresentado | Correção | Achado |
|---|---|---|---|
| 11 | tabela: alta renda 0,996 / 0,898 / 1,109 [1,007; 1,230]; renda média 1,000 / 0,931 / 1,074 [0,958; 1,262]; todos 0,997 / 0,910 / 1,096 [1,010; 1,197]; "A fronteira domina (H4a), mas recua em produtos por dólar"; "Catch-up da renda média 1,074 [...]"; "β-convergência +0,11 (p = 0,11)"; "Maiores ganhos: Brasil 1,45 · Áustria 1,27 · Polônia 1,25. Maiores perdas: China 0,65 · Hungria 0,81 · Japão 0,82" | tabela: alta renda 1,004 / 1,114 / 0,902 [0,813; 0,993]; renda média 1,000 / 1,074 / 0,931 [0,792; 1,044]; todos 1,003 / 1,099 / 0,913 [0,835; 0,990]; "A fronteira avança (TC 1,10 [1,02; 1,19]) e domina a variância (parcela 0,60); os países, em média, se afastam dela (EC 0,91)"; "Renda média: EC 0,931 [0,792; 1,044], sem catch-up"; "β-convergência −0,11 (p = 0,11)"; "Maiores ganhos: China 1,54 · Hungria 1,23 · Japão 1,22 · Estados Unidos 1,21. Maiores perdas: Brasil 0,69 · Áustria 0,79 · Polônia 0,80 · Grécia 0,81" | A01 |
| 12 | gráfico da versão anterior ("dependente em (0,1]"; efetividade ≈ −0,137 destacada como significativa) ao lado de uma tabela em log do escore; "(semi-elasticidade)" na nota | fig4 vigente (dependente = log do escore; efetividade do conjunto −0,58 [−1,31; 0,02], cruzando zero); "positivo = mais eficiente (leitura de sinal; o coeficiente é da média latente da truncada)" | A14, A09 |
| 14 | H2 "GERD eleva a eficiência média (M1 0,42–0,71 → M2 0,64–0,82) / a testar com SFA"; H4a "Fronteira domina (parcela 0,60) e recua / apoiada"; H4b "EC média 1,074 [0,958; 1,262]; β +0,11 (p = 0,11)" | H2 pelo SFA (slide 11 do deck novo); H4a "a fronteira avança e domina a variância (0,60); os países se afastam (EC 0,91)"; H4b "EC da renda média 0,931 [0,792; 1,044]; β −0,11 (p = 0,11) / critério não atendido" | A01, A12, A03 |
| 15 | "sem convergência (EC da renda média 0,984 [0,909; 1,062])" | "sem catch-up da renda média (EC 1,016 [0,942; 1,100]), mas ela acompanha a fronteira, enquanto a alta renda se afasta (0,903 [0,875; 0,932]); produtividade cresce (M 1,09 [1,05; 1,13]) porque a fronteira avança (TC 1,17)" | A01 |
| 16 | "0,75 — Patentes: CSET (país de prioridade) × OCDE (país do inventor) [0,61; 0,85]" | "0,76 [0,62; 0,86], 299 pares, sem a Índia de 2019 em diante (série quebrada; com a série bruta, 0,75)" | A08 |
| 18 | "a fronteira recua em produtos por dólar durante o boom" | "a fronteira avança, puxada pela China, e a maioria dos países se afasta dela" | A01 |

## 3. Instruções para o Claude Design

- **Formato.**
  - Apresentação 16:9, em português do Brasil, tom acadêmico e direto.
  - 21 slides, mais um de bibliografia (opcional).
  - Para uma fala de 20 minutos, os slides 10 e 16 viram apêndice: ficam no arquivo, sem fala.
- **Rodapé:** "Introdução à Análise de Eficiência em R — Prof. Peter Wanke".
- **Autor:** Fernando Silva.
- **Título:** **"Quem converte melhor investimento em IA em ciência e patentes? Uma análise de fronteira para 37 países (2013–2021)"**. Subtítulo: "Versão revisada após os comentários da apresentação de 28/09/2026".
- **Identidade visual.**
  - Fundo claro, uma cor de destaque (azul #1f77b4) e uma de contraste (laranja #ff7f0e), cinza para texto secundário.
  - Tipografia sem serifa; no máximo 5 bullets por slide; números grandes em destaque quando indicado.
- **Figuras.**
  - Embutir os PNGs como imagem: fazer o upload dos arquivos de `output/figures/` listados abaixo, em página inteira ou meia página.
  - Não redesenhar nem recolorir gráficos (a fig4 usa cores próprias para os níveis de evidência). Não deixar o caminho do arquivo no lugar da imagem.

| Slide | Arquivo |
|---|---|
| 9 | `fig1_ranking_m2.png` |
| 10 | `fig6_estimadores.png` |
| 12 | `fig3_canais.png` e `fig7_metafronteira.png` |
| 13 | `fig2_malmquist_decomposicao.png` (regenerada em 04/10, na convenção corrigida) |
| 15 | `fig4_segundo_estagio.png` (em log do escore) |
| 16 | `fig5_renda_ano.png` |
| 17 | `fig11_ranking_padronizacao_minmax.png` |

- **Estrutura de cada slide:** título, conteúdo (bullets ou tabela), figura (se houver) e nota do apresentador (o que falar, 60 a 80 segundos).
- **Escala e convenções:**
  - eficiência técnica em (0, 1], orientação a produto; 1 = na fronteira;
  - "corrigido de viés" = após o bootstrap de Simar e Wilson (1.000 réplicas);
  - índices de Malmquist: maior que 1 = melhora.

## 4. Slides

### Slide 1 — Título

- Título, subtítulo, nome, disciplina e data (outubro de 2026).
- Nota: "Medimos quanto cada país consegue extrair, em publicações e patentes de IA, do dinheiro que entra em IA e em P&D. Esta versão incorpora os comentários da aula e uma revisão completa dos resultados."

### Slide 2 — Pergunta e por que importa

- **Pergunta:** quais países são mais eficientes em converter investimento privado em IA e gasto em P&D em produção científica (publicações) e tecnológica (patentes) de IA, e o que explica as diferenças?
- **Por que fronteiras:** comparar produtos com insumos, e não volumes absolutos. Estados Unidos e China lideram em volume, não necessariamente em eficiência.
- **Antecedentes:**
  - Ernst e Mishra (2021), *AI Efficiency Index* (DEA, 27 países, 2015–2018);
  - Fukuyama, Tan e Wanke (2025), DEA para países em 2013–2021, em que a ineficiência em patentes é mais comum na América Latina e na renda média.
- **Contribuição:** mais países e anos, inferência por bootstrap, fronteiras robustas, SFA por canal, dinâmica (Malmquist), heterogeneidade (metafronteira) e segundo estágio institucional.
- Nota: enquadrar como função de produção de conhecimento (Griliches; Furman, Porter e Stern) e capacidade de absorção (Cohen e Levinthal). O trabalho do grupo do professor é o ponto de comparação; dele, até agora, só o resumo foi lido.

### Slide 3 — O que mudou desde 28/09

| Comentário da aula | O que foi feito | Slide |
|---|---|---|
| Padronizar as variáveis da fronteira e rodar tudo de novo | min-max em todo o pipeline. A escala pura não muda nada (diferença < 4 × 10⁻¹²); a min-max soma uma constante aos dados e muda resultados. Unidades originais na análise principal; min-max como robustez | 17 |
| Fronteira estocástica (SFA) de H2 em log | SFA por canal nas seis bases; em log, cada ajuste leva menos de meio segundo | 11 |
| Menos hipóteses, mais perguntas de pesquisa | 3 hipóteses e 2 perguntas de pesquisa | 6 |
| Separar deslocamento da fronteira e catch-up, país a país | Malmquist por país | 13, 14 |
| Dois níveis de evidência e o que mede o WGI | níveis de evidência; quatro dimensões do WGI e um índice | 15 |
| Dispersão por grupo de renda | dispersão por grupo e ano, com teste que respeita a repetição dos países | 16 |

- **Terceira revisão crítica do projeto** (15 achados, todos corrigidos): o principal é que o Malmquist estava lido ao contrário.
- Nota: "O resultado que mais mudou foi a dinâmica: a fronteira não recua, avança, e a maioria dos países fica para trás. As discussões país a país com evidência contemporânea (S04, S05) vêm a seguir."

### Slide 4 — Dados

| Item | Valor |
|---|---|
| Observações | 208 país-ano na base bruta; 191 na DEA (17 zeros de investimento fora do modelo principal) |
| Países | 37 na base bruta, 36 na DEA (a Eslovênia só tem uma observação, com investimento zero); sem Alemanha, Coreia, Canadá, Suécia, Finlândia e Dinamarca (a Noruega está na base) |
| Período | 2013–2021, painel desbalanceado (1 a 9 anos por país) |
| Insumos | investimento privado em IA (US$ constantes de 2021); GERD = P&D % PIB × PIB (P&D interno total, todos os setores) |
| Produtos | publicações de IA (contagem); pedidos de patente de IA (contagem) |
| Contexto | governança (WGI), alta tecnologia, comércio, crédito, mercado de capitais, PIB per capita (World Bank) |

- **Proveniência verificada:** indicadores de IA do CSET Country Activity Tracker via Our World in Data. As patentes vinham **por milhão de habitantes** e foram reconvertidas em contagem com a população do World Bank.
- Nota: a origem foi rastreada valor a valor (Argentina 2018: 1.079.101 no dataset e 1.079.102 na fonte).

### Slide 5 — Problemas de medida que condicionam tudo

- **Zeros e piso.** 17 país-ano com investimento zero e 22 no piso de 1 a 2 milhões de dólares (granularidade de 1 milhão): 39 das 208 observações.
  - Sob retornos variáveis, uma unidade sem investimento só é comparada a outras sem investimento e sai quase eficiente por construção. Em 2015, as cinco com zero têm escore médio 0,91, e a média das demais cai de 0,77 para 0,72.
  - O modelo principal deixa os zeros fora. O tratamento final está em aberto: o professor recomendou ler o zero como zero, e a sensibilidade com os zeros está pronta.
- **Supereficiência não é só piso.** 19 unidades ficam além da fronteira agrupada.
  - 7 estão no piso: Austrália e México 2013, Romênia e Malásia 2016, Ucrânia 2018, Peru 2019, Bulgária 2021.
  - As outras 12 são pontos extremos ou revisões de safra.
- **Publicações não nascem de capital de risco.** A Ucrânia 2013–2017 tem investimento zero e 134 a 359 publicações por ano. Por isso o GERD entra como segundo insumo.
- **Volume, não qualidade.** Contagens favorecem sistemas grandes: a China 2021 supera os Estados Unidos nos dois produtos com um sexto do insumo.
- Nota: "O diagnóstico começa reconhecendo o que os dados podem e não podem dizer."

### Slide 6 — Hipóteses e perguntas de pesquisa

| | Enunciado (resumo) | Como é testado |
|---|---|---|
| H1 | Retornos variáveis de escala; os grandes investidores com ineficiência de escala | teste de retornos de escala com bootstrap; escala por país; retornos no SFA |
| H2 | Dado o P&D, o investimento privado tem efeito em patentes e não em publicações | SFA em log por canal |
| H3 | H3a: canais acadêmico e tecnológico pouco correlacionados (ρ < 0,5); H3b: renda média com tecnologia menos favorável que a alta renda | DEA por canal; metafronteira por renda |
| RQ1 | A produtividade muda pela fronteira ou pela aproximação dela? A renda média alcança a alta renda? | Malmquist (intervalos descritivos) |
| RQ2 | Como instituições (E5), finanças (E6) e desenvolvimento (E7) se associam à eficiência? | segundo estágio exploratório, com níveis de evidência |

- Proposições de robustez:
  - R1, entre estimadores;
  - R2, defasagens;
  - R3, produtos e fontes alternativas;
  - R4, padronização min-max.
- Nota: "As antigas H4 a H7 viraram perguntas de pesquisa: os intervalos do Malmquist são descritivos e o segundo estágio não testa separabilidade, então não dão para refutar previsões com segurança."

### Slide 7 — Método

- **Modelos.** M1 (insumo único: investimento; replicação de Ernst e Mishra) e M2 (investimento + GERD; base). Canais separados: só publicações e só patentes.
- **Fronteiras.**
  - Contemporâneas por ano (16 a 27 países por ano), orientação a produto, CRS, VRS e NIRS.
  - Fronteira agrupada só para supereficiência, metafronteira, teste de retornos de escala e algoritmo 2.
- **Inferência.**
  - Bootstrap de Simar e Wilson (1.000 réplicas).
  - Ranking com pseudo-valores, intervalo de postos e contrastes pareados.
  - Teste de retornos de escala com a construção de `rDEA::rts.test` (tamanho ≈ 0,20 por simulação; diagnóstico exploratório).
  - Correlações com bootstrap em blocos de país.
  - Malmquist na convenção maior que 1 = melhora.
- **SFA por canal, em log.** Cobb-Douglas agrupada (principal), exponencial, translog e painel (Battese e Coelli, 1988 e 1992); intervalos por bootstrap de país; veredito de H2 pela diferença entre canais.
- **Segundo estágio.** Truncada sobre log(escore), com escores fixos e bootstrap por país (especificação exploratória própria; leitura de sinal), algoritmo 2 de Simar e Wilson e Tobit; níveis de evidência; Kruskal-Wallis e Mann-Whitney por renda.
- **Robustez à padronização:** min-max em [0,01; 1] (R4).
- Nota: tudo em R (Benchmarking, rDEA, nonparaeff, frontiles, truncreg, frontier, sfaR); pipeline único, com status por etapa e manifesto das saídas.

### Slide 8 — H1: escala e retornos

| Modelo | H0 | S | p-valor | Leitura |
|---|---|---|---|---|
| M2 | retornos constantes | 0,666 | 0,091 | sem indício (teste com tamanho ≈ 0,20) |
| M2 | retornos não crescentes | 0,989 | 0,96 | sem indício |
| M1 | retornos constantes | 0,202 | 0,116 | sem indício |

- **Por país:** 15 dos 36 operam em retornos decrescentes em todos os anos (Estados Unidos, eficiência de escala média 0,35; Japão 0,67; Reino Unido 0,41). A **China está em retornos constantes, com eficiência de escala 1, em todos os anos**; a Índia alterna. Em 2018: 20 países em DRS, 3 em IRS e 4 em CRS.
- **SFA, evidência complementar** (intervalo por bootstrap de país): retornos decrescentes em publicações, 0,69 [0,55; 0,79]. Em patentes, 1,25 [0,92; 1,45], não distinguíveis de constantes; no painel reconstruído, levemente crescentes: 1,29 [1,003; 1,53].
- **Min-max:** desloca a origem e tira a leitura econômica dos retornos de escala. H1 só vale em unidades originais.
- **Situação:** sem apoio conclusivo; heterogeneidade por país e por canal.
- Nota: "O teste global não decide, e um teste que rejeita demais não ajudaria. O que os dados mostram é heterogeneidade: os grandes ocidentais em retornos decrescentes, a China no tamanho de rendimento máximo. A discussão país a país, com evidência contemporânea, é o próximo passo."

### Slide 9 — Ranking com inferência

- **Figura:** `fig1_ranking_m2.png` (página inteira). As barras são o IC 95% por pseudo-valores de Simar e Wilson da média anual; os anos por país vêm entre parênteses.
- **Viés:** viés médio do bootstrap de 0,15 (escore médio 0,72 → 0,57 corrigido).
- **Topo:** Itália (2 anos) 0,80 [0,71; 0,90], Grécia (7) 0,78, Malásia (4) 0,77, Indonésia (2) 0,77, Índia (8) 0,77.
- **Base:** África do Sul (5) 0,25, Noruega (6) 0,24, Irlanda (2) 0,22, Israel (9) 0,19 [0,18; 0,20], Suíça (1) 0,15.
- **Contrastes pareados:** a Suíça fica abaixo dos 35 demais, Israel de 34, Irlanda de 32. A ordem dentro do topo não é distinguível: os intervalos de posto dos oito primeiros vão até 13–18.
- **Robustez:** com min-max, a base se mantém (Israel 35º → 36º de 36) e o topo muda (Spearman entre versões 0,45 [0,10; 0,73]).
- **Cautela:** Itália e Suíça têm 1 ou 2 anos. Pela regra de pelo menos três anos por país, sugerida no laboratório de 21/09, os dois sairiam do ranking (decisão em aberto).
- Nota: Israel e Suíça ficam na base porque têm GERD total alto (muito P&D empresarial) e produtos de IA pequenos em contagem. A "eficiência" aqui mede, em parte, a intensidade de IA do sistema de pesquisa.

### Slide 10 — Robustez entre estimadores (R1) [apêndice na fala de 20 minutos]

- **Figura:** `fig6_estimadores.png`.
- **Spearman com o escore VRS** (IC por bloco de país):
  - corrigido 0,93 [0,83; 0,97];
  - insumo único 0,72 [0,57; 0,84];
  - FDH 0,70 [0,51; 0,82];
  - order-α 0,69 [0,48; 0,81];
  - order-m 0,51 [0,23; 0,70].
- Nota: as fronteiras parciais (order-m) penalizam menos os vizinhos das observações no piso, por isso concordam menos. O ranking é moderadamente robusto.

### Slide 11 — H2: o investimento privado importa mais para patentes?

Elasticidade do investimento, ponto e IC 95% por bootstrap de país:

| Base e modelo | Publicações | Patentes | Patentes − publicações | Veredito |
|---|---|---|---|---|
| Fase A, agrupado | 0,10 [−0,05; 0,25] | 0,09 [−0,14; 0,27] | −0,01 [−0,22; 0,20] | não apoiada |
| Fase A, painel 1988 | 0,02 [−0,001; 0,07] | 0,14 [0,05; 0,21] | 0,12 [0,03; 0,20] | apoiada |
| Fase A, painel 1992 | 0,02 [−0,001; 0,04] | 0,15 [0,05; 0,24] | 0,13 [0,03; 0,23] | apoiada |
| Painel reconstruído, agrupado | 0,03 [−0,07; 0,13] | −0,12 [−0,30; 0,10] | −0,15 [−0,34; 0,09] | não apoiada |
| Painel reconstruído, painel 1988 | 0,03 [0,01; 0,06] | 0,04 [−0,03; 0,15] | 0,01 [−0,07; 0,12] | não apoiada |

- **Critério:** apoiada quando o efeito em patentes e a diferença patentes − publicações têm IC acima de zero.
- **Nas 18 combinações** (seis bases × três modelos):
  - 3 apoiadas: as duas da Fase A acima e, no limite, a agrupada com patentes por país do inventor;
  - 2 com apoio parcial;
  - 13 não apoiadas;
  - nenhuma contrária.
- **O robusto é o P&D:** elasticidade de 0,59 em publicações e 1,17 em patentes na Fase A (0,64 e 1,41 no painel).
- Nota: "Em palavras simples: depois de levar em conta o P&D, o dinheiro privado em IA explica pouco da produção; quem explica é o P&D. A comparação da DEA com e sem GERD não serve de teste, porque acrescentar um insumo nunca baixa o escore."

### Slide 12 — H3: dois canais e a metafronteira

- **Figuras:** `fig3_canais.png` (meia página) e `fig7_metafronteira.png` (meia página).
- **H3a, canais:** Spearman entre a eficiência acadêmica e a tecnológica de 0,52 [0,31; 0,69]; p unilateral de ρ ≥ 0,5 = 0,59. Inconclusiva.
- **H3b, metafronteira:** razão de gap tecnológico (TGR) de 0,62 na alta renda contra 0,94 na renda média; Mann-Whitney p = 1,0; diferença de TGR médio +0,32 [0,23; 0,40]. Não apoiada, com sinal contrário: com contagens, o grupo de renda média define a fronteira (China, Índia, México, Peru).
- **Patentes por renda:** Kruskal-Wallis p = 0,001 em país-ano e 0,022 em médias por país (0,34 na renda média-alta contra 0,17 na alta renda); publicações não diferem.
- **Robustez:**
  - nas classes latentes da SFA, só na Fase A, em publicações, as classes acompanham a renda;
  - com min-max, H3b continua sem apoio (+0,27 [0,18; 0,35]).
- Nota: ligar ao problema de volume × qualidade do slide 5.

### Slide 13 — RQ1: dinâmica 2016–2019

- **Figura:** `fig2_malmquist_decomposicao.png`.

| Grupo | n | Malmquist | Mudança técnica (fronteira) | Mudança de eficiência (catch-up) [intervalo] |
|---|---|---|---|---|
| Alta renda | 10 | 1,004 | 1,114 | 0,902 [0,813; 0,993] |
| Renda média | 6 | 1,000 | 1,074 | 0,931 [0,792; 1,044] |
| Todos | 16 | 1,003 | 1,099 | 0,913 [0,835; 0,990] |

- **Fronteira e países:** a fronteira avança cerca de 10% ao ano (TC 1,10 [1,02; 1,19]); os países, em média, se afastam dela (EC 0,91 [0,84; 0,99]); a produtividade fica estável. A mudança técnica domina a variância (parcela 0,60).
- **Renda média:** 0,931 [0,792; 1,044], sem catch-up pelo critério; β-convergência −0,11 (p = 0,11).
- **Painel reconstruído (2017–2021):** a produtividade cresce (M 1,09 [1,05; 1,13]) com a fronteira avançando (TC 1,17) e os países se afastando (EC 0,93).
- **Intervalos:** reamostragem de países com índices fixos; são descritivos.
- Nota: "Em palavras simples: a produtividade de um país muda porque os campeões avançaram ou porque ele se aproximou dos campeões. Aqui os campeões avançaram, e a maioria ficou para trás. O deck de 28/09 dizia o contrário, porque lia os índices do pacote no sentido inverso."

### Slide 14 — RQ1 por país: quem puxa a fronteira e quem fica para trás

Médias geométricas 2016–2019 (maior que 1 = melhora):

| País | Malmquist | Fronteira (TC) | Catch-up (EC) | Leitura |
|---|---|---|---|---|
| China | 1,54 | 1,54 | 1,00 | na fronteira em todos os anos: puxa a fronteira |
| Hungria | 1,23 | 1,21 | 1,02 | estável; fronteira avança |
| Japão | 1,22 | 1,31 | 0,93 | se afasta; fronteira avança |
| Estados Unidos | 1,21 | 1,47 | 0,82 | se afasta; fronteira avança |
| Índia | 1,05 | 1,05 | 1,00 | na fronteira em todos os anos |
| Grécia | 0,81 | 0,81 | 1,00 | na fronteira em todos os anos; a fronteira recua no seu ponto |
| Polônia | 0,80 | 1,00 | 0,80 | se afasta |
| Áustria | 0,79 | 1,28 | 0,61 | se afasta; fronteira avança |
| Brasil | 0,69 | 1,05 | 0,66 | se afasta; fronteira estável |

- **Catch-up:** só África do Sul, Israel e Singapura, a partir de escores baixos.
- **Tese do platô:** não se confirma. A fronteira avança mais onde estão os grandes investidores.
- **Renda média × alta renda:** no ponto, a renda média se sai um pouco melhor nas seis bases, mas sem catch-up pelo critério.
- **Expectativas da aula:** a da China se confirma (sem catch-up, com deslocamento positivo da fronteira); a do Brasil, não (ele se afasta da fronteira).
- Nota: Moraes e Wanke (2019) chamam o catch-up de "Mudança Técnica". Aqui, "mudança técnica" é o deslocamento da fronteira.

### Slide 15 — RQ2: segundo estágio com níveis de evidência

- **Figura:** `fig4_segundo_estagio.png`. Os painéis da figura ainda usam os nomes antigos dos modelos. Pôr uma legenda curta embaixo dela: "H5 = E5 (instituições), H6 = E6 (finanças), H7 = E7 (desenvolvimento)".

| Variável (expectativa) | Coeficiente [IC 95%] | Nível de evidência |
|---|---|---|
| Efetividade governamental (E5, +) | −0,58 [−1,31; 0,02] | sinal contrário, 5–10% |
| Efetividade, sem valores-piso | −0,66 [−1,69; 0,02] | sinal contrário, 5–10% |
| Pesquisadores por milhão (E5, +) | 0,15 [−0,18; 0,44] | só o sinal |
| Capitalização de mercado, patentes (E6, +) | 0,000 [−0,015; 0,023] | sem sinal (≈ 0) |
| Crédito privado, patentes (E6, não positivo) | 0,014 [−0,022; 0,042] | compatível |
| PIB per capita, patentes (E7, +) | −0,53 [−1,80; 0,27] | sinal contrário |
| PIB per capita, publicações (E7, não positivo) | −0,36 [−0,66; −0,02] | compatível |

- **Dependente:** log do escore corrigido (normal truncada em 0, especificação exploratória própria). Positivo = mais eficiente, com leitura de sinal.
- **Outras dimensões do WGI**, todas da mesma cópia dos dados (a do World Bank): efetividade −0,66 [−1,32; −0,04]; qualidade regulatória −0,56 (5–10%); estado de direito −0,49; controle da corrupção −0,49; índice −0,57. As dimensões têm correlação de 0,93 a 0,96 e não se separam.
  - A efetividade da tabela (−0,58) vem da cópia do dataset original, que difere da do World Bank em todas as observações. Parte da diferença entre −0,58 e −0,66 é a troca de cópia.
- **Nas seis bases**, a efetividade tem sinal contrário em 23 de 23 especificações (13 significativas a 5%); o algoritmo 2 e o Tobit concordam. Com min-max, o sinal das instituições e o do PIB per capita em patentes resistem; os de pesquisadores e crédito, não.
- **Contraste:** no trabalho de Fukuyama, Tan e Wanke (2025), o controle da corrupção reduz a ineficiência em patentes.
- Nota: "O sinal negativo aparece com qualquer dimensão do WGI. Uma leitura coerente: países ricos, com instituições melhores e sistemas de P&D grandes, produzem menos IA por dólar. Isso não quer dizer que a governança atrapalha. O segundo estágio é exploratório: não há teste de separabilidade."

### Slide 16 — Dispersão por renda e ano [apêndice na fala de 20 minutos]

- **Figura:** `fig5_renda_ano.png`.
- **Comparação entre as metades do período** (2013–2017 × 2018–2021), com bootstrap de países: nenhuma diferença distinguível de zero.
  - Alta renda: desvio mediano de 0,129 para 0,169 (+0,04 [−0,07; 0,11]).
  - Renda média-alta: de 0,021 para 0,054 (+0,03 [−0,09; 0,17]).
- **Quem abre a distribuição:**
  - Israel é o mínimo da alta renda em todos os anos.
  - Na renda média-alta, os mínimos são Brasil (até 2015), África do Sul (2016–2019) e Argentina (2020–2021).
  - A "abertura" de 2018 na renda média-baixa é a entrada das Filipinas (composição, não crise).
- Nota: as fronteiras são anuais, então a dispersão descreve cada ano e não se compara mecanicamente entre anos.

### Slide 17 — Robustez à padronização min-max (S01)

- **Figura:** `fig11_ranking_padronizacao_minmax.png`.
- **Escala pura:** dividir cada variável pelo seu máximo reproduz tudo (diferença < 4 × 10⁻¹²). A ordem de grandeza, sozinha, não muda a DEA.
- **Min-max:** além de mudar a escala, soma uma constante a cada variável. Na Fase A, equivale a dar a todos os países mais 854 patentes, 659 publicações, US$ 1,5 bilhão de investimento e US$ 7,0 bilhões de GERD. Reduzir ε não desfaz isso: com ε = 10⁻⁹, a diferença nos escores ainda chega a 0,35.
- **O que resiste e o que muda:**
  - **resistem:** a base do ranking (Israel), H3b sem apoio, o sinal das instituições e o do PIB per capita em patentes;
  - **mudam:** o topo do ranking, a força de H3a, pesquisadores e crédito;
  - **sem leitura com min-max:** retornos de escala (H1) e Malmquist (RQ1).
- **Decisão:** unidades originais na análise principal; min-max como robustez (R4).
- Nota: a preocupação levantada na aula foi testada: a escala sozinha não atrapalha, e a min-max muda resultados por outro motivo, a translação.

### Slide 18 — Síntese por hipótese e pergunta

| | Evidência (Fase A) | Situação |
|---|---|---|
| H1 escala | teste global sem indício contra CRS (p = 0,09; tamanho ≈ 0,20); EUA em DRS, China em CRS; SFA: publicações em retornos decrescentes | sem apoio conclusivo; heterogeneidade por país e canal |
| H2 insumos por canal | SFA: apoiada em 3 de 18 combinações (modelos de painel da Fase A; inventor, no limite); o P&D domina | apoio fraco e localizado; não no painel reconstruído |
| H3a canais | ρ = 0,52 [0,31; 0,69]; p(ρ ≥ 0,5) = 0,59 | inconclusiva |
| H3b metafronteira | TGR da renda média 0,94 > alta 0,62; diferença +0,32 [0,23; 0,40] | não apoiada (sinal contrário) |
| RQ1 dinâmica | a fronteira avança (TC 1,10) e os países se afastam (EC 0,91); renda média 0,93 [0,79; 1,04] | a fronteira domina; sem catch-up |
| RQ2-E5 instituições | sinal contrário em 23 de 23 especificações (13 a 5%), com todas as dimensões do WGI | associação negativa robusta, contrária à expectativa |
| RQ2-E6 finanças | capitalização ≈ 0; crédito compatível na Fase A e positivo no painel (contrário à expectativa), efeito que some com min-max | sem apoio |
| RQ2-E7 desenvolvimento | PIB per capita negativo em patentes e em publicações | contrária no canal de patentes |
| R1 estimadores | ρ entre 0,51 e 0,93 | moderadamente robusto |
| R4 padronização | escala pura sem efeito; a min-max muda por translação | resistem a base do ranking, H3b e os sinais de E5 e E7 |

### Slide 19 — Versão artigo: painel reconstruído e outras fontes

- **Painel CSET + World Bank:** 47 países (com Alemanha, Coreia, Canadá, nórdicos e Rússia), modelo conjunto 2017–2021 com insumos defasados, 204 observações.
- **Resultados que se mantêm:**
  - teste de retornos de escala sem indício contra retornos constantes (S = 0,577, p = 0,44), com China, Coreia e Índia em CRS;
  - instituições negativas e significativas (−0,69 [−1,20; −0,21]);
  - H2 sem apoio, inclusive com o P&D público como controle.
- **Dinâmica:** a produtividade cresce (M 1,09) com a fronteira avançando (TC 1,17). A renda média acompanha a fronteira (1,02 [0,94; 1,10]), e a alta renda se afasta (0,90). Não há catch-up pelo critério. Aqui a mudança de eficiência varia mais que a técnica (parcela da TC na variância 0,26), então a fronteira não domina como na Fase A.
- **Variantes:**
  - **produtos alternativos** (citações, famílias concedidas): invertem a metafronteira por especificação e atenuam a associação negativa com instituições (em amostra comum, o coeficiente sobe 0,43 [0,05; 0,75] em relação à base); nenhum dos dois resultados resiste à min-max;
  - **P&D executado por ensino superior e governo:** Israel vai de 0,16 a 0,22 pela composição da amostra e a 0,47 pelo insumo.
- **Fontes:**
  - investimento: CSET × Quid ρ = 0,93; CSET × Preqin 0,83 [0,76; 0,89];
  - publicações: CSET × OECD.AI 0,95;
  - patentes: CSET × OCDE (inventor) 0,76 [0,62; 0,86];
  - rankings em amostra e fronteira comuns: 0,87 (Preqin) e 0,91 (inventor);
  - instituições negativas também com a Preqin (−1,12) e com patentes por inventor (−0,30 [−0,71; −0,002]).
- Nota: os fornecedores preservam a ordem geral; a atribuição das patentes e a escolha dos produtos mudam resultados específicos.

### Slide 20 — Limitações

- **Medida.**
  - Produtos em contagem (volume) e insumo de P&D não específico de IA.
  - Patentes atribuídas ao país de prioridade, e não ao do inventor.
  - Cobertura do Crunchbase e granularidade de 1 milhão de dólares.
  - Tratamento dos zeros ainda em aberto.
- **Dimensionalidade:** poucas unidades por ano (16 a 27) com quatro variáveis, o que dá muitas eficientes e intervalos largos.
- **Inferência.**
  - Teste de retornos de escala com tamanho ≈ 0,20.
  - Intervalos do Malmquist só descritivos (falta o bootstrap de Simar e Wilson, 1999).
  - Pseudo-valores do ranking condicionais às fronteiras anuais.
  - Segundo estágio com escores fixos e leitura de sinal.
  - No SFA agrupado, a ineficiência em publicações não é identificada.
- **Separabilidade:** o segundo estágio depende dela, e o teste formal (Daraio, Simar e Wilson, 2018) ainda não foi feito.

### Slide 21 — Conclusões e próximos passos

- **Três mensagens:**
  1. Os retornos de escala são heterogêneos por país, e o teste global, liberal, não dá indício contra retornos constantes. No SFA, publicações têm retornos decrescentes.
  2. A fronteira avança, puxada pela China, e a maioria dos países fica para trás. A renda média não alcança a alta renda.
  3. Depois do P&D, o investimento privado explica pouco (H2 com apoio fraco), e instituições melhores andam junto com menos IA por dólar. Medir eficiência em IA exige produtos alternativos e P&D por setor de execução.
- **Próximos passos:**
  - discussões país a país com evidência contemporânea (S04, S05) e revisão de literatura (S09; periódico candidato: CEJOR);
  - teste de separabilidade e bootstrap de Malmquist;
  - as técnicas do programa que faltam: ganhos com fusões, TOPSIS e análise das folgas;
  - decisões com o professor: zeros, base industrial e regra de três anos no ranking;
  - manuscrito.
- Nota final: agradecer e abrir para perguntas.

### Bibliografia (opcional, slide 22)

Mesmo formato da lista de `artigo/01_hipoteses.md`, em duas colunas, com título do artigo em redondo e periódico em itálico.

- Ali, A. I.; Seiford, L. M. (1990). Translation invariance in data envelopment analysis. *Operations Research Letters*, 9(6), 403–405.
- Banker, R. D.; Charnes, A.; Cooper, W. W. (1984). Some models for estimating technical and scale inefficiencies in data envelopment analysis. *Management Science*, 30(9), 1078–1092.
- Battese, G. E.; Coelli, T. J. (1988). Prediction of firm-level technical efficiencies with a generalized frontier production function and panel data. *Journal of Econometrics*, 38(3), 387–399.
- Battese, G. E.; Coelli, T. J. (1992). Frontier production functions, technical efficiency and panel data: with application to paddy farmers in India. *Journal of Productivity Analysis*, 3, 153–169.
- Bogetoft, P.; Otto, L. (2011). *Benchmarking with DEA, SFA, and R*. Springer.
- Cazals, C.; Florens, J.-P.; Simar, L. (2002). Nonparametric frontier estimation: a robust approach. *Journal of Econometrics*, 106(1), 1–25.
- Charnes, A.; Cooper, W. W.; Rhodes, E. (1978). Measuring the efficiency of decision making units. *European Journal of Operational Research*, 2(6), 429–444.
- Cohen, W. M.; Levinthal, D. A. (1990). Absorptive capacity: a new perspective on learning and innovation. *Administrative Science Quarterly*, 35(1), 128–152.
- Daraio, C.; Simar, L. (2005). Introducing environmental variables in nonparametric frontier models: a probabilistic approach. *Journal of Productivity Analysis*, 24, 93–121.
- Daraio, C.; Simar, L.; Wilson, P. W. (2018). Central limit theorems for conditional efficiency measures and tests of the "separability" condition in non-parametric, two-stage models of production. *The Econometrics Journal*, 21(2), 170–191.
- Ernst, E.; Mishra, S. (2021). AI Efficiency Index: identifying regulatory and policy constraints for resilient national AI ecosystems. *SSRN Working Paper* 3800783.
- Färe, R.; Grosskopf, S.; Norris, M.; Zhang, Z. (1994). Productivity growth, technical progress, and efficiency change in industrialized countries. *American Economic Review*, 84(1), 66–83.
- Fukuyama, H.; Tan, Y.; Wanke, P. (2025). Global inefficiencies in labour, patents, energy, capital, environment, and economics: the role of corruption, democracy, and income distribution. *Socio-Economic Planning Sciences*, 100, 102248.
- Furman, J. L.; Porter, M. E.; Stern, S. (2002). The determinants of national innovative capacity. *Research Policy*, 31(6), 899–933.
- Holý, V.; Šafr, K. (2018). Are economically advanced countries more efficient in basic and applied research? *Central European Journal of Operations Research*, 26, 933–950.
- Hsu, P.-H.; Tian, X.; Xu, Y. (2014). Financial development and innovation: cross-country evidence. *Journal of Financial Economics*, 112(1), 116–135.
- Kaufmann, D.; Kraay, A.; Mastruzzi, M. (2010). The Worldwide Governance Indicators: methodology and analytical issues. *World Bank Policy Research Working Paper* 5430.
- Moraes, R. K.; Wanke, P. F. (2019). Impacto do BNDES na eficiência da indústria siderúrgica: aplicação do modelo Malmquist de dois estágios. *Cadernos EBAPE.BR*, 17(2), 229–246.
- O'Donnell, C. J.; Rao, D. S. P.; Battese, G. E. (2008). Metafrontier frameworks for the study of firm-level efficiencies and technology ratios. *Empirical Economics*, 34, 231–255.
- Simar, L.; Wilson, P. W. (1998). Sensitivity analysis of efficiency scores: how to bootstrap in nonparametric frontier models. *Management Science*, 44(1), 49–61.
- Simar, L.; Wilson, P. W. (1999). Estimating and bootstrapping Malmquist indices. *European Journal of Operational Research*, 115(3), 459–471.
- Simar, L.; Wilson, P. W. (2002). Non-parametric tests of returns to scale. *European Journal of Operational Research*, 139(1), 115–132.
- Simar, L.; Wilson, P. W. (2007). Estimation and inference in two-stage, semi-parametric models of production processes. *Journal of Econometrics*, 136(1), 31–64.

## 5. Fontes dos números

Os números dos slides vêm destes documentos:
- `artigo/05_resultados_fase_a.md`: slides 4–10, 12–16 e 18;
- `artigo/06_resultados_painel.md`: slide 19;
- `artigo/14_padronizacao_minmax.md`: slide 17;
- `artigo/15_sfa_canais.md`: slides 8 e 11;
- `artigo/16_acrescimos_s06_s07_s08.md`: slides 14–16;
- `artigo/18_avaliacao_analise_critica.md`: seção 2 e slide 3.

Todos conferidos contra as tabelas de `output/tables/` da reexecução de 04/10/2026, entre elas:
- medida: `sensibilidade_zeros_m2`, `supereficiencia_cruzada_piso`;
- DEA, ranking e canais: `teste_rts`, `validacao_teste_rts`, `rts_por_pais_m2`, `dea_ano_m2`, `boot_ano_m2`, `ranking_paises_boot`, `ranking_contrastes_resumo`, `spearman_estimadores_m2`, `spearman_canais`, `metafronteira_resumo`, `testes_grupo_renda`;
- Malmquist: `malmquist_resumo`, `malmquist_decomposicao_variancia`, `malmquist_por_pais`, `malmquist_escores_crs`, `malmquist_beta_convergencia`;
- segundo estágio e dispersão: `segundo_estagio_truncada`, `segundo_estagio_wgi`, `correlacao_wgi`, `wgi_original_vs_cache`, `segundo_estagio_simar_wilson_m2`, `segundo_estagio_tobit`, `dispersao_renda_ano`, `dispersao_renda_tendencia`;
- SFA: `sfa_h2`, `sfa_retornos`, `sfa_canais_bootstrap`;
- painel e variantes: os mesmos nomes com sufixo `_painel` (e `_painel_qualidade`, `_painel_fonte`, `_painel_preqin`, `_painel_publico`), `comparacao_coeficiente_efetividade_amostra_comum`;
- padronização e fontes: `comparacao_padronizacao_resumo_minmax`, `metafronteira_resumo_minmax`, `ranking_paises_boot_minmax`, `sensibilidade_padronizacao_epsilon`, `checagem_patentes_spearman`.

As figuras estão em `output/figures/`.
