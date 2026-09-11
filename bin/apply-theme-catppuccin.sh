#!/usr/bin/env bash
# Camada de aparencia inspirada no rice de prasanthrangan/dotfiles (Arch KDE), mas os
# arquivos vieram direto das fontes originais -- creditos em plasma/vendor-*/. Roda POR
# CIMA do apply-theme-win11os-dark.sh: troca Kvantum, icones, cursor e GTK, mas NAO mexe
# em decoracao de janela (org.kde.kdecoration2) nem no tema de desktop do Plasma
# (plasmarc), que continuam Win11OS-dark.
#
# forceblur/tilegaps do rice original ficam de fora: forceblur chama xprop e o proprio
# README diz "does not support wayland" (esta sessao e Wayland puro); tilegaps nao tem
# versao mantida em lugar nenhum que eu achei. O blur nativo do KWin (Effect-blur) e
# Wayland-safe e entra aqui.
set -uo pipefail

command -v kwriteconfig6 >/dev/null 2>&1 || exit 0

kwriteconfig6 --file kdeglobals --group General --key ColorScheme CatppuccinMochaRed
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum

kwriteconfig6 --file kdeglobals --group General --key AccentColorFromWallpaper false
kwriteconfig6 --file kdeglobals --group General --key AccentColor "243,139,168"

kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-dracula-dark
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Ice

kwriteconfig6 --file "$HOME/.config/Kvantum/kvantum.kvconfig" --group General --key theme LayanDark

GTK3="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
kwriteconfig6 --file "$GTK3" --group Settings --key gtk-theme-name Rosepine-Dark
kwriteconfig6 --file "$GTK3" --group Settings --key gtk-icon-theme-name Tela-dracula-dark
kwriteconfig6 --file "$GTK3" --group Settings --key gtk-cursor-theme-name Bibata-Modern-Ice

kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 8
kwriteconfig6 --file kwinrc --group Effect-blur --key NoiseStrength 0

# A regra global "sem titlebar/borda em nenhuma janela" (do rice original) foi testada e
# revertida no mesmo dia: sem titlebar nao da pra arrastar Dolphin/ghostty/nada pela borda.
# Nao entra aqui.

if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1
fi

if /usr/bin/systemctl --user is-active --quiet plasma-plasmashell.service; then
    /usr/bin/systemctl --user restart plasma-plasmashell.service
fi
