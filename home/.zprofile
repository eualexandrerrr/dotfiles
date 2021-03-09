#!/bin/zsh

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=br exec sway > ~/sway.log
fi

export GTK2_RC_FILES=~/.gtkrc-2.0

export WLR_NO_HARDWARE_CURSORS=1

rm -rf $HOME/Desktop
