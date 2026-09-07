#!/usr/bin/env bash
# Tema Dream (L4ki, GPL-3), vendorado em vendor/dream: tema do Plasma, esquema de cores,
# decoracao Aurorae e Kvantum. O SDDM do Dream fica no kde/login.sh.
set -uo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
V="$DOTFILES_DIR/vendor/dream"
[[ -d $V ]] || { printf 'dream: %s ausente\n' "$V" >&2; exit 1; }
mkdir -p ~/.local/share/plasma/desktoptheme ~/.local/share/color-schemes ~/.local/share/aurorae/themes ~/.config/Kvantum
cp -r "$V/plasma/Dream-Color-Plasma" ~/.local/share/plasma/desktoptheme/
cp "$V/colors/"*.colors ~/.local/share/color-schemes/
cp -r "$V/aurorae/Dream-Blur-Color-Dark-Aurorae-6" ~/.local/share/aurorae/themes/
cp -r "$V/kvantum/Dream-Violet-Dark-Kvantum" ~/.config/Kvantum/
kwriteconfig6 --file ~/.config/Kvantum/kvantum.kvconfig --group General --key theme Dream-Violet-Dark-Kvantum
printf '  ok   dream: plasma, cores, aurorae e kvantum instalados\n'
