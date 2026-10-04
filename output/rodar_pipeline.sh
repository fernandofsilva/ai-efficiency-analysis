#!/bin/zsh
# Executa o pipeline de análise com propagação de falhas.
# - Cada etapa grava seu status (OK/FALHA, horário) em output/status_execucao.txt.
# - Uma falha interrompe a cadeia dependente (02 -> 03 -> 04) daquela variante;
#   as demais variantes continuam; o script 05 só roda se todas as variantes do
#   painel tiverem concluído; o código de saída é o número de etapas com falha.
# - Não há modo "só rankings": o ranking sai do script 02, e o 03 e o 04 leem
#   suas saídas; rerodar o 02 exige rerodar 03 e 04 (a cadeia inteira).
# - Padronização das variáveis da fronteira (S01): com PADRONIZACAO=minmax (e,
#   opcionalmente, EPSILON_PADRONIZACAO; padrão 0,01) todas as etapas gravam
#   tabelas, figuras, logs e status com o sufixo "_minmax"; a validação por
#   simulação (02c) não depende dos dados e é pulada; no modo "tudo", a
#   comparação com a versão em unidades originais (05b) roda no fim.
# - SFA por canal (S02/H2, R/06): em log, não depende da padronização; roda nas seis
#   bases (Fase A, painel e variantes) e é pulado com PADRONIZACAO=minmax.
# - Modo estagio2: refaz só o segundo estágio e as figuras (03 -> 04) nas seis
#   bases, sobre as fronteiras já gravadas pelo 02 (o 02 não muda).
# Uso: zsh output/rodar_pipeline.sh [faseA|painel|variantes|rts|sfa|estagio2|validacao|padronizacao|tudo]
#      PADRONIZACAO=minmax zsh output/rodar_pipeline.sh tudo
set -u
cd "$(dirname "$0")/.." || exit 1
export PADRONIZACAO=${PADRONIZACAO:-nenhuma}
PAD=$(Rscript -e 'source("R/funcoes.R"); cat(ConfigurarPadronizacao()$sufixo)') || exit 2
STATUS=output/status_execucao$PAD.txt
MODO=${1:-tudo}
FALHAS=0
: > "$STATUS"
echo "$(date '+%Y-%m-%d %H:%M:%S') INICIO modo=$MODO padronizacao=$PADRONIZACAO sufixo=${PAD:-nenhum}" >> "$STATUS"

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
  if [[ ${SO_ESTAGIO2:-0} -eq 0 ]]; then
    rodar "$1 02 fronteiras" R/02_fronteiras_dataset_atual.R "output/log_02$s$PAD.txt" || return 1
  fi
  rodar "$1 03 segundo estágio" R/03_segundo_estagio_dataset_atual.R "output/log_03$s$PAD.txt" &&
    rodar "$1 04 figuras" R/04_figuras_apresentacao.R "output/log_04$s$PAD.txt"
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
    rodar "COMPARACOES 05" R/05_comparacoes_amostra_comum.R "output/log_05$PAD.txt" || true
  else
    registrar PULADA "COMPARACOES 05 (variante do painel com falha)"
  fi
}
rts() {
  limpar_ambiente
  N_REP_RTS=1000 rodar "RTS FASE A 02b" R/02b_teste_rts.R "output/log_02b$PAD.txt" || true
  export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1 \
    SUFIXO_SAIDA=_painel PRODUTOS=publicacoes,patentes
  N_REP_RTS=1000 rodar "RTS PAINEL 02b" R/02b_teste_rts.R "output/log_02b_painel$PAD.txt" || true
  limpar_ambiente
}
validacao() {
  limpar_ambiente
  if [[ -n $PAD ]]; then
    registrar PULADA "VALIDACAO RTS 02c (simulação; não depende da padronização)"
    return 0
  fi
  N_SIM=100 N_REP=100 rodar "VALIDACAO RTS 02c" R/02c_validacao_rts.R output/log_02c.txt || true
}
sfa() {  # fronteira estocástica por canal em log (S02/H2)
  limpar_ambiente
  if [[ -n $PAD ]]; then
    registrar PULADA "SFA 06 (em log; não depende da padronização)"
    return 0
  fi
  export SUFIXO_SAIDA=""
  rodar "SFA FASE A 06" R/06_sfa_canais.R output/log_06.txt || true
  export BASE_ARQUIVO=data/processed/painel_ia.csv INSUMOS=investimento_l1,gerd_l1 \
    SUFIXO_SAIDA=_painel PRODUTOS=publicacoes,patentes
  rodar "SFA PAINEL 06" R/06_sfa_canais.R output/log_06_painel.txt || true
  export SUFIXO_SAIDA=_painel_qualidade PRODUTOS=citacoes_ok,patentes_concedidas_ok
  rodar "SFA QUALIDADE 06" R/06_sfa_canais.R output/log_06_painel_qualidade.txt || true
  export SUFIXO_SAIDA=_painel_fonte PRODUTOS=publicacoes,patentes_inventor
  rodar "SFA FONTE 06" R/06_sfa_canais.R output/log_06_painel_fonte.txt || true
  export SUFIXO_SAIDA=_painel_preqin INSUMOS=investimento_preqin_l1,gerd_l1 PRODUTOS=publicacoes,patentes
  rodar "SFA PREQIN 06" R/06_sfa_canais.R output/log_06_painel_preqin.txt || true
  export SUFIXO_SAIDA=_painel_publico INSUMOS=investimento_l1,pd_publico_l1 PRODUTOS=publicacoes,patentes
  rodar "SFA PUBLICO 06" R/06_sfa_canais.R output/log_06_painel_publico.txt || true
  limpar_ambiente
}
padronizacao() {  # compara com a versão em unidades originais (S01)
  limpar_ambiente
  if [[ -z $PAD ]]; then
    registrar PULADA "COMPARACAO PADRONIZACAO 05b (rode com PADRONIZACAO=minmax)"
    return 0
  fi
  rodar "COMPARACAO PADRONIZACAO 05b" R/05b_comparacao_padronizacao.R "output/log_05b$PAD.txt" || true
}
case "$MODO" in
  faseA) fase_a ;;
  painel) painel_base; variantes; comparacoes ;;
  variantes) variantes ;;
  rts) rts ;;
  validacao) validacao ;;
  sfa) sfa ;;
  estagio2) SO_ESTAGIO2=1; fase_a; painel_base; variantes ;;
  padronizacao) padronizacao ;;
  tudo) fase_a; painel_base; variantes; comparacoes; rts; sfa; validacao; padronizacao ;;
  *) echo "modo desconhecido: $MODO"; exit 2 ;;
esac
echo "$(date '+%Y-%m-%d %H:%M:%S') FIM modo=$MODO falhas=$FALHAS" >> "$STATUS"
if [[ $FALHAS -gt 0 ]]; then
  echo "PIPELINE COM $FALHAS FALHA(S) — ver $STATUS"
else
  echo "PIPELINE CONCLUIDO SEM FALHAS"
fi
exit $FALHAS
