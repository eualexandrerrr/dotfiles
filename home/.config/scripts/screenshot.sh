#!/bin/bash
# github.com/mamutal91

# -s = Recorte
# -u = Fullscreen

local=$HOME/Images/Screenshots
[ ! -d $local ] && mkdir -p $local

dir="${HOME}/Images/Screenshots/"

app="maim"
#params="-u"
params=""
data=$(date +%Y-%m-%d_%H-%M-%S)
name="ss-${data}"
ext=".png"
delay=10
icon="$HOME/.config/files/icons/screenshot.png"
tipo="image/png"
trash="${HOME}/.local/share/Trash"
border="10"

[ ! -d $dir ] && mkdir -p $dir
[ ! -d $trash ] && mkdir -p $trash

if [ "$1" == "-c" ]; then
	icon="${HOME}/.local/share/icons/elementary/user-trash.png"
	listagem=(${dir}*)
	if [ ${#listagem[@]} -gt 0 ]; then
		mv ${dir}* ${trash}/files/
		msg="Pasta de screenshots limpa!"
		export DISPLAY=:0 ; canberra-gtk-play -i trash-empty 2>&1
	else
		msg="Pasta de screenshots já está vazia!"
	fi
	exit 0
elif [ "$1" == "-w" ]; then
	[ "$app" == "maim" ] && params="$params -i $(xdotool getactivewindow) -p $border" || params="$params -w"
	file="${name}-window${ext}"
	$app $params ${dir}${file}
elif [ "$1" == "-s" ]; then
	params="$params -s"
	file="${name}-sel${ext}"
	$app -d 2 $params ${dir}${file}
elif [ "$1" == "-d" ]; then
	params="$params -d $delay"
	file="${name}-delay${ext}"
	$app $params ${dir}${file}
elif [ "$1" == "-e" ]; then
	file="${name}-edit${ext}"
	$app $params ${dir}${file}
	viewnior ${dir}${file}
else
	file="${name}${ext}"
	$app $params ${dir}${file}
fi

if [ ! -z $file ]; then
	xclip -selection c -t $tipo -i $dir$file
fi

notify-send -i $icon "Captura de tela" "$msg $name"
canberra-gtk-play --file=$HOME/.config/files/sounds/screenshot.wav
exit 0
