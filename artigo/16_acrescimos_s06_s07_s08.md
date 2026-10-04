# S06, S07 e S08 — Malmquist por país, níveis de evidência do segundo estágio e dispersão por renda

Executado em 04/10/2026 sobre o commit `ee19b58`, em resposta aos itens S06, S07 e S08 de `artigo/13_comentarios_apresentacao.md`, os "acréscimos leves" da ordem acordada (S10).

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

- **S07, dois níveis de evidência.** A efetividade governamental tem o sinal contrário ao previsto em todas as 23 especificações da truncada: 12 significativas a 5%, 7 entre 5% e 10% e 4 sem significância. O algoritmo 2 e o Tobit concordam.
  - As outras três dimensões do WGI e o índice composto dão o mesmo sinal negativo em todas as bases, quase sempre significativo.
  - As quatro dimensões têm correlação de 0,91 a 0,96 entre si: não é possível separar a "capacidade regulatória que trava" (a leitura do professor) da qualidade institucional em geral.
  - Exportações de alta tecnologia e pesquisadores têm o sinal previsto em todas as especificações, mas só raramente com significância.
- **S06.** A tabela por país separa quem só se move com a fronteira de quem se aproxima dela. China, Índia, Grécia e Argentina estão sempre na fronteira na Fase A; China, Coreia do Sul, Malásia e Rússia no painel.
  - O Brasil se aproxima da fronteira nas duas bases.
  - Os Estados Unidos também se aproximam, mas são o caso em que a fronteira mais recua.
  - A tese do platô se confirma em parte (seção 3).
- **S08.** Nenhuma tendência da dispersão é significativa a 5% (seção 4).
  - A heterogeneidade crescente da renda média-alta, sugerida pela figura da aula, aparece na Fase A (p = 0,10), mas não no painel, onde a dispersão tende a cair.
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
| Efetividade governamental (H5, +) | 23 | 0 | 0 | 0 | 12 / 7 / 4 |
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

**H5 com a efetividade trocada por outra dimensão** (truncada sobre log do escore, coeficiente e IC 95%):

| Base | Efetividade | Qualidade regulatória | Estado de direito | Controle da corrupção | Índice composto | Correlação entre dimensões |
|---|---|---|---|---|---|---|
| Fase A | −0,58 [−1,31; 0,02] | −0,56 [−1,28; 0,04] | −0,49 [−1,06; −0,04] | −0,48 [−0,96; −0,06] | −0,55 [−1,16; −0,04] | 0,91–0,96 |
| Painel | −0,69 [−1,20; −0,21] | −0,71 [−1,25; −0,27] | −0,51 [−1,02; −0,15] | −0,51 [−0,95; −0,20] | −0,63 [−1,17; −0,24] | 0,95–0,96 |
| Qualidade | −0,22 [−0,74; 0,29] | −0,26 [−0,74; 0,19] | −0,14 [−0,64; 0,19] | −0,16 [−0,59; 0,16] | −0,20 [−0,70; 0,21] | 0,95–0,96 |
| Inventor | −0,29 [−0,71; 0,01] | −0,34 [−0,62; −0,06] | −0,22 [−0,47; 0,02] | −0,32 [−0,59; −0,09] | −0,31 [−0,63; −0,06] | 0,95–0,96 |
| Preqin | −1,12 [−1,58; −0,13] | −1,05 [−1,65; −0,15] | −0,87 [−1,40; −0,15] | −0,82 [−1,41; −0,17] | −1,02 [−1,62; −0,16] | 0,95–0,96 |
| P&D público | −0,38 [−0,59; −0,12] | −0,32 [−0,56; −0,06] | −0,25 [−0,46; −0,01] | −0,26 [−0,44; −0,03] | −0,32 [−0,55; −0,07] | 0,94–0,96 |

**Leitura.** O sinal negativo não é próprio da efetividade governamental: aparece com qualquer dimensão do WGI, que nesta amostra medem quase a mesma coisa. Uma leitura coerente com o resto dos resultados:
- instituições melhores andam junto com renda mais alta e P&D maior (H7: o PIB per capita também tem sinal negativo);
- e os países ricos, com sistemas de P&D grandes, produzem menos publicações e patentes de IA por dólar investido, como já indicava a base do ranking (Israel, Suíça, Noruega).

O segundo estágio é exploratório (separabilidade não testada) e não permite dizer que a governança "atrapalha". Para separar a capacidade regulatória da qualidade institucional seria preciso um indicador menos colinear, por exemplo os índices de restrição regulatória da OCDE, que cobrem só parte dos países da amostra.

## 3. S06 — Malmquist por país: deslocamento da fronteira × catch-up

`malmquist_por_pais<sufixo>.csv` traz as médias geométricas por país e uma leitura com faixas de 5% em torno de 1:
- para a mudança técnica (TC): a fronteira avança, fica estável ou recua;
- para a mudança de eficiência (EC): catch-up, estável ou se afasta;
- "na fronteira" quando EC = 1 em todos os pares de anos.

A tabela da Fase A está em `artigo/05`, seção 7. O padrão de cada base:

| Base | Países | Na fronteira | Catch-up com fronteira recuando | Catch-up com fronteira estável ou avançando | Se afastando |
|---|---|---|---|---|---|
| Fase A (2016–2019) | 16 | 4 (China, Índia, Grécia, Argentina) | 5 | 2 | 3 |
| Painel (2017–2021) | 34 | 4 (China, Coreia do Sul, Malásia, Rússia) | 21 | 2 | 2 |
| Qualidade | 34 | 4 | 11 | 5 | 5 |
| Inventor | 38 | 4 | 2 | 8 | 12 |
| Preqin | 32 | 4 | 19 | 4 | 0 |
| P&D público | 32 | 3 | 3 | 3 | 16 |

Os países que não aparecem nas colunas ficam "estáveis".

**O que a decomposição diz, em palavras simples.** Durante o boom de investimento, a fronteira recua em produtos por dólar, e a maioria dos países melhora a posição relativa (catch-up) porque a fronteira desce em direção a eles, não porque eles sobem.
- A **China** está na fronteira em todos os anos das duas bases. Todo o movimento dela é o da própria fronteira, e é o maior recuo: TC = 0,65 na Fase A e 0,77 no painel. Seu investimento cresce mais depressa que os produtos de IA.
- Os **Estados Unidos** se aproximam da fronteira (EC 1,21 e 1,25) com a fronteira recuando muito (TC 0,68 e 0,75).
- O **Brasil** ganha por catch-up nas duas bases (EC 1,52 e 1,13). Na Fase A, com a fronteira estável (TC 0,96), como o professor antecipou; no painel, com ela recuando (0,80).

**Tese do platô.** Ela se confirma em parte:
- Quem está perto da fronteira e investe muito (China, Estados Unidos, Japão) é quem mais vê a fronteira recuar: gastar mais para deslocá-la rende menos produto por dólar. Isso é coerente com retornos decrescentes em escala grande (H1: Estados Unidos em DRS) e com os retornos decrescentes do canal de publicações no SFA (`artigo/15`).
- Já a ideia de que a renda média se aproxima mais da fronteira que a alta renda não aparece. Na Fase A, a mudança de eficiência média é 1,07 na renda média e 1,11 na alta renda (H4b não atendida), e no painel 0,98 e 1,11.

**Moraes e Wanke (2019).** Moraes, R. K.; Wanke, P. F. Impacto do BNDES na eficiência da indústria siderúrgica: aplicação do modelo Malmquist de dois estágios. *Cadernos EBAPE.BR*, 17(2), 229–246, 2019. DOI 10.1590/1679-395172140.
- **Achado (conferido no resumo e no texto, em 04/10/2026):** na siderurgia brasileira (2010–2015), o financiamento do BNDES tem coeficiente negativo sobre o catch-up e não é significativo para o deslocamento da fronteira; a hipótese de impacto positivo não é suportada.
- **Atenção à nomenclatura:** o artigo chama o catch-up de "Mudança Técnica" (EFFch) e o deslocamento da fronteira de "variação tecnológica" (TECHch). Neste projeto, "mudança técnica" (TC) é o deslocamento da fronteira. Ao citar, descrever os componentes, e não só repetir os nomes.
- O primeiro autor é o "Ricardo Calil" citado de memória na aula.

## 4. S08 — Dispersão da eficiência por grupo de renda e ano

`dispersao_renda_ano<sufixo>.csv` traz, por grupo de renda e ano, a dispersão do escore corrigido de viés e os países nos extremos:
- número de países, média, desvio-padrão, IQR e coeficiente de variação (CV);
- o país com o menor e o com o maior escore.

As fronteiras são anuais, então só a dispersão relativa (CV, IQR) se compara entre anos, e não o nível. `dispersao_renda_tendencia<sufixo>.csv` testa a tendência em cada grupo com pelo menos 4 anos de 3 ou mais países, de duas formas:
- a inclinação do CV e do IQR no ano (MQO);
- a comparação dos desvios em relação à mediana de cada ano entre a primeira e a segunda metade do período (Mann-Whitney).

| Base | Grupo | CV por ano | IQR por ano | Desvios: 1ª → 2ª metade |
|---|---|---|---|---|
| Fase A (2013–2021) | Alta renda | −0,007 (p = 0,48) | 0,000 (p = 0,95) | 0,13 → 0,17 (p = 0,41) |
| Fase A | Renda média-alta | +0,022 (p = 0,10) | +0,021 (p = 0,20) | 0,02 → 0,05 (p = 0,71) |
| Painel (2017–2021) | Alta renda | −0,048 (p = 0,09) | +0,038 (p = 0,06) | 0,18 → 0,19 (p = 0,55) |
| Painel | Renda média-alta | −0,099 (p = 0,08) | −0,058 (p = 0,10) | 0,14 → 0,12 (p = 0,91) |
| Inventor | Alta renda | −0,011 (p = 0,26) | +0,022 (p = 0,03) | 0,13 → 0,14 (p = 0,69) |
| Preqin | Renda média-alta | +0,049 (p = 0,26) | +0,036 (p = 0,33) | 0,06 → 0,18 (p = 0,08) |
| P&D público | Renda média-alta | −0,055 (p = 0,07) | −0,012 (p = 0,65) | 0,20 → 0,15 (p = 0,87) |

As linhas que faltam (alta renda na Preqin e no P&D público; renda média-alta no inventor) não têm nenhum teste com p < 0,10. A variante de qualidade só tem três anos e fica de fora.

**Quem abre a distribuição:**
- **Alta renda:** Israel é o mínimo em todos os anos da Fase A e em quatro dos cinco anos do painel. Os máximos variam: Estados Unidos, Espanha, Japão, Polônia, Grécia.
- **Renda média-alta:** os mínimos são o Brasil até 2015, a África do Sul de 2016 a 2019 e a Argentina em 2020–2021 na Fase A; no painel, a África do Sul em quatro dos cinco anos. Os máximos são Indonésia, México, Malásia e China.
- **Renda média-baixa:** tem só a Índia, exceto em 2018 na Fase A, quando entram as Filipinas (escore 0,35). A "abertura" de 2018 é composição, não crise.

**Leitura.** Com n pequeno e composição que muda a cada ano, a dispersão não mostra tendência firme. A heterogeneidade crescente da renda média-alta, sugerida pela figura da aula, aparece só na Fase A, onde a China se descola do grupo, e não se repete no painel. A discussão com evidência contemporânea (Indonésia, Malásia e Peru em ascensão, México ligado aos Estados Unidos, Ucrânia antes da guerra) fica para o dossiê do S09, com fontes datadas.

## 5. Pendências decorrentes

1. **Deck e relatório final:**
   - slide 11: tabela do Malmquist por país;
   - slide 12: níveis de evidência e fig4 nova;
   - slide 13: nota da fig5 revista com a seção 4.
   Roteiro a acrescentar ao `artigo/08`.
2. **S03:** com os níveis de evidência, H5 tem sinal contrário robusto na efetividade (e em todo o WGI), H6 é contrariada no crédito e H7 em patentes. Esses resultados entram na decisão de quais pontos ficam como hipóteses e quais viram perguntas de pesquisa.
3. **S09:** dossiê de evidência contemporânea para as discussões do S04 (H1 por país), do S05 (perfis do ranking), do S06 (platô) e do S08 (heterogeneidade da renda média-alta), além de ler na íntegra Moraes e Wanke (2019) antes de citar.
4. **Opcional:** indicador de restrição regulatória menos colinear com o WGI (por exemplo, índices de regulação de produtos da OCDE) para testar a leitura do professor.
