#!/usr/bin/env bash
# Resolve um monitor pela MARCA, nao pelo conector: monitor.sh [--desc|--xrandr] principal|vertical
# imprime o conector do kernel (DP-1, HDMI-A-1...), a descricao completa do EDID ou o nome
# que o servidor X da ao mesmo monitor (DisplayPort-0, HDMI-A-0...), que nao e o mesmo.
#
# Le o EDID direto de /sys/class/drm, de proposito: nao depende de compositor nenhum, entao
# serve igual dentro do Plasma, de um tty ou de um ExecCondition do systemd, que roda antes
# da sessao grafica existir. A marca sai do screens.conf, unica fonte da verdade.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
telas="$DOTFILES_DIR/screens.conf"

campo="name"
case "${1:-}" in
    --desc)   campo="description"; shift ;;
    --xrandr) campo="xrandr";      shift ;;
esac
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

def nome_no_x(edid):
    # `xrandr --verbose` imprime o EDID em hex, 16 bytes por linha, indentado sob a saida.
    import re, subprocess
    try:
        saida = subprocess.run(["xrandr", "--verbose"], capture_output=True, text=True,
                               timeout=10).stdout
    except (OSError, subprocess.SubprocessError):
        return ""
    atual, hexa, lendo = "", [], False
    achados = {}
    for linha in saida.splitlines() + ["fim conectado"]:
        if re.match(r"^\S+ (connected|disconnected)", linha):
            if atual and hexa:
                achados[atual] = "".join(hexa)
            atual, hexa, lendo = linha.split()[0], [], False
        elif "EDID:" in linha:
            lendo = True
        elif lendo and re.match(r"^\s+[0-9a-f]+\s*$", linha):
            hexa.append(linha.strip())
        elif lendo:
            lendo = False
    alvo_hex = edid[:128].hex()
    for nome, blob in achados.items():
        if blob.startswith(alvo_hex):
            return nome
    return ""

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
    if not alvo or alvo not in desc.upper():
        continue
    if campo == "description":
        print(desc)
    elif campo == "xrandr":
        # O X nomeia a mesma saida de outro jeito (DisplayPort-0 no lugar de DP-4), entao
        # casar os dois pelo EDID, que e o mesmo byte a byte nos dois lados.
        print(nome_no_x(dados) or "")
    else:
        print(conector)
    sys.exit(0)
sys.exit(1)
PY
