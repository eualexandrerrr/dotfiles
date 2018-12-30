#[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
startx
fi

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty2 ]]; then
nvidia-xrun
fi