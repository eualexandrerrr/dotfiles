#!/bin/zsh

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    pidof sway > /dev/null || exec sway
fi

export WLR_NO_HARDWARE_CURSORS=1

rm -rf $HOME/Desktop
