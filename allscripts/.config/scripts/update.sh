#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

icon="$HOME/.config/assets/icons/pacman.png"

if [[ $(cat /etc/hostname) == mamutal91-v2 || $(cat /etc/hostname) == buildersbr.ninja-v2 ]]; then
  echo "${GRE}Updating apt${END}"
  sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
else
  echo "${GRE}Updating Pacman and AUR${END}"
  sudo pacman -Syu
  yay -Syu

  echo "${GRE}Removing unused packages${END}"
  sudo pacman -Qdtq --noconfirm
  yay -Qdtq --noconfirm
  sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
  yay -Rncs $(yay -Qdtq) --noconfirm

  play $HOME/.config/assets/sounds/completed.wav &> /dev/null
  dunstify -i $icon "ArchLinux" "Successfully updated packages."

  echo "${RED}Removing temp files...${END}"
  sudo rm -rf /tmp/* &> /dev/null

  echo -e "\n${GRE}Updating my apt hosts${END}"
  ssh mamutal91@86.109.7.111 "sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo rm -rf /tmp/* &> /dev/null"
  ssh mamutal91@147.75.80.89 "sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo rm -rf /tmp/* &> /dev/null"
fi
