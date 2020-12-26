#!/usr/bin/env bash
# github.com/mamutal91

icon="${iconpath}/modem.svg"

sleep 1

echo "Atualizando Pacman e AUR"
  sudo pacman -Syu
  yay -Syu

echo "Removendo pacotes não utilizados"
  sudo pacman -Qdtq --noconfirm
  yay -Qdtq --noconfirm
  sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
  yay -Rncs $(yay -Qdtq) --noconfirm

play $HOME/.bin/sounds/completed.wav
notify-send -i $icon "archlinux" "Pacotes atualizados com sucesso."
