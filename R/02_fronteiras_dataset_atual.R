# 02_fronteiras_dataset_atual.R
# Fase A: fronteiras de eficiência no dataset original (2013-2021).
# Modelos:
#   M1 (replicação de Ernst e Mishra): insumo = investimento privado em IA;
#   M2 (base): insumos = investimento privado em IA e GERD;
#   produtos = publicações e pedidos de patente (contagens);
#   canais: publicações (acadêmico) e patentes (tecnológico), insumos de M2.
# Etapas: outliers, DEA CRS/VRS/NIRS por ano, eficiência de escala e RTS,
# teste de RTS com bootstrap, bootstrap de Simar-Wilson, FDH, order-m,
# order-alfa, canais, metafronteira por renda e Malmquist.
# Uso: Rscript R/02_fronteiras_dataset_atual.R

source("R/00_setup.R")

n_rep_boot <- 1000   # réplicas do bootstrap DEA (Fase A; artigo usa 2000)

# Parâmetros por variáveis de ambiente (permitem rodar o mesmo pipeline no
# painel reconstruído da Fase B):
#   BASE_ARQUIVO: caminho da base (padrão: dataset original preparado);
#   SUFIXO_SAIDA: sufixo dos arquivos de saída (padrão: "");
#   INSUMOS: duas colunas de insumo, separadas por vírgula (padrão:
#            investimento,gerd; Fase B usa investimento_l1,gerd_l1);
#   PRODUTOS: duas colunas de produto (padrão: publicacoes,patentes; a
#             variante de qualidade usa citacoes_ok,patentes_concedidas_ok);
#   JANELA_MALMQUIST: primeiro e último ano do painel balanceado;
#   PADRONIZACAO, EPSILON_PADRONIZACAO: padronização das variáveis da
#            fronteira (ver ConfigurarPadronizacao em R/funcoes.R); com
#            "minmax", o sufixo das saídas ganha "_minmax".
arquivo_base <- Sys.getenv("BASE_ARQUIVO", "data/processed/base_atual.csv")
padronizacao <- ConfigurarPadronizacao()
sufixo <- paste0(Sys.getenv("SUFIXO_SAIDA", ""), padronizacao$sufixo)
insumos <- strsplit(Sys.getenv("INSUMOS", "investimento,gerd"), ",")[[1]]
produtos <- strsplit(Sys.getenv("PRODUTOS", "publicacoes,patentes"), ",")[[1]]
janela_env <- as.integer(strsplit(Sys.getenv("JANELA_MALMQUIST", "2016,2019"),
                                  ",")[[1]])
janela <- janela_env[1]:janela_env[2]
Salvar <- function(dados, nome) {
  return(SalvarTabela(dados, paste0(nome, sufixo)))
}

base <- utils::read.csv(arquivo_base, stringsAsFactors = FALSE)
base$grupo_renda2 <- ifelse(base$grupo_renda == "Alta renda",
                            "Alta renda", "Renda média")

# Amostra: observações completas nos insumos e produtos escolhidos, com o
# insumo de investimento positivo (insumo zero inviabiliza CRS) --------------
completas <- stats::complete.cases(base[, c(insumos, produtos)])
amostra <- base[completas & base[[insumos[1]]] > 0, ]
# Padronização das variáveis da fronteira: parâmetros calculados uma única
# vez nas observações completas (incluindo investimento zero) e usados em
# todas as fronteiras desta execução. A seleção de amostra (investimento
# positivo, produto positivo nos canais, valores-piso) usa sempre as
# unidades originais.
parametros_pad <- ParametrosPadronizacao(base[completas, ],
                                         c(insumos, produtos), padronizacao)
if (!is.null(parametros_pad)) {
  Salvar(parametros_pad, "padronizacao_parametros")
  Registrar("padronização", padronizacao$metodo, "| epsilon",
            padronizacao$epsilon, "| referência:",
            parametros_pad$n_referencia[1], "obs.")
}
amostra$inv_mi <- amostra[[insumos[1]]] / 1e6   # milhões de US$ 2021
amostra$gerd_mi <- amostra[[insumos[2]]] / 1e6  # milhões de US$ 2015
# Marca de piso construída SEMPRE a partir do insumo efetivamente usado
# (ex.: investimento defasado, ou Preqin), com o mesmo limite de 2,5 M US$
# (duas unidades da granularidade de 1 milhão do CSET; a Preqin também
# publica valores em milhões inteiros). A marca vinda da base, se houver,
# fica como proveniência em inv_piso_base.
amostra$inv_piso_base <- if ("inv_piso" %in% names(amostra)) {
  amostra$inv_piso
} else NA
amostra$inv_piso <- amostra$inv_mi > 0 & amostra$inv_mi <= 2.5
Registrar("valores-piso no insumo usado (<= 2,5 M):", sum(amostra$inv_piso))
Registrar("amostra (insumos", paste(insumos, collapse = "+"), "):",
          nrow(amostra), "obs.,",
          length(unique(amostra$pais)), "países")

MatrizesModelo <- function(dados, modelo, canal = "conjunto") {
  # Devolve as matrizes X e Y de um modelo e canal: insumos em milhões de
  # US$ e produtos em contagem, ou padronizados (parametros_pad).
  x <- switch(modelo,
              M1 = MatrizFronteira(dados, insumos[1], parametros_pad, 1e6),
              M2 = MatrizFronteira(dados, insumos, parametros_pad, 1e6))
  y <- switch(canal,
              conjunto = MatrizFronteira(dados, produtos, parametros_pad),
              publicacoes = MatrizFronteira(dados, produtos[1],
                                            parametros_pad),
              patentes = MatrizFronteira(dados, produtos[2], parametros_pad))
  return(list(x = x, y = y))
}

# 1. Outliers (amostra agrupada, M2) ------------------------------------------
m2 <- MatrizesModelo(amostra, "M2")
outliers <- Benchmarking::outlier.ap(m2$x, m2$y, NDEL = 3)
Registrar("outlier.ap: componentes", paste(names(outliers), collapse = ", "))
razoes <- outliers$ratio
if (!is.null(razoes)) {
  tabela_outliers <- data.frame(
    n_removidos = rep(seq_len(ncol(razoes)), each = nrow(razoes)),
    ordem = rep(seq_len(nrow(razoes)), times = ncol(razoes)),
    razao = as.numeric(razoes))
  Salvar(tabela_outliers, "outliers_ap_m2")
}
super_ef <- Benchmarking::sdea(m2$x, m2$y, RTS = "vrs", ORIENTATION = "out")
tabela_super <- data.frame(id = amostra$id, pais = amostra$pais,
                           ano = amostra$ano,
                           farrell_super = as.numeric(
                             Benchmarking::eff(super_ef)))
# LPs inviáveis (orientação a produto sob VRS) devolvem valores não finitos.
tabela_super$farrell_super[!is.finite(tabela_super$farrell_super)] <- NA
tabela_super <- tabela_super[order(tabela_super$farrell_super), ]
tabela_super <- dplyr::left_join(
  tabela_super, amostra[, c("id", "inv_mi", "inv_piso")], by = "id")
tabela_super$supereficiente <- is.finite(tabela_super$farrell_super) &
  tabela_super$farrell_super < 1
Salvar(tabela_super, "supereficiencia_m2_pooled")
cruzamento_super <- as.data.frame(table(
  supereficiente = tabela_super$supereficiente,
  no_piso = tabela_super$inv_piso))
Salvar(cruzamento_super, "supereficiencia_cruzada_piso")
Registrar("supereficientes:", sum(tabela_super$supereficiente),
          "| destes no piso:",
          sum(tabela_super$supereficiente & tabela_super$inv_piso))
Registrar("supereficientes (F < 1) no pooled M2:",
          sum(tabela_super$farrell_super < 1, na.rm = TRUE))
print(utils::head(tabela_super, 10))

# 2. DEA por ano: CRS, VRS, NIRS, eficiência de escala, RTS -------------------
anos <- sort(unique(amostra$ano))

DeaPorAno <- function(modelo, canal = "conjunto", dados_base = amostra) {
  # Nos modelos por canal, DMUs com produto igual a zero saem: a expansão
  # radial de um produto nulo é indefinida (Farrell infinito).
  if (canal != "conjunto") {
    coluna <- if (canal == "publicacoes") produtos[1] else produtos[2]
    dados_base <- dados_base[dados_base[[coluna]] > 0, ]
  }
  saida <- lapply(anos, function(a) {
    dados <- dados_base[dados_base$ano == a, ]
    mats <- MatrizesModelo(dados, modelo, canal)
    crs <- CalcularDea(mats$x, mats$y, dados$id, "crs")
    vrs <- CalcularDea(mats$x, mats$y, dados$id, "vrs")
    nirs <- CalcularDea(mats$x, mats$y, dados$id, "drs")
    data.frame(id = dados$id, pais = dados$pais, ano = a,
               grupo_renda = dados$grupo_renda, n_dmu = nrow(dados),
               f_crs = crs$farrell, f_vrs = vrs$farrell,
               f_nirs = nirs$farrell,
               escore_crs = crs$escore, escore_vrs = vrs$escore,
               eficiencia_escala = vrs$farrell / crs$farrell,
               rts = ClassificarRts(crs$farrell, vrs$farrell, nirs$farrell),
               folga_insumos_vrs = vrs$folga_insumos,
               folga_produtos_vrs = vrs$folga_produtos,
               stringsAsFactors = FALSE)
  })
  return(do.call(rbind, saida))
}

dea_m1 <- DeaPorAno("M1")
dea_m2 <- DeaPorAno("M2")
Salvar(dea_m1, "dea_ano_m1")
Salvar(dea_m2, "dea_ano_m2")
# Retornos de escala por país (M2): parcela de anos em cada regime e
# eficiência de escala média, para não generalizar a partir do teste
# global (ex.: a China é CRS em todos os anos).
rts_pais <- dea_m2 |>
  dplyr::group_by(pais) |>
  dplyr::summarise(anos = dplyr::n(), drs = sum(rts == "DRS"),
                   irs = sum(rts == "IRS"), crs = sum(rts == "CRS"),
                   se_media = mean(eficiencia_escala),
                   escore_vrs_medio = mean(escore_vrs), .groups = "drop") |>
  dplyr::arrange(dplyr::desc(escore_vrs_medio))
Salvar(rts_pais, "rts_por_pais_m2")

ResumoDea <- function(tab, rotulo) {
  resumo <- tab |>
    dplyr::group_by(ano) |>
    dplyr::summarise(n = dplyr::n(),
                     media_vrs = mean(escore_vrs),
                     eficientes_vrs = sum(escore_vrs > 0.999),
                     media_crs = mean(escore_crs),
                     media_se = mean(eficiencia_escala),
                     drs = sum(rts == "DRS"), irs = sum(rts == "IRS"),
                     crs = sum(rts == "CRS"), .groups = "drop")
  resumo$modelo <- rotulo
  return(resumo)
}
resumo_dea <- rbind(ResumoDea(dea_m1, "M1"), ResumoDea(dea_m2, "M2"))
Salvar(resumo_dea, "dea_resumo_por_ano")
print(as.data.frame(resumo_dea))

# 3. Teste de retornos de escala (Simar-Wilson 2002) --------------------------
# Rodado em separado (R/02b_teste_rts.R) por ser demorado; resultado em
# output/tables/teste_rts.csv.

# 4. Bootstrap de Simar-Wilson por ano (VRS) ---------------------------------
replicas_boot <- list()   # réplicas Farrell por ano (para o ranking)
BootPorAno <- function(modelo, n_rep, canal = "conjunto",
                       dados_base = amostra, guardar = FALSE) {
  saida <- lapply(anos, function(a) {
    dados <- dados_base[dados_base$ano == a, ]
    mats <- MatrizesModelo(dados, modelo, canal)
    boot <- BootstrapDea(mats$x, mats$y, dados$id, "vrs", n_rep = n_rep)
    if (guardar) {
      rep <- attr(boot, "replicas")
      rownames(rep) <- dados$id
      replicas_boot[[as.character(a)]] <<- rep
    }
    boot$pais <- dados$pais
    boot$ano <- a
    boot$grupo_renda <- dados$grupo_renda
    return(boot)
  })
  return(do.call(rbind, saida))
}

RankingComBootstrap <- function(boot_tab, replicas, n_base = 5) {
  # Ranking por país com incerteza de bootstrap, a partir das réplicas de
  # dea.boot por ano. Construção:
  #   1. pseudo-valor de Simar e Wilson (1998) por unidade e réplica, na
  #      escala de Farrell: F~ = 2 F^ - F*, com F* a réplica (observação
  #      original avaliada contra a pseudofronteira); o intervalo básico de
  #      Simar-Wilson é o intervalo percentílico dos pseudo-valores. F~ é
  #      limitado abaixo em 1 (réplicas raras com F* > F^);
  #   2. escore pseudo-replicado 1/F~ em (0, 1] e média sobre os anos do
  #      país, réplica a réplica: as réplicas são PAREADAS pelo índice
  #      dentro de cada ano (mesma pseudofronteira para todas as unidades
  #      do ano, o que preserva a dependência entre unidades) e
  #      independentes entre anos;
  #   3. ponto = média das pseudo-réplicas (escore corrigido de viés na
  #      escala da média anual); IC 95% = quantis 2,5% e 97,5% dessas
  #      médias; a média dos escores anuais corrigidos (1/F_bc) é guardada
  #      para rastreabilidade;
  #   4. incerteza de postos: posto do país em cada réplica (quantis);
  #   5. contrastes pareados entre os n_base países da base do ranking e
  #      cada um dos demais (diferença das médias pseudo-replicadas), com
  #      IC percentílico; "separado" quando o IC exclui zero.
  # Limitações declaradas: os pseudo-valores condicionam-se às fronteiras
  # anuais estimadas; anos diferentes por país não são estritamente
  # comparáveis; a cobertura da agregação temporal não foi validada.
  paises <- unique(boot_tab$pais)
  n_rep <- ncol(replicas[[1]])
  matriz <- matrix(NA_real_, nrow = length(paises), ncol = n_rep,
                   dimnames = list(paises, NULL))
  media_anual_bc <- stats::setNames(numeric(length(paises)), paises)
  for (p in paises) {
    linhas_p <- which(boot_tab$pais == p)
    pseudo <- lapply(linhas_p, function(k) {
      rep_k <- replicas[[as.character(boot_tab$ano[k])]][boot_tab$id[k], ]
      f_til <- pmax(2 * boot_tab$farrell[k] - rep_k, 1)
      1 / f_til
    })
    matriz[p, ] <- Reduce(`+`, pseudo) / length(linhas_p)
    media_anual_bc[p] <- mean(boot_tab$escore_bc[linhas_p])
  }
  # Réplicas com LP falho em algum ano do país ficam NA e são ignoradas.
  ponto <- rowMeans(matriz, na.rm = TRUE)
  ic <- t(apply(matriz, 1, stats::quantile, probs = c(0.025, 0.975),
                na.rm = TRUE))
  postos <- apply(-matriz, 2, rank, na.last = "keep")
  posto_ic <- t(apply(postos, 1, stats::quantile, probs = c(0.025, 0.975),
                      na.rm = TRUE))
  info <- boot_tab[!duplicated(boot_tab$pais), c("pais", "grupo_renda")]
  saida <- data.frame(
    pais = paises,
    grupo_renda = info$grupo_renda[match(paises, info$pais)],
    n_anos = as.numeric(table(boot_tab$pais)[paises]),
    escore = as.numeric(tapply(boot_tab$escore, boot_tab$pais, mean)[paises]),
    escore_bc = as.numeric(ponto),
    escore_bc_media_anual = as.numeric(media_anual_bc),
    ic_inf = ic[, 1], ic_sup = ic[, 2],
    posto = rank(-ponto),
    posto_ic_inf = posto_ic[, 1], posto_ic_sup = posto_ic[, 2],
    replicas_validas = rowSums(is.finite(matriz)),
    stringsAsFactors = FALSE)
  saida <- saida[order(-saida$escore_bc), ]
  rownames(saida) <- NULL
  base_rank <- utils::tail(saida$pais, n_base)
  contrastes <- do.call(rbind, lapply(base_rank, function(b) {
    outros <- setdiff(paises, b)
    difs <- matriz[outros, , drop = FALSE] -
      matrix(matriz[b, ], nrow = length(outros), ncol = n_rep, byrow = TRUE)
    q <- t(apply(difs, 1, stats::quantile, probs = c(0.025, 0.975),
                 na.rm = TRUE))
    data.frame(pais_base = b, pais = outros,
               dif_pontual = as.numeric(ponto[outros] - ponto[b]),
               dif_ic_inf = q[, 1], dif_ic_sup = q[, 2],
               separado = q[, 1] > 0, stringsAsFactors = FALSE)
  }))
  rownames(contrastes) <- NULL
  attr(saida, "contrastes") <- contrastes
  return(saida)
}
Registrar("bootstrap M2 por ano...")
boot_m2 <- BootPorAno("M2", n_rep_boot, guardar = TRUE)
Salvar(boot_m2, "boot_ano_m2")
ranking_boot <- RankingComBootstrap(boot_m2, replicas_boot)
Salvar(ranking_boot, "ranking_paises_boot")
contrastes_boot <- attr(ranking_boot, "contrastes")
Salvar(contrastes_boot, "ranking_contrastes_base")
resumo_contrastes <- contrastes_boot |>
  dplyr::group_by(pais_base) |>
  dplyr::summarise(n_separados = sum(separado), n_comparados = dplyr::n(),
                   .groups = "drop")
Salvar(resumo_contrastes, "ranking_contrastes_resumo")
Registrar("pontos fora do próprio IC:",
          sum(ranking_boot$escore_bc < ranking_boot$ic_inf |
                ranking_boot$escore_bc > ranking_boot$ic_sup))
print(as.data.frame(resumo_contrastes))
Registrar("bootstrap M1 por ano...")
boot_m1 <- BootPorAno("M1", n_rep_boot / 2)
Salvar(boot_m1, "boot_ano_m1")

# 5. Fronteiras robustas por ano (M2): FDH, order-m, order-alfa --------------
ExtrairSaida <- function(res) {
  # Extrai o vetor de escores orientado a produto de objetos de nonparaeff
  # ou frontiles, cujas estruturas de retorno diferem.
  if (is.data.frame(res) && "eff" %in% names(res)) {
    return(as.numeric(res$eff))
  }
  if (is.list(res) && !is.null(res$output)) {
    return(as.numeric(res$output))
  }
  return(as.numeric(res))
}

RobustasPorAno <- function(modelo) {
  saida <- lapply(anos, function(a) {
    dados <- amostra[amostra$ano == a, ]
    mats <- MatrizesModelo(dados, modelo)
    m_ordem <- max(5, round(0.4 * nrow(dados)))
    base_np <- data.frame(mats$y, mats$x)   # nonparaeff: produtos primeiro
    fdh <- ExtrairSaida(nonparaeff::fdh(base_np, noutput = ncol(mats$y),
                                        orientation = 2))
    orderm <- ExtrairSaida(frontiles::ordermscore(mats$x, mats$y,
                                                  m = m_ordem))
    alpha <- ExtrairSaida(frontiles::alphascore(mats$x, mats$y,
                                                alpha = 0.95))
    data.frame(id = dados$id, pais = dados$pais, ano = a, m = m_ordem,
               fdh = fdh, orderm = orderm, orderalfa = alpha,
               stringsAsFactors = FALSE)
  })
  return(do.call(rbind, saida))
}
robustas_m2 <- RobustasPorAno("M2")
Registrar("faixas: fdh", paste(range(robustas_m2$fdh), collapse = "-"),
          "| orderm", paste(round(range(robustas_m2$orderm), 3),
                            collapse = "-"),
          "| orderalfa", paste(round(range(robustas_m2$orderalfa), 3),
                               collapse = "-"))
Salvar(robustas_m2, "robustas_ano_m2")

# Correlações entre estimadores (R1) ------------------------------------------
comp <- dea_m2 |>
  dplyr::select(id, pais, escore_vrs, escore_crs) |>
  dplyr::inner_join(dplyr::select(boot_m2, id, escore_bc), by = "id") |>
  dplyr::inner_join(dplyr::select(robustas_m2, id, fdh, orderm, orderalfa),
                    by = "id") |>
  dplyr::inner_join(dplyr::select(dea_m1, id, escore_vrs_m1 = escore_vrs),
                    by = "id")
pares <- list(c("escore_vrs", "escore_bc"), c("escore_vrs", "orderm"),
              c("escore_vrs", "orderalfa"), c("escore_vrs", "fdh"),
              c("escore_vrs", "escore_vrs_m1"), c("orderm", "orderalfa"))
cor_estimadores <- do.call(rbind, lapply(pares, function(p) {
  # O FDH do nonparaeff é medida de Farrell (>= 1 = ineficiente) e é
  # invertido; os escores do frontiles (order-m e order-alfa) já vêm na
  # escala "<= 1 = ineficiente, > 1 = supereficiente" (verificado com dados
  # sintéticos) e entram sem inversão.
  a <- comp[[p[1]]]
  b <- comp[[p[2]]]
  if (p[2] == "fdh") b <- 1 / b
  if (p[1] == "fdh") a <- 1 / a
  r <- SpearmanComIc(a, b, grupo = comp$pais)
  data.frame(a = p[1], b = p[2], rho = r["rho"], ic_inf = r["ic_inf"],
             ic_sup = r["ic_sup"], n = r["n"], n_paises = r["n_blocos"])
}))
Salvar(cor_estimadores, "spearman_estimadores_m2")
print(cor_estimadores)

# 6. Canais (insumos de M2): publicações vs patentes --------------------------
canal_pub <- DeaPorAno("M2", "publicacoes")
canal_pat <- DeaPorAno("M2", "patentes")
canais <- dplyr::inner_join(
  dplyr::select(canal_pub, id, pais, ano, grupo_renda,
                escore_pub = escore_vrs, se_pub = eficiencia_escala),
  dplyr::select(canal_pat, id, escore_pat = escore_vrs,
                se_pat = eficiencia_escala), by = "id")
Salvar(canais, "canais_ano_m2")
rho_canais <- SpearmanComIc(canais$escore_pub, canais$escore_pat,
                            grupo = canais$pais, limiar = 0.5)
Registrar("Spearman entre canais:", paste(round(rho_canais, 3),
                                          collapse = " "))
Salvar(as.data.frame(t(rho_canais)), "spearman_canais")

# 7. Metafronteira por grupo de renda (pooled, M2, VRS) -----------------------
meta <- CalcularDea(m2$x, m2$y, amostra$id, "vrs")
grupo_escore <- rep(NA_real_, nrow(amostra))
for (g in unique(amostra$grupo_renda2)) {
  idx <- amostra$grupo_renda2 == g
  grupo_escore[idx] <- CalcularDea(m2$x[idx, , drop = FALSE],
                                   m2$y[idx, , drop = FALSE],
                                   amostra$id[idx], "vrs")$escore
}
metafronteira <- data.frame(id = amostra$id, pais = amostra$pais,
                            ano = amostra$ano, grupo = amostra$grupo_renda2,
                            escore_meta = meta$escore,
                            escore_grupo = grupo_escore,
                            tgr = meta$escore / grupo_escore)
Salvar(metafronteira, "metafronteira_renda_m2")
resumo_tgr <- metafronteira |>
  dplyr::group_by(grupo) |>
  dplyr::summarise(n = dplyr::n(), tgr_media = mean(tgr),
                   tgr_mediana = stats::median(tgr),
                   escore_meta_medio = mean(escore_meta),
                   escore_grupo_medio = mean(escore_grupo), .groups = "drop")
# H3b: a distribuição do TGR do grupo de renda média está deslocada para
# baixo em relação à da alta renda. Dois alvos, cada um com seu teste:
#   (i) deslocamento de distribuição (postos): Mann-Whitney unilateral em
#       país-ano e em médias por país;
#   (ii) diferença de TGR MÉDIO (renda média - alta renda): IC 95% por
#        bootstrap em blocos de país.
# Ambos condicionam-se às fronteiras estimadas (dependência entre TGRs
# pela fronteira compartilhada não modelada). A comparação entre grupos
# substitui "TGR < 1" por interesse substantivo, não por impossibilidade
# lógica de testar um parâmetro na fronteira do suporte.
DiferencaTgrMedia <- function(meta, n_boot = 1000) {
  Dif <- function(m) {
    return(mean(m$tgr[m$grupo == "Renda média"]) -
             mean(m$tgr[m$grupo == "Alta renda"]))
  }
  paises <- unique(meta$pais)
  set.seed(semente)
  reps <- replicate(n_boot, {
    esc <- sample(paises, replace = TRUE)
    m <- do.call(rbind, lapply(esc, function(p) meta[meta$pais == p, ]))
    if (length(unique(m$grupo)) < 2) NA_real_ else Dif(m)
  })
  return(data.frame(
    dif_tgr_media = Dif(meta),
    dif_ic_inf = unname(stats::quantile(reps, 0.025, na.rm = TRUE)),
    dif_ic_sup = unname(stats::quantile(reps, 0.975, na.rm = TRUE)),
    replicas_validas = sum(is.finite(reps)),
    inferencia = paste("bootstrap em blocos de país, condicional às",
                       "fronteiras estimadas")))
}
teste_tgr <- stats::wilcox.test(tgr ~ grupo, data = metafronteira,
                                alternative = "greater")
resumo_tgr$p_mann_whitney_unilateral <- teste_tgr$p.value
tgr_pais <- metafronteira |>
  dplyr::group_by(pais, grupo) |>
  dplyr::summarise(tgr = mean(tgr), .groups = "drop")
resumo_tgr$p_mann_whitney_medias_pais <- stats::wilcox.test(
  tgr ~ grupo, data = tgr_pais, alternative = "greater")$p.value
resumo_tgr$n_paises <- as.numeric(table(tgr_pais$grupo)[resumo_tgr$grupo])
resumo_tgr$alvo_mann_whitney <- "deslocamento de distribuição (postos)"
resumo_tgr <- cbind(resumo_tgr, DiferencaTgrMedia(metafronteira))
Salvar(resumo_tgr, "metafronteira_resumo")
print(as.data.frame(resumo_tgr))

# 8. Malmquist (CRS, orientação a produto) no painel balanceado ----------------
presentes <- amostra |>
  dplyr::filter(ano %in% janela) |>
  dplyr::count(pais) |>
  dplyr::filter(n == length(janela)) |>
  dplyr::pull(pais)
painel <- amostra |>
  dplyr::filter(pais %in% presentes, ano %in% janela) |>
  dplyr::arrange(pais, ano)
Registrar("Malmquist: países balanceados", length(presentes))
mats_p <- MatrizesModelo(painel, "M2")
malm <- Benchmarking::malmquist(mats_p$x, mats_p$y, ID = painel$pais,
                                TIME = painel$ano, RTS = "crs",
                                ORIENTATION = "out")
Registrar("malmquist: componentes", paste(names(malm), collapse = ", "))
tabela_malm <- data.frame(pais = malm$id, ano = malm$time,
                          malmquist = as.numeric(malm$m),
                          mudanca_tecnica = as.numeric(malm$tc),
                          mudanca_eficiencia = as.numeric(malm$ec))
tabela_malm <- tabela_malm[!is.na(tabela_malm$malmquist), ]
tabela_malm <- dplyr::left_join(
  tabela_malm,
  dplyr::distinct(painel, pais, grupo_renda, grupo_renda2), by = "pais")
Salvar(tabela_malm, "malmquist_m2")
resumo_malm <- tabela_malm |>
  dplyr::group_by(grupo_renda2) |>
  dplyr::summarise(n_paises = dplyr::n_distinct(pais),
                   malmquist = MediaGeometrica(malmquist),
                   mudanca_tecnica = MediaGeometrica(mudanca_tecnica),
                   mudanca_eficiencia = MediaGeometrica(mudanca_eficiencia),
                   .groups = "drop")
resumo_geral <- data.frame(
  grupo_renda2 = "Todos", n_paises = dplyr::n_distinct(tabela_malm$pais),
  malmquist = MediaGeometrica(tabela_malm$malmquist),
  mudanca_tecnica = MediaGeometrica(tabela_malm$mudanca_tecnica),
  mudanca_eficiencia = MediaGeometrica(tabela_malm$mudanca_eficiencia))
resumo_malm <- rbind(as.data.frame(resumo_malm), resumo_geral)
# Decomposição da variância de log M = log TC + log EC, com a covariância
# explícita; a "parcela de TC" usa a convenção de rateio simétrico da
# covariância (convenção contábil, não explicação causal).
lt <- log(tabela_malm$mudanca_tecnica)
le <- log(tabela_malm$mudanca_eficiencia)
decomp <- data.frame(
  var_log_m = stats::var(lt + le), var_log_tc = stats::var(lt),
  var_log_ec = stats::var(le), duas_cov = 2 * stats::cov(lt, le),
  parcela_tc_rateio_simetrico = (stats::var(lt) + stats::cov(lt, le)) /
    stats::var(lt + le),
  parcela_tc_soma_variancias = stats::var(lt) /
    (stats::var(lt) + stats::var(le)))
Salvar(decomp, "malmquist_decomposicao_variancia")
resumo_malm$parcela_tc_rateio_simetrico <- decomp$parcela_tc_rateio_simetrico
# Intervalos por reamostragem de países (blocos) das médias geométricas por
# grupo, com os índices M, TC e EC mantidos FIXOS: descrevem a variação de
# composição entre trajetórias, condicionais às fronteiras estimadas, e não
# propagam a incerteza da estimação das fronteiras (isso exigiria o
# bootstrap de Malmquist de Simar e Wilson, 1999, não implementado). O
# critério numérico de H4b (EC da renda média > 1 com este intervalo
# excluindo 1) é, portanto, descritivo, não uma confirmação inferencial.
set.seed(semente)
BootMalm <- function(tab, coluna, n_boot = 1000) {
  paises <- unique(tab$pais)
  reps <- replicate(n_boot, {
    esc <- sample(paises, replace = TRUE)
    MediaGeometrica(unlist(lapply(esc, function(p) {
      tab[[coluna]][tab$pais == p]
    })))
  })
  return(stats::quantile(reps, c(0.025, 0.975)))
}
grupos_malm <- c(unique(tabela_malm$grupo_renda2), "Todos")
ic_malm <- do.call(rbind, lapply(grupos_malm, function(g) {
    tab <- if (g == "Todos") {
      tabela_malm
    } else {
      tabela_malm[tabela_malm$grupo_renda2 == g, ]
    }
    linha <- data.frame(grupo_renda2 = g, n_paises = length(unique(tab$pais)))
    for (col in c("malmquist", "mudanca_tecnica", "mudanca_eficiencia")) {
      q <- BootMalm(tab, col)
      linha[[paste0(col, "_ic_inf")]] <- unname(q[1])
      linha[[paste0(col, "_ic_sup")]] <- unname(q[2])
    }
    linha
  }))
resumo_malm <- dplyr::left_join(resumo_malm, ic_malm,
                                by = c("grupo_renda2", "n_paises"))
resumo_malm$inferencia <- paste("reamostragem de países com índices fixos;",
                                "não propaga a incerteza das fronteiras")
Salvar(resumo_malm, "malmquist_resumo")
print(resumo_malm)
# Beta-convergência: log EC médio por país contra log da eficiência CRS do
# país no primeiro ano da janela, medida contra a MESMA fronteira do painel
# balanceado usada no Malmquist (componente e00 do primeiro par de anos:
# Farrell da unidade em t-1 contra a fronteira de t-1; ec = e11/e00 por
# construção), e não contra a DEA anual com todos os países. Inclinação
# negativa = quem estava longe se aproxima mais. Regressão MQO descritiva,
# condicional às fronteiras estimadas.
ec_pais <- tabela_malm |>
  dplyr::group_by(pais, grupo_renda2) |>
  dplyr::summarise(log_ec = mean(log(mudanca_eficiencia)), .groups = "drop")
primeiro_par <- malm$time == janela[2]
inicial <- data.frame(pais = malm$id[primeiro_par],
                      escore_crs = 1 / as.numeric(malm$e00[primeiro_par]),
                      stringsAsFactors = FALSE)
inicial <- inicial[is.finite(inicial$escore_crs), ]
beta <- dplyr::inner_join(ec_pais, inicial, by = "pais")
if (nrow(beta) >= 8) {
  modelo_beta <- stats::lm(log_ec ~ log(escore_crs), data = beta)
  cb <- summary(modelo_beta)$coefficients
  Salvar(data.frame(termo = rownames(cb), coeficiente = cb[, 1], ep = cb[, 2],
                    p_valor = cb[, 4], n_paises = nrow(beta),
                    eficiencia_inicial = paste("CRS do painel balanceado",
                                               "(e00 do Malmquist)")),
         "malmquist_beta_convergencia")
  Salvar(beta, "malmquist_beta_dados")
}
# 8b. Sensibilidade: incluir as observações com investimento zero (M2) ------
# Com dois insumos a LP orientada a produto é viável; a exclusão no modelo
# principal é por medida (zero = negócio não registrado), não por
# inviabilidade. Unidades com zero tendem a sair eficientes por construção
# e a rebaixar as demais.
zeros <- base[completas & base[[insumos[1]]] == 0, ]
if (nrow(zeros) > 0) {
  com_zeros <- rbind(amostra[, names(base)], zeros)
  com_zeros$inv_mi <- com_zeros[[insumos[1]]] / 1e6
  com_zeros$gerd_mi <- com_zeros[[insumos[2]]] / 1e6
  com_zeros$inv_piso <- com_zeros$inv_mi > 0 & com_zeros$inv_mi <= 2.5
  sens_zeros <- lapply(intersect(anos, unique(zeros$ano)), function(a) {
    d <- com_zeros[com_zeros$ano == a, ]
    mats <- MatrizesModelo(d, "M2")
    vrs <- CalcularDea(mats$x, mats$y, d$id, "vrs")
    crs <- CalcularDea(mats$x, mats$y, d$id, "crs")
    e_zero <- d[[insumos[1]]] == 0
    data.frame(ano = a, n = nrow(d), n_zeros = sum(e_zero),
               escore_vrs_zeros = mean(vrs$escore[e_zero]),
               escore_crs_zeros = mean(crs$escore[e_zero]),
               media_vrs_demais_com_zeros = mean(vrs$escore[!e_zero]),
               media_vrs_demais_sem_zeros = mean(
                 dea_m2$escore_vrs[dea_m2$ano == a]))
  })
  Salvar(do.call(rbind, sens_zeros), "sensibilidade_zeros_m2")
}

# 9. Sensibilidade: excluir valores-piso do investimento (<= 2,5 M US$) -------
# Os valores-piso (1 a 2 unidades de 1 milhão) são artefato de VC não
# registrado e tendem a definir a fronteira; refazemos M2 sem eles.
amostra_sp <- amostra[!amostra$inv_piso, ]
Registrar("amostra sem valores-piso:", nrow(amostra_sp), "obs.,",
          length(unique(amostra_sp$pais)), "países")
dea_m2_sp <- DeaPorAno("M2", dados_base = amostra_sp)
Salvar(dea_m2_sp, "dea_ano_m2_sem_piso")
boot_m2_sp <- BootPorAno("M2", n_rep_boot, dados_base = amostra_sp)
Salvar(boot_m2_sp, "boot_ano_m2_sem_piso")
canal_pub_sp <- DeaPorAno("M2", "publicacoes", amostra_sp)
canal_pat_sp <- DeaPorAno("M2", "patentes", amostra_sp)
canais_sp <- dplyr::inner_join(
  dplyr::select(canal_pub_sp, id, escore_pub = escore_vrs),
  dplyr::select(canal_pat_sp, id, escore_pat = escore_vrs), by = "id")
canais_sp <- dplyr::left_join(canais_sp,
                              dplyr::select(canal_pub_sp, id, pais), by = "id")
rho_canais_sp <- SpearmanComIc(canais_sp$escore_pub, canais_sp$escore_pat,
                               grupo = canais_sp$pais, limiar = 0.5)
Registrar("Spearman entre canais (sem piso):",
          paste(round(rho_canais_sp, 3), collapse = " "))
Salvar(as.data.frame(t(rho_canais_sp)), "spearman_canais_sem_piso")

m2_sp <- MatrizesModelo(amostra_sp, "M2")
meta_sp <- CalcularDea(m2_sp$x, m2_sp$y, amostra_sp$id, "vrs")
grupo_sp <- rep(NA_real_, nrow(amostra_sp))
for (g in unique(amostra_sp$grupo_renda2)) {
  idx <- amostra_sp$grupo_renda2 == g
  grupo_sp[idx] <- CalcularDea(m2_sp$x[idx, , drop = FALSE],
                               m2_sp$y[idx, , drop = FALSE],
                               amostra_sp$id[idx], "vrs")$escore
}
metafronteira_sp <- data.frame(id = amostra_sp$id, pais = amostra_sp$pais,
                               ano = amostra_sp$ano,
                               grupo = amostra_sp$grupo_renda2,
                               escore_meta = meta_sp$escore,
                               escore_grupo = grupo_sp,
                               tgr = meta_sp$escore / grupo_sp)
Salvar(metafronteira_sp, "metafronteira_renda_m2_sem_piso")
resumo_tgr_sp <- metafronteira_sp |>
  dplyr::group_by(grupo) |>
  dplyr::summarise(n = dplyr::n(), tgr_media = mean(tgr),
                   tgr_mediana = stats::median(tgr),
                   escore_meta_medio = mean(escore_meta),
                   escore_grupo_medio = mean(escore_grupo), .groups = "drop")
resumo_tgr_sp$p_mann_whitney_unilateral <- stats::wilcox.test(
  tgr ~ grupo, data = metafronteira_sp, alternative = "greater")$p.value
resumo_tgr_sp <- cbind(resumo_tgr_sp, DiferencaTgrMedia(metafronteira_sp))
Salvar(resumo_tgr_sp, "metafronteira_resumo_sem_piso")
print(as.data.frame(resumo_tgr_sp))

comparacao_piso <- rbind(
  data.frame(amostra = "com piso", ResumoDea(dea_m2, "M2")),
  data.frame(amostra = "sem piso", ResumoDea(dea_m2_sp, "M2")))
Salvar(comparacao_piso, "dea_resumo_com_vs_sem_piso")
RegistrarManifesto("02_fronteiras_dataset_atual.R", sufixo, arquivo_base, "ok")
Registrar("FIM fronteiras Fase A")
