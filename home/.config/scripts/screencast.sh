#!/bin/bash
# github.com/mamutal91

list_descendants () {
  local children=$(ps -o pid= --ppid "$1")

  for pid in $children
  do
    list_descendants "$pid"
  done

  echo "$children "
}

# ultrafast,superfast,veryfast,faster,fast,medium,slow,slower,veryslow,placebo
PRESET="ultrafast"
ext="mp4"
date=$(date +%Y-%m-%d_%H-%M-%S)
icon="${HOME}/.config/files/icons/screencast.png"
resolution=$(xrandr | grep '*' | awk 'NR==1{print $1}')

APPS=("ffmpeg" "xrandr" "pacmd")
for APP in ${APPS[@]}
do
    command -v $APP >/dev/null 2>&1 || { echo >&2 "O aplicativo $APP não está instalado. Abortando."; exit 1; }
done

if [ -f ~/.config/user-dirs.dirs ]; then
    . ~/.config/user-dirs.dirs
    dir="${XDG_VIDEOS_DIR}/Screencasts"
else
    dir="${HOME}/Videos/Screencasts"
fi

file="screencast-${date}.${ext}"

[ ! -d $dir ] && mkdir -p $dir

#if pgrep -x "ffmpeg" > /dev/null;
if pgrep -x "ffmpeg" > /dev/null && test -f "/tmp/videodown.pid" && test -f "/tmp/screencast.step1.${ext}";
then
    [ -f /tmp/screencast.step2.${ext} ] && rm -f /tmp/screencast.step2.${ext}
    [ -f /tmp/screencast.final.${ext} ] && rm -f /tmp/screencast.final.${ext}

    newpid=$(/bin/cat /tmp/videodown.pid)

    notify-send -h int:transient:1 -i $icon "ScreenCast" "ScreenCast terminado, matando os processos: $(list_descendants $newpid)"
    kill -QUIT $(list_descendants $newpid)
    #kill -TERM $newpid
    sleep 2

    notify-send -h int:transient:1 -i $icon "ScreenCast" "Conversão para o WhatsApp"
    ffmpeg -i /tmp/screencast.step1.${ext} -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p /tmp/screencast.step2.${ext}

    notify-send -h int:transient:1 -i $icon "ScreenCast" "Corte de 2 segundos"
    ffmpeg -ss 2 -i /tmp/screencast.step2.${ext} /tmp/screencast.final.${ext}

    mv /tmp/screencast.final.${ext} "${dir}/${file}"

    notify-send -h int:transient:1 -i $icon "ScreenCast" "ScreenCast salvo ${file}"
    rm -f /tmp/videodown.pid /tmp/screencast.step1.${ext} /tmp/screencast.step2.${ext}
else
    [ -f /tmp/screencast.step1.${ext} ] && rm -f /tmp/screencast.step1.${ext}
    echo $$ > /tmp/videodown.pid
    notify-send -h int:transient:1 -i $icon "ScreenCast" "ScreenCast iniciado\n\nPID: $(/bin/cat /tmp/videodown.pid)"
    ffmpeg -async 1 -f x11grab -s $resolution -i $DISPLAY -f pulse -ac 2 -i default -c:v libx264 -crf 23 -c:a aac -ac 2 -b:a 128k -movflags faststart /tmp/screencast.step1.${ext}
fi

exit 0
