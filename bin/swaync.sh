#!/usr/bin/env bash
# Sobe o swaync preso na tela principal por marca. O config versionado nao carrega output
# nenhum de proposito: nome de conector nesse arquivo quebra a cada troca de cabo.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CONFIG="$HOME/.config/swaync/config.json"
ESTILO="$HOME/.config/swaync/style.css"
GERADO="${XDG_RUNTIME_DIR:-/tmp}/swaync-config.json"

tela="$("$DOTFILES_DIR/bin/monitor.sh" --desc principal 2>/dev/null)"

if [[ -n $tela ]] && command -v jq >/dev/null 2>&1; then
    jq --arg t "$tela" \
        '.["notification-window-preferred-output"] = $t | .["control-center-preferred-output"] = $t' \
        "$CONFIG" >"$GERADO" && exec swaync --config "$GERADO" --style "$ESTILO" "$@"
fi

exec swaync --config "$CONFIG" --style "$ESTILO" "$@"
