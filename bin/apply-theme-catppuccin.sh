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

# Regra global "sem titlebar/borda em nenhuma janela" (wmclass=.* como regex). Isso apaga
# visualmente os botoes de janela e a opacidade da titlebar ajustados nesta mesma sessao --
# sem titlebar nenhuma, nao ha o que mostrar. So adiciona se ainda nao existir (idempotente
# e nao mexe nas outras regras ja gravadas, ex. a do RicePanel).
REGRAS="${XDG_CONFIG_HOME:-$HOME/.config}/kwinrulesrc"
if ! grep -q "^Description=TitleNoBar$" "$REGRAS" 2>/dev/null; then
    ID="$(python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || cat /proc/sys/kernel/random/uuid)"
    kwriteconfig6 --file kwinrulesrc --group "$ID" --key Description "TitleNoBar"
    kwriteconfig6 --file kwinrulesrc --group "$ID" --key noborder "true"
    kwriteconfig6 --file kwinrulesrc --group "$ID" --key noborderrule "2"
    kwriteconfig6 --file kwinrulesrc --group "$ID" --key wmclass ".*"
    kwriteconfig6 --file kwinrulesrc --group "$ID" --key wmclassmatch "3"

    atuais="$(kreadconfig6 --file kwinrulesrc --group General --key rules 2>/dev/null)"
    novas="${atuais:+$atuais,}$ID"
    total=$(( $(kreadconfig6 --file kwinrulesrc --group General --key count 2>/dev/null || echo 0) + 1 ))
    kwriteconfig6 --file kwinrulesrc --group General --key count "$total"
    kwriteconfig6 --file kwinrulesrc --group General --key rules "$novas"
fi

if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1
fi

if /usr/bin/systemctl --user is-active --quiet plasma-plasmashell.service; then
    /usr/bin/systemctl --user restart plasma-plasmashell.service
fi
