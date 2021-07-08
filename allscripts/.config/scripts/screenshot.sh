#!/usr/bin/env bash

icon="$HOME/.config/assets/icons/screenshot.png"

date=$(date +"%Y%m%d-%H:%M:%S")
dir="$HOME/Images/Screenshots/"
[[ ! -d $dir ]] && mkdir -p $dir

if [[ ${1} == "window" ]]; then
  maim -s "$dir/w-$date.png"
  xclip -selection clipboard -t image/png -i "$dir/w-$date.png"
  dunstify -i $icon "Screenshot" "Cropped capture.\nw-$window-$date.png"
else
  maim "$dir/f-$date.png"
  sleep 0
  xclip -selection clipboard -t image/png -i "$dir/f-$date.png"
  dunstify -i $icon "Screenshot" "Fullscreen capture.\nf-$window-$date.png"
fi
