#!/bin/bash
# github.com/mamutal91

cd $HOME/.dotfiles

stow compton
stow dunst
stow home
stow i3
stow neofetch
stow polybar
stow rofi
stow scripts
stow termite
stow thunar
stow etc

function mamutal91configs(){
    sudo rm -rf /etc/X11/xorg.conf.d/10-evdev.conf
    sudo rm -rf /etc/X11/xorg.conf.d/20-intel.conf
    sudo rm -rf /etc/X11/xorg.conf.d/30-touchpad.conf
#    sudo cp -r etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
#    sudo cp -r etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/
#    sudo cp -r etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/

    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/30-nvidia.conf
    sudo rm -rf /etc/modules-load.d/bbswitch.conf
    sudo rm -rf /etc/modprobe.d/bbswitch.conf
#    sudo cp -r etc/X11/nvidia-xorg.conf.d/30-nvidia.conf /etc/X11/nvidia-xorg.conf.d/
#    sudo cp -r etc/modules-load.d/bbswitch.conf /etc/modules-load.d/
#    sudo cp -r etc/modprobe.d/bbswitch.conf /etc/modprobe.d/
}
[[ $USER == "mamutal91" ]] && mamutal91configs || echo No

# Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav 
sleep 1s
i3-msg restart
notify-send "Atualização concluída com sucesso"
sleep 1s
cd $HOME/.config/polybar && ./launch.sh