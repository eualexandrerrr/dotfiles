#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

# -s = Recorte
# -u = Fullscreen

app=screenshot.png
icon=$icons/$app

var=${1}
msg=${2}

local=$HOME/Images
[ ! -d $local ] && mkdir -p $local

name=$(date "+%d-%m-%Y_%H-%M-%S").png
file=$local/$name
type="image/png"

maim $var -u $file
sleep 1
xclip -selection c -t $type -i $file

DISPLAY=:0 dbus-launch notify-send -i $icon "Captura de tela" "$msg $name"
canberra-gtk-play --file=$HOME/.config/files/sounds/screenshot.wav
