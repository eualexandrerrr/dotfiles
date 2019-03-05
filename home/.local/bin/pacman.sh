#!/bin/bash
# github.com/mamutal91

app=utilities-terminal.png
icon=$iconsnotify/$app

(cat ~/.cache/wal/sequences &)

echo ▆▆ Atualizando Pacman
sleep 1s
    sudo pacman -Syu --noconfirm

echo ▆▆ Atualizando AUR
sleep 1s
    yay -Syyu --noconfirm

echo ▆▆ Removendo pacotes Pacman não utilizados
sleep 1s
    sudo pacman -Qdtq
    sudo pacman -Rns $(pacman -Qdtq) --noconfirm

echo ▆▆ Removendo pacotes AUR não utilizados
sleep 1s
    yay -Qdtq
    yay -R $(yay -Qdtq) --noconfirm

canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav

DISPLAY=:0 dbus-launch notify-send -i $icon "Pacotes atualizados com sucesso."
