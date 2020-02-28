#!/bin/bash
# github.com/mamutal91

app=pacman.png
icon=$icons_path/$app

sleep 1

echo "Atualizando Pacman e AUR"
  sudo pacman -Syyu --color auto
  yay -Syyu --color auto

echo "Removendo pacotes não utilizados"
  sudo pacman -Qdtq --noconfirm --color auto
  yay -Qdtq --noconfirm --color auto
  sudo pacman -Rncs $(pacman -Qdtq) --noconfirm --color auto
  yay -Rncs $(yay -Qdtq) --noconfirm --color auto

canberra-gtk-play --file=$HOME/.config/files/sounds/completed.wav
DISPLAY=:0 dbus-launch notify-send -i $icon "archlinux" "Pacotes atualizados com sucesso."
