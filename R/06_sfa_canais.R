# 06_sfa_canais.R
# S02 / H2: fronteira estocástica de produção (SFA) por canal, com as
# variáveis em log. H2: controlando pelo P&D executado no país, o
# investimento privado em IA tem elasticidade significativa no canal de
# patentes e não no de publicações.
# Modelos, por canal (DMUs com produto zero saem do canal, como na DEA):
#   principal: Cobb-Douglas com efeitos de ano e ineficiência meia-normal,
#              amostra agrupada (frontier::sfa), com IC das elasticidades
#              por bootstrap em blocos de país;
#   robustez:  ineficiência exponencial (sfaR::sfacross); translog com os
#              logs centrados na média (os termos de primeira ordem são as
#              elasticidades na média); painel com ineficiência invariante
#              no tempo (Battese e Coelli, 1988) e variante no tempo
#              (Battese e Coelli, 1992);
#   exploratório: SFA de duas classes latentes (sfaR::sfalcmcross), como
#              robustez de H3 (heterogeneidade tecnológica sem impor os
#              grupos de renda).
# Diagnósticos gravados: assimetria dos resíduos de MQO (positiva = sem
# ineficiência identificável numa fronteira de produção, e o SFA recai no
# MQO), correlação entre os insumos, convergência, iterações e tempo.
# Convergência (A04 de artigo/17): quando o frontier para sem convergir
# (código diferente de 1; quase sempre o código 5, "não encontra parâmetros
# com log-verossimilhança maior que a do passo anterior"), o ajuste é
# reiniciado do próprio ponto final e só é aceito se então convergir sem
# perder log-verossimilhança. Vale para o ajuste pontual e para cada réplica
# do bootstrap: no diagnóstico de 04/10/2026, a maioria das paradas com
# código 5 já estava no máximo, mas nos modelos de painel algumas estavam
# longe dele (o reinício ganhou até 83 de log-verossimilhança), de modo que
# descartar essas réplicas, como antes, não era neutro.
# Inferência: elasticidades, diferença entre canais e retornos de escala
# (soma das elasticidades) com IC por bootstrap em blocos de país nos três
# modelos com bootstrap; o teste de Wald com a hessiana fica só como
# diagnóstico (supõe observações independentes; A05 de artigo/17).
# O log torna a escala irrelevante (multiplicar uma variável por uma
# constante só muda o intercepto); por isso a padronização da DEA (S01) não
# se aplica aqui.
# Variáveis de ambiente: BASE_ARQUIVO, SUFIXO_SAIDA, INSUMOS, PRODUTOS (como
# no script 02), N_BOOT_SFA (réplicas do bootstrap; padrão 300) e
# N_NUCLEOS (processos paralelos do bootstrap; padrão: núcleos - 1).
# Uso: Rscript R/06_sfa_canais.R

source("R/00_setup.R")

arquivo_base <- Sys.getenv("BASE_ARQUIVO", "data/processed/base_atual.csv")
sufixo <- Sys.getenv("SUFIXO_SAIDA", "")
insumos <- strsplit(Sys.getenv("INSUMOS", "investimento,gerd"), ",")[[1]]
produtos <- strsplit(Sys.getenv("PRODUTOS", "publicacoes,patentes"), ",")[[1]]
n_boot_sfa <- as.integer(Sys.getenv("N_BOOT_SFA", "300"))
n_nucleos <- as.integer(Sys.getenv(
  "N_NUCLEOS", max(1, parallel::detectCores() - 1)))
if (ConfigurarPadronizacao()$metodo != "nenhuma") {
  Registrar("PADRONIZACAO ignorada: o SFA usa log, que já remove a escala")
}
Salvar <- function(dados, nome) {
  return(SalvarTabela(dados, paste0(nome, sufixo)))
}

# Amostra: a mesma regra do script 02 (observações completas, investimento
# positivo), mais o segundo insumo positivo, exigido pelo log -------------
base <- utils::read.csv(arquivo_base, stringsAsFactors = FALSE)
completas <- stats::complete.cases(base[, c(insumos, produtos)])
amostra <- base[completas & base[[insumos[1]]] > 0, ]
sem_pd <- amostra[[insumos[2]]] <= 0
if (any(sem_pd)) {
  Registrar("excluídas por segundo insumo não positivo:", sum(sem_pd))
  amostra <- amostra[!sem_pd, ]
}
amostra$l_inv <- log(amostra[[insumos[1]]] / 1e6)   # milhões de US$
amostra$l_pd <- log(amostra[[insumos[2]]] / 1e6)
amostra$ano_f <- factor(amostra$ano)
Registrar("amostra:", nrow(amostra), "obs.,", length(unique(amostra$pais)),
          "países | insumos:", paste(insumos, collapse = " + "),
          "| correlação dos logs:",
          round(stats::cor(amostra$l_inv, amostra$l_pd), 3))

Assimetria <- function(e) {
  return(mean((e - mean(e))^3) / stats::sd(e)^3)
}

PValorLrMisto <- function(lr) {
  # p-valor do teste de razão de verossimilhança de ausência de ineficiência
  # (parâmetro na fronteira do espaço): mistura 50:50 de qui-quadrados com
  # 0 e 1 grau de liberdade.
  return(0.5 * stats::pchisq(max(lr, 0), df = 1, lower.tail = FALSE))
}

TesteRetornos <- function(coefs, vcov_m, termos) {
  # Soma das elasticidades (retornos de escala na média) e teste de Wald de
  # retornos constantes (soma = 1) com a covariância da hessiana, que supõe
  # observações independentes: diagnóstico, não a inferência adotada (essa
  # vem do bootstrap por país, em BootstrapPais).
  soma <- sum(coefs[termos])
  ep <- sqrt(sum(vcov_m[termos, termos]))
  return(c(retornos = soma, ep_retornos_hessiana = ep,
           p_retornos_constantes = 2 * stats::pnorm(-abs((soma - 1) / ep))))
}

SfaFrontier <- function(formula, dados, indice = NULL, tempo = FALSE) {
  # frontier::sfa agrupado (indice = NULL) ou em painel (indice = colunas
  # de unidade e ano; tempo = TRUE para a ineficiência variante no tempo de
  # Battese e Coelli, 1992). Sem convergência (código diferente de 1),
  # reinicia do próprio ponto final e aceita o novo ajuste se ele convergir
  # sem perder log-verossimilhança. Devolve o ajuste, com o atributo
  # "reinicio" (TRUE quando houve nova tentativa), ou o erro capturado.
  dados_ajuste <- if (is.null(indice)) {
    dados
  } else {
    plm::pdata.frame(dados, index = indice)
  }
  Rodar <- function(inicio) {
    ajuste <- NULL
    # capture.output: o frontier imprime as próprias tentativas internas.
    invisible(utils::capture.output(ajuste <- tryCatch(
      suppressWarnings(frontier::sfa(formula, data = dados_ajuste,
                                     timeEffect = tempo, startVal = inicio)),
      error = function(e) e)))
    return(ajuste)
  }
  ajuste <- Rodar(NULL)
  if (inherits(ajuste, "error")) {
    return(ajuste)
  }
  attr(ajuste, "reinicio") <- FALSE
  if (ajuste$code != 1) {
    novo <- Rodar(stats::coef(ajuste))
    if (!inherits(novo, "error") && novo$code == 1 &&
        novo$mleLogl >= ajuste$mleLogl - 1e-6) {
      ajuste <- novo
    }
    attr(ajuste, "reinicio") <- TRUE
  }
  return(ajuste)
}

AjustarModelo <- function(d, modelo) {
  # Ajusta um modelo e devolve uma linha padronizada: elasticidades (os
  # termos l_inv e l_pd, ou os de primeira ordem da translog centrada),
  # erros-padrão da hessiana, ineficiência, teste de razão de
  # verossimilhança contra o MQO, convergência, iterações e tempo.
  formula <- switch(
    modelo,
    translog = l_y ~ l_inv + l_pd + I(0.5 * l_inv^2) + I(0.5 * l_pd^2) +
      I(l_inv * l_pd) + ano_f,
    l_y ~ l_inv + l_pd + ano_f)
  if (modelo == "translog") {
    # Logs centrados: os termos de primeira ordem viram as elasticidades
    # na média geométrica da amostra do canal.
    d$l_inv <- d$l_inv - mean(d$l_inv)
    d$l_pd <- d$l_pd - mean(d$l_pd)
  }
  inicio <- Sys.time()
  ajuste <- switch(
    modelo,
    exponencial = tryCatch(
      suppressWarnings(sfaR::sfacross(formula, data = d,
                                      udist = "exponential")),
      error = function(e) e),
    painel_bc88 = SfaFrontier(formula, d, indice = c("iso3c", "ano")),
    painel_bc92 = SfaFrontier(formula, d, indice = c("iso3c", "ano"),
                              tempo = TRUE),
    SfaFrontier(formula, d))
  segundos <- as.numeric(difftime(Sys.time(), inicio, units = "secs"))
  linha <- data.frame(modelo = modelo, n_obs = nrow(d),
                      n_paises = length(unique(d$pais)),
                      segundos = segundos, stringsAsFactors = FALSE)
  if (inherits(ajuste, "error")) {
    linha$convergiu <- FALSE
    linha$inferencia_valida <- FALSE
    linha$reinicio <- FALSE
    linha$mensagem <- conditionMessage(ajuste)
    return(linha)
  }
  tab <- stats::coef(summary(ajuste))
  coefs <- tab[, 1]
  vcov_m <- stats::vcov(ajuste)
  # Inferência válida: otimizador convergiu e os erros-padrão das
  # elasticidades são finitos (e, no sfaR, o gradiente também). Quando os
  # resíduos de MQO têm a assimetria errada, o modelo exponencial leva a
  # variância da ineficiência a zero, a hessiana degenera e o sfaR ainda
  # informa "successful convergence"; essas linhas não são interpretadas.
  ep_finitos <- all(is.finite(tab[c("l_inv", "l_pd"), 2]))
  reinicio <- isTRUE(attr(ajuste, "reinicio"))
  if (inherits(ajuste, "frontier")) {
    convergiu <- ajuste$code == 1
    gradiente_finito <- TRUE
    mensagem <- paste0("frontier, código ", ajuste$code,
                       if (reinicio) " (após reinício do ponto final)")
    iteracoes <- ajuste$nIter
    loglik <- ajuste$mleLogl
    lr <- lmtest::lrtest(ajuste)
    estatistica_lr <- lr[2, "Chisq"]
    p_lr <- lr[2, "Pr(>Chisq)"]
    eficiencia <- mean(frontier::efficiencies(ajuste), na.rm = TRUE)
    gamma <- unname(coefs["gamma"])
    eta <- if ("time" %in% names(coefs)) unname(coefs["time"]) else NA
  } else {
    convergiu <- grepl("successful", ajuste$optStatus, ignore.case = TRUE)
    gradiente_finito <- is.finite(ajuste$gradientNorm)
    mensagem <- paste("sfaR,", trimws(ajuste$optStatus))
    iteracoes <- ajuste$nIter
    loglik <- ajuste$mlLoglik
    loglik_mqo <- as.numeric(stats::logLik(stats::lm(formula, d)))
    estatistica_lr <- 2 * (loglik - loglik_mqo)
    p_lr <- PValorLrMisto(estatistica_lr)
    eficiencia <- mean(sfaR::efficiencies(ajuste)$teJLMS, na.rm = TRUE)
    gamma <- NA
    eta <- NA
  }
  retornos <- TesteRetornos(coefs, vcov_m, c("l_inv", "l_pd"))
  linha$elasticidade_inv <- unname(coefs["l_inv"])
  linha$ep_inv <- unname(tab["l_inv", 2])
  linha$p_inv <- unname(tab["l_inv", 4])
  linha$elasticidade_pd <- unname(coefs["l_pd"])
  linha$ep_pd <- unname(tab["l_pd", 2])
  linha$p_pd <- unname(tab["l_pd", 4])
  linha$retornos <- unname(retornos["retornos"])
  linha$ep_retornos_hessiana <- unname(retornos["ep_retornos_hessiana"])
  linha$p_retornos_constantes_wald_hessiana <- unname(
    retornos["p_retornos_constantes"])
  linha$gamma <- gamma
  linha$eta_tempo <- eta
  linha$lr_ineficiencia <- estatistica_lr
  linha$p_lr_ineficiencia <- p_lr
  linha$eficiencia_media <- eficiencia
  linha$loglik <- loglik
  linha$convergiu <- convergiu
  linha$inferencia_valida <- convergiu && ep_finitos && gradiente_finito
  linha$reinicio <- reinicio
  linha$iteracoes <- iteracoes
  linha$mensagem <- mensagem
  return(linha)
}

AjustarRapido <- function(dados, modelo) {
  # Ajuste usado no bootstrap: devolve as elasticidades (NA sem
  # convergência, mesmo depois do reinício) e se houve reinício. Nos modelos
  # de painel, a unidade é a cópia do país.
  formula <- l_y ~ l_inv + l_pd + ano_f
  dados$ano_f <- droplevels(dados$ano_f)
  s <- switch(
    modelo,
    painel_bc88 = SfaFrontier(formula, dados, indice = c("unidade", "ano")),
    painel_bc92 = SfaFrontier(formula, dados, indice = c("unidade", "ano"),
                              tempo = TRUE),
    SfaFrontier(formula, dados))
  if (inherits(s, "error")) {
    return(c(NA_real_, NA_real_, 0))
  }
  reinicio <- as.numeric(isTRUE(attr(s, "reinicio")))
  if (s$code != 1) {
    return(c(NA_real_, NA_real_, reinicio))
  }
  return(c(unname(stats::coef(s)[c("l_inv", "l_pd")]), reinicio))
}

BootstrapPais <- function(n_boot, modelo) {
  # IC percentílico das elasticidades por reamostragem de países (blocos
  # com todos os anos do país), como no segundo estágio: a SE da hessiana
  # supõe observações independentes, e o mesmo país aparece em vários
  # anos. Os dois canais são ajustados no MESMO sorteio de países, o que dá
  # também o IC da diferença entre as elasticidades do investimento
  # (patentes - publicações), o teste da especificidade relativa de H2, e o
  # IC dos retornos de escala de cada canal (soma das duas elasticidades na
  # MESMA réplica, o que preserva a covariância entre elas; somar os
  # limites dos IC individuais seria errado). Nos
  # modelos de painel, cada país sorteado recebe um identificador próprio
  # (o mesmo país sorteado duas vezes vira duas unidades). Réplicas sem
  # convergência são descartadas e contadas. Os sorteios são feitos antes,
  # em sequência e com a semente do projeto; só os ajustes (que não usam
  # números aleatórios) vão para processos paralelos, de modo que o
  # resultado não depende do número de núcleos.
  paises <- unique(amostra$pais)
  set.seed(semente)
  sorteios <- lapply(seq_len(n_boot), function(b) {
    return(sample(paises, replace = TRUE))
  })
  Replica <- function(escolhidos) {
    db <- do.call(rbind, lapply(seq_along(escolhidos), function(k) {
      dk <- amostra[amostra$pais == escolhidos[k], ]
      dk$unidade <- paste0(dk$iso3c, "_", k)
      return(dk)
    }))
    return(unlist(lapply(names(canais), function(canal) {
      dc <- db[db[[canais[[canal]]]] > 0, ]
      dc$l_y <- log(dc[[canais[[canal]]]])
      return(AjustarRapido(dc, modelo))
    })))
  }
  # Distribuição dinâmica (mc.preschedule = FALSE): réplicas lentas não
  # travam um núcleo com um bloco fixo de réplicas.
  lista <- parallel::mclapply(sorteios, Replica, mc.cores = n_nucleos,
                              mc.preschedule = FALSE)
  replicas <- vapply(lista, function(r) {
    if (!is.numeric(r) || length(r) != 6) return(rep(NA_real_, 6))
    return(r)
  }, numeric(6))
  rownames(replicas) <- c("publicacoes.l_inv", "publicacoes.l_pd",
                          "publicacoes.reinicio", "patentes.l_inv",
                          "patentes.l_pd", "patentes.reinicio")
  Resumo <- function(v, canal, termo, reinicios) {
    v <- v[is.finite(v)]
    Q <- function(p) {
      if (length(v) < 20) return(NA_real_)
      return(unname(stats::quantile(v, p)))
    }
    return(data.frame(modelo = modelo, canal = canal, termo = termo,
                      ic_inf = Q(0.025), ic_sup = Q(0.975),
                      ic90_inf = Q(0.05), ic90_sup = Q(0.95),
                      replicas_tentadas = n_boot,
                      replicas_convergentes = length(v),
                      replicas_com_reinicio = sum(reinicios, na.rm = TRUE),
                      stringsAsFactors = FALSE))
  }
  pub_reinicio <- replicas["publicacoes.reinicio", ]
  pat_reinicio <- replicas["patentes.reinicio", ]
  return(rbind(
    Resumo(replicas["publicacoes.l_inv", ], "publicacoes", "l_inv",
           pub_reinicio),
    Resumo(replicas["publicacoes.l_pd", ], "publicacoes", "l_pd",
           pub_reinicio),
    Resumo(replicas["publicacoes.l_inv", ] + replicas["publicacoes.l_pd", ],
           "publicacoes", "retornos", pub_reinicio),
    Resumo(replicas["patentes.l_inv", ], "patentes", "l_inv", pat_reinicio),
    Resumo(replicas["patentes.l_pd", ], "patentes", "l_pd", pat_reinicio),
    Resumo(replicas["patentes.l_inv", ] + replicas["patentes.l_pd", ],
           "patentes", "retornos", pat_reinicio),
    Resumo(replicas["patentes.l_inv", ] - replicas["publicacoes.l_inv", ],
           "patentes - publicacoes", "l_inv",
           pmax(pub_reinicio, pat_reinicio))))
}

# Ajustes por canal -------------------------------------------------------
modelos <- c("cobb_douglas", "exponencial", "translog", "painel_bc88",
             "painel_bc92")
# Modelos com IC por bootstrap em blocos de país: o principal e os dois de
# painel (as conclusões sobre H2 diferem entre eles).
modelos_boot <- c("cobb_douglas", "painel_bc88", "painel_bc92")
canais <- c(publicacoes = produtos[1], patentes = produtos[2])
resultados <- list()
for (canal in names(canais)) {
  d <- amostra[amostra[[canais[[canal]]]] > 0, ]
  d$l_y <- log(d[[canais[[canal]]]])
  mqo <- stats::lm(l_y ~ l_inv + l_pd + ano_f, data = d)
  assimetria <- Assimetria(stats::residuals(mqo))
  Registrar(canal, "(", canais[[canal]], "):", nrow(d), "obs. | assimetria",
            "dos resíduos de MQO:", round(assimetria, 3))
  for (modelo in modelos) {
    linha <- AjustarModelo(d, modelo)
    resultados[[paste(canal, modelo)]] <- data.frame(
      canal = canal, produto = canais[[canal]], linha,
      assimetria_mqo = assimetria, assimetria_ok = assimetria < 0,
      cor_insumos = stats::cor(d$l_inv, d$l_pd), stringsAsFactors = FALSE)
    Registrar(" ", modelo, "| inv", round(linha$elasticidade_inv, 3),
              "(p", round(linha$p_inv, 3), ") | P&D",
              round(linha$elasticidade_pd, 3), "| LR p",
              round(linha$p_lr_ineficiencia, 3), "| convergiu",
              linha$convergiu, "| inferência válida",
              linha$inferencia_valida, "|", round(linha$segundos, 2), "s")
  }
}
resultados <- dplyr::bind_rows(resultados)
Salvar(resultados, "sfa_canais")
bootstrap <- do.call(rbind, lapply(modelos_boot, function(modelo) {
  Registrar("bootstrap por país (", n_boot_sfa, "réplicas ):", modelo)
  return(BootstrapPais(n_boot_sfa, modelo))
}))
rownames(bootstrap) <- NULL
Salvar(bootstrap, "sfa_canais_bootstrap")

# Veredito de H2 por modelo (IC 95% por bootstrap em blocos de país) -----
# Alvo (A03 de artigo/17): especificidade relativa com a direção prevista.
# H2 é "apoiada" quando (i) a elasticidade do investimento em patentes tem
# IC 95% acima de zero E (ii) a diferença patentes - publicações também tem
# IC 95% acima de zero. Ser significativo num canal e não no outro não é
# teste da diferença (Gelman e Stern, 2006), e um IC de publicações que
# contém zero não demonstra efeito nulo: sem margem de equivalência
# definida antes dos resultados, o texto diz "não distinguível de zero". O
# padrão de significância de cada canal fica na tabela só como descrição.
# Antes de qualquer veredito (A04 de artigo/17): ajuste pontual válido nos
# dois canais (convergência, erros-padrão finitos) e pelo menos 90% de
# réplicas convergentes na diferença (mesmo limiar de alerta do segundo
# estágio); sem isso, a combinação é "não estimável" ou "inconclusiva" e
# sai do denominador dos vereditos. Ausência de IC nunca vira "sem efeito".
minimo_replicas <- 0.9
Ic <- function(m, canal, termo = "l_inv") {
  return(bootstrap[bootstrap$modelo == m & bootstrap$canal == canal &
                     bootstrap$termo == termo, ])
}
Ponto <- function(m, canal, coluna = "elasticidade_inv") {
  return(resultados[[coluna]][resultados$modelo == m &
                                resultados$canal == canal])
}
Sinal <- function(ic) {
  # Leitura descritiva de um IC 95%.
  if (nrow(ic) != 1 || is.na(ic$ic_inf)) return("sem IC")
  if (ic$ic_inf > 0) return("positiva")
  if (ic$ic_sup < 0) return("negativa")
  return("não distinguível de zero")
}
EstadoH2 <- function(m, dif) {
  for (canal in names(canais)) {
    valido <- Ponto(m, canal, "inferencia_valida")
    if (!isTRUE(valido)) {
      return(paste0("não estimável (ajuste pontual sem inferência válida em ",
                    canal, ": ", Ponto(m, canal, "mensagem"), ")"))
    }
  }
  if (nrow(dif) != 1 || is.na(dif$ic_inf) ||
      dif$replicas_convergentes < minimo_replicas * n_boot_sfa) {
    return(sprintf(
      "inconclusivo (réplicas convergentes %d de %d, abaixo de %d%%)",
      if (nrow(dif) == 1) as.integer(dif$replicas_convergentes) else 0L,
      as.integer(n_boot_sfa), as.integer(round(100 * minimo_replicas))))
  }
  return("estimável")
}
VereditoH2 <- function(pat, dif) {
  pat_positiva <- pat$ic_inf > 0
  dif_positiva <- dif$ic_inf > 0
  if (pat_positiva && dif_positiva) return("apoiada")
  if (dif$ic_sup < 0) {
    return("contrariada (elasticidade maior em publicações)")
  }
  if (pat$ic_sup < 0) {
    return("contrariada (elasticidade negativa em patentes)")
  }
  if (pat_positiva) {
    return(paste("apoio parcial (efeito positivo em patentes; diferença",
                 "entre canais não distinguível de zero)"))
  }
  if (dif_positiva) {
    return(paste("apoio parcial (diferença positiva entre canais; efeito",
                 "em patentes não distinguível de zero)"))
  }
  return(paste("não apoiada (efeito em patentes e diferença entre canais",
               "não distinguíveis de zero)"))
}
h2 <- do.call(rbind, lapply(modelos_boot, function(m) {
  pub <- Ic(m, "publicacoes")
  pat <- Ic(m, "patentes")
  dif <- Ic(m, "patentes - publicacoes")
  estado <- EstadoH2(m, dif)
  veredito <- if (estado == "estimável") {
    VereditoH2(pat, dif)
  } else {
    sub(" \\(.*$", "", estado)
  }
  if (startsWith(estado, "não estimável")) {
    # Réplicas que convergem não validam um ponto original sem inferência
    # válida: os intervalos não são mostrados.
    Vazio <- function(ic) {
      ic[1, c("ic_inf", "ic_sup")] <- NA_real_
      return(ic)
    }
    pub <- Vazio(pub)
    pat <- Vazio(pat)
    dif <- Vazio(dif)
  }
  return(data.frame(
    modelo = m,
    n_obs_publicacoes = Ponto(m, "publicacoes", "n_obs"),
    n_obs_patentes = Ponto(m, "patentes", "n_obs"),
    inferencia_valida_publicacoes = Ponto(m, "publicacoes",
                                          "inferencia_valida"),
    inferencia_valida_patentes = Ponto(m, "patentes", "inferencia_valida"),
    inv_publicacoes = Ponto(m, "publicacoes"),
    ic_inf_publicacoes = pub$ic_inf, ic_sup_publicacoes = pub$ic_sup,
    inv_patentes = Ponto(m, "patentes"),
    ic_inf_patentes = pat$ic_inf, ic_sup_patentes = pat$ic_sup,
    diferenca = Ponto(m, "patentes") - Ponto(m, "publicacoes"),
    ic_inf_diferenca = dif$ic_inf, ic_sup_diferenca = dif$ic_sup,
    replicas_tentadas = n_boot_sfa,
    replicas_convergentes_diferenca = dif$replicas_convergentes,
    replicas_com_reinicio_diferenca = dif$replicas_com_reinicio,
    estado = estado,
    veredito = veredito,
    efeito_publicacoes = Sinal(pub),
    efeito_patentes = Sinal(pat),
    especificidade_relativa = isTRUE(dif$ic_inf > 0),
    stringsAsFactors = FALSE))
}))
Salvar(h2, "sfa_h2")

# Retornos de escala por canal (A05 de artigo/17) ---------------------------
# Soma das elasticidades (retornos na média). Nos modelos com bootstrap, o
# IC vem da soma calculada em cada réplica (bootstrap por país, com o mesmo
# controle de validade de H2); nos demais (exponencial e translog), só há o
# Wald da hessiana, que supõe observações independentes: a coluna
# inferencia_retornos diz qual é qual. Retornos só são classificados como
# decrescentes ou crescentes quando o IC 95% exclui 1.
ClassificarRetornos <- function(inf, sup) {
  if (is.na(inf) || is.na(sup)) return("sem IC")
  if (sup < 1) return("decrescentes (IC 95% abaixo de 1)")
  if (inf > 1) return("crescentes (IC 95% acima de 1)")
  return("não distinguíveis de constantes (IC 95% contém 1)")
}
retornos <- do.call(rbind, lapply(seq_len(nrow(resultados)), function(i) {
  r <- resultados[i, ]
  linha <- data.frame(
    canal = r$canal, modelo = r$modelo, retornos = r$retornos,
    inferencia_valida = r$inferencia_valida,
    p_retornos_constantes_wald_hessiana =
      r$p_retornos_constantes_wald_hessiana,
    ic_inf = NA_real_, ic_sup = NA_real_, ic90_inf = NA_real_,
    ic90_sup = NA_real_, replicas_convergentes = NA_integer_,
    inferencia_retornos = NA_character_, classificacao = NA_character_,
    stringsAsFactors = FALSE)
  if (!isTRUE(r$inferencia_valida)) {
    linha$inferencia_retornos <- "nenhuma (ajuste pontual inválido)"
    linha$classificacao <- "não estimável"
    return(linha)
  }
  if (r$modelo %in% modelos_boot) {
    b <- Ic(r$modelo, r$canal, "retornos")
    linha$ic_inf <- b$ic_inf
    linha$ic_sup <- b$ic_sup
    linha$ic90_inf <- b$ic90_inf
    linha$ic90_sup <- b$ic90_sup
    linha$replicas_convergentes <- b$replicas_convergentes
    linha$inferencia_retornos <- "bootstrap em blocos de país"
    linha$classificacao <- if (b$replicas_convergentes <
                               minimo_replicas * n_boot_sfa) {
      "inconclusivo (réplicas insuficientes)"
    } else {
      ClassificarRetornos(b$ic_inf, b$ic_sup)
    }
  } else {
    z <- stats::qnorm(0.975)
    linha$ic_inf <- r$retornos - z * r$ep_retornos_hessiana
    linha$ic_sup <- r$retornos + z * r$ep_retornos_hessiana
    linha$inferencia_retornos <- paste("Wald da hessiana (sem bootstrap;",
                                       "supõe observações independentes)")
    linha$classificacao <- ClassificarRetornos(linha$ic_inf, linha$ic_sup)
  }
  return(linha)
}))
Salvar(retornos, "sfa_retornos")

# Classes latentes (exploratório; robustez de H3) -------------------------
# SFA de duas classes (sfaR::sfalcmcross): cada classe tem a sua fronteira,
# e os dados decidem quem pertence a qual. Se as classes coincidirem com os
# grupos de renda, a heterogeneidade tecnológica da metafronteira (H3b)
# aparece também sem impor a divisão por renda. Usa tendência linear no
# lugar dos efeitos de ano: com os efeitos de ano (cerca de 29 parâmetros
# para 191 observações na Fase A) a hessiana fica singular. Um modelo só
# conta como identificado se todos os erros-padrão forem finitos e
# positivos; sem isso, as estimativas não são interpretadas.
ClassesLatentes <- function(canal) {
  d <- amostra[amostra[[canais[[canal]]]] > 0, ]
  d$l_y <- log(d[[canais[[canal]]]])
  d$tendencia <- d$ano - min(d$ano)
  inicio <- Sys.time()
  # O sfaR avisa a hessiana singular por mensagem ou aviso; os dois são
  # capturados e contam contra a identificação.
  singular <- FALSE
  Capturar <- function(condicao) {
    if (grepl("singular", conditionMessage(condicao))) singular <<- TRUE
    return(invisible(NULL))
  }
  ajuste <- tryCatch(withCallingHandlers(
    sfaR::sfalcmcross(l_y ~ l_inv + l_pd + tendencia, data = d,
                      udist = "hnormal", lcmClasses = 2),
    warning = function(w) {
      Capturar(w)
      invokeRestart("muffleWarning")
    },
    message = function(m) {
      Capturar(m)
      invokeRestart("muffleMessage")
    }),
    error = function(e) e)
  segundos <- as.numeric(difftime(Sys.time(), inicio, units = "secs"))
  if (inherits(ajuste, "error")) {
    return(data.frame(canal = canal, classe = NA, convergiu = FALSE,
                      identificado = FALSE, segundos = segundos,
                      mensagem = conditionMessage(ajuste)))
  }
  tab <- stats::coef(summary(ajuste))
  # Linhas por classe, na ordem: intercepto, l_inv, l_pd, tendência, Zu e
  # Zv; a última linha é o logit de pertencer à classe 1.
  k <- (nrow(tab) - 1) / 2
  identificado <- !singular && all(is.finite(tab[, 2]) & tab[, 2] > 1e-6)
  classes <- sfaR::efficiencies(ajuste)
  saida <- do.call(rbind, lapply(1:2, function(j) {
    bloco <- tab[((j - 1) * k + 1):(j * k), , drop = FALSE]
    linha_inv <- which(rownames(bloco) == "l_inv")
    linha_pd <- which(rownames(bloco) == "l_pd")
    membros <- classes$Group_c == j
    return(data.frame(
      canal = canal, classe = j, n_obs = sum(membros),
      parcela_alta_renda = mean(d$grupo_renda[membros] == "Alta renda"),
      elasticidade_inv = bloco[linha_inv, 1], ep_inv = bloco[linha_inv, 2],
      p_inv = bloco[linha_inv, 4], elasticidade_pd = bloco[linha_pd, 1],
      ep_pd = bloco[linha_pd, 2], p_pd = bloco[linha_pd, 4],
      eficiencia_media = mean(classes$teJLMS_c[membros], na.rm = TRUE),
      loglik = ajuste$mlLoglik,
      convergiu = grepl("successful", ajuste$optStatus, ignore.case = TRUE),
      identificado = identificado, segundos = segundos,
      mensagem = paste("sfaR,", trimws(ajuste$optStatus)),
      stringsAsFactors = FALSE))
  }))
  Registrar("classes latentes,", canal, "| identificado:", identificado,
            "| parcela de alta renda por classe:",
            paste(round(saida$parcela_alta_renda, 2), collapse = " e "))
  return(saida)
}
classes_latentes <- dplyr::bind_rows(lapply(names(canais), ClassesLatentes))
Salvar(classes_latentes, "sfa_classes_latentes")
Formatar <- function(t) {
  # Só para o log: números com três algarismos significativos.
  numericas <- vapply(t, is.numeric, logical(1))
  t[numericas] <- lapply(t[numericas], formatC, digits = 3, format = "g")
  return(t)
}
print(Formatar(as.data.frame(resultados[, c(
  "canal", "modelo", "elasticidade_inv", "p_inv", "elasticidade_pd",
  "retornos", "gamma", "p_lr_ineficiencia", "inferencia_valida",
  "reinicio", "segundos")])))
print(Formatar(h2[, c("modelo", "inv_publicacoes", "ic_inf_publicacoes",
                      "ic_sup_publicacoes", "inv_patentes",
                      "ic_inf_patentes", "ic_sup_patentes", "diferenca",
                      "ic_inf_diferenca", "ic_sup_diferenca")]))
print(h2[, c("modelo", "estado", "veredito", "efeito_publicacoes",
              "efeito_patentes", "replicas_convergentes_diferenca")])
print(retornos[, c("canal", "modelo", "retornos", "ic_inf", "ic_sup",
                   "inferencia_retornos", "classificacao")])
RegistrarManifesto("06_sfa_canais.R", sufixo, arquivo_base, "ok")
Registrar("FIM SFA por canal")
