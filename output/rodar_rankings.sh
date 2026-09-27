#!/bin/zsh
cd /Users/fernando/Projects/ai-efficiency-analysis
run02_04() { Rscript R/02_fronteiras_dataset_atual.R > "output/log_02$SUFIXO_SAIDA.txt" 2>&1 && Rscript R/04_figuras_apresentacao.R > "output/log_04$SUFIXO_SAIDA.txt" 2>&1 && echo "$1 OK" || echo "$1 FALHOU"; }
unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST
export SUFIXO_SAIDA=""; run02_04 "RANK FASE A"
export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1
export SUFIXO_SAIDA=_painel_qualidade PRODUTOS=citacoes_ok,patentes_concedidas_ok JANELA_MALMQUIST=2017,2019; run02_04 "RANK QUALIDADE"
export SUFIXO_SAIDA=_painel_fonte PRODUTOS=publicacoes,patentes_inventor JANELA_MALMQUIST=2017,2021; run02_04 "RANK FONTE"
export SUFIXO_SAIDA=_painel_preqin INSUMOS=investimento_preqin_l1,gerd_l1 PRODUTOS=publicacoes,patentes; run02_04 "RANK PREQIN"
export SUFIXO_SAIDA=_painel_publico INSUMOS=investimento_l1,pd_publico_l1 PRODUTOS=publicacoes,patentes; run02_04 "RANK PUBLICO"
echo "RANKINGS CONCLUIDOS"
