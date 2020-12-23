#!/usr/bin/env bash
# github.com/mamutal91

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  XKB_DEFAULT_LAYOUT=br exec sway
fi
