#!/bin/zsh
cd /Users/fernando/Projects/ai-efficiency-analysis
unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST
N_SIM=30 N_DMU=40 N_REP=100 Rscript R/02c_validacao_rts.R > output/log_02c.txt 2>&1 && echo "VALIDACAO RTS OK" || echo "VALIDACAO RTS FALHOU"
N_REP_RTS=1000 Rscript R/02b_teste_rts.R > output/log_02b.txt 2>&1 && echo "RTS A OK" || echo "RTS A FALHOU"
export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1 SUFIXO_SAIDA=_painel PRODUTOS=publicacoes,patentes JANELA_MALMQUIST=2017,2021
N_REP_RTS=1000 Rscript R/02b_teste_rts.R > output/log_02b_painel.txt 2>&1 && echo "RTS PAINEL OK" || echo "RTS PAINEL FALHOU"
Rscript R/02_fronteiras_dataset_atual.R > output/log_02_painel.txt 2>&1 && Rscript R/03_segundo_estagio_dataset_atual.R > output/log_03_painel.txt 2>&1 && Rscript R/04_figuras_apresentacao.R > output/log_04_painel.txt 2>&1 && echo "PAINEL OK" || echo "PAINEL FALHOU"
unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST
Rscript R/05_comparacoes_amostra_comum.R > output/log_05.txt 2>&1 && echo "COMPARACOES OK" || echo "COMPARACOES FALHOU"
echo "RESTANTE CONCLUIDO"
