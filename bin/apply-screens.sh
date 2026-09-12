#!/usr/bin/env bash
# Reforca a config de monitor no login: taxa, rotacao, posicao e qual tela e primaria.
#
# A disposicao e uma so e vale em qualquer desktop -- o que muda e quem aplica. Cada familia
# tem seu backend aqui embaixo: kscreen-doctor no Plasma, D-Bus do mutter no GNOME, xrandr em
# todos os X11 (XFCE, Cinnamon, MATE, LXQt, Budgie), hl.monitor no Hyprland e no NAnDoroid,
# cosmic-randr no COSMIC. Nenhum deles sabe qual conector e qual tela: isso vem do
# bin/monitor.sh, que resolve pela marca no EDID.
#
# Cada monitor vai no teto real dele (ver Modes: no kscreen-doctor -o -- nao adianta pedir
# mais que isso): o ASUS em 2560x1440@144 e o LG em 1920x1080@144 (143,98 real), que e o
# preferred dele. O LG fica girado a esquerda, entao ocupa 1080x1920 e empurra o ASUS pra
# x=1080; o y=240 alinha o centro dos dois.
#
# Idempotente e silencioso: nao imprime nada quando ja esta certo, so age quando falta.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

# Rodando de um tty (o setup.sh, por exemplo) nada disso esta no ambiente: pegar da sessao
# grafica de pe, senao o backend escolhido seria o errado -- ou nenhum.
for _v in XDG_CURRENT_DESKTOP XDG_SESSION_TYPE WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE; do
    [[ -n ${!_v:-} ]] && continue
    _val="$(/usr/bin/systemctl --user show-environment 2>/dev/null | sed -n "s/^$_v=//p" | head -1)"
    [[ -n $_val ]] && export "$_v=$_val"
done
unset _v _val

# Qual familia de desktop aplicar. A sessao de pe manda; sem ela (o setup.sh logo depois do
# format, antes do primeiro login) vale a escolha gravada pelo install.sh. Backend que so
# funciona com o compositor rodando sai vazio nesse caso -- quem aplica dali e a
# apply-screens.service, no login.
DEFILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/de"
familia() {
    if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then printf 'hypr'; return; fi
    case "${XDG_CURRENT_DESKTOP:-}" in
        *COSMIC*)   printf 'cosmic'; return ;;
        *KDE*)      printf 'kde';    return ;;
        *Hyprland*) printf 'hypr';   return ;;
        *XFCE*)     printf 'xfce';   return ;;
        *Cinnamon*) printf 'cinnamon'; return ;;
        *MATE*)     printf 'mate';   return ;;
        *LXQt*)     printf 'lxqt';   return ;;
        *GNOME*|*Budgie*) printf 'gnome'; return ;;
    esac

    local escolhido=""
    [[ -f $DEFILE ]] && escolhido="$(<"$DEFILE")"
    case "${escolhido//[[:space:]]/}" in
        kde)                 printf 'kde'      ;;
        gnome|budgie)        printf 'gnome'    ;;
        xfce)                printf 'xfce'     ;;
        cinnamon)            printf 'cinnamon' ;;
        mate)                printf 'mate'     ;;
        lxqt)                printf 'lxqt'     ;;
        cosmic)              printf 'cosmic'   ;;
        hyprland|nandoroid)  printf 'hypr'     ;;
    esac
}

# A disposicao, em um lugar so. Quem mexer aqui muda todos os desktops de uma vez.
PRINC_W=2560; PRINC_H=1440; PRINC_HZ=144; PRINC_X=1080; PRINC_Y=240
VERT_W=1920;  VERT_H=1080;  VERT_HZ=144;  VERT_X=0;     VERT_Y=0

principal="$("$DOTFILES_DIR/bin/monitor.sh" principal 2>/dev/null)"
vertical="$("$DOTFILES_DIR/bin/monitor.sh" vertical 2>/dev/null)"
[[ -n $principal && -n $vertical ]] || exit 0

# Saidas da 3090: ela tem dummy plug pro IDD/modo-jogo e fica "connected" sem ter desktop
# nenhum ali. Quem enxerga isso como tela de verdade duplica painel e papel de parede nelas.
saidas_nvidia() {
    local st dir card drv
    for st in /sys/class/drm/card*-*/status; do
        [[ -e $st ]] || continue
        [[ $(cat "$st") == connected ]] || continue
        dir="$(dirname "$st")"
        card="$(basename "$dir")"; card="${card%%-*}"
        drv="$(basename "$(readlink -f "/sys/class/drm/$card/device/driver" 2>/dev/null)")"
        [[ $drv == nvidia ]] || continue
        printf '%s\n' "$(basename "$dir" | cut -d- -f2-)"
    done
}

backend_kscreen() {
    kscreen-doctor \
        "output.$vertical.mode.${VERT_W}x${VERT_H}@${VERT_HZ}" \
        "output.$vertical.rotation.left" \
        "output.$vertical.position.$VERT_X,$VERT_Y" \
        "output.$vertical.priority.2" \
        "output.$principal.mode.${PRINC_W}x${PRINC_H}@${PRINC_HZ}" \
        "output.$principal.position.$PRINC_X,$PRINC_Y" \
        "output.$principal.priority.1" \
        >/dev/null 2>&1

    local saida
    while read -r saida; do
        [[ -n $saida ]] && kscreen-doctor "output.$saida.disable" >/dev/null 2>&1
    done < <(saidas_nvidia)
}

# GNOME e qualquer outro mutter: nao existe arquivo pra escrever a mao que valha de imediato,
# e o monitors.xml exige a taxa com a precisao que o compositor usa internamente (143,981 e
# nao 144). O jeito certo e o D-Bus: ele devolve os modos reais, e o metodo 2 (persistente)
# aplica agora e grava o monitors.xml sozinho, entao o proximo login ja nasce certo.
backend_mutter() {
    # O mutter nomeia a saida de outro jeito (HDMI-2 onde o kernel diz HDMI-A-2), entao aqui
    # o casamento e por marca do EDID -- o mesmo texto que o monitor.sh --desc imprime.
    PRINCIPAL="$("$DOTFILES_DIR/bin/monitor.sh" --desc principal 2>/dev/null)" \
    VERTICAL="$("$DOTFILES_DIR/bin/monitor.sh" --desc vertical 2>/dev/null)" \
    PRINC="${PRINC_W}x${PRINC_H}@${PRINC_HZ}@${PRINC_X},${PRINC_Y}" \
    VERT="${VERT_W}x${VERT_H}@${VERT_HZ}@${VERT_X},${VERT_Y}" \
    python3 - <<'PY'
import os, sys
import gi
gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

SERVICOS = (
    ("org.gnome.Mutter.DisplayConfig", "/org/gnome/Mutter/DisplayConfig",
     "org.gnome.Mutter.DisplayConfig"),
    ("org.cinnamon.Muffin.DisplayConfig", "/org/cinnamon/Muffin/DisplayConfig",
     "org.cinnamon.Muffin.DisplayConfig"),
)

def spec(txt):
    modo, pos = txt.split("@", 1)[0], txt.rsplit("@", 1)[1]
    hz = float(txt.split("@")[1])
    w, h = (int(v) for v in modo.split("x"))
    x, y = (int(v) for v in pos.split(","))
    return w, h, hz, x, y

bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
proxy = None
for nome, caminho, iface in SERVICOS:
    try:
        p = Gio.DBusProxy.new_sync(bus, Gio.DBusProxyFlags.NONE, None, nome, caminho, iface, None)
        if p.get_name_owner():
            proxy = p
            break
    except GLib.Error:
        continue
if proxy is None:
    sys.exit(0)

serial, monitores, logicos, _props = proxy.call_sync(
    "GetCurrentState", None, Gio.DBusCallFlags.NONE, -1, None).unpack()

def achar(desc, w, h, hz):
    for (spec_mon, modos, _p) in monitores:
        conector, fabricante, produto, _serie = spec_mon
        if "%s %s" % (fabricante, produto) != desc:
            continue
        candidatos = [m for m in modos if m[1] == w and m[2] == h]
        if not candidatos:
            return None, None
        # A taxa vem como float real (143.981003): pegar a mais proxima da pedida.
        return conector, min(candidatos, key=lambda m: abs(m[3] - hz))[0]
    return None, None

pw, ph, phz, px, py = spec(os.environ["PRINC"])
vw, vh, vhz, vx, vy = spec(os.environ["VERT"])
principal, vertical = os.environ["PRINCIPAL"], os.environ["VERTICAL"]

con_princ, id_princ = achar(principal, pw, ph, phz)
con_vert, id_vert = achar(vertical, vw, vh, vhz)
if not id_princ or not id_vert:
    sys.exit(0)

# transform 1 = 90 graus, o mesmo "girado a esquerda" do kscreen-doctor.
config = GLib.Variant(
    "(uua(iiduba(ssa{sv}))a{sv})",
    (serial, 2,
     [(vx, vy, 1.0, 1, False, [(con_vert, id_vert, {})]),
      (px, py, 1.0, 0, True, [(con_princ, id_princ, {})])],
     {}),
)
try:
    proxy.call_sync("ApplyMonitorsConfig", config, Gio.DBusCallFlags.NONE, -1, None)
except GLib.Error as e:
    print("apply-screens: mutter recusou a config -- %s" % e.message, file=sys.stderr)
    sys.exit(1)
PY
}

backend_xrandr() {
    # No X o mesmo monitor tem outro nome (DisplayPort-0, e nao DP-4); o monitor.sh casa os
    # dois pelo EDID. Sem o casamento, xrandr responderia "cannot find output".
    local px vx
    px="$("$DOTFILES_DIR/bin/monitor.sh" --xrandr principal 2>/dev/null)"
    vx="$("$DOTFILES_DIR/bin/monitor.sh" --xrandr vertical 2>/dev/null)"
    [[ -n $px && -n $vx ]] || return 0

    xrandr \
        --output "$vx" --mode "${VERT_W}x${VERT_H}" --rate "$VERT_HZ" \
                 --rotate left --pos "${VERT_X}x${VERT_Y}" \
        --output "$px" --mode "${PRINC_W}x${PRINC_H}" --rate "$PRINC_HZ" \
                 --rotate normal --pos "${PRINC_X}x${PRINC_Y}" --primary \
        >/dev/null 2>&1
}

# Hyprland le config, nao aceita comando: o `hyprctl keyword` saiu junto com o hyprlang. O
# arquivo abaixo e gerado e carregado por ultimo, entao vence o hl.monitor generico que o
# NAnDoroid escreve. `hyprctl reload` aplica na sessao de pe.
backend_hypr() {
    mkdir -p "$CFG/hypr/configs"
    cat > "$CFG/hypr/configs/screens.lua" <<LUA
-- Gerado por ~/.dotfiles/bin/apply-screens.sh -- reescrito a cada execucao, nao edite aqui.
-- transform = 1 e o giro de 90 graus do monitor vertical.
hl.monitor({ output = "$principal", mode = "${PRINC_W}x${PRINC_H}@${PRINC_HZ}", position = "${PRINC_X}x${PRINC_Y}", scale = 1 })
hl.monitor({ output = "$vertical", mode = "${VERT_W}x${VERT_H}@${VERT_HZ}", position = "${VERT_X}x${VERT_Y}", scale = 1, transform = 1 })
LUA

    local raiz="$CFG/hypr/hyprland.lua"
    if [[ ! -f $raiz ]]; then
        # Hyprland de fabrica so copia o exemplo dele na primeira subida. Copiar aqui e o que
        # deixa a tela certa ja no primeiro frame -- e sem os binds do exemplo a sessao nasce
        # sem terminal e sem menu, entao o arquivo tem que ser o deles, nao um pedaco.
        [[ -f /usr/share/hypr/hyprland.lua ]] && cp /usr/share/hypr/hyprland.lua "$raiz"
    fi
    if [[ -f $raiz ]] && ! grep -q 'configs/screens' "$raiz"; then
        printf '\n-- Acrescentado por ~/.dotfiles/bin/apply-screens.sh\nrequire("configs/screens")\n' >> "$raiz"
    fi

    # A 3090 so sai de cena pelo AQ_DRM_DEVICES, e o SDDM nao le environment.d: enquanto a
    # variavel nao pega, os dummy plugs dela entram como tela de verdade e o desktop ganha
    # dois monitores fantasma. Desligar por nome resolve na sessao que ja esta de pe.
    local saida
    while read -r saida; do
        [[ -n $saida ]] || continue
        printf 'hl.monitor({ output = "%s", disabled = true })\n' "$saida" >> "$CFG/hypr/configs/screens.lua"
    done < <(saidas_nvidia)

    [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && hyprctl reload >/dev/null 2>&1
    return 0
}

backend_cosmic() {
    cosmic-randr mode "$principal" "$PRINC_W" "$PRINC_H" --refresh "$PRINC_HZ" \
        --pos-x "$PRINC_X" --pos-y "$PRINC_Y" --scale 1 --transform normal >/dev/null 2>&1
    cosmic-randr mode "$vertical" "$VERT_W" "$VERT_H" --refresh "$VERT_HZ" \
        --pos-x "$VERT_X" --pos-y "$VERT_Y" --scale 1 --transform rotate90 >/dev/null 2>&1
    cosmic-randr xwayland --primary "$principal" >/dev/null 2>&1

    local saida
    while read -r saida; do
        [[ -n $saida ]] && cosmic-randr disable "$saida" >/dev/null 2>&1
    done < <(saidas_nvidia)

    # O painel guarda o conector pelo nome, e o nome muda: com a 3090 saindo pro vfio, o que
    # era HDMI-A-2 virou HDMI-A-1 e o painel sumiu da tela inteira, sem erro no log
    # (12/09/2026). Reescrever com o nome de agora, e so reiniciar quando mudou mesmo.
    local arq="$CFG/cosmic/com.system76.CosmicPanel.Panel/v1/output"
    if [[ -f $arq ]]; then
        local desejado="Name(\"$principal\")"
        if [[ $(<"$arq") != "$desejado" ]]; then
            printf '%s' "$desejado" > "$arq"
            pkill -x cosmic-panel >/dev/null 2>&1
        fi
    fi
    return 0
}

# Quem aplica sai da familia do desktop. X11 e mutter nao se confundem porque a familia ja
# separa os dois: Cinnamon e Budgie rodam em X11 aqui, mesmo publicando D-Bus de display.
case "$(familia)" in
    hypr)
        backend_hypr ;;
    cosmic)
        command -v cosmic-randr >/dev/null 2>&1 && backend_cosmic ;;
    kde)
        command -v kscreen-doctor >/dev/null 2>&1 && backend_kscreen ;;
    xfce|cinnamon|mate|lxqt)
        # So tem o que fazer com o X de pe: xrandr nao escreve config, ele fala com o servidor.
        [[ -n ${DISPLAY:-} ]] && command -v xrandr >/dev/null 2>&1 && backend_xrandr ;;
    gnome)
        [[ -n ${WAYLAND_DISPLAY:-}${DISPLAY:-} ]] && backend_mutter ;;
esac
