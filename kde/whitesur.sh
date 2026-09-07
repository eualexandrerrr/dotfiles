#!/usr/bin/env bash
# Kvantum WhiteSur escuro (vinceliuice, GPL-3), vendorado em vendor/whitesur.
# Kvantum + esquema de cores: e o corpo da janela (Dolphin translucido, barra
# lateral limpa). A decoracao e o tema do Plasma ficam como estao, entao a barra
# de tarefas nao vira macOS.
#   kde/whitesur.sh            aplica
#   kde/whitesur.sh --reverter volta pro Kvantum do Dream
set -uo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
V="$DOTFILES_DIR/vendor/whitesur"

if [[ ${1:-} == --reverter ]]; then
    kwriteconfig6 --file ~/.config/Kvantum/kvantum.kvconfig --group General --key theme Dream-Violet-Dark-Kvantum
    plasma-apply-colorscheme DreamVioletDarkColor >/dev/null 2>&1
    printf '  ok   whitesur: revertido para Dream-Violet-Dark-Kvantum\n'
    exit 0
fi

[[ -d $V ]] || { printf 'whitesur: %s ausente\n' "$V" >&2; exit 1; }
mkdir -p ~/.config/Kvantum ~/.local/share/color-schemes
cp -r "$V/kvantum/WhiteSurDark" ~/.config/Kvantum/
cp "$V/colors/WhiteSurDark.colors" ~/.local/share/color-schemes/
kwriteconfig6 --file ~/.config/Kvantum/kvantum.kvconfig --group General --key theme WhiteSurDark
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
plasma-apply-colorscheme WhiteSurDark >/dev/null 2>&1
printf '  ok   whitesur: kvantum WhiteSurDark aplicado (reabra os apps pra ver)\n'
