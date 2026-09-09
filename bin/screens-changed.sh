#!/usr/bin/env bash
# Chamado pelo Hyprland quando um monitor entra ou sai. Resubir os daemons que so leem o
# monitor na inicializacao (waybar, swaync, hyprexpose, hyprswitch) e refazer o wallpaper,
# para que desligar uma tela nunca deixe barra, notificacao ou Alt+Tab fora do lugar.
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
trava="${XDG_RUNTIME_DIR:-/tmp}/telas-mudaram.lock"

exec 9>"$trava"
flock -n 9 || exit 0

# Uma tela que liga dispara varios eventos seguidos; esperar o ultimo evita subir a waybar
# no meio da renumeracao e ter que subir de novo.
sleep 1.5

pkill -x waybar 2>/dev/null
pkill -x swaync 2>/dev/null
pkill -x hyprexpose 2>/dev/null
pkill -x hyprswitch 2>/dev/null

uwsm app -- "$DOTFILES_DIR/bin/waybar.sh" >/dev/null 2>&1 &
uwsm app -- "$DOTFILES_DIR/bin/swaync.sh" >/dev/null 2>&1 &
command -v hyprexpose >/dev/null 2>&1 && uwsm app -- "$DOTFILES_DIR/bin/hyprexpose.sh" >/dev/null 2>&1 &
command -v hyprswitch >/dev/null 2>&1 && uwsm app -- hyprswitch init \
    --custom-css "$HOME/.config/hyprswitch/style.css" \
    --show-title --workspaces-per-row 5 --size-factor 5 >/dev/null 2>&1 &

"$DOTFILES_DIR/bin/wallpaper.sh" >/dev/null 2>&1 &

# O painel so existe se a tela vertical existir. O ExecCondition da unit decide; aqui so se
# pede o start (ligou a tela) ou o stop (desligou), que sem isso ficaria em fullscreen no
# monitor principal.
if [[ -n $("$DOTFILES_DIR/bin/monitor.sh" vertical 2>/dev/null) ]]; then
    systemctl --user start ricepanel.service >/dev/null 2>&1 &
else
    systemctl --user stop ricepanel.service >/dev/null 2>&1 &
fi
