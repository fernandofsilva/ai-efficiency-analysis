# 10_download_wdi.R
# Baixa indicadores do World Bank (WDI, GFDD, WGI) para data/wdi/ e
# data/wgi/, com cache em disco. Serve às Fases A e B.
# Uso: Rscript R/10_download_wdi.R

source("R/funcoes.R")

indicadores <- c(
  populacao = "SP.POP.TOTL",
  pesquisadores_pm = "SP.POP.SCIE.RD.P6",
  pd_pct_pib = "GB.XPD.RSDV.GD.ZS",
  pib_const_2015 = "NY.GDP.MKTP.KD",
  pib_pc_const_2015 = "NY.GDP.PCAP.KD",
  pib_ppc_const = "NY.GDP.MKTP.PP.KD",
  fator_ppc = "PA.NUS.PPP",
  artigos_ct = "IP.JRN.ARTC.SC",
  matricula_terciaria = "SE.TER.ENRR",
  internet_pct = "IT.NET.USER.ZS",
  banda_larga_p100 = "IT.NET.BBND.P2",
  alta_tec_export_pct = "TX.VAL.TECH.MF.ZS",
  credito_privado_pct = "FS.AST.PRVT.GD.ZS",
  market_cap_pct = "CM.MKT.LCAP.GD.ZS",
  npl_pct = "FB.AST.NPER.ZS",
  zscore_bancos = "GFDD.SI.01",
  patentes_residentes = "IP.PAT.RESD",
  patentes_nao_resid = "IP.PAT.NRES",
  comercio_pct_pib = "NE.TRD.GNFS.ZS",
  cpi = "FP.CPI.TOTL")

BaixarComTentativas <- function(codigo, fonte = NULL, pasta = "data/wdi",
                                tentativas = 3) {
  # Tenta baixar um indicador até `tentativas` vezes; devolve n de linhas.
  for (tentativa in seq_len(tentativas)) {
    resultado <- tryCatch(
      nrow(BaixarWorldBank(codigo, fonte = fonte, pasta = pasta)),
      error = function(e) {
        Registrar("erro", codigo, "tentativa", tentativa, ":",
                  conditionMessage(e))
        return(NA_integer_)
      })
    if (!is.na(resultado)) {
      return(resultado)
    }
  }
  return(NA_integer_)
}

for (nome in names(indicadores)) {
  codigo <- indicadores[[nome]]
  linhas <- BaixarComTentativas(codigo)
  Registrar(sprintf("%-22s %-20s %5s linhas", nome, codigo, linhas))
}

# WGI: a API v2 renomeou os códigos para GOV_WGI_* (fonte 3).
codigos_wgi <- c("GOV_WGI_GE.EST", "GOV_WGI_CC.EST", "GOV_WGI_RL.EST",
                 "GOV_WGI_RQ.EST")
for (codigo in codigos_wgi) {
  linhas <- BaixarComTentativas(codigo, fonte = 3, pasta = "data/wgi")
  Registrar(sprintf("%-22s %5s linhas", codigo, linhas))
}

# Arquivo oficial do WGI como fallback.
arquivo_wgi <- "data/wgi/wgidataset.xlsx"
if (!file.exists(arquivo_wgi)) {
  tryCatch({
    curl::curl_download(
      paste0("https://www.worldbank.org/content/dam/sites/govindicators/",
             "doc/wgidataset.xlsx"),
      arquivo_wgi,
      handle = curl::new_handle(timeout = 300, useragent = "Mozilla/5.0"))
    Registrar("wgidataset.xlsx baixado:", file.size(arquivo_wgi), "bytes")
  }, error = function(e) {
    Registrar("erro ao baixar wgidataset.xlsx:", conditionMessage(e))
  })
}
Registrar("FIM downloads World Bank")
