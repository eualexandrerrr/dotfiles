#!/usr/bin/env bash

dir="$HOME/Images/Screenshots/"
if [[ ! -d "$dir" ]]; then
	mkdir -p $dir
fi

date=$(date +"%m%d%Y-%H%M")

if [[ ${1} = "window" ]]; then
	grim -g "$(slurp -d)" - | wl-copy
else
	grim - | wl-copy
fi
