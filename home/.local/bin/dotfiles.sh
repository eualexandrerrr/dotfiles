#!/bin/bash
# github.com/mamutal91

function mamutal91-dotfiles(){
    rm -rf $HOME/.dotfiles
    cp -r $HOME/github/dotfiles $HOME/.dotfiles
    cd $HOME/.dotfiles
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

function mamutal91-configs(){
    sudo rm -rf /etc/X11/xorg.conf.d/10-evdev.conf
    sudo rm -rf /etc/X11/xorg.conf.d/30-touchpad.conf

    sudo mkdir -p /etc/X11/xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/
}

function mamutal91(){
    mamutal91-dotfiles
    stows
    mamutal91-configs
}

function user(){
    cd $HOME/.dotfiles
    stows
}

[[ $USER == "mamutal91" ]] && mamutal91 || user

# Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav 
i3-msg restart
#sleep 1s
$HOME/.config/polybar/launch.sh