#!/usr/bin/env bash
# Aplica o tema Win11Nord (creditos em plasma/vendor-win11nord/) depois que o stow ja
# colocou os arquivos em ~/.local/share e ~/.config/Kvantum. So gravar o arquivo nao muda
# nada na tela -- cada peca do tema tem a propria chave de config.
#
# Fora do pacote original de proposito: tema de icones (Win11) e cursor (Afterglow-cursors)
# nao vem nesse repositorio (o pacote so referencia via KNS, download avulso do KDE Store).
# Gravar essas duas chaves sem os arquivos instalados quebra em silencio -- ai fica so
# Breeze mesmo pros dois.
set -uo pipefail

command -v kwriteconfig6 >/dev/null 2>&1 || exit 0

kwriteconfig6 --file kdeglobals --group General --key ColorScheme Windows11Nord
kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum

kwriteconfig6 --file "$HOME/.config/Kvantum/kvantum.kvconfig" --group General --key theme Win11OS-Nord

# O nome depois de __aurorae__svg__ e o da pasta em aurorae/themes/, Win11OS-Nord --
# nao confundir com Windows11-Nord, nome do tema de desktop/look-and-feel do mesmo autor.
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__Win11OS-Nord"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnLeft "XAI"
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key ButtonsOnRight ""

kwriteconfig6 --file plasmarc --group Theme --key name Windows11-Nord
kwriteconfig6 --file ksplashrc --group KSplash --key Theme "com.github.yeyushengfan258.Windows11-Nord"

# KWin recarrega decoracao e temas com um sinal, sem derrubar o compositor.
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1
fi

# ColorScheme, widgetStyle e o tema do plasmarc so pegam depois que o shell recarrega.
if /usr/bin/systemctl --user is-active --quiet plasma-plasmashell.service; then
    /usr/bin/systemctl --user restart plasma-plasmashell.service
fi
