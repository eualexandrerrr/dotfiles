#!/usr/bin/env bash
# github.com/mamutal91

# -s = Recorte
# -u = Fullscreen

icon="${iconpath}/blueman-camera.svg"

params=${1}
date=$(date +%Y-%m-%d_%H-%M-%S)
name="ss-${date}"
file="$name.png"

maim $params $dir$file

xclip -selection c -t image/png -i $dir$file

notify-send -i $icon "Captura de tela" "$msg $name"
play ~/.bin/sounds/screenshot.wav
echo $icon
exit 0
