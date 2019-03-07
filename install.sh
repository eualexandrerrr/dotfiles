#!/bin/bash
# github.com/mamutal91

cd $HOME/.dotfiles

stow compton
stow dunst
stow gpicview
stow gtk
stow home
stow i3
stow neofetch
stow polybar
stow rofi
stow termite

function mamutal91(){
    sudo stow -t /etc etc
}

[[ $USER == "mamutal91" ]] && mamutal91 || echo ""

# Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh
