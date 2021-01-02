#!/usr/bin/env bash

dir="$HOME/Videos/Screencasts/"
if [[ ! -d "$dir" ]]; then
	mkdir -p $dir
fi

date=$(date +"%m%d%Y-%H%M")

icon="${iconpath}/bluetooth.svg"

window=" Window"
full=" Full"
kill=" Stop recorder"

devices="$window\n$full\n$kill"

chosen="$(echo -e "$devices" | wofi --lines 3 --sort-order=DEFAULT --dmenu -p "  Screencast")"
case $chosen in
    $window)
			wf-recorder -g "$(slurp)" -f "$dir/window-$date.mp4";;
    $full)
      wf-recorder -f "$dir/full-$date.mp4";;
    $kill)
      pkill -2 wf-recorder;;
esac
exit 0;
