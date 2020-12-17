#!/usr/bin/env bash
# github.com/mamutal91

# -s = Recorte
# -u = Fullscreen

dir="${HOME}/Images/Screenshots/"
icon="$HOME/.config/files/icons/screenshot.png"

params=${1}
date=$(date +%Y-%m-%d_%H-%M-%S)
name="ss-${date}"
file="$name.png"

maim $params $dir$file

xclip -selection c -t image/png -i $dir$file

notify-send -i $icon "Captura de tela" "$msg $name"
play $HOME/.config/files/sounds/screenshot.wav
exit 0
