#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

icon="$HOME/.config/assets/icons/pacman.png"

clear

echo -e "${BOL_GRE}Updating packages${END}"
sudo pacman -Syu
yay -Syu

if sudo pacman -Qdtq; then
  echo -e "${BOL_RED}Removing unused packages${END}"
  sudo pacman -Rncs $(sudo pacman -Qdtq) --noconfirm
  yay -Rncs $(yay -Qdtq) --noconfirm
else
  echo -e "${BOL_BLU}There are no unused packages to remove${END}"
fi

echo -e "${BOL_RED}Removing /tmp files...${END}"
sudo rm -rf /tmp/* &> /dev/null

play $HOME/.config/assets/sounds/completed.wav &> /dev/null
dunstify -i $icon "ArchLinux" "Successfully updated packages."
