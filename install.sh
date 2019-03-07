#!/bin/bash
# github.com/mamutal91

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

function mamutal91(){
    cd /home/mamutal91/.dotfiles && rm -rf *
    cd /media/storage/GitHub/dotfiles && cp -rf * $HOME/.dotfiles
    cd $HOME/.dotfiles
    stows
    sudo stow -t /etc etc
}

[[ $USER == "mamutal91" ]] && mamutal91 || userinstall

# Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh
