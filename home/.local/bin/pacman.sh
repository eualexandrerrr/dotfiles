#!/bin/bash
# github.com/mamutal91

app=utilities-terminal.png
icon=$iconsnotify/$app

echo -e "
Updater mirrors with reflector?
-------------------------------
     1. 10 bests Mirrors
     2. Bests Mirrors Brazil
     3. No [enter]

Answer: "
read answer
case "$answer" in
  1|y)
    sudo reflector -l 10 --sort rate --save /etc/pacman.d/mirrorlist
  ;;
  2|b)
    sudo reflector -c Brazil --save /etc/pacman.d/mirrorlist
  ;;
  3|""|n)
  ;;
  *)
    echo "Invalid answer..."
  ;;
esac
echo

echo "Atualizando Pacman e AUR"
    sudo pacman -Syyu
    yay -Syyu

echo "Removendo pacotes não utilizados"
    sudo pacman -Qdtq --noconfirm
    yay -Qdtq --noconfirm
    sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
    yay -Rncs $(yay -Qdtq) --noconfirm

canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav
DISPLAY=:0 dbus-launch notify-send -i $icon "Pacotes atualizados com sucesso."
