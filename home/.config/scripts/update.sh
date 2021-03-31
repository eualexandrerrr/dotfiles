#!/usr/bin/env bash

iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"
icon="${iconpath}/modem.svg"

source $HOME/.colors

HOSTNAME=$(cat /etc/hostname)

if [[ $HOSTNAME = mamutal91 || $HOSTNAME = buildersbr.ninja-v2 ]]; then
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

  play $HOME/.config/sounds/completed.wav &>/dev/null
  notify-send -i $icon "ArchLinux" "Successfully updated packages."
fi
