#!/usr/bin/env bash

icon="${iconpath}/modem.svg"

END=$(tput sgr0)
GRE=$END$(tput setaf 2)

echo "${GRE}Updating Pacman and AUR${END}"
  sudo pacman -Syu
  yay -Syu

echo "${GRE}Removing unused packages${END}"
  sudo pacman -Qdtq --noconfirm
  yay -Qdtq --noconfirm
  sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
  yay -Rncs $(yay -Qdtq) --noconfirm

play $HOME/.bin/sounds/completed.wav
notify-send -i $icon "archlinux" "Successfully updated packages."
