#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

clear

calcular() {
  if [[ -z ${1} ]]; then
    echo "${YEL}Específique a data e hora, exemplo: ${CYA}MES-DIA hora/min${END}"
    echo "${GRE}./te.sh ${CYA}01-03 ${BLU}10:42${END}"
  else
    dia=$(date '+%d')
    mes=$(date '+%m')
    ano=$(date '+%Y')
    hora=$(date '+%H')
    min=$(date '+%M')
    sec=00

    dataJogo=${1}
    horaJogo=${2}

    CURRENT=$(date +%s -d "$ano-$mes-$dia $hora:$min:$sec")
    TARGET=$(date +%s -d "$ano-$dataJogo $horaJogo:$sec")

    MINUTES=$(((TARGET - CURRENT) / 60))
    CICLOS=$((MINUTES / 180))
    PORCENTAGEM=$((CICLOS * 6))

    echo -e "${BOL_BLU}\n # TopEleven\n${END}"

    echo -e "${BLU} Hora atual: ${YEL}$ano-$mes-$dia $hora:$min:$sec"
    echo -e "${BLU} Hora jogo : ${YEL}$ano-$dataJogo $horaJogo:$sec\n"

    echo -e "${BLU} Minutos para a partida : ${YEL} ${YEL}$MINUTES"
    echo -e "${BLU} Ciclos a serem feitos  : ${YEL} ${RED}$CICLOS"
    echo -e "${BLU} Porcentagem a recuperar: ${YEL} ${CYA}$PORCENTAGEM%"

    echo -e "${BLU} \n Exemplos de recuperação\n"

    j20=$((20 + PORCENTAGEM))
    j30=$((30 + PORCENTAGEM))
    j50=$((50 + PORCENTAGEM))
    j60=$((60 + PORCENTAGEM))
    j70=$((70 + PORCENTAGEM))

    jr20=$((100 - j20))
    jr30=$((100 - j30))
    jr50=$((100 - j50))
    jr60=$((100 - j60))
    jr70=$((100 - j70))

    echo -e "${BLU} Jogador 1: ${YEL}20 ${BLU}>${RED} $j20 ${RED}# Diff: ${BOL_RED}$jr20"
    echo -e "${BLU} Jogador 2: ${YEL}30 ${BLU}>${YEL} $j30 ${RED}# Diff: ${BOL_RED}$jr30"
    echo -e "${BLU} Jogador 3: ${YEL}50 ${BLU}>${CYA} $j50 ${RED}# Diff: ${BOL_RED}$jr50"
    echo -e "${BLU} Jogador 4: ${YEL}60 ${BLU}>${BLU} $j60 ${RED}# Diff: ${BOL_RED}$jr60"
    echo -e "${BLU} Jogador 5: ${YEL}70 ${BLU}>${GRE} $j70 ${RED}# Diff: ${BOL_RED}$jr70"
  fi
}
calcular ${1} ${2}
