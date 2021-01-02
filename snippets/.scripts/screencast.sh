#!/usr/bin/env bash

dir="$HOME/Videos/Screencasts/"
if [ ! -d "$dir" ]; then
	mkdir -p $dir
fi

date=$(date +"%m%d%Y-%H%M")

if [[ ${1} = "window" ]]; then
	wf-recorder -g "$(slurp)" -f "$dir/window-$date.mp4"
else
	wf-recorder -f "$dir/full-$date.mp4"
fi
