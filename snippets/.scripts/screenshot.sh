#!/usr/bin/env bash

iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"
icon="${iconpath}/camera.svg"

dir="$HOME/Images/Screenshots/"
if [[ ! -d "$dir" ]]; then
	mkdir -p $dir
fi

date=$(date +"%m%d%Y-%H%M")

if [[ ${1} = "window" ]]; then
	grim "$dir/window-$date.png" -g "$(slurp -d)" - | wl-copy
	notify-send -i $icon "Screenshot" "Cropped capture."
else
	grim "$dir/full-$date.png" - | wl-copy
	notify-send -i $icon "Screenshot" "Fullscreen capture."
fi
