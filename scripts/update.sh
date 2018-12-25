#!/bin/bash
# github.com/mamutal91

# DOTFILES
df="${HOME}/github/dotfiles"
# DOTCONFIGS
dc="${HOME}/.config"

cd $df

    sudo rm -rf ${dc}/i3
    sudo cp -r i3 ${dc}

    sudo rm -rf ${dc}/scripts
    sudo cp -r scripts ${dc}


# Finalizando
#canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav 
sleep 1s
i3-msg restart
notify-send "Atualização concluída com sucesso"