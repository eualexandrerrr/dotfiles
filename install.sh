#!/bin/bash
# github.com/mamutal91

function dots(){
    source $HOME/github/dotfiles/home/.local/bin/mamutal91.sh
    mamutal91
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
stow thunar
}

function userinstall(){
    cd $HOME/.dotfiles
    stows
}

[[ $USER == "mamutal91" ]] && dots || userinstall

# Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav 
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh