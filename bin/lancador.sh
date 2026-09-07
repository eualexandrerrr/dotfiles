#!/usr/bin/env bash
# Abre o fuzzel na workspace e no monitor onde o foco esta, e fecha se ja estiver aberto.
# Chamado pelo Meta+R, Meta+Space e Alt+D (hypr/atalhos.lua).
set -uo pipefail

command -v fuzzel >/dev/null 2>&1 || {
    command -v notify-send >/dev/null 2>&1 && notify-send "Lancador" "fuzzel nao esta instalado"
    exit 1
}

pkill -x fuzzel 2>/dev/null && exit 0

exec uwsm app -- fuzzel "$@"
