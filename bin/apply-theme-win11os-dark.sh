#!/usr/bin/env bash
# Aplica o tema Win11OS-dark (creditos em plasma/vendor-win11os/) depois que o stow ja
# colocou os arquivos em ~/.local/share e ~/.config/Kvantum. So gravar o arquivo nao muda
# nada na tela -- cada peca do tema tem a propria chave de config.
#
# Fora do pacote original de proposito: tema de icones (Win11) e cursor (Win10OS-cursors)
# nao vem nesse repositorio (o pacote so referencia via KNS, download avulso do KDE Store).
# Gravar essas duas chaves sem os arquivos instalados quebra em silencio -- ai fica so
# Breeze mesmo pros dois.
#
# Cor de destaque do esquema original e azul (padrao do Windows 11); o Alexandre quer o
# visual escuro sem azul, entao a cor de destaque e sobrescrita pra cinza depois de aplicar
# o esquema de cores inteiro.
#
# Transparencia de janela e menu do Kvantum (translucent_windows, blurring, popup_blurring)
# foi desligada direto no .kvconfig vendorizado -- o pedido foi "tudo opaco", painel e
# janela.
set -uo pipefail

command -v kwriteconfig6 >/dev/null 2>&1 || exit 0

kwriteconfig6 --file kdeglobals --group General --key ColorScheme Win11OSDark
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum

kwriteconfig6 --file kdeglobals --group General --key AccentColorFromWallpaper false
kwriteconfig6 --file kdeglobals --group General --key AccentColor "128,128,128"

kwriteconfig6 --file "$HOME/.config/Kvantum/kvantum.kvconfig" --group General --key theme Win11OS-dark

# Icones e cursor de terceiros (creditos em plasma/vendor-tela-icons e
# plasma/vendor-bibata-cursor). Sao os unicos restos da camada Catppuccin que ficaram: o
# Kvantum Layan e o esquema de cores dela saiam em 11/09/2026 -- fundo cinza claro e
# destaque rosa, os dois recusados. Aqui o tema inteiro e o Win11OS-dark.
kwriteconfig6 --file kdeglobals --group Icons --key Theme Tela-dracula-dark
kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Ice

GTK3="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
kwriteconfig6 --file "$GTK3" --group Settings --key gtk-theme-name Breeze-Dark
kwriteconfig6 --file "$GTK3" --group Settings --key gtk-icon-theme-name Tela-dracula-dark
kwriteconfig6 --file "$GTK3" --group Settings --key gtk-cursor-theme-name Bibata-Modern-Ice

# Nada de alpha: blur e contraste de fundo desligados.
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key contrastEnabled false

# O nome depois de __aurorae__svg__ e o da pasta em aurorae/themes/, Win11OS-dark.
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__Win11OS-dark"

# Letras de src/kcms/decoration/utils.cpp do KWin: I=Minimize, A=Maximize, X=Close. O
# default do pacote original poe os tres a esquerda (XAI); o Alexandre quer a direita,
# ordem do Windows.
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft ""
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight "IAX"

# Sem isso, janela maximizada mantem a faixa de borda invisivel do Aurorae e o cursor de
# redimensionar aparece encostado na tela -- sem borda visivel pra redimensionar de verdade.
kwriteconfig6 --file kwinrc --group Windows --key BorderlessMaximizedWindows true

kwriteconfig6 --file plasmarc --group Theme --key name Win11OS-dark
kwriteconfig6 --file ksplashrc --group KSplash --key Theme "com.github.yeyushengfan258.Win11OS-dark"

# Painel translucido por padrao (panelOpacity=2, Translucent); 1 = Opaque. O numero do
# painel muda a cada instalacao limpa, entao acha todo "[PlasmaViews][Panel N]" que existir.
paineis="$(awk -F'[][]' '/^\[PlasmaViews\]\[Panel [0-9]+\]$/ { print $4 }' \
    "${XDG_CONFIG_HOME:-$HOME/.config}/plasmashellrc" 2>/dev/null | sort -u)"
for painel in $paineis; do
    kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $painel" \
        --group Defaults --key panelOpacity 1
done

# KWin recarrega decoracao e temas com um sinal, sem derrubar o compositor.
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1
fi

# ColorScheme, widgetStyle, o tema do plasmarc e a opacidade do painel so pegam depois
# que o shell recarrega.
if /usr/bin/systemctl --user is-active --quiet plasma-plasmashell.service; then
    /usr/bin/systemctl --user restart plasma-plasmashell.service
fi
