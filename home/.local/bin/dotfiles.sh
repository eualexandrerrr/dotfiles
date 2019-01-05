#!/bin/bash
# github.com/mamutal91

function mamutal91-dotfiles(){
    sudo rm -rf $HOME/.dotfiles
    cp -r $HOME/github/dotfiles $HOME/.dotfiles
    cd $HOME/.dotfiles
}

function stows(){
stow compton
stow dunst
stow gpicview
stow home
stow i3
stow neofetch
stow polybar
stow rofi
stow scripts
stow termite
stow thunar
}

function mamutal91-configs(){
    sudo rm -rf /etc/X11/xorg.conf.d/10-evdev.conf
    sudo rm -rf /etc/X11/xorg.conf.d/20-intel.conf
    sudo rm -rf /etc/X11/xorg.conf.d/30-touchpad.conf
    sudo cp -r etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/

    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/30-nvidia.conf
    sudo rm -rf /etc/modules-load.d/bbswitch.conf
    sudo rm -rf /etc/modprobe.d/bbswitch.conf
    sudo cp -r etc/X11/nvidia-xorg.conf.d/30-nvidia.conf /etc/X11/nvidia-xorg.conf.d/
    sudo cp -r etc/modules-load.d/bbswitch.conf /etc/modules-load.d/
    sudo cp -r etc/modprobe.d/bbswitch.conf /etc/modprobe.d/
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
sleep 1s
i3-msg restart
notify-send "Atualização concluída com sucesso"
sleep 1s
cd $HOME/.config/polybar && ./launch.sh