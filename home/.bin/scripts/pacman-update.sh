#!/usr/bin/env bash
# github.com/mamutal91

icon="${iconpath}/modem.svg"

sleep 1

echo "Atualizando Pacman e AUR"
  sudo pacman -Syyu
  yay -Syyu

echo "Removendo pacotes não utilizados"
  sudo pacman -Qdtq --noconfirm
  yay -Qdtq --noconfirm
  sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
  yay -Rncs $(yay -Qdtq) --noconfirm

play ~/.bin/sounds/completed.wav
notify-send -i $icon "archlinux" "Pacotes atualizados com sucesso."
