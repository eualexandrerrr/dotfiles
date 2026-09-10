#!/usr/bin/env bash
set -uo pipefail

APPIMAGE="${RADMIN_APPIMAGE:-$HOME/.local/bin/RadminVPN-Linux-x86_64.AppImage}"
CRED="${RADMIN_CRED:-$HOME/.config/radmin-vpn/RRRDevTests.env}"
ESTADO="$HOME/.local/share/radmin-vpn-linux"
LOG="$ESTADO/run.log"
REPO="baptisterajaut/radmin-vpn-linux"

erro() { printf '  ERRO %s\n' "$*" >&2; }

if [[ ! -x $APPIMAGE ]]; then
    tag=$(curl -fsSI --max-time 15 "https://github.com/$REPO/releases/latest" \
        | grep -i '^location:' | grep -oE 'v[0-9.]+' | head -1)
    [[ -n $tag ]] || { erro "nao descobri a release mais nova de $REPO"; exit 1; }
    mkdir -p "$(dirname "$APPIMAGE")"
    curl -fsSL -o "$APPIMAGE" \
        "https://github.com/$REPO/releases/download/$tag/RadminVPN-Linux-x86_64.AppImage" ||
        { erro "download do AppImage falhou"; exit 1; }
    chmod +x "$APPIMAGE"
fi

# O agrupamento importa: sem ele o `||` pega o `[[ -f ]]` tambem, e o chmod roda
# justamente quando o arquivo nao existe.
if [[ -f $CRED ]]; then
    [[ $(stat -c %a "$CRED") == 600 ]] || chmod 600 "$CRED" 2>/dev/null
fi

parar() {
    # O run.sh do AppImage respawna a GUI, entao TERM na arvore nao basta: ele fica preso
    # em "Closing Radmin VPN..." com um filho em sleep. Mata de dentro pra fora, na marra.
    local p
    for p in $(pgrep -f 'RvRvpnGui\.exe|RvControlSvc\.exe|rvpn_launcher\.exe'); do kill -9 "$p" 2>/dev/null; done
    for p in $(pgrep -f 'mount_Radmin.*run\.sh|mount_Radmin.*AppRun|RadminVPN-Linux'); do kill -9 "$p" 2>/dev/null; done
    pkill -f 'radmin-vpn/tap_bridge' 2>/dev/null
    # Nada de `wineserver -k`: o Wine mora dentro do AppImage, nao no sistema. Quem
    # alcanca o processo montado e o pgrep logo abaixo.
    sleep 2
    for p in $(pgrep -x wineserver); do kill -9 "$p" 2>/dev/null; done
    ip link show radminvpn0 >/dev/null 2>&1 && sudo ip link delete radminvpn0 2>/dev/null
    return 0
}

case "${1:-}" in
    parar|stop) parar; exit 0 ;;
    reiniciar|restart) parar; shift ;;
esac

pgrep -f 'RvControlSvc\.exe' >/dev/null 2>&1 && exit 0

command -v xembedsniproxy >/dev/null 2>&1 &&
    ! pgrep -x xembedsniproxy >/dev/null 2>&1 &&
    setsid -f xembedsniproxy >/dev/null 2>&1

mkdir -p "$ESTADO"
setsid -f "$APPIMAGE" "$@" >>"$LOG" 2>&1 </dev/null
