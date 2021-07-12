#!/usr/bin/env bash

pacman -Ss linux-tkg

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm

sudo pacman -Sy && sudo powerpill -Su && paru -Su

if ! grep "chaotic-aur" /etc/pacman.conf; then
  chaoticFirstInstall=true
  echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
else
  chaoticFirstInstall=false
fi

sudo pacman -Sy powerpill paru --noconfirm

sudo pacman -Sy && sudo powerpill -Su && paru -Su

sudo pacman -Sy chaotic-aur/dxvk-mingw-git --noconfirm

sudo pacman -S linux-tkg-cacule-generic_v3 --noconfirm
sudo pacman -S linux-tkg-cacule-generic_v3-headers --noconfirm
