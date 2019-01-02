#!/bin/bash
# github.com/mamutal91

resolucao=$(xrandr | grep '*' | awk 'NR==1{print $1}')
audio=$(pacmd list-sinks | grep -A 1 'index: 0' | awk 'NR==2{print $2}' | awk '{print substr($0,2,length($0)-2)}')

app="ffmpeg"

command -v $app >/dev/null 2>&1 || {
	msg="O aplicativo $app não está instalado." 

	command -v notify-send >/dev/null 2>&1 && {
		notify-send "ERRO" "$msg";
	} || {
		echo $msg;
	}

	exit 1;
}

if [ -f $HOME/.config/user-dirs.dirs ]; then
    source $HOME/.config/user-dirs.dirs
    caminho="${XDG_VIDEOS_DIR}/Screencasts/"
else
    caminho="${HOME}/Vídeos/Screencasts/"
fi

if [ ! $1 ]; then
        data=$(date +%Hh%Mm%Ss-%d-%m-%Y)
        arquivo="${caminho}/Screencast-${data}.mp4"
        [ ! -d $caminho ] && mkdir -p $caminho
        fi

        if pgrep -x "ffmpeg" > /dev/null
        then
        [ "$(pgrep -x polybar)" ] && [ "$1" == "status" ] && echo "%{F-}" && exit
        if [ ! $1 ]; then
                canberra-gtk-play --file=$HOME/.local/share/sounds/screencast-stop.wav
                killall ffmpeg
                notify-send "Gravação finalizada"
                exit 0
        fi
        else
        [ "$(pgrep -x polybar)" ] && [ "$1" == "status" ] && echo "" && exit
        if [ ! "$1" ]; then
                notify-send "Gravação iniciada"
                canberra-gtk-play --file=$HOME/.local/share/sounds/screencast-start.wav
                ffmpeg -f x11grab -s $resolucao -i :0 -f pulse -ac 2 -i default -c:v libx264 -crf 23 -profile:v baseline -level 3.0 -pix_fmt yuv420p -c:a aac -ac 2 -strict experimental -b:a 128k -movflags faststart $arquivo
        fi
fi

exit 0