#!/usr/bin/env bash

tmpImg=/tmp/i3lockscreen.png
img="$HOME/.config/assets/i3lock/linus.png"
res=$(xrandr | grep 'current' | sed -E 's/.*current\s([0-9]+)\sx\s([0-9]+).*/\1x\2/')

ffmpeg -f x11grab -video_size $res -y -i $DISPLAY -i $img -filter_complex "boxblur=5:1,overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2" -vframes 1 $tmpImg -loglevel quiet
i3lock -i $tmpImg
rm $tmpImg
