#!/usr/bin/env bash
# Overview das workspaces com preview ao vivo (hyprexpose). Chamado pelo Alt+Tab.
#
#   ~/.dotfiles/bin/expo.sh            abre; com a tela aberta, avanca a selecao
#   ~/.dotfiles/bin/expo.sh confirmar  entra na workspace selecionada e fecha
#
# Dentro da tela o mouse tambem vale: por cima seleciona, clique entra. Setas ou hjkl
# navegam, 1..9 vao direto na workspace, Enter entra, Esc fecha sem trocar.
set -uo pipefail

command -v hyprexpose >/dev/null 2>&1 || {
    command -v notify-send >/dev/null 2>&1 && notify-send "Overview" "hyprexpose nao esta instalado"
    exit 1
}

aberto() { hyprctl layers 2>/dev/null | grep -q "namespace: hyprexpose"; }

if [[ ${1:-abrir} == confirmar ]]; then
    aberto && pkill -SIGUSR2 -x hyprexpose
    exit 0
fi

if ! pgrep -x hyprexpose >/dev/null 2>&1; then
    uwsm app -- hyprexpose >/dev/null 2>&1 &
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        pgrep -x hyprexpose >/dev/null 2>&1 && break
        sleep 0.2
    done
fi

pkill -SIGUSR1 -x hyprexpose
