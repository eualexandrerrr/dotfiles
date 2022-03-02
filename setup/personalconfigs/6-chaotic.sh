#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

clear

echo -e "\n${BOL_BLU} https://aur.chaotic.cx/${END}\n"

sudo sed -i '/chaotic/d' /etc/pacman.conf

sudo pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key FBA220DFC880C036
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

sudo pacman -Sy --no-confirm && sudo powerpill -Su --no-confirm && paru -Su --no-confirm

echo "[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

sudo pacman -Sy powerpill paru --noconfirm
sudo pacman -Sy && sudo powerpill -Su && paru -Su
sudo pacman -Sy chaotic-aur/dxvk-mingw-git --noconfirm

sudo pacman -Ss linux- | grep chaotic-aur

kernel=linux-tkg-pds
kernel=linux-xanmod-cacule

sudo pacman -S "${kernel}" --noconfirm
sudo pacman -S "${kernel}-headers" --noconfirm

sudo mkinitcpio -p ${kernel}

sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
