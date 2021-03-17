#!/usr/bin/env bash

clear

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm

sudo pacman -Sy && sudo powerpill -Su && paru -Su

if ! grep "chaotic-aur" /etc/pacman.conf; then
  echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
fi

sudo pacman -Sy powerpill paru --noconfirm
sudo pacman -Sy && sudo powerpill -Su && paru -Su
sudo pacman -Sy chaotic-aur/dxvk-mingw-git --noconfirm

sudo pacman -Ss linux-tkg

kernel=linux-tkg-cacule-generic_v3

sudo pacman -S "${kernel}" --noconfirm
sudo pacman -S "${kernel}-headers" --noconfirm

sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
