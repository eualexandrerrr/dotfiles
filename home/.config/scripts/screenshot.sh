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
nome="ss-${data}"
extensao=".png"
atraso=10
icon="$HOME/.config/files/icons/screenshot.png"
tipo="image/png"
lixeira="${HOME}/.local/share/Trash"
borda="10"

[ ! -d $dir ] && mkdir -p $dir
[ ! -d $lixeira ] && mkdir -p $lixeira

if [ "$1" == "-c" ]; then
	icone="${HOME}/.local/share/icons/elementary/user-trash.png"
	listagem=(${dir}*)
	if [ ${#listagem[@]} -gt 0 ]; then
		mv ${dir}* ${lixeira}/files/
		msg="Pasta de screenshots limpa!"
		export DISPLAY=:0 ; canberra-gtk-play -i trash-empty 2>&1
	else
		msg="Pasta de screenshots já está vazia!"
	fi
	exit 0
elif [ "$1" == "-w" ]; then
	[ "$app" == "maim" ] && params="$params -i $(xdotool getactivewindow) -p $borda" || params="$params -w"
	arquivo="${nome}-window${extensao}"
	$app $params ${dir}${arquivo}
elif [ "$1" == "-s" ]; then
	params="$params -s"
	arquivo="${nome}-sel${extensao}"
	$app -d 2 $params ${dir}${arquivo}
elif [ "$1" == "-d" ]; then
	params="$params -d $atraso"
	arquivo="${nome}-delay${extensao}"
	$app $params ${dir}${arquivo}
elif [ "$1" == "-e" ]; then
	arquivo="${nome}-edit${extensao}"
	$app $params ${dir}${arquivo}
	viewnior ${dir}${arquivo}
else
	arquivo="${nome}${extensao}"
	$app $params ${dir}${arquivo}
fi

if [ ! -z $arquivo ]; then
	xclip -selection c -t $tipo -i $dir$arquivo
fi

notify-send -i $icon "Captura de tela" "$msg $name"
canberra-gtk-play --file=$HOME/.config/files/sounds/screenshot.wav
exit 0
