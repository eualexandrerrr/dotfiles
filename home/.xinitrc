#!/bin/bash
# github.com/mamutal91

# Xresources
xrdb -merge "${HOME}/.Xresources"

# Dunst
dunst &

# Compton
compton --config ${HOME}/.config/compton/compton.conf -b &

# Numlock On
numlockx &

# i3lock
exec xautolock -time 10 -detectsleep -locker $HOME/.config/scripts/i3lock.sh &

# Hora
exec sudo ntpd -qg

# Iniciar i3
exec i3