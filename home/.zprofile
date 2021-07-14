if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
  export QT_STYLE_OVERRIDE="gtk2"
  startx
fi
