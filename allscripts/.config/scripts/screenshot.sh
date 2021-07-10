#!/usr/bin/env bash

icon="$HOME/.config/assets/icons/screenshot.png"

date=$(date +"%Y%m%d-%H:%M:%S")
dir="$HOME/Images/Screenshots/"
[[ ! -d $dir ]] && mkdir -p $dir

if [[ ${1} == "window" ]]; then
  maim -s --format png "$dir/w-$date.png"
  xclip -selection clipboard -t image/png -i "$dir/w-$date.png"
  dunstify -i $icon "Screenshot" "Cropped capture.\n w-$date.png"
else
  maim --format png "$dir/f-$date.png"
  sleep 2
  xclip -selection clipboard -t image/png -i "$dir/f-$date.png"
  dunstify -i $icon "Screenshot" "Fullscreen capture.\n f-$date.png"
fi
