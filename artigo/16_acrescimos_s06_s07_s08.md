# S06, S07 e S08 — Malmquist por país, níveis de evidência do segundo estágio e dispersão por renda

Executado em 04/10/2026 sobre o commit `ee19b58`, em resposta aos itens S06, S07 e S08 de `artigo/13_comentarios_apresentacao.md`, os "acréscimos leves" da ordem acordada (S10).

**Revisão de 04/10/2026, após a análise crítica 3 (`artigo/17` → `artigo/18`).** As seções 1 a 4 foram refeitas com a reexecução que corrigiu os achados A01, A02, A06, A07, A10 e A15:
- Malmquist na convenção maior que 1 = melhora: a leitura anterior estava invertida.
- "Na fronteira em todos os anos" pelos escores CRS de todos os anos.
- Amostra do conjunto preservada na variante por inventor.
- Bloco WGI com uma só cópia dos dados.
- Dispersão com bootstrap de países e IQR relativo.

O texto anterior está no histórico do git.

**O que mudou no código:**
- `R/03`: níveis de evidência e dimensões alternativas do WGI.
- `R/04`: Malmquist por país, dispersão por grupo de renda e fig4 colorida pelo nível de evidência.
- Runner: novo modo `estagio2`, que refaz só o segundo estágio e as figuras sobre as fronteiras já gravadas.

**Execução:** `zsh output/rodar_pipeline.sh estagio2`, das 11h28 às 11h50, nas seis bases, sem falhas.

**Tabelas novas** (com o sufixo de cada base):
- `segundo_estagio_wgi` e `correlacao_wgi`;
- `malmquist_por_pais`;
- `dispersao_renda_ano` e `dispersao_renda_tendencia`.

As tabelas do segundo estágio ganharam as colunas `ic90_inf`, `ic90_sup`, `p_boot` (só na truncada), `significativo_10pct`, `sinal_previsto` e `nivel_evidencia`.

**Verificação.** Coeficientes, erros-padrão e intervalos de 95% são idênticos aos das tabelas versionadas. Só mudaram as linhas da parametrização em Farrell de modelos que não convergem (H6 de patentes no painel, na qualidade e no inventor; H7 de patentes no inventor). Essas linhas tinham sido gravadas antes da regra que pula o bootstrap de modelos sem convergência (a tabela antiga da qualidade mostra 219 réplicas de um modelo cujo ajuste pontual não convergiu) e agora estão coerentes com o código. Em boa parte por isso, a execução da variante de qualidade caiu de 31 minutos, em 28/09, para 7,5 minutos.

## 1. Resumo

- **S07, dois níveis de evidência.** A efetividade governamental tem o sinal contrário ao previsto em todas as 23 especificações da truncada: 13 significativas a 5%, 6 entre 5% e 10% e 4 sem significância. O algoritmo 2 e o Tobit concordam.
  - As outras três dimensões do WGI e o índice composto dão o mesmo sinal negativo em todas as bases, quase sempre significativo. Agora as cinco medidas vêm da mesma cópia do WGI (`artigo/18`, A07).
  - As quatro dimensões têm correlação de 0,93 a 0,96 entre si: não é possível separar a "capacidade regulatória que trava" (a leitura do professor) da qualidade institucional em geral.
  - Exportações de alta tecnologia e pesquisadores têm o sinal previsto em todas as especificações, mas só raramente com significância.
- **S06.** A tabela por país separa quem só se move com a fronteira de quem se aproxima dela ou se afasta. Na leitura corrigida (`artigo/18`, A01 e A02):
  - **Na fronteira em todos os anos:** China, Índia e Grécia na Fase A; China, Malásia e Coreia do Sul no painel.
  - **A fronteira avança**, puxada pela China, e a maioria dos países se afasta dela. O Brasil se afasta nas duas bases. Os Estados Unidos se afastam, embora a fronteira avance muito no seu ponto.
  - **A tese do platô não se confirma** no Malmquist (seção 3).
- **S08.** Nenhuma diferença de dispersão entre as metades do período é distinguível de zero (seção 4). A comparação usa bootstrap de países, porque os mesmos países estão nas duas metades.
  - A heterogeneidade crescente da renda média-alta, sugerida pela figura da aula, aparece como tendência descritiva na Fase A (CV), mas não no painel, onde a dispersão tende a cair.
  - A "abertura" de 2018 na renda média-baixa é a entrada das Filipinas.

## 2. S07 — Segundo estágio: níveis de evidência e o que mede a efetividade governamental

**Níveis.** Para cada coeficiente com sinal previsto em H5–H7 (`artigo/01`):
- **significativo (5%):** o IC 95% exclui zero;
- **bateu na trave (5–10%):** só o IC 90% exclui zero;
- **só o sinal:** o sinal previsto, sem significância;
- **sinal contrário:** dividido em significativo (5%), 5–10% e sem significância.

Quando a hipótese só exclui um sentido (crédito no canal de patentes em H6; PIB per capita em publicações em H7), o coeficiente é "compatível", a menos que vá para o sentido excluído com intervalo fora do zero. Coeficiente desprezível diante da largura do intervalo (menos de um milésimo dela) fica "sem sinal". Controles não têm previsão.

A classificação usa os intervalos percentílicos do bootstrap por país, os mesmos do resto do projeto, e o p-valor bootstrap (`p_boot`) é informado ao lado. No algoritmo 2, o IC 90% vem de uma segunda execução com a mesma semente e alpha = 0,10; o `rDEA` não devolve as réplicas, só o intervalo.

**Truncada sobre log(escore), seis bases:**

| Variável (hipótese, sinal previsto) | Especificações | Significativo (5%) | Bateu na trave | Só o sinal ou compatível | Sinal contrário (5% / 5–10% / sem sig.) |
|---|---|---|---|---|---|
| Efetividade governamental (H5, +) | 23 | 0 | 0 | 0 | 13 / 6 / 4 |
| Exportações de alta tecnologia (H5, +) | 23 | 3 | 2 | 18 | 0 |
| Pesquisadores por milhão (H5, +) | 6 | 2 | 0 | 4 | 0 |
| Talento em IA (H5, +; só painel) | 5 | 1 | 0 | 2 | 0 / 0 / 2 |
| Capitalização de mercado (H6, +) | 6 | 0 | 0 | 1 (≈ 0) | 0 / 0 / 5 |
| Crédito privado (H6, não positivo) | 6 | — | — | 2 | 3 / 1 / 0 |
| PIB per capita, patentes (H7, +) | 6 | 0 | 0 | 0 | 4 / 0 / 2 |
| PIB per capita, publicações (H7, não positivo) | 6 | — | — | 6 | 0 |

Algoritmo 2 de Simar-Wilson (Farrell, fronteira agrupada), efetividade governamental: sinal contrário significativo em quatro bases e entre 5% e 10% na Preqin (IC 95% [−12,2; 94,9], IC 90% [7,7; 93,6]). Na variante de qualidade, o algoritmo 2 não conclui em 300 s, como antes. Tobit: sinal contrário significativo em cinco bases; na de qualidade, p = 0,12.

**O que o indicador mede.** A efetividade governamental do WGI capta percepções sobre:
- a qualidade dos serviços públicos e da burocracia;
- o grau de independência de pressões políticas;
- a qualidade da formulação e da implementação de políticas;
- a credibilidade do compromisso do governo com elas (Kaufmann, Kraay e Mastruzzi, 2010).

As outras três dimensões usadas aqui medem:
- **qualidade regulatória:** capacidade de formular e aplicar regulações que favoreçam o setor privado;
- **estado de direito:** confiança nas regras, nos contratos, na polícia e nos tribunais;
- **controle da corrupção.**

**H5 com a efetividade trocada por outra dimensão** (truncada sobre log do escore, coeficiente e IC 95%). Desde 04/10/2026, as quatro dimensões, o índice e a efetividade de referência vêm todos da mesma cópia do WGI, o cache do World Bank (`artigo/18`, A07). Na Fase A, a efetividade e o controle da corrupção do dataset original diferem dessa cópia em todas as observações (até 0,53). Antes, o bloco misturava as duas cópias:

| Base | Efetividade (cópia do bloco) | Qualidade regulatória | Estado de direito | Controle da corrupção | Índice composto | Correlação entre dimensões |
|---|---|---|---|---|---|---|
| Fase A | −0,66 [−1,32; −0,04] | −0,56 [−1,28; 0,04] | −0,49 [−1,06; −0,04] | −0,49 [−0,99; −0,06] | −0,57 [−1,17; −0,06] | 0,93–0,96 |
| Painel | −0,69 [−1,20; −0,21] | −0,71 [−1,25; −0,27] | −0,51 [−1,02; −0,15] | −0,51 [−0,95; −0,20] | −0,63 [−1,17; −0,24] | 0,95–0,96 |
| Qualidade | −0,22 [−0,74; 0,29] | −0,26 [−0,74; 0,19] | −0,14 [−0,64; 0,19] | −0,16 [−0,59; 0,16] | −0,20 [−0,70; 0,21] | 0,95–0,96 |
| Inventor | −0,30 [−0,71; −0,002] | −0,35 [−0,63; −0,09] | −0,23 [−0,49; 0,02] | −0,33 [−0,61; −0,11] | −0,33 [−0,64; −0,08] | 0,95–0,96 |
| Preqin | −1,12 [−1,58; −0,13] | −1,05 [−1,65; −0,15] | −0,87 [−1,40; −0,15] | −0,82 [−1,41; −0,17] | −1,02 [−1,62; −0,16] | 0,95–0,96 |
| P&D público | −0,38 [−0,59; −0,12] | −0,32 [−0,56; −0,06] | −0,25 [−0,46; −0,01] | −0,26 [−0,44; −0,03] | −0,32 [−0,55; −0,07] | 0,94–0,96 |

Na Fase A, a efetividade da H5 principal (cópia original) é −0,58 [−1,31; 0,02], "bateu na trave". Na cópia do cache, na mesma amostra, é −0,66 [−1,32; −0,04], significativa a 5%. Parte da diferença que antes se atribuía à troca de dimensão vinha da troca de cópia. No painel, a efetividade do bloco coincide com a da H5 principal, porque as cópias são iguais. Na variante por inventor, os números mudaram um pouco porque as regressões do conjunto recuperaram duas observações (`artigo/18`, A06).

**Leitura.** O sinal negativo não é próprio da efetividade governamental: aparece com qualquer dimensão do WGI, que nesta amostra medem quase a mesma coisa. Uma leitura coerente com o resto dos resultados:
- instituições melhores andam junto com renda mais alta e P&D maior (H7: o PIB per capita também tem sinal negativo);
- e os países ricos, com sistemas de P&D grandes, produzem menos publicações e patentes de IA por dólar investido, como já indicava a base do ranking (Israel, Suíça, Noruega).

O segundo estágio é exploratório (separabilidade não testada) e não permite dizer que a governança "atrapalha". Para separar a capacidade regulatória da qualidade institucional seria preciso um indicador menos colinear, por exemplo os índices de restrição regulatória da OCDE, que cobrem só parte dos países da amostra.

## 3. S06 — Malmquist por país: deslocamento da fronteira × catch-up

**Convenção (revista em 04/10/2026, `artigo/18`, A01).** Índice maior que 1 = melhora: TC > 1, a fronteira avança; EC > 1, o país se aproxima dela. Na orientação a produto, o `Benchmarking` devolve os recíprocos, e a versão anterior desta seção lia tudo no sentido inverso: o que estava escrito como "catch-up com a fronteira recuando" era afastamento com a fronteira avançando.

`malmquist_por_pais<sufixo>.csv` traz as médias geométricas por país, os escores CRS inicial, final e mínimo, e uma leitura com faixas de 5% em torno de 1:
- para a mudança técnica (TC): a fronteira avança, fica estável ou recua;
- para a mudança de eficiência (EC): catch-up, estável ou se afasta;
- "na fronteira em todos os anos" quando o escore CRS contemporâneo é 1 em todos os anos da janela (`malmquist_escores_crs<sufixo>.csv`). A versão anterior usava a média geométrica do EC igual a 1, que inclui países com anos fora da fronteira (Argentina na Fase A; Rússia no painel, no inventor e no P&D público; Japão e Malásia no inventor; Turquia na Preqin) e não distingue eficiência constante de presença na fronteira (`artigo/18`, A02).

A tabela da Fase A está em `artigo/05`, seção 7. O padrão de cada base:

| Base | Países | Na fronteira em todos os anos | Catch-up | Estáveis | Se afastam | TC médio | EC médio |
|---|---|---|---|---|---|---|---|
| Fase A (2016–2019) | 16 | 3 (China, Índia, Grécia) | 3 | 3 | 7 | 1,10 | 0,91 |
| Painel (2017–2021) | 34 | 3 (China, Malásia, Coreia do Sul) | 2 | 7 | 22 | 1,17 | 0,93 |
| Qualidade | 34 | 4 (China, Coreia do Sul, Singapura, Grécia) | 5 | 9 | 16 | 1,14 | 0,91 |
| Inventor | 38 | 1 (Índia) | 14 | 13 | 10 | 1,03 | 1,02 |
| Preqin | 32 | 3 (China, Coreia do Sul, Rússia) | 0 | 6 | 23 | 1,16 | 0,91 |
| P&D público | 32 | 2 (China, Coreia do Sul) | 16 | 8 | 6 | 1,05 | 1,04 |

**O que a decomposição diz, em palavras simples.** A fronteira avança em todas as bases, puxada pelos países que estão nela, e a maioria dos outros fica para trás. As exceções são as variantes de patentes por inventor e de P&D público: nelas a fronteira avança pouco (TC 1,03 e 1,05) e os países, em média, se aproximam dela (EC 1,02 e 1,04).
- A **China** está na fronteira em todos os anos em cinco das seis bases. Na de inventor, as famílias IP5 reduzem muito suas patentes. O movimento dela é o da própria fronteira, e é o maior avanço da Fase A (1,54 ao ano; 1,30 no painel). Seu produto de IA cresce mais depressa que os insumos.
- Os **Estados Unidos** se afastam da fronteira (EC 0,82 na Fase A e 0,80 no painel), embora ela avance muito no seu ponto (TC 1,47 e 1,34): a produtividade americana cresce, mas menos que a dos líderes.
- O **Brasil** se afasta da fronteira nas duas bases (EC 0,66 e 0,88). Na Fase A, com a fronteira estável no seu ponto (TC 1,05), a produtividade cai (0,69). No painel, a fronteira avança (1,25) e a produtividade sobe um pouco (1,11). É o contrário da leitura anterior e da expectativa levantada na aula.

**Tese do platô.** Não se confirma no Malmquist:
- **Quem está perto da fronteira e investe muito** (China, Estados Unidos, Japão) é justamente onde a fronteira mais avança. Não há sinal de que gastar mais para deslocá-la renda cada vez menos. Os retornos decrescentes da H1 são uma propriedade de escala num ano, e não da dinâmica.
- **Renda média e alta renda.** Em todas as seis bases, a renda média se sai melhor que a alta renda no ponto: se afasta menos ou se aproxima mais (EC 0,93 contra 0,90 na Fase A; 1,02 contra 0,90 no painel). É o que o professor chamou de "economicamente não estranho". Mas o critério de catch-up da renda média (EC acima de 1 com intervalo excluindo 1) não é atendido em nenhuma base, a diferença entre os grupos não foi testada, e na Preqin a renda média se afasta da fronteira (0,964 [0,924; 0,999]).

**Moraes e Wanke (2019).** Moraes, R. K.; Wanke, P. F. Impacto do BNDES na eficiência da indústria siderúrgica: aplicação do modelo Malmquist de dois estágios. *Cadernos EBAPE.BR*, 17(2), 229–246, 2019. DOI 10.1590/1679-395172140.
- **Achado (conferido no resumo e no texto, em 04/10/2026):** na siderurgia brasileira (2010–2015), o financiamento do BNDES tem coeficiente negativo sobre o catch-up e não é significativo para o deslocamento da fronteira; a hipótese de impacto positivo não é suportada.
- **Atenção à nomenclatura:** o artigo chama o catch-up de "Mudança Técnica" (EFFch) e o deslocamento da fronteira de "variação tecnológica" (TECHch). Neste projeto, "mudança técnica" (TC) é o deslocamento da fronteira. Ao citar, descrever os componentes, e não só repetir os nomes.
- O primeiro autor é o "Ricardo Calil" citado de memória na aula.

## 4. S08 — Dispersão da eficiência por grupo de renda e ano

`dispersao_renda_ano<sufixo>.csv` traz, por grupo de renda e ano, a dispersão do escore corrigido de viés e os países nos extremos:
- número de países, média, mediana, desvio-padrão, IQR, IQR relativo (IQR/mediana) e coeficiente de variação (CV);
- o país com o menor e o com o maior escore.

**O que cada medida diz (revisto em 04/10/2026, `artigo/18`, A15).**
- **Absoluta e relativas.** O IQR é dispersão **absoluta**: multiplicar todos os escores por uma constante multiplica o IQR. O CV e o IQR relativo são relativos ao centro da distribuição.
- **Comparação entre anos.** Como as fronteiras são anuais e uma fronteira nova pode mudar os escores de forma não proporcional, nem as medidas relativas são automaticamente comparáveis entre anos. As tabelas descrevem a dispersão observada em cada referência anual.

`dispersao_renda_tendencia<sufixo>.csv` olha cada grupo com pelo menos 4 anos de 3 ou mais países, de duas formas:
- **Inclinação do CV, do IQR e do IQR relativo no ano.** É só descrição de tendência (MQO com um ponto por ano); sem significância, isso não prova estabilidade.
- **Teste (revisto em 04/10/2026, `artigo/18`, A10).** Diferença do desvio absoluto mediano, em relação à mediana de cada ano, entre a segunda e a primeira metade do período.
  - **Incerteza:** como os mesmos países aparecem nas duas metades, o IC e o p-valor vêm de bootstrap de países (2.000 réplicas, todos os anos de cada país juntos, medianas e desvios recalculados em cada réplica).
  - **Sensibilidade:** Wilcoxon pareado sobre o desvio médio de cada país nas duas metades.
  - **Antes:** o Mann-Whitney anterior tratava os país-ano como independentes.

| Base | Grupo | Países (nas duas metades) | CV por ano | Desvio mediano: 1ª → 2ª metade | Diferença [IC 95%], p bootstrap | Wilcoxon pareado |
|---|---|---|---|---|---|---|
| Fase A (2013–2021) | Alta renda | 24 (19) | −0,007 | 0,129 → 0,169 | +0,040 [−0,074; 0,111], p = 0,56 | p = 0,86 |
| Fase A | Renda média-alta | 10 (7) | +0,022 | 0,021 → 0,054 | +0,033 [−0,088; 0,170], p = 0,53 | p = 0,67 |
| Painel (2017–2021) | Alta renda | 35 (33) | −0,048 | 0,183 → 0,191 | +0,008 [−0,055; 0,090], p = 0,63 | p = 0,99 |
| Painel | Renda média-alta | 11 (9) | −0,099 | 0,140 → 0,123 | −0,017 [−0,162; 0,122], p = 0,98 | p = 0,34 |
| Inventor | Alta renda | 35 (34) | −0,011 | 0,130 → 0,140 | +0,010 [−0,065; 0,084], p = 0,87 | p = 0,58 |
| Inventor | Renda média-alta | 10 (9) | −0,043 | 0,158 → 0,192 | +0,034 [−0,160; 0,137], p = 1,00 | p = 0,91 |
| Preqin | Alta renda | 35 (31) | −0,027 | 0,212 → 0,210 | −0,001 [−0,101; 0,078], p = 0,91 | p = 0,90 |
| Preqin | Renda média-alta | 10 (9) | +0,049 | 0,064 → 0,178 | +0,114 [−0,049; 0,188], p = 0,30 | p = 0,48 |
| P&D público | Alta renda | 34 (32) | −0,012 | 0,153 → 0,165 | +0,013 [−0,067; 0,048], p = 0,91 | p = 0,09 |
| P&D público | Renda média-alta | 7 (6) | −0,055 | 0,201 → 0,153 | −0,048 [−0,170; 0,133], p = 0,81 | p = 0,53 |

Nenhuma diferença entre as metades é distinguível de zero. A variante de qualidade só tem três anos e fica de fora.

**Quem abre a distribuição:**
- **Alta renda:** Israel é o mínimo em todos os anos da Fase A e em quatro dos cinco anos do painel. Os máximos variam: Estados Unidos, Espanha, Japão, Polônia, Grécia.
- **Renda média-alta:** os mínimos são o Brasil até 2015, a África do Sul de 2016 a 2019 e a Argentina em 2020–2021 na Fase A; no painel, a África do Sul em quatro dos cinco anos. Os máximos são Indonésia, México, Malásia e China.
- **Renda média-baixa:** tem só a Índia, exceto em 2018 na Fase A, quando entram as Filipinas (escore 0,35). A "abertura" de 2018 é composição, não crise.

**Leitura.** Com n pequeno e composição que muda a cada ano, a dispersão não mostra mudança distinguível entre as metades do período. A heterogeneidade crescente da renda média-alta, sugerida pela figura da aula, aparece só como tendência descritiva do CV na Fase A, onde a China se descola do grupo, e não se repete no painel. A discussão com evidência contemporânea (Indonésia, Malásia e Peru em ascensão, México ligado aos Estados Unidos, Ucrânia antes da guerra) fica para o dossiê do S09, com fontes datadas.

## 5. Pendências decorrentes

1. **Deck e relatório final:**
   - slide 11: tabela do Malmquist por país, na convenção corrigida;
   - slide 12: níveis de evidência e a fig4 vigente (a do deck apresentado era a da versão anterior);
   - slide 13: nota da fig5 revista com a seção 4.
   Errata e roteiro no `artigo/08`, seção 2a.
2. **S03:** com os níveis de evidência, H5 tem sinal contrário robusto na efetividade (e em todo o WGI), H6 é contrariada no crédito e H7 em patentes. Esses resultados entram na decisão de quais pontos ficam como hipóteses e quais viram perguntas de pesquisa.
3. **S09:** dossiê de evidência contemporânea para as discussões do S04 (H1 por país), do S05 (perfis do ranking), do S06 (platô) e do S08 (heterogeneidade da renda média-alta), além de ler na íntegra Moraes e Wanke (2019) antes de citar.
4. **Opcional:** indicador de restrição regulatória menos colinear com o WGI (por exemplo, índices de regulação de produtos da OCDE) para testar a leitura do professor.
