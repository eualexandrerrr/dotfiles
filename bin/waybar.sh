#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
monitores="$DOTFILES_DIR/hypr/.config/hypr/monitores.lua"
base="$HOME/.config/waybar/config.jsonc"
estilo="$HOME/.config/waybar/style.css"
gerada="${XDG_RUNTIME_DIR:-/tmp}/waybar/config.jsonc"

marca_de() {
    sed -n "s/^local $1 = \"desc:\(.*\)\".*/\1/p" "$monitores" | head -1
}

principal="$(marca_de principal)"
vertical="$(marca_de vertical)"

saida=""
if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    telas="$(hyprctl monitors -j 2>/dev/null)"
    if [[ -n "$telas" && -n "$principal" ]]; then
        saida="$(jq -r --arg m "$principal" \
            'map(select(.disabled | not) | select(.description | startswith($m))) | .[0].description // empty' \
            <<<"$telas")"
    fi
    if [[ -z "$saida" && -n "$telas" ]]; then
        saida="$(jq -r --arg v "$vertical" \
            'map(select(.disabled | not) | select($v == "" or (.description | startswith($v) | not))) | .[0].description // empty' \
            <<<"$telas")"
    fi
fi

mkdir -p "$(dirname "$gerada")"
if [[ -n "$saida" ]] && command -v jq >/dev/null 2>&1; then
    jq --arg o "$saida" '.output = [$o]' "$base" >"$gerada" || cp "$base" "$gerada"
else
    cp "$base" "$gerada"
fi

exec waybar -c "$gerada" -s "$estilo"
