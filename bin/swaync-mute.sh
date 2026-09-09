#!/usr/bin/env bash
# Silencia um app nas notificacoes: grava a regra no config versionado do swaync e recarrega
# na hora. "state":"muted" mantem o app no historico, so tira o popup -- desbloqueia editando
# ~/.dotfiles/swaync/.config/swaync/config.json ou apagando a chave em "notification-visibility".
#
# O daemon roda com --config apontando pro arquivo gerado (bin/swaync.sh), nao pra fonte
# versionada: sem regenerar o gerado, o --reload-config nao veria a regra nova.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CONFIG="$DOTFILES_DIR/swaync/.config/swaync/config.json"
GERADO="${XDG_RUNTIME_DIR:-/tmp}/swaync-config.json"

aviso() { command -v notify-send >/dev/null 2>&1 && notify-send "$@" 2>/dev/null; }

app="${1:-}"
if [[ -z $app ]]; then
    printf 'uso: %s <app-name>\n' "$(basename "$0")" >&2
    exit 1
fi

command -v jq >/dev/null 2>&1 || { aviso -u critical "swaync" "jq nao esta instalado"; exit 1; }

tmp="$(mktemp)"
jq --arg a "$app" \
    '.["notification-visibility"][$a] = {"state": "muted", "app-name": $a}' \
    "$CONFIG" >"$tmp" && mv "$tmp" "$CONFIG"

tela="$("$DOTFILES_DIR/bin/monitor.sh" --desc principal 2>/dev/null)"
if [[ -n $tela ]]; then
    jq --arg t "$tela" \
        '.["notification-window-preferred-output"] = $t | .["control-center-preferred-output"] = $t' \
        "$CONFIG" >"$GERADO"
else
    cp "$CONFIG" "$GERADO"
fi

swaync-client --reload-config >/dev/null 2>&1
aviso "swaync" "notificacoes de $app silenciadas"
