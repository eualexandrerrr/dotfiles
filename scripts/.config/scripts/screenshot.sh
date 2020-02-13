#!/bin/bash
# github.com/mamutal91

# -s = Recorte
# -u = Fullscreen

app=screenshot.png
icon=$icons_path/$app

var=${1}
msg=${2}

local="$HOME/Imagens"
[ ! -d $local ] && mkdir -p $local

name=$(date "+%d-%m-%Y_%H-%M-%S").png
file=$local/$name
type="image/png"

maim $var -u $file
sleep 2
xclip -selection c -t $type -i $file
sleep 1
DISPLAY=:0 dbus-launch notify-send -i $icon "Captura de tela" "$msg $name"
canberra-gtk-play --file=$HOME/.config/files/sounds/screenshot.wav
