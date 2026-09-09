#!/usr/bin/env bash
# Tela de bloqueio. Gera o hyprlock.conf com o monitor dos widgets resolvido pela marca; o
# bloco background fica sem monitor de proposito, pra cobrir todas as telas.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
base="$HOME/.config/hypr/hyprlock.conf"
gerado="${XDG_RUNTIME_DIR:-/tmp}/hyprlock.conf"

pidof hyprlock >/dev/null 2>&1 && exit 0

tela="$("$DOTFILES_DIR/bin/monitor.sh" principal 2>/dev/null)"
if [[ -n $tela && -f $base ]]; then
    awk -v tela="$tela" '
        /^[a-zA-Z_]+[ \t]*\{/ { bloco = $1 }
        bloco != "background" && /^[ \t]*monitor[ \t]*=/ { sub(/=.*/, "= " tela) }
        { print }
    ' "$base" >"$gerado" && exec hyprlock -c "$gerado" "$@"
fi

exec hyprlock "$@"
