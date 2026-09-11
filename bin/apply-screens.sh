#!/usr/bin/env bash
# Reforca a config de monitor no login: taxa, rotacao, posicao e qual tela e primaria.
#
# O KWin salva isso sozinho em ~/.config/kwinoutputconfig.json, mas nao e confiavel: em
# 10/09/2026 o arquivo foi regravado horas depois de aplicado, provavelmente por um ciclo de
# DPMS (tela apagando por inatividade) que fez o KWin re-negociar o EDID. Cada monitor vai no
# teto real dele (ver Modes: no kscreen-doctor -o -- nao adianta pedir mais que isso): o ASUS
# em 2560x1440@144 e o LG em 1920x1080@144 (143,98 real), que e o preferred dele. Isso era
# resolvido pelo monitores.lua no Hyprland, que era declarativo e reaplicava toda vez.
#
# Idempotente e silencioso: nao imprime nada quando ja esta certo, so age quando falta.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
principal="$("$DOTFILES_DIR/bin/monitor.sh" principal 2>/dev/null)"
vertical="$("$DOTFILES_DIR/bin/monitor.sh" vertical 2>/dev/null)"

[[ -n $principal && -n $vertical ]] || exit 0
command -v kscreen-doctor >/dev/null 2>&1 || exit 0

kscreen-doctor \
    "output.$vertical.mode.1920x1080@144" \
    "output.$vertical.rotation.left" \
    "output.$vertical.position.0,0" \
    "output.$vertical.priority.2" \
    "output.$principal.mode.2560x1440@144" \
    "output.$principal.position.1080,240" \
    "output.$principal.priority.1" \
    >/dev/null 2>&1

# A 3090 (nvidia) tem dummy plug pro IDD/modo-jogo: fica com saida conectada mesmo sem
# desktop nenhum ali. Sem isso o KWin trata como tela de verdade -- sobrepoe o espaco
# virtual dos monitores reais (RX 550) e o Plasma duplica wallpaper/painel nelas.
for st in /sys/class/drm/card*-*/status; do
    [[ -e $st ]] || continue
    [[ $(cat "$st") == connected ]] || continue
    dir="$(dirname "$st")"
    card="$(basename "$dir")"; card="${card%%-*}"
    drv="$(basename "$(readlink -f "/sys/class/drm/$card/device/driver" 2>/dev/null)")"
    [[ $drv == nvidia ]] || continue
    saida="$(basename "$dir")"; saida="${saida#*-}"
    kscreen-doctor "output.$saida.disable" >/dev/null 2>&1
done
