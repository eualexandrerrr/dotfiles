#!/usr/bin/env bash
# Tira o "+" que o Plasma desenha em cima do icone quando 2+ janelas do mesmo app
# se juntam num icone so (org.kde.plasma.icontasks com groupingStrategy=1, o default).
#
# Nao existe chave de config pra isso: o applet decide mostrar so por
# `model.IsGroupParent` (GroupExpanderOverlay.qml, upstream KDE/plasma-desktop) e
# desenha o elemento group-expander-{bottom,top,left,right} do SVG do tema ativo
# (widgets/tasks.svgz). A unica forma de tirar so o "+" e mantendo o agrupamento e
# sobrepor esse SVG com uma copia sem esses 4 elementos.
#
# A copia vai em ~/.local/share/plasma/desktoptheme/<tema>/widgets/tasks.svgz --
# o Plasma sempre prefere o SVG do usuario sobre o de /usr/share quando os dois
# existem, e recarrega tema sozinho (KDirWatch), sem precisar derrubar plasmashell.
# Fragil a upgrade do Plasma: se o `tasks.svg` de sistema mudar de estrutura, a
# copia do usuario fica congelada na versao velha ate rodar este script de novo.
set -uo pipefail

command -v python3 >/dev/null 2>&1 || exit 0

tema="$(kreadconfig6 --file plasmarc --group Theme --key name 2>/dev/null)"
tema="${tema:-default}"

origem="/usr/share/plasma/desktoptheme/$tema/widgets/tasks.svgz"
[[ -f $origem ]] || exit 0

destino="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/desktoptheme/$tema/widgets/tasks.svgz"

python3 - "$origem" "$destino" <<'PY'
import gzip
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

origem, destino = Path(sys.argv[1]), Path(sys.argv[2])

raiz = ET.fromstring(gzip.decompress(origem.read_bytes()))

removidos = 0
for pai in raiz.iter():
    for filho in list(pai):
        if filho.get("id", "").startswith("group-expander-"):
            pai.remove(filho)
            removidos += 1

if removidos == 0:
    sys.exit(0)  # SVG de sistema ja sem os elementos (tema mudou de estrutura)

novo = gzip.compress(ET.tostring(raiz, encoding="unicode").encode("utf-8"), mtime=0)

if destino.exists() and destino.read_bytes() == novo:
    sys.exit(0)

destino.parent.mkdir(parents=True, exist_ok=True)
destino.write_bytes(novo)
PY
