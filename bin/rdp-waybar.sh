#!/usr/bin/env bash
# Indicador do RDP para a waybar, em JSON, mais as duas acoes do clique.
#
# A janela do FreeRDP vive na workspace 7 e some da vista quando ele troca de workspace.
# Sem indicador, a sessao fica aberta esquecida e o servidor continua com a sessao presa.
#
# Uso: sem argumento imprime o JSON; "focar" leva ate ela; "fechar" encerra a sessao.
set -uo pipefail

CLASSE='freerdp'
ICONE=$'\U000f0379'

endereco() {
    hyprctl clients -j 2>/dev/null | jq -r --arg c "$CLASSE" \
        '[.[] | select(.class | test($c; "i")) | .address] | first // ""'
}

case "${1:-}" in
    focar)
        end="$(endereco)"
        [[ -n $end ]] || exit 0
        hyprctl dispatch "hl.dsp.focus({ window = 'address:$end' })" >/dev/null 2>&1
        ;;
    fechar)
        end="$(endereco)"
        [[ -n $end ]] || exit 0
        hyprctl dispatch "hl.dsp.window.close({ window = 'address:$end' })" >/dev/null 2>&1
        ;;
    *)
        if [[ -n "$(endereco)" ]]; then
            printf '{"text":"%s","tooltip":"RDP aberto — clique vai até ele, botão direito encerra","class":"aberto"}\n' "$ICONE"
        else
            printf '{"text":"","tooltip":"RDP fechado","class":"fechado"}\n'
        fi
        ;;
esac
