#!/usr/bin/env bash
# Opacidade do fundo da barra, em porcentagem (0 = invisivel, 100 = o tema cheio).
# O Plasma so oferece tres estados (adaptativo/opaco/translucido), entao o meio-termo sai
# daqui: reescreve a variante translucida do tema a partir da opaca, com a opacidade pedida
# nos grupos que desenham o fundo. Sempre parte da opaca, entao rodar de novo nao acumula.
#
#   ~/.dotfiles/bin/painel-opacidade.sh 25
set -uo pipefail

PCT="${1:-25}"
TEMA="${TEMA_PLASMA:-Dream-Color-Plasma}"
RAIZ="$HOME/.local/share/plasma/desktoptheme/$TEMA"
ORIGEM="$RAIZ/solid/widgets/panel-background.svg"
DESTINO="$RAIZ/translucent/widgets/panel-background.svg"

[[ $PCT =~ ^[0-9]+$ ]] && (( PCT <= 100 )) || { echo "opacidade tem que ser 0-100" >&2; exit 1; }
[[ -f $ORIGEM ]] || { echo "sem $ORIGEM -- o tema $TEMA nao esta instalado" >&2; exit 1; }

python3 - "$ORIGEM" "$DESTINO" "$PCT" <<'PY'
import re, sys

origem, destino, pct = sys.argv[1], sys.argv[2], int(sys.argv[3])
alfa = pct / 100.0
svg = open(origem).read()

# So os pedacos que pintam o fundo. mask-*, shadow-* e hint-* ficam intactos: sao eles que
# dao a forma da barra e a regiao de blur do KWin. Cada peca do 9-patch pode ser <g>, <rect>
# ou <use>, dependendo de como o autor desenhou -- por isso o elemento nao entra no padrao.
fundo = ('center top bottom left right '
         'topleft topright bottomleft bottomright').split()

def aplicar(m):
    tag = re.sub(r'\s+opacity="[^"]*"', '', m.group(0))
    fecha = '/>' if tag.rstrip().endswith('/>') else '>'
    corpo = tag.rstrip()[:-len(fecha)].rstrip()
    return '%s opacity="%s"%s' % (corpo, alfa, fecha)

n = 0
for gid in fundo:
    svg, k = re.subn(r'<\w+\b[^>]*\bid="%s"[^>]*?/?>' % gid, aplicar, svg, count=1)
    n += k

open(destino, 'w').write(svg)
print('%d grupo(s) de fundo em %d%%' % (n, pct))
PY
