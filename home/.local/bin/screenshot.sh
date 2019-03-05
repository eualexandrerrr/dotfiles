#!/bin/bash
# github.com/mamutal91

# -s = Recorte
# -u = Fullscreen

app=variety.png
icon=$iconsnotify/$app

var=${1}
msg=${2}

[ ! -d $local ] && mkdir -p $local

local="$HOME/Imagens"
name=$(date "+%d-%m-%Y_%H-%M-%S").png
file=$local/$name
type="image/png"

maim $var $file
xclip -selection c -t $type -i $file
notify-send -i $icon "Captura de tela" "$msg $name"
canberra-gtk-play --file=$HOME/.local/share/sounds/screenshot.wav
