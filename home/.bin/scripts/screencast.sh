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

killrecording() {
	recpid="$(cat /tmp/recordingpid)"
	# kill with SIGTERM, allowing finishing touches.
	kill -15 "$recpid"
	rm -f /tmp/recordingpid
	sleep 3
	kill -9 "$recpid"
	exit
	}

screencast() { \
	wf-recorder -c libx264rgb -f "$dir/screencast-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
}

video() { \
	wf-recorder -a -c libx264rgb -f "$dir/video-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
	}

window() { \
	wf-recorder -a -c libx264rgb -g "$(slurp)" -f "$dir/window-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
}

vaapi() { \
	wf-recorder -a -c h264_vaapi -d /dev/dri/renderD128 -f "$dir/video-$(date '+%y%m%d-%H%M-%S').mkv" &
	echo $! > /tmp/recordingpid
	}

askrecording() { \
  choice="$(printf "screencast\\nvideo\\nvaapi\\nwindow" | wofi --lines 9 --dmenu -p " ICONE Screencast")"
#	choice=$(printf "screencast\\nvideo\\nvaapi\\nwindow" | wofi -p " 🎥 " -p "Select recording style:")
	case "$choice" in
		screencast) screencast;;
		video) video;;
		vaapi) vaapi;;
		window) window;;
	esac
	}

asktoend() { \
	response=$(prompt "Recording still active. End recording?" "echo Yes") &&
	[ "$response" = "Yes" ] &&  killrecording
	}


case "$1" in
	screencast) screencast;;
	video) video;;
	kill) killrecording;;
	*) ([ -f /tmp/recordingpid ] && asktoend && exit) || askrecording;;
esac
