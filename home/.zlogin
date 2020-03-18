#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
startx
fi

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty2 ]]; then
nvidia-xrun
fi
