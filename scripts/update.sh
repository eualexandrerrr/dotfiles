#!/bin/bash
# github.com/mamutal91

# DOTFILES
dotfiles="${HOME}/github/dotfiles"
# DOTCONFIGS
configs="${HOME}/.config"

cd $dotfiles

    sudo rm -rf $HOME/.local/share/{fonts,i3lock,sounds,wallpapers}
    sudo cp -r home/.local/ $HOME

    sudo rm -rf $HOME/{.zshrc,.Xresources,.xinitrc,.nvidia-xinitrc,.zlogin}
    sudo cp -r home/{.zshrc,.Xresources,.xinitrc,.nvidia-xinitrc,.zlogin} $HOME

    sudo rm -rf ${configs}/compton && sudo cp -r compton ${configs}
    sudo rm -rf ${configs}/dunst && sudo cp -r dunst ${configs}
    sudo rm -rf ${configs}/i3 && sudo cp -r i3 ${configs}
    sudo rm -rf ${configs}/neofetch && sudo cp -r neofetch ${configs}
    sudo rm -rf ${configs}/polybar && sudo cp -r polybar ${configs}
    sudo rm -rf ${configs}/rofi && sudo cp -r rofi ${configs}
    sudo rm -rf ${configs}/scripts && sudo cp -r scripts ${configs}
    sudo rm -rf ${configs}/termite && sudo cp -r termite ${configs}
    sudo rm -rf ${configs}/Thunar && sudo cp -r Thunar ${configs}


function mamutal91configs(){
    sudo rm -rf /etc/X11/xorg.conf.d/10-evdev.conf
    sudo rm -rf /etc/X11/xorg.conf.d/20-intel.conf
    sudo rm -rf /etc/X11/xorg.conf.d/30-touchpad.conf
    sudo cp -r ${dotfiles}/system/.files/etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
    sudo cp -r ${dotfiles}/system/.files/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/
    sudo cp -r ${dotfiles}/system/.files/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/

    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/30-nvidia.conf
    sudo rm -rf /etc/modules-load.d/bbswitch.conf
    sudo rm -rf /etc/modprobe.d/bbswitch.conf
    sudo cp -r ${dotfiles}/system/.files/etc/X11/nvidia-xorg.conf.d/30-nvidia.conf /etc/X11/nvidia-xorg.conf.d/
    sudo cp -r ${dotfiles}/system/.files/etc/modules-load.d/bbswitch.conf /etc/modules-load.d/
    sudo cp -r ${dotfiles}/system/.files/etc/modprobe.d/bbswitch.conf /etc/modprobe.d/
}
[[ $USER == "mamutal91" ]] && mamutal91configs || echo No

# Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav 
sleep 1s
i3-msg restart
notify-send "Atualização concluída com sucesso"
sleep 1s
cd $HOME/.config/polybar && ./launch.sh