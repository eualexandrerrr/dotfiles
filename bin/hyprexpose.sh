#!/usr/bin/env bash
# Sobe o hyprexpose com o ignore_monitors resolvido pela MARCA do monitor vertical, nao pelo
# conector: o config versionado nunca fica desatualizado quando o cabo muda de porta.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
base="$HOME/.config/hyprexpose/config.toml"
raiz="${XDG_RUNTIME_DIR:-/tmp}/hyprexpose-cfg"
gerado="$raiz/hyprexpose/config.toml"

if [[ -f $base ]]; then
    ignorar="$("$DOTFILES_DIR/bin/monitor.sh" vertical 2>/dev/null)"
    lista="[]"
    [[ -n $ignorar ]] && lista="[\"$ignorar\"]"
    mkdir -p "$(dirname "$gerado")"
    sed "s|^ignore_monitors = .*|ignore_monitors = $lista|" "$base" >"$gerado"
    exec env XDG_CONFIG_HOME="$raiz" hyprexpose "$@"
fi

exec hyprexpose "$@"
