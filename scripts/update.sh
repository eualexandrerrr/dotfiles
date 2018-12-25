#!/bin/bash
# github.com/mamutal91

# DOTFILES
df="${HOME}/github/dotfiles"
# DOTCONFIGS
dc="${HOME}/.config"

cd $df

    sudo rm -rf $HOME/{.zshrc,.Xresources,.xinitrc,.nvidia-xinitrc,.zprofile}
    sudo cp -r home/{.zshrc,.Xresources,.xinitrc,.nvidia-xinitrc,.zprofile} $HOME

    sudo rm -rf ${dc}/i3 && sudo cp -r i3 ${dc}
    sudo rm -rf ${dc}/scripts && sudo cp -r scripts ${dc}


function mamutal91configs(){
    sudo rm -rf /etc/X11/xorg.conf.d/10-evdev.conf
    sudo rm -rf /etc/X11/xorg.conf.d/20-intel.conf
    sudo rm -rf /etc/X11/xorg.conf.d/30-touchpad.conf
    sudo cp -r ${df}/system/.files/etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
    sudo cp -r ${df}/system/.files/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/
    sudo cp -r ${df}/system/.files/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/

    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/30-nvidia.conf
    sudo rm -rf /etc/modules-load.d/bbswitch.conf
    sudo rm -rf /etc/modprobe.d/bbswitch.conf
    sudo cp -r ${df}/system/.files/etc/X11/nvidia-xorg.conf.d/30-nvidia.conf /etc/X11/nvidia-xorg.conf.d/
    sudo cp -r ${df}/system/.files/etc/modules-load.d/bbswitch.conf /etc/modules-load.d/
    sudo cp -r ${df}/system/.files/etc/modprobe.d/bbswitch.conf /etc/modprobe.d/
}
[[ $USER == "mamutal91" ]] && mamutal91configs || echo No

# Finalizando
#canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav 
sleep 1s
i3-msg restart
notify-send "Atualização concluída com sucesso"