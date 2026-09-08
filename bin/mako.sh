#!/usr/bin/env bash
# Sobe o mako preso na tela principal por marca. O config versionado nao carrega output
# nenhum de proposito: nome de conector nesse arquivo quebra a cada troca de cabo.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

tela="$("$DOTFILES_DIR/bin/monitor.sh" principal 2>/dev/null)"
[[ -n $tela ]] && exec mako --output "$tela" "$@"

exec mako "$@"
