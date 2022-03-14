#!/usr/bin/env bash

# ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo
name="ScreenCast"
preset="ultrafast"
ext="mp4"
date=$(date +"%Y%m%d-%H:%M:%S")
icon="/usr/share/icons/Flatery-Dark/devices/48/camera-video.svg"
res=$(xrandr | grep '*' | awk 'NR==1{print $1}')
trimStart=3
trimEnd=2
trimMin=$((trimStart + trimEnd))

app=("ffmpeg" "xrandr" "pacmd")
for APP in ${app[@]}; do
  command -v $APP > /dev/null 2>&1 || {
                                       echo >&2 "O aplicativo $APP não está instalado. Abortando."
                                                                                                      exit 1
  }
done

list_descendants()  {
  local children=$(ps -o pid= --ppid "$1")
  for pid in $children; do
    list_descendants "$pid"
  done
  echo "$children "
}

notifycommand="$HOME/bin/notify.sh ScreenCast ${icon} $name"

[[ -z $DESKTOP_SESSION   ]] && notifycommand="notify-send -h int:transient:1 -i $icon $name"

[[ -z $DISPLAY   ]] && DISPLAY=:0

path="${HOME}/Videos/Screencasts"

file="s-${date}.${ext}"

[ ! -d $path ] && mkdir -p $path

#if pgrep -x "ffmpeg" > /dev/null;
if pgrep -x "ffmpeg" > /dev/null && test -f "/tmp/videodown.pid" && test -f "/tmp/screencast.step1.${ext}"; then

  [ -f /tmp/screencast.step2.${ext} ] && rm -f /tmp/screencast.step2.${ext}
  [ -f /tmp/screencast.final.${ext} ] && rm -f /tmp/screencast.final.${ext}

  newPid=$(/bin/cat /tmp/videodown.pid)

  $notifycommand "Gravação terminada, matando os processos: $(list_descendants $newPid)"
  kill -QUIT $(list_descendants $newPid)
  sleep 2

  $notifycommand "Conversão para o Telegram"
  ffmpeg -i /tmp/screencast.step1.${ext} -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p /tmp/screencast.step2.${ext} 1> /dev/null 2> /dev/null

  duration=$(ffprobe -i /tmp/screencast.step2.${ext} -show_entries format=duration -v quiet -of csv='p=0')
  int=${duration%.*}
  trim=$((int - 3))

  if [[ $trim -gt $trimMin ]]; then
    $notifycommand "Corte de 5 segundos no começo e 3 no final"
    ffmpeg -ss 2 -t $trim -i /tmp/screencast.step2.${ext} /tmp/screencast.final.${ext}
    mv /tmp/screencast.final.${ext} "${path}/${file}"
  else
    mv /tmp/screencast.step2.${ext} "${path}/${file}"
  fi

  $notifycommand "ScreenCast salvo ${file}"

  rm -f /tmp/videodown.pid /tmp/screencast.step1.${ext} /tmp/screencast.step2.${ext}
else
  [ -f /tmp/screencast.step1.${ext} ] && rm -f /tmp/screencast.step1.${ext}
  echo $$ > /tmp/videodown.pid
  $notifycommand "Gravação iniciada"
  ffmpeg -async 1 -f x11grab -s $res -i $DISPLAY -f pulse -ac 2 -i default -c:v libx264 -crf 23 -c:a aac -ac 2 -b:a 128k -movflags faststart /tmp/screencast.step1.${ext}
fi

exit 0
