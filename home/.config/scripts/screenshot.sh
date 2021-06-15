#!/usr/bin/env bash

iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"
icon="${iconpath}/camera.svg"

dir="$HOME/Images/Screenshots/"
if [[ ! -d "$dir" ]]; then
	mkdir -p $dir
fi

date=$(date +"%Y%m%d-%H%M")

if [[ ${1} = "window" ]]; then
	img="$dir/window-$date.png"
	grim -g "$(slurp -d)" "$img"
	wl-copy < $img
	notify-send -i $icon "Screenshot" "Cropped capture."
else
	img="$dir/full-$date.png"
	grim "$img"
	wl-copy < $img
	notify-send -i $icon "Screenshot" "Fullscreen capture."
fi
