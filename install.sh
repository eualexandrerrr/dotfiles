#!/bin/bash
# github.com/mamutal91

function programs(){
    cd $HOME/.dotfiles
    stow compton
    stow dunst
    stow gpicview
    stow home
    stow i3
    stow neofetch
    stow polybar
    stow rofi
    stow termite
}

function mamutal91(){
    rm -rf $HOME/.dotfiles && cp -rf /media/storage/GitHub/dotfiles $HOME/.dotfiles
    programs
    sudo stow bbswitch -t /etc
    sudo stow X11 -t /etc/X11

    sudo rm -rf /etc/systemd/logind.conf && sudo cp -rf systemd/logind.conf /etc/systemd
}

[[ $USER == "mamutal91" ]] && mamutal91 || programs

canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh
