#!/usr/bin/env bash
# github.com/mamutal91

# Usage:
# `$0`: Ask for recording type via wofi
# `$0 screencast`: Record both audio and screen
# `$0 video`: Record only screen
# `$0 audio`: Record only audio
# `$0 kill`: Kill existing recording
#
# If there is already a running instance, user will be prompted to end it.

dir="$HOME/Videos/Screencasts/"
date=$(date +"%m%d%Y-%H%M")

if [[ ${1} = "window" ]]; then
	wf-recorder -g "$(slurp)" -f "$dir/window-$date.mp4"
else
	wf-recorder -f "$dir/full-$date.mp4"
fi
