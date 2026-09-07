#!/usr/bin/env bash
# Wallpaper por monitor, com a mesma regra do MyWinISO: a imagem em retrato vai para o monitor
# em pe, a paisagem vai para os outros. As duas imagens sao as mesmas que estao la, para o
# Windows e o Arch nao terem cara diferente.
#
# Por que nao versionar o plasma-org.kde.plasma.desktop-appletsrc: ele mistura configuracao com
# estado (posicao de janela, hash de tema, UUID de desktop virtual), e commitar isso e commitar
# lixo que muda sozinho -- decisao ja registrada no README. Entao o wallpaper e APLICADO por
# script, e nao restaurado por arquivo.
#
# Roda sozinho no primeiro login (kde/layout-once.sh) e pode rodar a mao depois:
#   ~/.dotfiles/kde/wallpaper.sh
set -uo pipefail

aqui="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(dirname "$aqui")"
destino="$HOME/.local/share/wallpapers/mywiniso"
PAISAGEM="Jason_and_Lucia_Robbery_landscape.jpg"
RETRATO="Real_Dimez_portrait.jpg"

[[ -d $repo/wallpaper ]] || { echo "sem a pasta wallpaper/ em $repo"; exit 1; }
mkdir -p "$destino"
install -m 644 "$repo/wallpaper/$PAISAGEM" "$repo/wallpaper/$RETRATO" "$destino/"
echo "imagens em $destino"

# O plasmashell so aceita mudanca de wallpaper por script pela sua propria API de D-Bus; nao ha
# arquivo para escrever com o shell vivo (ele reescreve por cima ao sair). O evaluateScript recebe
# JavaScript que roda dentro do proprio shell.
if ! command -v qdbus6 >/dev/null 2>&1 && ! command -v qdbus >/dev/null 2>&1; then
    echo "qdbus nao encontrado (pacote qt6-tools); wallpaper nao aplicado"
    exit 1
fi
QDBUS=$(command -v qdbus6 || command -v qdbus)

# desktops() devolve um containment por monitor. screenGeometry diz qual esta em pe.
"$QDBUS" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var ds = desktops();
for (var i = 0; i < ds.length; i++) {
    var d = ds[i];
    var g = screenGeometry(d.screen);
    var img = (g.height > g.width) ? '$destino/$RETRATO' : '$destino/$PAISAGEM';
    d.wallpaperPlugin = 'org.kde.image';
    d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
    d.writeConfig('Image', 'file://' + img);
    d.writeConfig('FillMode', 2);            // 2 = preencher mantendo proporcao
    print(d.screen + ': ' + g.width + 'x' + g.height + ' -> ' + img);
}
" && echo "wallpaper aplicado por monitor" || echo "evaluateScript falhou (o plasmashell esta rodando?)"
