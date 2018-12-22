#!/bin/bash
# github.com/mamutal91

refind-install --usedefault /dev/sda1
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg