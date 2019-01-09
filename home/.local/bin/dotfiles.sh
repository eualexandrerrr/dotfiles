#!/bin/bash
# github.com/mamutal91

function mamutal91-dotfiles(){
    sudo rm -rf $HOME/.dotfiles
    sudo cp -r $HOME/github/dotfiles $HOME/.dotfiles
    cd $HOME/.dotfiles
}

function stows(){
stow compton
stow dunst
stow gpicview
stow gtk
stow home
stow i3
stow openbox
stow neofetch
stow polybar
stow rofi
stow termite
}

function xorg(){
    # XORGS de teclado e mouse
    sudo rm -rf /etc/X11/xorg.conf.d/10-evdev.conf
    sudo rm -rf /etc/X11/xorg.conf.d/30-touchpad.conf

    sudo mkdir -p /etc/X11/xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/
}

function xorg-nvidia(){
    # XORG da INTEL
    sudo rm -rf /etc/X11/xorg.conf.d/20-intel.conf

    sudo mkdir -p /etc/X11/xorg.conf.d/
    sudo cp -r etc/nvidia/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/

    # XORG da NVIDIA e BBSWITCH
    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/20-nvidia.conf
    sudo rm -rf /etc/modules-load.d/bbswitch.conf
    sudo rm -rf /etc/modprobe.d/bbswitch.conf

    sudo mkdir -p /etc/modules-load.d/
    sudo mkdir -p /etc/modprobe.d/
    sudo mkdir -p /etc/X11/nvidia-xorg.conf.d/
    sudo cp -r etc/nvidia/etc/X11/nvidia-xorg.conf.d/20-nvidia.conf /etc/X11/nvidia-xorg.conf.d/
    sudo cp -r etc/nvidia/etc/modules-load.d/bbswitch.conf /etc/modules-load.d/
    sudo cp -r etc/nvidia/etc/modprobe.d/bbswitch.conf /etc/modprobe.d/

    # XORGS de teclado e mouse para NVIDIA
    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/10-evdev.conf
    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/30-touchpad.conf

    sudo cp -r etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/nvidia-xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/nvidia-xorg.conf.d/
}

function mamutal91(){
    mamutal91-dotfiles
    stows
    xorg
    xorg-nvidia
}

function user(){
    cd $HOME/.dotfiles
    stows
}

[[ $USER == "mamutal91" ]] && mamutal91 || user

# Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav 
#i3-msg restart
openbox --restart
sleep 1s
$HOME/.config/polybar/launch.sh
notify-send "dotfiles atualizado!!!"