#!/usr/bin/env bash
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
telas="$DOTFILES_DIR/hypr/.config/hypr/telas.lua"
base="$HOME/.config/waybar/config.jsonc"
estilo="$HOME/.config/waybar/style.css"
gerada="${XDG_RUNTIME_DIR:-/tmp}/waybar/config.jsonc"

marca_de() {
    sed -n "s/^telas\.$1 = \"\(.*\)\".*/\1/p" "$telas" | head -1
}

principal="$(marca_de principal)"
vertical="$(marca_de vertical)"

saida=""
if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    ativos="$(hyprctl monitors -j 2>/dev/null)"
    if [[ -n $ativos && -n $principal ]]; then
        saida="$(jq -r --arg m "$principal" \
            'map(select(.description | startswith($m))) | .[0].description // empty' \
            <<<"$ativos")"
    fi
    if [[ -z $saida && -n $ativos && -n $vertical ]]; then
        saida="$(jq -r --arg v "$vertical" \
            'map(select(.description | startswith($v) | not)) | .[0].description // empty' \
            <<<"$ativos")"
    fi
fi

# Sem a tela principal a barra nao sobe: a vertical e do RicePanel e nunca recebe barra.
[[ -n $saida ]] || exit 0

mkdir -p "$(dirname "$gerada")"
jq --arg o "$saida" '.output = [$o]' "$base" >"$gerada" || exit 1

exec waybar -c "$gerada" -s "$estilo"
