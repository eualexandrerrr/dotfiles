#!/usr/bin/env bash
# Contador de notificacoes do Discord para a waybar, em JSON.
# O Discord escreve "(3) #canal | Servidor - Discord" no titulo da janela quando ha
# mencao ou DM nao lida, e tira o "(3)" quando voce le. E a unica fonte local do numero:
# o app nao expoe API e o icone da bandeja so tem o ponto vermelho, sem a quantidade.
set -uo pipefail

titulo="$(hyprctl clients -j 2>/dev/null | jq -r '[.[] | select(.class == "discord") | .title] | first // ""')"

if [[ -z $titulo ]]; then
    printf '{"text":"","tooltip":"Discord fechado","class":"fechado"}\n'
    exit 0
fi

if [[ $titulo =~ ^\(([0-9]+)\) ]]; then
    n="${BASH_REMATCH[1]}"
    printf '{"text":"\uf392 %s","tooltip":"%s no Discord","class":"pendente"}\n' \
        "$n" "$([[ $n == 1 ]] && echo "1 mensagem" || echo "$n mensagens")"
else
    printf '{"text":"","tooltip":"Discord sem mensagem nova","class":"limpo"}\n'
fi
