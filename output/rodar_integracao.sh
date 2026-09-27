#!/bin/zsh
cd /Users/fernando/Projects/ai-efficiency-analysis
Rscript R/12_import_fontes_alternativas.R > output/log_12.txt 2>&1 && Rscript R/13_build_painel.R > output/log_13.txt 2>&1 || { echo "12/13 FALHOU"; exit 1; }
export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1
export SUFIXO_SAIDA=_painel PRODUTOS=publicacoes,patentes JANELA_MALMQUIST=2017,2021
Rscript R/03_segundo_estagio_dataset_atual.R > output/log_03_painel.txt 2>&1 && Rscript R/04_figuras_apresentacao.R > output/log_04_painel.txt 2>&1 && echo "PAINEL OK" || echo "PAINEL FALHOU"
export SUFIXO_SAIDA=_painel_qualidade PRODUTOS=citacoes_ok,patentes_concedidas_ok JANELA_MALMQUIST=2017,2019
Rscript R/03_segundo_estagio_dataset_atual.R > output/log_03_painel_qualidade.txt 2>&1 && Rscript R/04_figuras_apresentacao.R > output/log_04_painel_qualidade.txt 2>&1 && echo "QUALIDADE OK" || echo "QUALIDADE FALHOU"
echo "INTEGRACAO CONCLUIDA"
