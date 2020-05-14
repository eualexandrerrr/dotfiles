#!/bin/bash
# github.com/mamutal91


if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
startx
fi

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty2 ]]; then
nvidia-xrun
fi
