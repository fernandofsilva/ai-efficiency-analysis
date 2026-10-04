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
  # retornos constantes (soma = 1).
  soma <- sum(coefs[termos])
  ep <- sqrt(sum(vcov_m[termos, termos]))
  return(c(retornos = soma, p_retornos_constantes =
             2 * stats::pnorm(-abs((soma - 1) / ep))))
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
  ajuste <- tryCatch(suppressWarnings(switch(
    modelo,
    exponencial = sfaR::sfacross(formula, data = d, udist = "exponential"),
    painel_bc88 = frontier::sfa(
      formula, data = plm::pdata.frame(d, index = c("iso3c", "ano"))),
    painel_bc92 = frontier::sfa(
      formula, data = plm::pdata.frame(d, index = c("iso3c", "ano")),
      timeEffect = TRUE),
    frontier::sfa(formula, data = d))),
    error = function(e) e)
  segundos <- as.numeric(difftime(Sys.time(), inicio, units = "secs"))
  linha <- data.frame(modelo = modelo, n_obs = nrow(d),
                      n_paises = length(unique(d$pais)),
                      segundos = segundos, stringsAsFactors = FALSE)
  if (inherits(ajuste, "error")) {
    linha$convergiu <- FALSE
    linha$inferencia_valida <- FALSE
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
  if (inherits(ajuste, "frontier")) {
    convergiu <- ajuste$code == 1
    gradiente_finito <- TRUE
    mensagem <- paste("frontier, código", ajuste$code)
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
  linha$p_retornos_constantes <- unname(retornos["p_retornos_constantes"])
  linha$gamma <- gamma
  linha$eta_tempo <- eta
  linha$lr_ineficiencia <- estatistica_lr
  linha$p_lr_ineficiencia <- p_lr
  linha$eficiencia_media <- eficiencia
  linha$loglik <- loglik
  linha$convergiu <- convergiu
  linha$inferencia_valida <- convergiu && ep_finitos && gradiente_finito
  linha$iteracoes <- iteracoes
  linha$mensagem <- mensagem
  return(linha)
}

AjustarRapido <- function(dados, modelo) {
  # Ajuste usado no bootstrap: devolve só as elasticidades (NA sem
  # convergência). Nos modelos de painel, a unidade é a cópia do país.
  formula <- l_y ~ l_inv + l_pd + ano_f
  dados$ano_f <- droplevels(dados$ano_f)
  s <- tryCatch(suppressWarnings(switch(
    modelo,
    painel_bc88 = frontier::sfa(
      formula, data = plm::pdata.frame(dados, index = c("unidade", "ano"))),
    painel_bc92 = frontier::sfa(
      formula, data = plm::pdata.frame(dados, index = c("unidade", "ano")),
      timeEffect = TRUE),
    frontier::sfa(formula, data = dados))),
    error = function(e) NULL)
  if (is.null(s) || s$code != 1) {
    return(c(NA_real_, NA_real_))
  }
  return(unname(stats::coef(s)[c("l_inv", "l_pd")]))
}

BootstrapPais <- function(n_boot, modelo) {
  # IC percentílico das elasticidades por reamostragem de países (blocos
  # com todos os anos do país), como no segundo estágio: a SE da hessiana
  # supõe observações independentes, e o mesmo país aparece em vários
  # anos. Os dois canais são ajustados no MESMO sorteio de países, o que dá
  # também o IC da diferença entre as elasticidades do investimento
  # (patentes - publicações), o teste da especificidade relativa de H2. Nos
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
    if (!is.numeric(r) || length(r) != 4) return(rep(NA_real_, 4))
    return(r)
  }, numeric(4))
  rownames(replicas) <- c("publicacoes.l_inv", "publicacoes.l_pd",
                          "patentes.l_inv", "patentes.l_pd")
  Resumo <- function(v, canal, termo) {
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
                      stringsAsFactors = FALSE))
  }
  return(rbind(
    Resumo(replicas["publicacoes.l_inv", ], "publicacoes", "l_inv"),
    Resumo(replicas["publicacoes.l_pd", ], "publicacoes", "l_pd"),
    Resumo(replicas["patentes.l_inv", ], "patentes", "l_inv"),
    Resumo(replicas["patentes.l_pd", ], "patentes", "l_pd"),
    Resumo(replicas["patentes.l_inv", ] - replicas["publicacoes.l_inv", ],
           "patentes - publicacoes", "l_inv")))
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
# Critério estrito (artigo/01): elasticidade do investimento significativa
# só em patentes. Especificidade relativa: elasticidade em patentes maior
# que em publicações (IC da diferença acima de zero).
Ic <- function(m, canal) {
  return(bootstrap[bootstrap$modelo == m & bootstrap$canal == canal &
                     bootstrap$termo == "l_inv", ])
}
Ponto <- function(m, canal, coluna = "elasticidade_inv") {
  return(resultados[[coluna]][resultados$modelo == m &
                                resultados$canal == canal])
}
Significativo <- function(ic) {
  # Sem IC (réplicas insuficientes) conta como não significativo.
  return(isTRUE(ic$ic_inf > 0 | ic$ic_sup < 0))
}
h2 <- do.call(rbind, lapply(modelos_boot, function(m) {
  pub <- Ic(m, "publicacoes")
  pat <- Ic(m, "patentes")
  dif <- Ic(m, "patentes - publicacoes")
  sig_pub <- Significativo(pub)
  sig_pat <- Significativo(pat)
  veredito <- if (sig_pat && !sig_pub) {
    "apoiada"
  } else if (!sig_pat && sig_pub) {
    "contrariada (efeito só em publicações)"
  } else if (!sig_pat && !sig_pub) {
    "não apoiada (sem efeito nos dois canais)"
  } else {
    "não apoiada (efeito nos dois canais)"
  }
  return(data.frame(
    modelo = m,
    n_obs_publicacoes = Ponto(m, "publicacoes", "n_obs"),
    n_obs_patentes = Ponto(m, "patentes", "n_obs"),
    inv_publicacoes = Ponto(m, "publicacoes"),
    ic_inf_publicacoes = pub$ic_inf, ic_sup_publicacoes = pub$ic_sup,
    inv_patentes = Ponto(m, "patentes"),
    ic_inf_patentes = pat$ic_inf, ic_sup_patentes = pat$ic_sup,
    diferenca = Ponto(m, "patentes") - Ponto(m, "publicacoes"),
    ic_inf_diferenca = dif$ic_inf, ic_sup_diferenca = dif$ic_sup,
    replicas_tentadas = n_boot_sfa,
    replicas_convergentes_diferenca = dif$replicas_convergentes,
    veredito_estrito = veredito,
    especificidade_relativa = isTRUE(dif$ic_inf > 0),
    stringsAsFactors = FALSE))
}))
Salvar(h2, "sfa_h2")

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
  "segundos")])))
print(Formatar(h2[, c("modelo", "inv_publicacoes", "ic_inf_publicacoes",
                      "ic_sup_publicacoes", "inv_patentes",
                      "ic_inf_patentes", "ic_sup_patentes", "diferenca",
                      "ic_inf_diferenca", "ic_sup_diferenca")]))
print(h2[, c("modelo", "veredito_estrito", "especificidade_relativa")])
RegistrarManifesto("06_sfa_canais.R", sufixo, arquivo_base, "ok")
Registrar("FIM SFA por canal")
