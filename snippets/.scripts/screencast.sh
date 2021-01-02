#!/usr/bin/env bash

iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"
icon="${iconpath}/camera-video.svg"

dir="$HOME/Videos/Screencasts/"
if [[ ! -d "$dir" ]]; then
	mkdir -p $dir
fi

date=$(date +"%m%d%Y-%H%M")

window=" Window"
full=" Full"
kill=" Stop recorder"

devices="$window\n$full\n$kill"

chosen="$(echo -e "$devices" | wofi --lines 3 --sort-order=DEFAULT --dmenu -p "  Screencast")"
case $chosen in
    $window)
			notify-send -i $icon "Screencast" "Cropped screen capture." && wf-recorder -g "$(slurp)" -f "$dir/window-$date.mp4";;
    $full)
      notify-send -i $icon "Screencast" "Full screen capture." && wf-recorder -f "$dir/full-$date.mp4";;
    $kill)
      pkill -2 wf-recorder && notify-send -i $icon "Screencast" "Recorder finished.";;
esac
exit 0;
