#!/bin/zsh
cd /Users/fernando/Projects/ai-efficiency-analysis
export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1 SUFIXO_SAIDA=_painel_fonte PRODUTOS=publicacoes,patentes_inventor JANELA_MALMQUIST=2017,2021
Rscript R/02_fronteiras_dataset_atual.R > output/log_02_painel_fonte.txt 2>&1 && Rscript R/03_segundo_estagio_dataset_atual.R > output/log_03_painel_fonte.txt 2>&1 && Rscript R/04_figuras_apresentacao.R > output/log_04_painel_fonte.txt 2>&1 && echo "FONTE OK" || echo "FONTE FALHOU"
echo "FONTE CONCLUIDO"
