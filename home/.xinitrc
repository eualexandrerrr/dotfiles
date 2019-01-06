#!/bin/bash
# github.com/mamutal91

# Início
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# UTF-8
export LANG="pt_BR.UTF-8"
export LC_ALL="pt_BR.UTF-8"
export LANGUAGE="pt_BR.UTF-8"
export LC_CTYPE="pt_BR.UTF-8"
export EDITOR="nano"
export BROWSER="firefox"

# Dunst
dunst &

# Compton
compton --config ${HOME}/.config/compton/compton.conf -b &

# Numlock On
numlockx &

# i3lock
exec xautolock -time 10 -detectsleep -locker $HOME/.config/scripts/i3lock.sh &

# Iniciar i3
exec i3