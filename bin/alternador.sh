#!/usr/bin/env bash
# Alternador de janelas do Super+Tab. O --monitors sai da marca da tela, resolvida na hora
# do uso, entao trocar o cabo de porta nao deixa a GUI presa num conector que nao existe.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

args=(gui --mod-key SUPER --key TAB --close mod-key-release)
tela="$("$DOTFILES_DIR/bin/monitor.sh" principal 2>/dev/null)"
[[ -n $tela ]] && args+=(--monitors "$tela")

exec hyprswitch "${args[@]}" "$@"
