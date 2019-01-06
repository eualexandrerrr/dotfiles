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
stow scripts
stow termite
}

function mamutal91-configs(){
    sudo rm -rf /etc/X11/
    sudo cp -r etc/X11/ /etc/

    sudo rm -rf /etc/modules-load.d
    sudo rm -rf /etc/modprobe.d

    sudo cp -r etc/modules-load.d /etc/
    sudo cp -r etc/modprobe.d /etc/
}

function mamutal91(){
#    mamutal91-dotfiles
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
sleep 1s
i3-msg restart
notify-send "Atualização concluída com sucesso"
sleep 1s
$HOME/.config/polybar/launch.sh