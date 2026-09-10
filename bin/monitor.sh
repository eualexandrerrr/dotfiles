#!/usr/bin/env bash
# Resolve um monitor pela MARCA, nao pelo conector: monitor.sh [--desc] principal|vertical
# imprime o conector atual (DP-1, HDMI-A-1...) ou a descricao completa do EDID.
#
# Le o EDID direto de /sys/class/drm, de proposito: nao depende de compositor nenhum, entao
# serve igual dentro do Plasma, de um tty ou de um ExecCondition do systemd, que roda antes
# da sessao grafica existir. A marca sai do telas.conf, unica fonte da verdade.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
telas="$DOTFILES_DIR/telas.conf"

campo="name"
if [[ ${1:-} == --desc ]]; then
    campo="description"
    shift
fi
papel="${1:-principal}"

[[ -f $telas ]] || exit 1
marca="$(sed -n "s/^$papel=//p" "$telas" | head -1)"
[[ -n $marca ]] || exit 1

MARCA="$marca" CAMPO="$campo" python3 - <<'PY'
import glob, os, sys

def texto_edid(b):
    # Descritores de 18 bytes a partir do offset 54: tipo 0xFC e o nome do modelo,
    # 0xFF o serial. O fabricante vem codificado em 5 bits por letra nos bytes 8-9.
    nomes = []
    for off in range(54, 126, 18):
        d = b[off:off+18]
        if len(d) < 18 or d[0:2] != b"\x00\x00":
            continue
        if d[3] in (0xFC, 0xFF):
            nomes.append((d[3], d[5:18].split(b"\n")[0].decode("ascii", "ignore").strip()))
    if len(b) < 10:
        return ""
    n = (b[8] << 8) | b[9]
    fab = "".join(chr(((n >> s) & 0x1F) + ord("@")) for s in (10, 5, 0))
    modelo = next((v for t, v in nomes if t == 0xFC), "")
    return " ".join(x for x in (fab, modelo) if x)

marca = os.environ["MARCA"]
campo = os.environ["CAMPO"]

# O EDID nao guarda o nome comercial do fabricante ("ASUSTek COMPUTER INC"), so o codigo de
# tres letras ("AUS"/"GSM"). Casar pelo modelo, que e o que distingue as telas aqui.
alvo = marca.split()[-1].upper()

for caminho in sorted(glob.glob("/sys/class/drm/card*-*/edid")):
    conector = os.path.basename(os.path.dirname(caminho)).split("-", 1)[1]
    est = os.path.join(os.path.dirname(caminho), "status")
    try:
        if open(est).read().strip() != "connected":
            continue
        dados = open(caminho, "rb").read()
    except OSError:
        continue
    if not dados:
        continue
    desc = texto_edid(dados)
    if alvo and alvo in desc.upper():
        print(conector if campo == "name" else desc)
        sys.exit(0)
sys.exit(1)
PY
