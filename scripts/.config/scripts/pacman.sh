#!/bin/bash
# github.com/mamutal91

app=pacman.png
icon=$iconsnotify/$app

echo "Atualizando Pacman e AUR"
    sudo pacman -Syyu
    yay -Syyu

echo "Removendo pacotes não utilizados"
    sudo pacman -Qdtq --noconfirm
    yay -Qdtq --noconfirm
    sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
    yay -Rncs $(yay -Qdtq) --noconfirm

canberra-gtk-play --file=$HOME/.config/files/sounds/completed.wav
DISPLAY=:0 dbus-launch notify-send -i $icon "pacman" "Pacotes atualizados com sucesso."
