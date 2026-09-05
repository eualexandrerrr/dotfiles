#!/usr/bin/env bash
marca="$HOME/.config/.kde-layout-aplicado"
[[ -e $marca ]] && exit 0
js="$HOME/.dotfiles/scripts/kde-layout.js"
[[ -f $js ]] || exit 0

for i in $(seq 1 60); do
    qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "" >/dev/null 2>&1 && break
    sleep 1
done

plasma-apply-lookandfeel -a org.kde.breezedark.desktop >/dev/null 2>&1 || true
plasma-apply-colorscheme BreezeDark >/dev/null 2>&1 || true
plasma-apply-desktoptheme breeze-dark >/dev/null 2>&1 || true
kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-dark
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme capitaine-cursors-white
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true

qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$js")" >/dev/null 2>&1 && touch "$marca"

qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
