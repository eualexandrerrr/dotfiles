#!/bin/bash

icon="$HOME/.config/assets/icons"

date=$(date +"%Y%m%d-%H%M")
dir=$HOME/Videos/Screencasts
[[ ! -d $dir ]] && mkdir -p $dir

res=$(xrandr | awk '$0 ~ "*" {print $1}')

if pidof ffmpeg; then
    killall ffmpeg
    dunstify -i $icon/stoprec.png "Stopped Recording!"
else
  if [[ ${1} == window ]]; then
    slop=$(slop -f "%x %y %w %h")
    read -r X Y W H < <(echo $slop)
    width=${#W}

    if [ $width -gt 0 ]; then
      dunstify -i $icon/rec.png "Started Recording!"
      ffmpeg -f x11grab -s "$W"x"$H" -framerate 60  -thread_queue_size 512  -i $DISPLAY.0+$X,$Y -f alsa -i pulse \
        -vcodec libx264 -qp 18 -preset ultrafast \
        $dir/w-${date}.mp4
    fi
  else
    dunstify -i $icon/rec.png "Started Recording!"
    ffmpeg -f x11grab -s "$res" -framerate 60  -thread_queue_size 512  -i $DISPLAY.0+$X,$Y -f alsa -i pulse \
      -vcodec libx264 -qp 18 -preset ultrafast \
      $dir/f-${date}.mp4
  fi
fi
