#!/bin/bash
# github.com/mamutal91

echo :::::::::::::::::::::::: rEFInd
refind-install --usedefault /dev/sda1

echo :::::::::::::::::::::::: GRUB-INSTALL
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub

echo :::::::::::::::::::::::: GRUB-MKCONFIG
grub-mkconfig -o /boot/grub/grub.cfg