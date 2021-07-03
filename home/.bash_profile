#!/usr/bin/env bash

[[ $DISPLAY == xterm-256color ]] && zsh

[[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]] && startx
[[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty2 ]] && nvidia-xrun
