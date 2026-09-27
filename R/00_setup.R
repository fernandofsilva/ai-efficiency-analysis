# 00_setup.R
# Configuração comum a todos os scripts: pacotes, opções, pastas, semente.
# Uso: source("R/00_setup.R") no início de cada script de análise.

pacotes_necessarios <- c(
  "Benchmarking", "rDEA", "nonparaeff", "frontiles", "truncreg", "AER",
  "frontier", "sfaR", "npsf", "countrycode", "dplyr", "tidyr", "ggplot2",
  "curl", "jsonlite", "readxl", "boot", "lpSolveAPI", "ggrepel")
faltantes <- setdiff(pacotes_necessarios,
                     rownames(utils::installed.packages()))
if (length(faltantes) > 0) {
  utils::install.packages(faltantes, repos = "https://cloud.r-project.org")
}

# frontiles depende de rgl; sem dispositivo gráfico usamos o modo nulo.
options(rgl.useNULL = TRUE, scipen = 999, width = 100,
        stringsAsFactors = FALSE)

semente <- 2026
set.seed(semente)

pastas <- c("output/figures", "output/tables", "data/wdi", "data/wgi",
            "data/processed")
for (pasta in pastas) {
  dir.create(pasta, showWarnings = FALSE, recursive = TRUE)
}

source("R/funcoes.R")
