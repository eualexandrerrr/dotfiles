#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

clear

sudo pacman -Sy powerpill paru --noconfirm
sudo pacman -Sy && sudo powerpill -Su && paru -Su
sudo pacman -Sy chaotic-aur/dxvk-mingw-git --noconfirm

sudo pacman -Ss linux- | grep chaotic-aur

kernel=linux-tkg-cfs-generic_v3

sudo pacman -S "${kernel}" --noconfirm
sudo pacman -S "${kernel}-headers" --noconfirm

sudo mkinitcpio -p ${kernel}

sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
