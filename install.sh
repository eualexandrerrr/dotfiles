#!/bin/bash
# github.com/mamutal91

function mamutal91(){
    source /media/storage/GitHub/dotfiles/home/.local/bin/mamutal91.sh
    install
}

function stows(){
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
}

function userinstall(){
    cd $HOME/.dotfiles
    stows
}

[[ $USER == "mamutal91" ]] && mamutal91 || userinstall

# Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh
