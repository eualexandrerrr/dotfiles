#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

# -eq : (equal), igual.
# -lt : (less than), menor que.
# -gt : (greather than), maior que.
# -le : (less or equal), menor ou igual.
# -ge : (greater or equal), maior ou igual.
# -ne : (not equal) diferente.

producao=$1
producao=$(echo $producao | cut -c1-5)

if [[ -z "$producao" ]]; then
  echo "${BOL_RED}Por favor diga o valor da comissão, examplo: ${BOL_GRE}45000${END}"
  exit 1
fi

if [[ $producao -ge "50001" ]]; then
  porcentagem="5,5"
elif [[ $producao -ge "40001" ]]; then
  porcentagem="5"
elif [[ $producao -ge "30001" ]]; then
  porcentagem="4"
elif [[ $producao -ge "20001" ]]; then
  porcentagem="2"
elif [[ $producao -le "20000" ]]; then
  porcentagem="1"
else
  porcentagem="fail"
fi

if [[ $porcentagem == "fail" ]]; then
  echo "Algo deu errado"
else
  ticket="1100"
  adiantamento="800"
  beneficios=$((ticket+adiantamento))

  restanteSalario="1200"
  DSR="350"
  pernoite="600"
  descontos="1250"
  somaExtras=$((restanteSalario+DSR+pernoite-descontos))

  comissao=$((producao*porcentagem/100))

  liquido=$((comissao+somaExtras))
  bruto=$((liquido+beneficios))

  echo -e "${BOL_CYA}Produção: R\$ ${producao},00"
  echo -e "${BOL_MAG}Comissão: R\$ ${comissao},00 (${porcentagem}%)\n"
  echo -e "${GRE}Bruto:    R\$ ${bruto},00${END}"
  echo -e "${BOL_GRE}Líquido:  R\$ ${liquido},00${END}"
fi
