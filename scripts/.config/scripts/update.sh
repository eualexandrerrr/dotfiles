#!/bin/bash
# github.com/mamutal91

dotfiles="${HOME}/github/dotfiles"

    echo :::::::::::::::::::::::: Atualizando I3 e POLYBAR
    cd ${dotfiles}
    chmod +x -R scripts
            
    echo :::::::::::::::::::::::: Removendo .local
    sudo rm -rf $HOME/.local/share/{fonts,i3lock,sounds,wallpapers}

    echo :::::::::::::::::::::::: Removendo .configs
    sudo rm -rf $HOME/.config/{compton,dunst,i3,neofetch,polybar,rofi,scripts,termite}
    sudo rm -rf $HOME/{.nanorc,.zshrc,.Xresources,.xinitrc,.nvidia-xinitrc,.zprofile}

    echo :::::::::::::::::::::::: Copiando .local
    sudo cp -r home/.local/ $HOME

    echo :::::::::::::::::::::::: Copiando .configs
    sudo cp -r compton/.config/compton $HOME/.config
    sudo cp -r dunst/.config/dunst $HOME/.config
    sudo cp -r i3/.config/i3 $HOME/.config
    sudo cp -r neofetch/.config/neofetch $HOME/.config
    sudo cp -r polybar/.config/polybar $HOME/.config
    sudo cp -r rofi/.config/rofi $HOME/.config
    sudo cp -r scripts/.config/scripts $HOME/.config
    sudo cp -r termite/.config/termite $HOME/.config
    sudo cp -r home/{.nanorc,.zshrc,.Xresources,.xinitrc,.nvidia-xinitrc,.zprofile} $HOME

# Se o usuário for = mamutal91
function configuracoespessoais(){
    echo :::::::::::::::::::::::: Teclado, Touchpad e Intel
    sudo rm -rf /etc/X11/xorg.conf.d/10-evdev.conf
    sudo rm -rf /etc/X11/xorg.conf.d/20-intel.conf
    sudo rm -rf /etc/X11/xorg.conf.d/30-touchpad.conf
    sudo cp -r ${dotfiles}/system/.files/etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
    sudo cp -r ${dotfiles}/system/.files/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/
    sudo cp -r ${dotfiles}/system/.files/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/

    echo :::::::::::::::::::::::: NVIDIA
    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/30-nvidia.conf
    sudo rm -rf /etc/modules-load.d/bbswitch.conf
    sudo rm -rf /etc/modprobe.d/bbswitch.conf
    sudo cp -r ${dotfiles}/system/.files/etc/X11/nvidia-xorg.conf.d/30-nvidia.conf /etc/X11/nvidia-xorg.conf.d/
    sudo cp -r ${dotfiles}/system/.files/etc/modules-load.d/bbswitch.conf /etc/modules-load.d/
    sudo cp -r ${dotfiles}/system/.files/etc/modprobe.d/bbswitch.conf /etc/modprobe.d/
}

[[ $USER == "mamutal91" ]] && configuracoespessoais || echo No

cd $HOME/.config/polybar/
./launch.sh

echo :::::::::::::::::::::::: Finalizando
canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav 
sleep 1s
notify-send "Atualizações concluídas com sucesso"