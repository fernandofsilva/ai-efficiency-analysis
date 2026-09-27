#!/bin/zsh
cd /Users/fernando/Projects/ai-efficiency-analysis
unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST
Rscript R/12_import_fontes_alternativas.R > output/log_12.txt 2>&1 && Rscript R/13_build_painel.R > output/log_13.txt 2>&1 || { echo "12/13 FALHOU"; exit 1; }
export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_preqin_l1,gerd_l1 SUFIXO_SAIDA=_painel_preqin PRODUTOS=publicacoes,patentes JANELA_MALMQUIST=2017,2021
Rscript R/02_fronteiras_dataset_atual.R > output/log_02_painel_preqin.txt 2>&1 && Rscript R/03_segundo_estagio_dataset_atual.R > output/log_03_painel_preqin.txt 2>&1 && Rscript R/04_figuras_apresentacao.R > output/log_04_painel_preqin.txt 2>&1 && echo "PREQIN OK" || echo "PREQIN FALHOU"
echo "PREQIN CONCLUIDO"
