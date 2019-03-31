#!/bin/bash
# github.com/mamutal91

# -s = Recorte
# -u = Fullscreen

app=variety.png
icon=$iconsnotify/$app

var=${1}
msg=${2}

local="${HOME}/Imagens"
name=$(date "+%d-%m-%Y_%H-%M-%S").png
file=$local/$name
type="image/png"

[ ! -d $local ] && mkdir -p $local

maim $var $file
notify-send -i $icon "Captura de tela" "$msg $name"
canberra-gtk-play --file=$HOME/.local/share/sounds/screenshot.wav
xclip -selection c -t $type -i $file
