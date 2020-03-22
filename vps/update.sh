#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

sudo pacman -Syyu --noconfirm
yay -Syyu --noconfirm

sudo pacman -Qdtq --noconfirm
yay -Qdtq --noconfirm
sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
yay -Rncs $(yay -Qdtq) --noconfirm
