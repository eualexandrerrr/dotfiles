#!/usr/bin/env bash

icon="${iconpath}/modem.svg"

sleep 1

echo "Updating Pacman and AUR"
  sudo pacman -Syu
  yay -Syu

echo "Removing unused packages"
  sudo pacman -Qdtq --noconfirm
  yay -Qdtq --noconfirm
  sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
  yay -Rncs $(yay -Qdtq) --noconfirm

play $HOME/.bin/sounds/completed.wav
notify-send -i $icon "archlinux" "Successfully updated packages."
