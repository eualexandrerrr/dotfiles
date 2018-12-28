#!/bin/bash
# github.com/mamutal91

if [ -f $HOME/.config/user-dirs.dirs ]; then
	source $HOME/.config/user-dirs.dirs
	dir="${XDG_PICTURES_DIR}/Screenshots/"
else
	dir="${HOME}/Imagens/Screenshots/"
fi

app="maim"
params="-u"
data=$(date +%Hh%Mm%Ss-%d-%m-%Y)
nome="Screenshot-${data}"
extensao=".png"
atraso=10
tipo="image/png"
lixeira="${HOME}/.local/share/Trash"
titulo="."

[ ! -d $dir ] && mkdir -p $dir
[ ! -d $lixeira ] && mkdir -p $lixeira

command -v $app >/dev/null 2>&1 || {
	msg="O aplicativo $app não está instalado." 

	command -v notify-send >/dev/null 2>&1 && {
		notify-send "ERRO" "$msg";
	} || {
		echo $msg;
	}

	exit 1;
}

if [ "$1" == "-c" ]; then

	exit 0

elif [ "$1" == "-w" ]; then
	params="$params -w"
	arquivo="${nome}-window${extensao}"
	$app $params ${arquivo}
	msg="Imagens/Screenshots/$arquivo"
elif [ "$1" == "-s" ]; then
	params="$params -s"
	arquivo="${nome}-sel${extensao}"
	$app -d 2 $params ${arquivo}
	msg="Imagens/Screenshots/$arquivo"
elif [ "$1" == "-d" ]; then
	params="$params -d $atraso"
	arquivo="${nome}-delay${extensao}"
	$app $params ${arquivo}
	msg="Imagens/Screenshots/$arquivo"
elif [ "$1" == "-e" ]; then
	arquivo="${nome}-edit${extensao}"
	$app $params ${dir}${arquivo}
	msg="Imagens/Screenshots/$arquivo"
	viewnior ${dir}${arquivo}
else
	arquivo="${nome}${extensao}"
	$app $params ${arquivo}
	msg="Imagens/Screenshots/$arquivo"
fi

if [ ! -z $arquivo ]; then
	if [ $(pwd) != $dir ]; then
		mv $arquivo $dir
	fi
	xclip -selection c -t $tipo -i $dir$arquivo
fi

notify-send -i $titulo "Captura de tela realizada" "$msg"
canberra-gtk-play --file=$HOME/.local/share/sounds/screenshot.wav
exit 0