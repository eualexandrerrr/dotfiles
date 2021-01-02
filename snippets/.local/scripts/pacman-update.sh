#!/usr/bin/env bash

source $HOME/.colors

icon="${iconpath}/modem.svg"

echo "${GRE}Updating Pacman and AUR${END}"
  sudo pacman -Syu
  yay -Syu

echo "${GRE}Removing unused packages${END}"
  sudo pacman -Qdtq --noconfirm
  yay -Qdtq --noconfirm
  sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
  yay -Rncs $(yay -Qdtq) --noconfirm

play $HOME/.local/sounds/completed.wav
notify-send -i $icon "ArchLinux" "Successfully updated packages."
