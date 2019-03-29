#!/bin/bash
# github.com/mamutal91

app=variety.png
icon=$iconsnotify/$app

variavel=${1}
local="${HOME}/Imagens"
name=$(date "+%d-%m-%Y_%H-%M-%S").png
file=$local/$name
type="image/png"

[[ $variavel == "-full" ]] && var="-u" || var="-s"
[[ $variavel == "-full" ]] && msg="Fullscreen" || msg="Recorte"
[ ! -d $local ] && mkdir -p $local

maim $var $file
notify-send -i $icon "Captura de tela" "$msg. $name"
canberra-gtk-play --file=$HOME/.local/share/sounds/screenshot.wav
xclip -selection c -t $type -i $file
