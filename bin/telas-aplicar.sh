#!/usr/bin/env bash
# Reforca a config de monitor no login: taxa, rotacao, posicao e qual tela e primaria.
#
# O KWin salva isso sozinho em ~/.config/kwinoutputconfig.json, mas nao e confiavel: em
# 10/09/2026 o arquivo foi regravado horas depois de aplicado, provavelmente por um ciclo de
# DPMS (tela apagando por inatividade) que fez o KWin re-negociar o EDID e escolher de novo a
# maior taxa disponivel (144Hz) em vez de manter a taxa configurada (120Hz). Isso era
# resolvido pelo monitores.lua no Hyprland, que era declarativo e reaplicava toda vez.
#
# Idempotente e silencioso: nao imprime nada quando ja esta certo, so age quando falta.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
principal="$("$DOTFILES_DIR/bin/monitor.sh" principal 2>/dev/null)"
vertical="$("$DOTFILES_DIR/bin/monitor.sh" vertical 2>/dev/null)"

[[ -n $principal && -n $vertical ]] || exit 0
command -v kscreen-doctor >/dev/null 2>&1 || exit 0

kscreen-doctor \
    "output.$vertical.rotation.left" \
    "output.$vertical.position.0,0" \
    "output.$vertical.priority.2" \
    "output.$principal.mode.2560x1440@120" \
    "output.$principal.position.1080,240" \
    "output.$principal.priority.1" \
    >/dev/null 2>&1
