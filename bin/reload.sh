#!/usr/bin/env bash
# Recarrega a sessao sem fechar nada: Hyprland, waybar, mako e os dois alternadores.
# Chamado pelo CTRL+SHIFT+Home (hypr/atalhos.lua). Equivale a setup.sh recarregar.
set -uo pipefail

aviso() { command -v notify-send >/dev/null 2>&1 && notify-send "$@" 2>/dev/null; }

if bash "$HOME/.dotfiles/setup.sh" recarregar >/tmp/recarregar-wm.log 2>&1; then
    erros="$(hyprctl configerrors 2>/dev/null)"
    if [[ -n $erros && $erros != *"no errors"* ]]; then
        aviso -u critical "Hyprland" "recarregado com erro de config, veja hyprctl configerrors"
    else
        aviso "Hyprland" "sessao recarregada"
    fi
else
    aviso -u critical "Hyprland" "falha ao recarregar, veja /tmp/recarregar-wm.log"
    exit 1
fi
