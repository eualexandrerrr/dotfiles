#!/bin/bash
# github.com/mamutal91

app=variety.png
icon=$iconsnotify/$app

variavel=${1}

local="${HOME}/Imagens"
file=$local/$(date "+%d-%m-%Y_%H-%M-%S").png
tipo="image/png"

[ ! -d $local ] && mkdir -p $local

function full(){
	maim $file
	notify-send -i $icon "Captura de tela" "Fullscreen."
	canberra-gtk-play --file=$HOME/.local/share/sounds/screenshot.wav
	xclip -selection c -t $tipo -i $file
}

function cortar(){
	maim -s $file
	notify-send -i $iconfim "Gravação de tela" "Fim."
	canberra-gtk-play --file=$HOME/.local/share/sounds/screenshot.wav
	xclip -selection c -t $tipo -i $file
}

[[ $variavel == "-full" ]] && full || cortar
