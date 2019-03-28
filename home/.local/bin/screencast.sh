#!/bin/bash
# github.com/mamutal91

app=audience.png
appfim=XMind.png
icon=$iconsnotify/$app
iconfim=$iconsnotify/$appfim

variavel=${1}

local=/home/mamutal91/Videos/
file=$local/Screencast-$(date "+%Y-%m-%d_%H-%M-%S")

function gravar(){
	notify-send -i $icon "Gravação de tela" "Início."
	canberra-gtk-play --file=$HOME/.local/share/sounds/screencast-start.wav
	ffmpeg -f x11grab -video_size 1920x1080 -i $DISPLAY -f alsa -i default -c:v ffvhuff -c:a flac $file.mkv
}

function parar(){
	notify-send -i $iconfim "Gravação de tela" "Fim."
	canberra-gtk-play --file=$HOME/.local/share/sounds/screencast-stop.wav
	sudo pkill ffmpeg
}

[[ $variavel == "-start" ]] && gravar || parar
