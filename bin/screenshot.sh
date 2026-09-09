#!/usr/bin/env bash
# Captura de tela do Hyprland. Substitui o Spectacle.
#
#   ~/.dotfiles/bin/screenshot.sh tela      monitor focado -> arquivo + clipboard
#   ~/.dotfiles/bin/screenshot.sh regiao    selecao        -> arquivo + clipboard
#   ~/.dotfiles/bin/screenshot.sh anotar    selecao        -> satty para anotar
#   ~/.dotfiles/bin/screenshot.sh gravar    liga/desliga a gravacao de tela
set -uo pipefail

PASTA="${XDG_PICTURES_DIR:-$HOME/Downloads}/Capturas"
CARIMBO="$(date +%Y-%m-%d_%H-%M-%S)"
VIDEO="/tmp/gravacao-tela.mp4"

aviso() { command -v notify-send >/dev/null 2>&1 && notify-send "Captura" "$1" || printf '%s\n' "$1"; }

falta() {
    local p
    for p in "$@"; do
        command -v "$p" >/dev/null 2>&1 || { aviso "$p nao esta instalado"; exit 1; }
    done
}

monitor_focado() {
    hyprctl monitors -j | python3 -c "
import json,sys
for m in json.load(sys.stdin):
    if m.get('focused'):
        print(m['name']); break
"
}

case "${1:-regiao}" in
    tela)
        falta grim wl-copy
        mkdir -p "$PASTA"
        arquivo="$PASTA/tela-$CARIMBO.png"
        grim -o "$(monitor_focado)" "$arquivo" || { aviso "grim falhou"; exit 1; }
        wl-copy --type image/png < "$arquivo"
        aviso "Tela salva em $(basename "$arquivo")"
        ;;

    regiao)
        falta grim slurp wl-copy
        mkdir -p "$PASTA"
        area="$(slurp -d)" || exit 0
        arquivo="$PASTA/regiao-$CARIMBO.png"
        grim -g "$area" "$arquivo" || { aviso "grim falhou"; exit 1; }
        wl-copy --type image/png < "$arquivo"
        aviso "Recorte salvo em $(basename "$arquivo")"
        ;;

    anotar)
        falta grim slurp satty
        mkdir -p "$PASTA"
        area="$(slurp -d)" || exit 0
        grim -g "$area" - | satty --filename - \
            --output-filename "$PASTA/anotado-$CARIMBO.png" \
            --early-exit --copy-command wl-copy
        ;;

    gravar)
        falta wf-recorder slurp
        if pkill -INT -x wf-recorder 2>/dev/null; then
            sleep 0.5
            mkdir -p "$PASTA"
            destino="$PASTA/gravacao-$CARIMBO.mp4"
            mv "$VIDEO" "$destino" 2>/dev/null && aviso "Gravacao salva em $(basename "$destino")"
            exit 0
        fi
        area="$(slurp -d)" || exit 0
        aviso "Gravando. Meta+Shift+R para parar."
        wf-recorder -g "$area" -f "$VIDEO" --codec libx264 -x yuv420p >/dev/null 2>&1 &
        ;;

    *)
        printf 'uso: %s [tela|regiao|anotar|gravar]\n' "$(basename "$0")" >&2
        exit 1
        ;;
esac
