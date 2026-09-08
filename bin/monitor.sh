#!/usr/bin/env bash
# Resolve um monitor pela MARCA, nao pelo conector: monitor.sh [--desc] principal|vertical
# imprime o nome atual (DP-1, DP-2...) ou a descricao completa. A marca sai do telas.lua,
# que e a unica fonte da verdade -- trocar de cabo nao muda nada aqui.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
telas="$DOTFILES_DIR/hypr/.config/hypr/telas.lua"

campo="name"
if [[ ${1:-} == --desc ]]; then
    campo="description"
    shift
fi
papel="${1:-principal}"

[[ -f $telas ]] || exit 1
command -v hyprctl >/dev/null 2>&1 || exit 1
command -v jq >/dev/null 2>&1 || exit 1

marca="$(sed -n "s/^telas\.$papel = \"\(.*\)\".*/\1/p" "$telas" | head -1)"
[[ -n $marca ]] || exit 1

lista="$(hyprctl monitors all -j 2>/dev/null)"
[[ -n $lista ]] || exit 1

jq -r --arg m "$marca" --arg c "$campo" \
    'map(select(.description | startswith($m))) | sort_by(.disabled) | .[0][$c] // empty' \
    <<<"$lista"
