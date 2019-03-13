#!/bin/bash
# github.com/mamutal91

app=utilities-terminal.png
icon=$iconsnotify/$app

echo "Atualizando Pacman"
    sudo pacman -Syyu --noconfirm

echo "Atualizando AUR"
    yay -Syyu --noconfirm

echo "Removendo pacotes Pacman não utilizados"
    sudo pacman -Qdtq --noconfirm
    sudo pacman -Rncs $(pacman -Qdtq) --noconfirm

echo "Removendo pacotes AUR não utilizados"
    yay -Qdtq --noconfirm
    yay -Rncs $(yay -Qdtq) --noconfirm

canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav
DISPLAY=:0 dbus-launch notify-send -i $icon "Pacotes atualizados com sucesso."
