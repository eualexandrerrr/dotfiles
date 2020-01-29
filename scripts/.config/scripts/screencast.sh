#!/bin/bash
# github.com/mamutal91

app=screencast.png
icon=$iconsnotify/$app

variable=${1}

local="$HOME/Vídeos"
file=$local/$(date "+%d-%m-%Y_%H-%M-%S")

[ ! -d $local ] && mkdir -p $local

function record(){
	sudo pkill ffmpeg
	DISPLAY=:0 dbus-launch notify-send -i $icon "Gravação de tela" "Início."
	ffmpeg -f x11grab -video_size 1920x1080 -i $DISPLAY -f alsa -i default -c:v ffvhuff -c:a flac $file.mkv
}

function stop(){
	DISPLAY=:0 dbus-launch notify-send -i $icon "Gravação de tela" "Fim."
	sudo pkill ffmpeg
}

[[ $variable == "-start" ]] && record || stop
