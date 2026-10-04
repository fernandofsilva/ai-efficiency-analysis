# 03_segundo_estagio_dataset_atual.R
# Fase A: segundo estágio sobre os escores do modelo M2 (dataset original).
# Testes preliminares de H5 (instituições e capacidade de absorção),
# H6 (finanças de mercado vs bancárias no canal de patentes) e
# H7 (assimetria por nível de desenvolvimento entre canais).
# Métodos: regressão normal truncada sobre log(escore) com bootstrap
# agrupado por país (especificação principal, exploratória e própria: não
# equivale ao modelo de Simar e Wilson, 2007, em outra escala; ver
# AjustarTruncada; parametrizações em escore (0,1] e em Farrell como
# comparação, todas com verificação de convergência),
# Simar-Wilson algoritmo 2 (rDEA::dea.env.robust), Tobit comparativo
# (AER::tobit), Kruskal-Wallis e Mann-Whitney por grupo de renda.
# Níveis de evidência (S07, comentários da apresentação de 28/09/2026):
# cada coeficiente com sinal previsto é classificado em significativo a 5%,
# "bateu na trave" (só o IC 90% exclui zero), só o sinal, ou sinal
# contrário; a efetividade governamental é trocada, uma de cada vez, pelas
# outras dimensões do WGI e por um índice composto, todas da mesma cópia do
# WGI (cache do World Bank).
# Amostras: as regressões do modelo conjunto usam todas as observações do
# conjunto; as dos canais, só as observações em que o canal é definido
# (produto positivo). Uma exclusão do canal de patentes não tira a
# observação das regressões do conjunto (A06 de artigo/17).
# Variáveis de ambiente: as do script 02 (BASE_ARQUIVO, SUFIXO_SAIDA,
# INSUMOS, PRODUTOS, PADRONIZACAO, EPSILON_PADRONIZACAO); as fronteiras dos
# canais e do algoritmo 2 usam a mesma padronização do script 02.
# Uso: Rscript R/03_segundo_estagio_dataset_atual.R (após o script 02)

source("R/00_setup.R")

n_boot_cluster <- 300   # réplicas do bootstrap agrupado por país
l1_sw <- 50             # réplicas internas do algoritmo 2 (Fase A)
l2_sw <- 500            # réplicas externas do algoritmo 2 (Fase A)
n_rep_canais <- 500     # bootstrap DEA dos canais

arquivo_base <- Sys.getenv("BASE_ARQUIVO", "data/processed/base_atual.csv")
padronizacao <- ConfigurarPadronizacao()
sufixo <- paste0(Sys.getenv("SUFIXO_SAIDA", ""), padronizacao$sufixo)
insumos <- strsplit(Sys.getenv("INSUMOS", "investimento,gerd"), ",")[[1]]
produtos <- strsplit(Sys.getenv("PRODUTOS", "publicacoes,patentes"), ",")[[1]]
Salvar <- function(dados, nome) {
  return(SalvarTabela(dados, paste0(nome, sufixo)))
}
LerSaida <- function(nome) {
  return(utils::read.csv(file.path("output/tables",
                                   paste0(nome, sufixo, ".csv")),
                         stringsAsFactors = FALSE))
}

SinalPrevisto <- function(modelo, termo) {
  # Sinal previsto por H5-H7 (artigo/01) na escala do escore (positivo =
  # mais eficiente): "+", ou "nao+" quando a hipótese só exclui o efeito
  # positivo (crédito no canal de patentes, H6; PIB per capita no canal de
  # publicações, H7); NA para controles e contrastes.
  Um <- function(m, t) {
    institucionais <- c("efetividade_governo", "alta_tec_export",
                        "log_pesquisadores", "log_talento",
                        "qualidade_regulatoria", "estado_direito",
                        "controle_corrupcao", "indice_wgi")
    if (grepl("^H5", m) && t %in% institucionais) return("+")
    if (grepl("^H6 truncada", m) && t == "market_cap") return("+")
    if (grepl("^H6 truncada", m) && t == "credito_privado") return("nao+")
    if (grepl("^H7 canal patentes", m) && t == "log_pib_pc") return("+")
    if (grepl("^H7 canal publica", m) && t == "log_pib_pc") return("nao+")
    return(NA_character_)
  }
  return(as.character(mapply(Um, modelo, termo, USE.NAMES = FALSE)))
}

InverterSinal <- function(previsto) {
  # Para as escalas de Farrell (positivo = MENOS eficiente).
  return(unname(c("+" = "-", "-" = "+", "nao+" = "nao-",
                  "nao-" = "nao+")[previsto]))
}

NivelEvidencia <- function(coeficiente, sig5, sig10, previsto,
                           largura = rep(NA_real_, length(coeficiente))) {
  # Com sinal previsto: "significativo (5%)" quando o IC 95% exclui zero;
  # "bateu na trave (5-10%)" quando só o IC 90% exclui; "só o sinal" quando
  # nenhum exclui; no sentido oposto, "sinal contrário", "sinal contrário,
  # 5-10%" ou "sinal contrário, significativo (5%)". Quando a hipótese só
  # exclui um sentido ("nao+", "nao-"): "compatível", salvo coeficiente no
  # sentido excluído com IC fora do zero. Coeficiente desprezível diante da
  # largura do IC 95% (menos de um milésimo dela) não tem sinal. NA para
  # controles.
  Um <- function(b, s5, s10, p, l) {
    if (is.na(p) || is.na(b)) return(NA_character_)
    if (!is.na(l) && abs(b) < 1e-3 * l) return("sem sinal (coeficiente ≈ 0)")
    s5 <- isTRUE(s5)
    s10 <- isTRUE(s10)
    if (p %in% c("nao+", "nao-")) {
      contra <- (p == "nao+" && b > 0) || (p == "nao-" && b < 0)
      if (contra && s5) return("sinal contrário, significativo (5%)")
      if (contra && s10) return("sinal contrário, 5-10%")
      return("compatível")
    }
    if ((p == "+" && b > 0) || (p == "-" && b < 0)) {
      if (s5) return("significativo (5%)")
      if (s10) return("bateu na trave (5-10%)")
      return("só o sinal")
    }
    if (s5) return("sinal contrário, significativo (5%)")
    if (s10) return("sinal contrário, 5-10%")
    return("sinal contrário")
  }
  return(as.character(mapply(Um, coeficiente, sig5, sig10, previsto,
                             largura, USE.NAMES = FALSE)))
}

ClassificarTabela <- function(t) {
  # Acrescenta sinal previsto e nível de evidência a uma tabela de
  # truncadas; na parametrização em Farrell o sinal previsto se inverte.
  previsto <- SinalPrevisto(t$modelo, t$termo)
  farrell <- t$dependente == "farrell"
  previsto[farrell] <- InverterSinal(previsto[farrell])
  t$sinal_previsto <- previsto
  t$nivel_evidencia <- NivelEvidencia(t$coeficiente, t$significativo_5pct,
                                      t$significativo_10pct, previsto,
                                      t$ic_sup - t$ic_inf)
  return(t)
}

base <- utils::read.csv(arquivo_base, stringsAsFactors = FALSE)
# Mesmos parâmetros de padronização do script 02 (mesma amostra de
# referência: observações completas nas colunas da fronteira).
parametros_pad <- ParametrosPadronizacao(
  base[stats::complete.cases(base[, c(insumos, produtos)]), ],
  c(insumos, produtos), padronizacao)
boot_m2 <- LerSaida("boot_ano_m2")
dea_m2 <- LerSaida("dea_ano_m2")
# Pesquisadores por milhão: o painel reconstruído já traz a coluna; o
# dataset original precisa da junção com o cache do World Bank.
if (!"pesquisadores_pm" %in% names(base)) {
  pesquisadores <- LerWorldBank("SP.POP.SCIE.RD.P6", "pesquisadores_pm")
  base <- dplyr::left_join(base, pesquisadores, by = c("iso3c", "ano"))
}

dados <- base |>
  dplyr::inner_join(dplyr::select(boot_m2, id, escore_bc, farrell_bc),
                    by = "id") |>
  dplyr::inner_join(dplyr::select(dea_m2, id, escore_vrs, f_vrs), by = "id") |>
  dplyr::mutate(ano_f = factor(ano),
                grupo_renda2 = ifelse(grupo_renda == "Alta renda",
                                      "Alta renda", "Renda média"),
                log_pesquisadores = log(pesquisadores_pm),
                log_escore_bc = log(escore_bc))
Registrar("obs. no segundo estágio:", nrow(dados),
          "| com pesquisadores:", sum(!is.na(dados$pesquisadores_pm)))

# Bootstrap dos canais (escores corrigidos > 1 para a regressão truncada) ---
BootCanal <- function(coluna_y) {
  # DMUs com produto zero no canal saem (Farrell orientado a produto
  # indefinido; o bootstrap do Benchmarking falha nesses casos).
  anos <- sort(unique(dados$ano))
  saida <- lapply(anos, function(a) {
    d <- dados[dados$ano == a & dados[[coluna_y]] > 0, ]
    boot <- BootstrapDea(MatrizFronteira(d, insumos, parametros_pad, 1e6),
                         MatrizFronteira(d, coluna_y, parametros_pad), d$id,
                         "vrs", n_rep = n_rep_canais)
    return(boot[, c("id", "farrell_bc", "escore_bc")])
  })
  return(do.call(rbind, saida))
}
Registrar("bootstrap dos canais...")
boot_pub <- BootCanal(produtos[1])
names(boot_pub)[2:3] <- c("farrell_bc_pub", "escore_bc_pub")
boot_pat <- BootCanal(produtos[2])
names(boot_pat)[2:3] <- c("farrell_bc_pat", "escore_bc_pat")
# left_join: o escore do canal fica ausente onde o canal não é definido
# (produto zero), e a observação continua no conjunto. Cada regressão
# seleciona os casos completos só das variáveis que usa (TruncadaAgrupada).
dados <- dados |>
  dplyr::left_join(boot_pub, by = "id") |>
  dplyr::left_join(boot_pat, by = "id") |>
  dplyr::mutate(log_escore_bc_pub = log(escore_bc_pub),
                log_escore_bc_pat = log(escore_bc_pat))
Registrar("obs. com escore de publicações:", sum(!is.na(dados$escore_bc_pub)),
          "| de patentes:", sum(!is.na(dados$escore_bc_pat)), "| conjunto:",
          nrow(dados))
Salvar(dados[, c("id", "pais", "ano", "grupo_renda", "escore_bc",
                       "escore_bc_pub", "escore_bc_pat")],
             "escores_bc_conjunto_e_canais")

# Regressão truncada com bootstrap agrupado por país --------------------------
# AjustarTruncada (R/funcoes.R) ajusta a truncada em três parametrizações
# e devolve convergiu = FALSE quando o otimizador não converge. A principal
# é "log_escore" (log do escore corrigido, truncada à direita em 0); as
# outras duas ("escore_1lim", "farrell") entram só como comparação.
TruncadaAgrupada <- function(formula, d, rotulo, n_boot = n_boot_cluster,
                             dependente = "log_escore") {
  # Estimativas pontuais e IC percentílico por reamostragem de países com
  # os escores mantidos fixos (não propaga a incerteza da fronteira; o
  # algoritmo 2 de Simar-Wilson, abaixo, faz isso na fronteira agrupada).
  # A amostra é formada pelos casos completos da fórmula ANTES do ajuste e
  # da reamostragem, e n_obs/n_paises referem-se a esse quadro efetivo.
  # Réplicas cujo ajuste não converge são descartadas e contadas
  # (replicas_tentadas x replicas_convergentes); se o ajuste pontual não
  # converge, o modelo é marcado como não estimado (coeficientes NA).
  variaveis <- all.vars(formula)
  d <- d[stats::complete.cases(d[, variaveis]), ]
  ajuste <- AjustarTruncada(formula, d, dependente)
  coefs <- ajuste$coeficientes
  paises <- unique(d$pais)
  set.seed(semente)
  # Sem ajuste pontual convergente não há o que reamostrar: o modelo é
  # marcado como não estimado e as réplicas são puladas (cada réplica de
  # um modelo degenerado tentaria três otimizadores até o limite).
  n_boot_efetivo <- if (ajuste$convergiu) n_boot else 0
  replicas <- replicate(n_boot_efetivo, {
    escolhidos <- sample(paises, replace = TRUE)
    d_boot <- do.call(rbind, lapply(escolhidos, function(p) d[d$pais == p, ]))
    r <- tryCatch(AjustarTruncada(formula, d_boot, dependente),
                  error = function(e) NULL)
    if (is.null(r) || !r$convergiu) {
      rep(NA_real_, length(coefs))
    } else {
      r$coeficientes[names(coefs)]
    }
  })
  replicas <- matrix(replicas, nrow = length(coefs),
                     ncol = n_boot_efetivo)
  validas <- colSums(is.na(replicas)) == 0
  replicas <- replicas[, validas, drop = FALSE]
  Quantil <- function(prob) {
    if (ncol(replicas) < 20) return(rep(NA_real_, length(coefs)))
    return(apply(replicas, 1, stats::quantile, probs = prob))
  }
  PValor <- function() {
    # p-valor bootstrap bicaudal pelo método percentílico: duas vezes a
    # menor fração de réplicas de um lado do zero (resolução 1/réplicas).
    if (ncol(replicas) < 20) return(rep(NA_real_, length(coefs)))
    return(pmin(1, 2 * pmin(rowMeans(replicas <= 0),
                            rowMeans(replicas >= 0))))
  }
  saida <- data.frame(
    modelo = rotulo, dependente = dependente, termo = names(coefs),
    coeficiente = if (ajuste$convergiu) as.numeric(coefs) else NA_real_,
    ep_boot = if (ncol(replicas) >= 20) apply(replicas, 1, stats::sd) else NA,
    ic_inf = Quantil(0.025), ic_sup = Quantil(0.975),
    ic90_inf = Quantil(0.05), ic90_sup = Quantil(0.95), p_boot = PValor(),
    n_obs = nrow(d), n_paises = length(paises),
    convergiu_pontual = ajuste$convergiu,
    mensagem_ajuste = ajuste$mensagem,
    loglik = ajuste$loglik, grad_max = ajuste$grad_max,
    replicas_tentadas = n_boot, replicas_convergentes = sum(validas),
    replicas_validas = sum(validas),
    inferencia = "truncada, escores fixos, bootstrap por país",
    stringsAsFactors = FALSE)
  saida$significativo_5pct <- ajuste$convergiu & !is.na(saida$ic_inf) &
    (saida$ic_inf > 0 | saida$ic_sup < 0)
  saida$significativo_10pct <- ajuste$convergiu & !is.na(saida$ic90_inf) &
    (saida$ic90_inf > 0 | saida$ic90_sup < 0)
  if (!ajuste$convergiu) {
    Registrar("modelo não estimado:", rotulo, "(", dependente, ")",
              ajuste$mensagem)
  } else if (sum(validas) < 0.9 * n_boot) {
    Registrar("atenção:", rotulo, "(", dependente, ") réplicas convergentes",
              sum(validas), "de", n_boot)
  }
  return(saida)
}

TruncadaParametrizacoes <- function(formula_log, d, rotulo,
                                    parametrizacoes = c("log_escore",
                                                        "escore_1lim",
                                                        "farrell")) {
  # Roda a especificação principal (log_escore) e as comparações, trocando
  # a dependente da fórmula (log_escore_* -> escore_* -> farrell_*).
  dep <- all.vars(formula_log)[1]
  lado_direito <- as.character(formula_log)[3]
  Formula <- function(nome_dep) {
    return(stats::as.formula(paste(nome_dep, "~", lado_direito)))
  }
  dependentes <- c(log_escore = dep,
                   escore_1lim = sub("^log_escore", "escore", dep),
                   farrell = sub("^log_escore", "farrell", dep))
  saida <- lapply(parametrizacoes, function(par) {
    TruncadaAgrupada(Formula(dependentes[[par]]), d, rotulo, dependente = par)
  })
  return(do.call(rbind, saida))
}

# H5: instituições e capacidade de absorção (modelo conjunto M2) --------------
# Nota: a variável dependente principal é o log da eficiência corrigida
# (em (-Inf, 0), normal truncada em 0): um coeficiente positivo indica MAIOR
# eficiência. O coeficiente se refere à média latente, antes da truncagem:
# leitura de sinal, não de efeito percentual sobre o escore observado.
formula_h5 <- log_escore_bc ~ efetividade_governo + alta_tec_export +
  log_comercio + market_cap + credito_privado + ano_f
h5 <- TruncadaParametrizacoes(formula_h5, dados, "H5 truncada (M2)")
formula_h5b <- log_escore_bc ~ efetividade_governo + alta_tec_export +
  log_comercio + log_pesquisadores + ano_f
dados_pesq <- dados[!is.na(dados$log_pesquisadores), ]
h5b <- TruncadaAgrupada(formula_h5b, dados_pesq,
                        "H5 truncada com pesquisadores (subamostra)")

# H5 com concentração de talento em IA (AI Index), quando disponível
h5c <- NULL
if ("talento_ia_media_genero_pct" %in% names(dados)) {
  dados_tal <- dados[!is.na(dados$talento_ia_media_genero_pct) &
                       dados$talento_ia_media_genero_pct > 0, ]
  dados_tal$log_talento <- log(dados_tal$talento_ia_media_genero_pct)
  formula_h5c <- log_escore_bc ~ efetividade_governo + alta_tec_export +
    log_comercio + log_talento + ano_f
  h5c <- TruncadaAgrupada(formula_h5c, dados_tal,
                          paste("H5 truncada com talento em IA (média por",
                                "gênero, subamostra)"))
}

# H5 com outras dimensões do WGI (S07) ----------------------------------------
# O WGI de efetividade governamental mede a percepção da qualidade dos
# serviços públicos e da burocracia, de sua independência de pressões
# políticas, da formulação e implementação de políticas e da credibilidade
# do compromisso do governo com elas (Kaufmann, Kraay e Mastruzzi, 2010).
# Para ver se o sinal negativo vem da capacidade regulatória (leitura do
# professor na apresentação) ou da qualidade institucional em geral, a
# efetividade é trocada, uma de cada vez, por qualidade regulatória, estado
# de direito, controle da corrupção e um índice composto (média simples das
# quatro estimativas, que já estão na mesma escala).
# Uma só cópia dos dados (A07 de artigo/17): as quatro dimensões, o índice
# e a própria efetividade de referência deste bloco vêm todos do cache do
# World Bank (data/wgi/, API v2, fonte 3), na mesma amostra. Na Fase A, a
# efetividade e o controle da corrupção do dataset original divergem do
# cache em todas as observações (até 0,53 na efetividade; não é defasagem
# de um ano), de modo que misturar as duas cópias confundiria troca de
# dimensão com troca de fonte. A H5 principal continua com a cópia de cada
# base (na Fase A, a do dataset original, para manter a replicação), e a
# tabela wgi_original_vs_cache mostra a diferença entre as cópias. No
# painel reconstruído as quatro dimensões já vêm do mesmo cache.
dimensoes_wgi <- c("efetividade_governo", "qualidade_regulatoria",
                   "estado_direito", "controle_corrupcao")
codigos_wgi <- c(efetividade_governo = "GOV_WGI_GE.EST",
                 qualidade_regulatoria = "GOV_WGI_RQ.EST",
                 estado_direito = "GOV_WGI_RL.EST",
                 controle_corrupcao = "GOV_WGI_CC.EST")
dados_wgi <- dados[, setdiff(names(dados), dimensoes_wgi)]
for (v in dimensoes_wgi) {
  dados_wgi <- dplyr::left_join(
    dados_wgi, LerWorldBank(codigos_wgi[[v]], v, pasta = "data/wgi"),
    by = c("iso3c", "ano"))
}
dados_wgi$indice_wgi <- rowMeans(dados_wgi[, dimensoes_wgi])
fonte_wgi <- "cache World Bank (data/wgi), as quatro dimensões da mesma cópia"
# Diferença entre a cópia da base e a do cache, por dimensão presente nas
# duas (pela mesma chave país-ano).
wgi_copias <- do.call(rbind, lapply(intersect(dimensoes_wgi, names(dados)),
                                    function(v) {
  original <- dados[[v]]
  cache <- dados_wgi[[v]][match(dados$id, dados_wgi$id)]
  ok <- stats::complete.cases(original, cache)
  dif <- abs(original[ok] - cache[ok])
  return(data.frame(dimensao = v, observacoes = sum(ok),
                    diferentes = sum(dif > 1e-6), max_dif_absoluta = max(dif),
                    mediana_dif_absoluta = stats::median(dif),
                    correlacao = stats::cor(original[ok], cache[ok])))
}))
Salvar(wgi_copias, "wgi_original_vs_cache")
print(wgi_copias)
correlacao_wgi <- stats::cor(dados_wgi[, c(dimensoes_wgi, "indice_wgi")],
                             use = "pairwise.complete.obs")
Salvar(data.frame(dimensao = rownames(correlacao_wgi), correlacao_wgi,
                  fonte = fonte_wgi, row.names = NULL), "correlacao_wgi")
h5_wgi <- do.call(rbind, lapply(c(dimensoes_wgi, "indice_wgi"),
                                function(v) {
  formula <- stats::as.formula(paste(
    "log_escore_bc ~", v, "+ alta_tec_export + log_comercio + market_cap +",
    "credito_privado + ano_f"))
  rotulo <- if (v == "efetividade_governo") {
    "H5 truncada com efetividade_governo do cache WGI (referência do bloco)"
  } else {
    paste("H5 truncada com", v, "no lugar da efetividade (M2)")
  }
  return(TruncadaAgrupada(formula, dados_wgi, rotulo))
}))
h5_wgi$fonte_wgi <- fonte_wgi

# Tobit comparativo (escore em (0, 1], censurado à direita em 1; prática
# anterior da literatura, mantido só para comparação) -------------------------
tobit_h5 <- AER::tobit(escore_bc ~ efetividade_governo + alta_tec_export +
                         log_comercio + market_cap + credito_privado + ano_f,
                       right = 1, data = dados)
tob <- summary(tobit_h5)$coefficients
tobit_tab <- data.frame(modelo = "H5 Tobit (escore_bc, M2)",
                        termo = rownames(tob), coeficiente = tob[, 1],
                        ep = tob[, 2], p_valor = tob[, 4],
                        stringsAsFactors = FALSE)
tobit_tab$ic90_inf <- tobit_tab$coeficiente - stats::qnorm(0.95) * tobit_tab$ep
tobit_tab$ic90_sup <- tobit_tab$coeficiente + stats::qnorm(0.95) * tobit_tab$ep
tobit_tab$sinal_previsto <- SinalPrevisto(tobit_tab$modelo, tobit_tab$termo)
tobit_tab$nivel_evidencia <- NivelEvidencia(
  tobit_tab$coeficiente, tobit_tab$p_valor < 0.05, tobit_tab$p_valor < 0.10,
  tobit_tab$sinal_previsto, 2 * stats::qnorm(0.975) * tobit_tab$ep)

# Simar-Wilson algoritmo 2 (rDEA) no pooled ------------------------------------
Registrar("Simar-Wilson algoritmo 2 (L1 =", l1_sw, ", L2 =", l2_sw, ")...")
# rDEA exige o mesmo número de linhas em X, Y e Z: usamos só os casos
# completos nas variáveis de contexto (o painel tem lacunas em market_cap).
vars_z <- c("efetividade_governo", "alta_tec_export", "log_comercio",
            "market_cap", "credito_privado")
dados_sw <- dados[stats::complete.cases(dados[, vars_z]), ]
dados_sw$ano_f <- droplevels(dados_sw$ano_f)
z_sw <- stats::model.matrix(~ efetividade_governo + alta_tec_export +
                              log_comercio + market_cap + credito_privado +
                              ano_f, dados_sw)[, -1]
Registrar("obs. no Simar-Wilson alg. 2:", nrow(dados_sw))
# rDEA pode travar na regressão truncada interna (e engole interrupções
# do setTimeLimit); por isso o passo roda em um processo filho com tempo
# máximo real. Em caso de estouro, seguimos sem ele: a regressão truncada
# com bootstrap agrupado acima é a especificação principal.
limite_sw_seg <- as.numeric(Sys.getenv("LIMITE_SW_SEG", "300"))
RodarComTempoMaximo <- function(funcao, segundos) {
  # Avalia `funcao()` em processo filho (fork); devolve NULL se estourar.
  # A semente é fixada DENTRO do filho: mcparallel reinicializa o gerador
  # do processo filho a partir do PID e do horário, o que tornava o
  # algoritmo 2 irreprodutível entre execuções.
  tarefa <- parallel::mcparallel({
    set.seed(semente)
    funcao()
  })
  resultado <- parallel::mccollect(tarefa, wait = FALSE, timeout = segundos)
  if (is.null(resultado)) {
    tools::pskill(tarefa$pid, tools::SIGKILL)
    parallel::mccollect(tarefa, wait = FALSE)
    return(NULL)
  }
  saida <- resultado[[1]]
  if (inherits(saida, "try-error")) {
    return(NULL)
  }
  return(saida)
}
RodarSw <- function(alpha) {
  # Algoritmo 2 com nível `alpha` para o IC; com a mesma semente, as
  # réplicas são as mesmas em qualquer alpha (o rDEA não devolve as
  # réplicas, só o IC básico).
  return(tryCatch(
    RodarComTempoMaximo(
      function() {
        rDEA::dea.env.robust(X = MatrizFronteira(dados_sw, insumos,
                                                 parametros_pad, 1e6),
                             Y = MatrizFronteira(dados_sw, produtos,
                                                 parametros_pad),
                             Z = z_sw, model = "output", RTS = "variable",
                             L1 = l1_sw, L2 = l2_sw, alpha = alpha)
      },
      limite_sw_seg),
    error = function(e) {
      Registrar("dea.env.robust não concluído:", conditionMessage(e))
      return(NULL)
    }))
}
sw <- RodarSw(0.05)
# IC 90% (S07) só quando o IC 95% foi obtido.
sw90 <- if (is.null(sw)) NULL else RodarSw(0.10)
arquivo_sw <- file.path(
  "output/tables", paste0("segundo_estagio_simar_wilson_m2", sufixo, ".csv"))
if (is.null(sw)) {
  Registrar("dea.env.robust não concluído em", limite_sw_seg,
            "s; seguindo sem o algoritmo 2 do rDEA")
  # Uma tabela antiga não pode sobreviver a uma execução que falhou.
  if (file.exists(arquivo_sw)) {
    file.rename(arquivo_sw, sub("\\.csv$", "_OBSOLETO.csv", arquivo_sw))
  }
  Salvar(data.frame(status = "nao_concluido", limite_seg = limite_sw_seg,
                    horario = format(Sys.time())),
         "segundo_estagio_simar_wilson_status")
} else {
  Salvar(data.frame(status = "ok", horario = format(Sys.time())),
         "segundo_estagio_simar_wilson_status")
}
if (!is.null(sw)) {
  Registrar("dea.env.robust: componentes", paste(names(sw), collapse = ", "))
  Registrar("faixa de delta corrigido:",
            paste(round(range(sw$delta_hat_hat), 3), collapse = " a "))
  ci <- sw$beta_ci
  if (is.null(ci)) ci <- sw$ci
  sw_tab <- data.frame(modelo = "H5 Simar-Wilson alg. 2 (rDEA, pooled)",
                       termo = c("(Intercept)", colnames(z_sw)),
                       coeficiente = as.numeric(sw$beta_hat_hat),
                       stringsAsFactors = FALSE)
  if (!is.null(ci) && nrow(ci) == nrow(sw_tab)) {
    sw_tab$ic_inf <- ci[, 1]
    sw_tab$ic_sup <- ci[, 2]
    sw_tab$significativo_5pct <- sw_tab$ic_inf > 0 | sw_tab$ic_sup < 0
  }
  ci90 <- if (is.null(sw90)) NULL else sw90$beta_ci
  if (!is.null(ci90) && nrow(ci90) == nrow(sw_tab)) {
    sw_tab$ic90_inf <- ci90[, 1]
    sw_tab$ic90_sup <- ci90[, 2]
    sw_tab$significativo_10pct <- sw_tab$ic90_inf > 0 | sw_tab$ic90_sup < 0
  } else {
    sw_tab$significativo_10pct <- NA
  }
  # Farrell: positivo = MENOS eficiente; o sinal previsto se inverte.
  sw_tab$sinal_previsto <- InverterSinal(SinalPrevisto(sw_tab$modelo,
                                                       sw_tab$termo))
  sw_tab$nivel_evidencia <- NivelEvidencia(
    sw_tab$coeficiente, sw_tab$significativo_5pct,
    sw_tab$significativo_10pct, sw_tab$sinal_previsto,
    if (is.null(sw_tab$ic_inf)) NA_real_ else sw_tab$ic_sup - sw_tab$ic_inf)
  sw_tab$fronteira <- "agrupada, casos completos de contexto"
  sw_tab$semente_filho <- semente
  Salvar(sw_tab, "segundo_estagio_simar_wilson_m2")
  print(sw_tab)
}

# H6: finanças no canal de patentes -------------------------------------------
formula_h6 <- log_escore_bc_pat ~ market_cap + credito_privado + npl +
  efetividade_governo + ano_f
h6 <- TruncadaParametrizacoes(formula_h6, dados, "H6 truncada (canal patentes)")
formula_h6_pub <- log_escore_bc_pub ~ market_cap + credito_privado + npl +
  efetividade_governo + ano_f
h6_pub <- TruncadaAgrupada(formula_h6_pub, dados,
                           "H6 contraste (canal publicações)")

# H7: PIB per capita por canal -------------------------------------------------
formula_h7_pat <- log_escore_bc_pat ~ log_pib_pc + alta_tec_export +
  log_comercio + ano_f
formula_h7_pub <- log_escore_bc_pub ~ log_pib_pc + alta_tec_export +
  log_comercio + ano_f
h7_pat <- TruncadaParametrizacoes(formula_h7_pat, dados, "H7 canal patentes")
h7_pub <- TruncadaParametrizacoes(formula_h7_pub, dados,
                                  "H7 canal publicações")

# H5 sem valores-piso do investimento (fronteiras reestimadas no script 02)
boot_sp <- LerSaida("boot_ano_m2_sem_piso")
dados_sp <- base |>
  dplyr::inner_join(dplyr::select(boot_sp, id, escore_bc), by = "id") |>
  dplyr::mutate(ano_f = factor(ano), log_escore_bc = log(escore_bc))
h5_sp <- TruncadaAgrupada(formula_h5, dados_sp,
                          "H5 truncada sem valores-piso (M2)")

segundo_estagio <- rbind(h5, h5_sp, h5b, h5c, h6, h6_pub, h7_pat, h7_pub)
segundo_estagio <- ClassificarTabela(segundo_estagio)
Salvar(segundo_estagio, "segundo_estagio_truncada")
h5_wgi <- ClassificarTabela(h5_wgi)
Salvar(h5_wgi, "segundo_estagio_wgi")
print(h5_wgi[h5_wgi$termo %in% c(dimensoes_wgi, "indice_wgi"),
             c("modelo", "termo", "coeficiente", "ic_inf", "ic_sup",
               "p_boot", "nivel_evidencia")])
Salvar(tobit_tab, "segundo_estagio_tobit")
print(segundo_estagio[!grepl("^ano_f", segundo_estagio$termo) &
                        segundo_estagio$dependente == "log_escore",
                      c("modelo", "termo", "coeficiente", "ic_inf", "ic_sup",
                        "p_boot", "nivel_evidencia",
                        "replicas_convergentes")])

# Testes não paramétricos por grupo de renda -----------------------------------
TesteGrupos <- function(variavel, rotulo) {
  # Dois testes, cada um em duas unidades amostrais, identificados pelo
  # nome da coluna: Kruskal-Wallis com os TRÊS grupos de renda e
  # Mann-Whitney com DOIS grupos (alta renda vs renda média agregada), em
  # país-ano (linhas repetidas por país) e em médias por país (uma linha
  # por país). Comparar o mesmo teste nas duas unidades isola o efeito da
  # repetição temporal; comparar testes diferentes não.
  # Só as observações em que o escore é definido (nos canais, produto
  # positivo).
  d <- dados[!is.na(dados[[variavel]]), ]
  kw <- stats::kruskal.test(d[[variavel]], factor(d$grupo_renda))
  mw <- stats::wilcox.test(d[[variavel]] ~ d$grupo_renda2)
  por_pais <- d |>
    dplyr::group_by(pais, grupo_renda, grupo_renda2) |>
    dplyr::summarise(v = mean(.data[[variavel]]), .groups = "drop")
  kw_pais <- stats::kruskal.test(por_pais$v, factor(por_pais$grupo_renda))
  mw_pais <- stats::wilcox.test(v ~ grupo_renda2, data = por_pais)
  medias <- tapply(d[[variavel]], d$grupo_renda, mean)
  Media <- function(g) if (g %in% names(medias)) medias[[g]] else NA_real_
  saida <- data.frame(escore = rotulo, n_obs = nrow(d),
                      p_kruskal_3grupos_pais_ano = kw$p.value,
                      p_kruskal_3grupos_medias_pais = kw_pais$p.value,
                      p_mann_whitney_2grupos_pais_ano = mw$p.value,
                      p_mann_whitney_2grupos_medias_pais = mw_pais$p.value,
                      n_paises = nrow(por_pais),
                      media_alta = Media("Alta renda"),
                      media_media_alta = Media("Renda média-alta"),
                      media_media_baixa = Media("Renda média-baixa"))
  return(saida)
}
testes_grupos <- rbind(TesteGrupos("escore_bc", "conjunto M2 (bc)"),
                       TesteGrupos("escore_bc_pub", "canal publicações (bc)"),
                       TesteGrupos("escore_bc_pat", "canal patentes (bc)"))
Salvar(testes_grupos, "testes_grupo_renda")
print(testes_grupos)

# Associação descritiva entre Z e escores (NÃO testa separabilidade) --------
# Correlações de Spearman com bootstrap por país. Elas não distinguem Z que
# desloca a fronteira de Z que afeta só a distribuição da ineficiência; o
# teste de separabilidade (Daraio, Simar e Wilson, 2018) permanece pendente
# e o segundo estágio deve ser lido como exploratório.
zs <- c("efetividade_governo", "alta_tec_export", "log_comercio",
        "market_cap", "credito_privado", "log_pib_pc", "pd_pct_pib")
diag_sep <- do.call(rbind, lapply(zs, function(z) {
  r <- SpearmanComIc(dados[[z]], dados$escore_bc, n_boot = 500,
                     grupo = dados$pais)
  data.frame(z = z, rho = r["rho"], ic_inf = r["ic_inf"], ic_sup = r["ic_sup"])
}))
Salvar(diag_sep, "associacao_z_vs_escore")
print(diag_sep)
RegistrarManifesto("03_segundo_estagio_dataset_atual.R", sufixo,
                   arquivo_base,
                   if (is.null(sw)) "ok_sem_simar_wilson" else "ok")
Registrar("FIM segundo estágio Fase A")
