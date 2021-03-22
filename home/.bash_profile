#!/usr/bin/env bash

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    pidof sway > /dev/null || exec sway
fi
