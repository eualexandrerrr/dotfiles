#!/bin/zsh

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
  export WLR_NO_HARDWARE_CURSORS=1
  export XDG_SESSION_TYPE=wayland
  export XDG_SESSION_DESKTOP=sway
  export XDG_CURRENT_DESKTOP=sway
  export LIBSEAT_BACKEND=logind
  rm -rf $HOME/Desktop
  XKB_DEFAULT_LAYOUT=br exec sway
fi
