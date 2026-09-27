#!/bin/zsh
# Reexecução completa após a análise crítica (I01, I04, I06, I08, I11-I14, I16, I17, I22).
cd /Users/fernando/Projects/ai-efficiency-analysis
rm -f output/tables/manifesto_execucoes.csv
unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST
run_chain() { Rscript R/02_fronteiras_dataset_atual.R > "output/log_02$SUFIXO_SAIDA.txt" 2>&1 && Rscript R/03_segundo_estagio_dataset_atual.R > "output/log_03$SUFIXO_SAIDA.txt" 2>&1 && Rscript R/04_figuras_apresentacao.R > "output/log_04$SUFIXO_SAIDA.txt" 2>&1 && echo "$1 OK" || echo "$1 FALHOU"; }
Rscript R/12_import_fontes_alternativas.R > output/log_12.txt 2>&1 && Rscript R/13_build_painel.R > output/log_13.txt 2>&1 && echo "12/13 OK" || echo "12/13 FALHOU"
export SUFIXO_SAIDA=""; run_chain "FASE A"
N_REP_RTS=1000 Rscript R/02b_teste_rts.R > output/log_02b.txt 2>&1 && echo "RTS A OK" || echo "RTS A FALHOU"
export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1 SUFIXO_SAIDA=_painel PRODUTOS=publicacoes,patentes JANELA_MALMQUIST=2017,2021; run_chain "PAINEL"
N_REP_RTS=1000 Rscript R/02b_teste_rts.R > output/log_02b_painel.txt 2>&1 && echo "RTS PAINEL OK" || echo "RTS PAINEL FALHOU"
export SUFIXO_SAIDA=_painel_qualidade PRODUTOS=citacoes_ok,patentes_concedidas_ok JANELA_MALMQUIST=2017,2019; run_chain "QUALIDADE"
export SUFIXO_SAIDA=_painel_fonte PRODUTOS=publicacoes,patentes_inventor JANELA_MALMQUIST=2017,2021; run_chain "FONTE"
export SUFIXO_SAIDA=_painel_preqin INSUMOS=investimento_preqin_l1,gerd_l1 PRODUTOS=publicacoes,patentes; run_chain "PREQIN"
export SUFIXO_SAIDA=_painel_publico INSUMOS=investimento_l1,pd_publico_l1 PRODUTOS=publicacoes,patentes; run_chain "PUBLICO"
unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST
Rscript R/05_comparacoes_amostra_comum.R > output/log_05.txt 2>&1 && echo "COMPARACOES OK" || echo "COMPARACOES FALHOU"
N_SIM=30 N_DMU=40 N_REP=100 Rscript R/02c_validacao_rts.R > output/log_02c.txt 2>&1 && echo "VALIDACAO RTS OK" || echo "VALIDACAO RTS FALHOU"
echo "TUDO CONCLUIDO"
