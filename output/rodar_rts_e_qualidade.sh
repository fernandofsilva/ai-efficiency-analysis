#!/bin/zsh
cd /Users/fernando/Projects/ai-efficiency-analysis
unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST
# Teste de RTS no dataset original (Fase A)
N_REP_RTS=1000 Rscript R/02b_teste_rts.R > output/log_02b.txt 2>&1 && echo "RTS FASE A OK" || echo "RTS FASE A FALHOU"
# Segundo estágio e figuras da variante de qualidade (com limite no rDEA)
export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1
export SUFIXO_SAIDA=_painel_qualidade PRODUTOS=citacoes_ok,patentes_concedidas_ok JANELA_MALMQUIST=2017,2019
Rscript R/03_segundo_estagio_dataset_atual.R > output/log_03_painel_qualidade.txt 2>&1 && Rscript R/04_figuras_apresentacao.R > output/log_04_painel_qualidade.txt 2>&1 && echo "QUALIDADE OK" || echo "QUALIDADE FALHOU"
# Teste de RTS no painel reconstruído (Fase B)
export SUFIXO_SAIDA=_painel PRODUTOS=publicacoes,patentes
N_REP_RTS=1000 Rscript R/02b_teste_rts.R > output/log_02b_painel.txt 2>&1 && echo "RTS PAINEL OK" || echo "RTS PAINEL FALHOU"
echo "RTS E QUALIDADE CONCLUIDOS"
