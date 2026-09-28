#!/bin/zsh
# Executa o pipeline de análise com propagação de falhas.
# - Cada etapa grava seu status (OK/FALHA, horário) em output/status_execucao.txt.
# - Uma falha interrompe a cadeia dependente (02 -> 03 -> 04) daquela variante;
#   as demais variantes continuam; o script 05 só roda se todas as variantes do
#   painel tiverem concluído; o código de saída é o número de etapas com falha.
# - Não há modo "só rankings": o ranking sai do script 02, e o 03 e o 04 leem
#   suas saídas; rerodar o 02 exige rerodar 03 e 04 (a cadeia inteira).
# Uso: zsh output/rodar_pipeline.sh [faseA|painel|variantes|rts|validacao|tudo]
set -u
cd "$(dirname "$0")/.." || exit 1
STATUS=output/status_execucao.txt
MODO=${1:-tudo}
FALHAS=0
: > "$STATUS"
echo "$(date '+%Y-%m-%d %H:%M:%S') INICIO modo=$MODO" >> "$STATUS"

registrar() {  # estado rótulo
  echo "$(date '+%H:%M:%S') $1 $2" | tee -a "$STATUS"
}
rodar() {  # rótulo script log
  if Rscript "$2" > "$3" 2>&1; then
    registrar OK "$1"; return 0
  else
    registrar FALHA "$1 (ver $3)"; FALHAS=$((FALHAS + 1)); return 1
  fi
}
limpar_ambiente() { unset BASE_ARQUIVO SUFIXO_SAIDA INSUMOS PRODUTOS JANELA_MALMQUIST; }
cadeia() {  # rótulo (usa as variáveis de ambiente exportadas)
  local s=${SUFIXO_SAIDA:-}
  rodar "$1 02 fronteiras" R/02_fronteiras_dataset_atual.R "output/log_02$s.txt" &&
    rodar "$1 03 segundo estágio" R/03_segundo_estagio_dataset_atual.R "output/log_03$s.txt" &&
    rodar "$1 04 figuras" R/04_figuras_apresentacao.R "output/log_04$s.txt"
}
PAINEL_OK=1
fase_a() { limpar_ambiente; export SUFIXO_SAIDA=""; cadeia "FASE A" || true; }
painel_base() {
  limpar_ambiente
  export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1 \
    SUFIXO_SAIDA=_painel PRODUTOS=publicacoes,patentes JANELA_MALMQUIST=2017,2021
  cadeia "PAINEL" || PAINEL_OK=0
}
variantes() {
  limpar_ambiente
  export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1
  export SUFIXO_SAIDA=_painel_qualidade PRODUTOS=citacoes_ok,patentes_concedidas_ok JANELA_MALMQUIST=2017,2019
  cadeia "QUALIDADE" || PAINEL_OK=0
  export SUFIXO_SAIDA=_painel_fonte PRODUTOS=publicacoes,patentes_inventor JANELA_MALMQUIST=2017,2021
  cadeia "FONTE" || PAINEL_OK=0
  export SUFIXO_SAIDA=_painel_preqin INSUMOS=investimento_preqin_l1,gerd_l1 PRODUTOS=publicacoes,patentes
  cadeia "PREQIN" || PAINEL_OK=0
  export SUFIXO_SAIDA=_painel_publico INSUMOS=investimento_l1,pd_publico_l1 PRODUTOS=publicacoes,patentes
  cadeia "PUBLICO" || PAINEL_OK=0
}
comparacoes() {
  limpar_ambiente
  if [[ $PAINEL_OK -eq 1 ]]; then
    rodar "COMPARACOES 05" R/05_comparacoes_amostra_comum.R output/log_05.txt || true
  else
    registrar PULADA "COMPARACOES 05 (variante do painel com falha)"
  fi
}
rts() {
  limpar_ambiente
  N_REP_RTS=1000 rodar "RTS FASE A 02b" R/02b_teste_rts.R output/log_02b.txt || true
  export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1 \
    SUFIXO_SAIDA=_painel PRODUTOS=publicacoes,patentes
  N_REP_RTS=1000 rodar "RTS PAINEL 02b" R/02b_teste_rts.R output/log_02b_painel.txt || true
  limpar_ambiente
}
validacao() {
  limpar_ambiente
  N_SIM=100 N_REP=100 rodar "VALIDACAO RTS 02c" R/02c_validacao_rts.R output/log_02c.txt || true
}
case "$MODO" in
  faseA) fase_a ;;
  painel) painel_base; variantes; comparacoes ;;
  variantes) variantes ;;
  rts) rts ;;
  validacao) validacao ;;
  tudo) fase_a; painel_base; variantes; comparacoes; rts; validacao ;;
  *) echo "modo desconhecido: $MODO"; exit 2 ;;
esac
echo "$(date '+%Y-%m-%d %H:%M:%S') FIM modo=$MODO falhas=$FALHAS" >> "$STATUS"
if [[ $FALHAS -gt 0 ]]; then
  echo "PIPELINE COM $FALHAS FALHA(S) — ver $STATUS"
else
  echo "PIPELINE CONCLUIDO SEM FALHAS"
fi
exit $FALHAS
