# 03_segundo_estagio_dataset_atual.R
# Fase A: segundo estágio sobre os escores do modelo M2 (dataset original).
# Testes preliminares de H5 (instituições e capacidade de absorção),
# H6 (finanças de mercado vs bancárias no canal de patentes) e
# H7 (assimetria por nível de desenvolvimento entre canais).
# Métodos: Simar-Wilson algoritmo 2 (rDEA::dea.env.robust), regressão
# truncada com bootstrap agrupado por país (truncreg), Tobit comparativo
# (AER::tobit) e Kruskal-Wallis por grupo de renda.
# Uso: Rscript R/03_segundo_estagio_dataset_atual.R (após o script 02)

source("R/00_setup.R")

n_boot_cluster <- 300   # réplicas do bootstrap agrupado por país
l1_sw <- 50             # réplicas internas do algoritmo 2 (Fase A)
l2_sw <- 500            # réplicas externas do algoritmo 2 (Fase A)
n_rep_canais <- 500     # bootstrap DEA dos canais

arquivo_base <- Sys.getenv("BASE_ARQUIVO", "data/processed/base_atual.csv")
sufixo <- Sys.getenv("SUFIXO_SAIDA", "")
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

base <- utils::read.csv(arquivo_base, stringsAsFactors = FALSE)
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
                inv_mi = .data[[insumos[1]]] / 1e6,
                gerd_mi = .data[[insumos[2]]] / 1e6,
                log_pesquisadores = log(pesquisadores_pm))
Registrar("obs. no segundo estágio:", nrow(dados),
          "| com pesquisadores:", sum(!is.na(dados$pesquisadores_pm)))

# Bootstrap dos canais (escores corrigidos > 1 para a regressão truncada) ---
BootCanal <- function(coluna_y) {
  # DMUs com produto zero no canal saem (Farrell orientado a produto
  # indefinido; o bootstrap do Benchmarking falha nesses casos).
  anos <- sort(unique(dados$ano))
  saida <- lapply(anos, function(a) {
    d <- dados[dados$ano == a & dados[[coluna_y]] > 0, ]
    boot <- BootstrapDea(as.matrix(d[, c("inv_mi", "gerd_mi")]),
                         as.matrix(d[, coluna_y, drop = FALSE]), d$id,
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
dados <- dados |>
  dplyr::inner_join(boot_pub, by = "id") |>
  dplyr::inner_join(boot_pat, by = "id")
Salvar(dados[, c("id", "pais", "ano", "grupo_renda", "escore_bc",
                       "escore_bc_pub", "escore_bc_pat")],
             "escores_bc_conjunto_e_canais")

# Regressão truncada com bootstrap agrupado por país --------------------------
AjustarTruncada <- function(formula, d, dependente = "escore") {
  # Duas parametrizações da regressão truncada:
  #   "farrell": dependente >= 1 (medida de Farrell corrigida), truncada à
  #              esquerda em 1 — a do algoritmo de Simar e Wilson (2007);
  #              coeficiente positivo = MENOS eficiente;
  #   "escore":  dependente em (0, 1] (1/Farrell), truncada à direita em 1;
  #              coeficiente positivo = MAIS eficiente. Não equivale à
  #              anterior (1/(Zb + e) não é linear com erro normal truncado)
  #              e admite, em princípio, valores negativos; é reportada como
  #              sensibilidade de escala, útil quando Farrell tem caudas
  #              extremas (canais com poucos produtos).
  if (dependente == "farrell") {
    modelo <- truncreg::truncreg(formula, data = d, point = 1,
                                 direction = "left")
  } else {
    modelo <- truncreg::truncreg(formula, data = d, point = 1,
                                 direction = "right")
  }
  return(modelo)
}

TruncadaAgrupada <- function(formula, d, rotulo, n_boot = n_boot_cluster,
                             dependente = "escore") {
  # Estimativas pontuais e IC percentílico por reamostragem de países com
  # os escores mantidos fixos (não propaga a incerteza da fronteira; o
  # algoritmo 2 de Simar-Wilson, abaixo, faz isso na fronteira agrupada).
  # A amostra é formada pelos casos completos da fórmula ANTES do ajuste e
  # da reamostragem, e n_obs/n_paises referem-se a esse quadro efetivo.
  variaveis <- all.vars(formula)
  d <- d[stats::complete.cases(d[, variaveis]), ]
  ajuste <- AjustarTruncada(formula, d, dependente)
  coefs <- stats::coef(ajuste)
  paises <- unique(d$pais)
  set.seed(semente)
  replicas <- replicate(n_boot, {
    escolhidos <- sample(paises, replace = TRUE)
    d_boot <- do.call(rbind, lapply(escolhidos, function(p) d[d$pais == p, ]))
    tryCatch({
      cb <- stats::coef(AjustarTruncada(formula, d_boot, dependente))
      cb[names(coefs)]
    }, error = function(e) rep(NA_real_, length(coefs)))
  })
  replicas <- matrix(replicas, nrow = length(coefs))
  validas <- colSums(is.na(replicas)) == 0
  replicas <- replicas[, validas, drop = FALSE]
  saida <- data.frame(
    modelo = rotulo, dependente = dependente, termo = names(coefs),
    coeficiente = as.numeric(coefs),
    ep_boot = apply(replicas, 1, stats::sd),
    ic_inf = apply(replicas, 1, stats::quantile, probs = 0.025),
    ic_sup = apply(replicas, 1, stats::quantile, probs = 0.975),
    n_obs = nrow(d), n_paises = length(paises),
    replicas_validas = sum(validas),
    inferencia = "truncada, escores fixos, bootstrap por país",
    stringsAsFactors = FALSE)
  saida$significativo_5pct <- saida$ic_inf > 0 | saida$ic_sup < 0
  return(saida)
}

TruncadaDupla <- function(formula_escore, d, rotulo) {
  # Roda as duas parametrizações: escore (0,1] e Farrell (>= 1), trocando
  # a dependente da fórmula pela coluna Farrell correspondente.
  dep <- all.vars(formula_escore)[1]
  dep_farrell <- sub("^escore", "farrell", dep)
  formula_farrell <- stats::as.formula(
    paste(dep_farrell, "~", as.character(formula_escore)[3]))
  saida <- TruncadaAgrupada(formula_escore, d, rotulo, dependente = "escore")
  farrell <- tryCatch(
    TruncadaAgrupada(formula_farrell, d, rotulo, dependente = "farrell"),
    error = function(e) NULL)
  return(rbind(saida, farrell))
}

# H5: instituições e capacidade de absorção (modelo conjunto M2) --------------
# Nota: a variável dependente é a eficiência corrigida em (0, 1]: um
# coeficiente positivo indica MAIOR eficiência.
formula_h5 <- escore_bc ~ efetividade_governo + alta_tec_export +
  log_comercio + market_cap + credito_privado + ano_f
h5 <- TruncadaDupla(formula_h5, dados, "H5 truncada (M2)")
formula_h5b <- escore_bc ~ efetividade_governo + alta_tec_export +
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
  formula_h5c <- escore_bc ~ efetividade_governo + alta_tec_export +
    log_comercio + log_talento + ano_f
  h5c <- TruncadaAgrupada(formula_h5c, dados_tal,
                          paste("H5 truncada com talento em IA (média por",
                                "gênero, subamostra)"))
}

# Tobit comparativo (escore em (0, 1], censurado à direita em 1) ---------------
tobit_h5 <- AER::tobit(escore_bc ~ efetividade_governo + alta_tec_export +
                         log_comercio + market_cap + credito_privado + ano_f,
                       right = 1, data = dados)
tob <- summary(tobit_h5)$coefficients
tobit_tab <- data.frame(modelo = "H5 Tobit (escore_bc, M2)",
                        termo = rownames(tob), coeficiente = tob[, 1],
                        ep = tob[, 2], p_valor = tob[, 4],
                        stringsAsFactors = FALSE)

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
RodarComTempoMaximo <- function(expressao, segundos) {
  # Avalia `expressao` em processo filho (fork); devolve NULL se estourar.
  tarefa <- parallel::mcparallel(expressao)
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
sw <- tryCatch(
  RodarComTempoMaximo(
    rDEA::dea.env.robust(X = as.matrix(dados_sw[, c("inv_mi", "gerd_mi")]),
                         Y = as.matrix(dados_sw[, produtos]),
                         Z = z_sw, model = "output", RTS = "variable",
                         L1 = l1_sw, L2 = l2_sw, alpha = 0.05),
    limite_sw_seg),
  error = function(e) {
    Registrar("dea.env.robust não concluído:", conditionMessage(e))
    return(NULL)
  })
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
  sw_tab$fronteira <- "agrupada, casos completos de contexto"
  Salvar(sw_tab, "segundo_estagio_simar_wilson_m2")
  print(sw_tab)
}

# H6: finanças no canal de patentes -------------------------------------------
formula_h6 <- escore_bc_pat ~ market_cap + credito_privado + npl +
  efetividade_governo + ano_f
h6 <- TruncadaDupla(formula_h6, dados, "H6 truncada (canal patentes)")
formula_h6_pub <- escore_bc_pub ~ market_cap + credito_privado + npl +
  efetividade_governo + ano_f
h6_pub <- TruncadaAgrupada(formula_h6_pub, dados,
                           "H6 contraste (canal publicações)")

# H7: PIB per capita por canal -------------------------------------------------
formula_h7_pat <- escore_bc_pat ~ log_pib_pc + alta_tec_export +
  log_comercio + ano_f
formula_h7_pub <- escore_bc_pub ~ log_pib_pc + alta_tec_export +
  log_comercio + ano_f
h7_pat <- TruncadaDupla(formula_h7_pat, dados, "H7 canal patentes")
h7_pub <- TruncadaDupla(formula_h7_pub, dados, "H7 canal publicações")

# H5 sem valores-piso do investimento (fronteiras reestimadas no script 02)
boot_sp <- LerSaida("boot_ano_m2_sem_piso")
dados_sp <- base |>
  dplyr::inner_join(dplyr::select(boot_sp, id, escore_bc), by = "id") |>
  dplyr::mutate(ano_f = factor(ano))
h5_sp <- TruncadaAgrupada(formula_h5, dados_sp,
                          "H5 truncada sem valores-piso (M2)")

segundo_estagio <- rbind(h5, h5_sp, h5b, h5c, h6, h6_pub, h7_pat, h7_pub)
Salvar(segundo_estagio, "segundo_estagio_truncada")
Salvar(tobit_tab, "segundo_estagio_tobit")
print(segundo_estagio[!grepl("^ano_f", segundo_estagio$termo),
                      c("modelo", "termo", "coeficiente", "ic_inf", "ic_sup",
                        "significativo_5pct")])

# Testes não paramétricos por grupo de renda -----------------------------------
TesteGrupos <- function(variavel, rotulo) {
  # Testes em país-ano (linhas repetidas por país) e, como sensibilidade,
  # em médias por país (uma linha por país).
  kw <- stats::kruskal.test(dados[[variavel]], factor(dados$grupo_renda))
  mw <- stats::wilcox.test(dados[[variavel]] ~ dados$grupo_renda2)
  por_pais <- dados |>
    dplyr::group_by(pais, grupo_renda2) |>
    dplyr::summarise(v = mean(.data[[variavel]]), .groups = "drop")
  mw_pais <- stats::wilcox.test(v ~ grupo_renda2, data = por_pais)
  medias <- tapply(dados[[variavel]], dados$grupo_renda, mean)
  Media <- function(g) if (g %in% names(medias)) medias[[g]] else NA_real_
  saida <- data.frame(escore = rotulo, p_kruskal = kw$p.value,
                      p_mann_whitney = mw$p.value,
                      p_mann_whitney_medias_pais = mw_pais$p.value,
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
