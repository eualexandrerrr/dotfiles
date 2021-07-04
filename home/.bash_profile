#!/usr/bin/env bash

[[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]] && startx
