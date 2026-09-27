#!/bin/zsh
# Executa as três cadeias em sequência: Fase A, Fase B e variante de qualidade.
cd /Users/fernando/Projects/ai-efficiency-analysis
run_chain() {
  local rotulo=$1
  Rscript R/02_fronteiras_dataset_atual.R > "output/log_02$SUFIXO_SAIDA.txt" 2>&1 &&
  Rscript R/03_segundo_estagio_dataset_atual.R > "output/log_03$SUFIXO_SAIDA.txt" 2>&1 &&
  Rscript R/04_figuras_apresentacao.R > "output/log_04$SUFIXO_SAIDA.txt" 2>&1 &&
  echo "$rotulo OK" || echo "$rotulo FALHOU"
}
unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST
export SUFIXO_SAIDA=""; run_chain "FASE A"
export BASE_ARQUIVO=data/processed/painel_ia.csv SUFIXO_SAIDA=_painel INSUMOS=investimento_l1,gerd_l1 JANELA_MALMQUIST=2017,2021
run_chain "FASE B"
export SUFIXO_SAIDA=_painel_qualidade PRODUTOS=citacoes_ok,patentes_concedidas_ok JANELA_MALMQUIST=2017,2019
run_chain "QUALIDADE"
echo "CADEIAS CONCLUIDAS"
