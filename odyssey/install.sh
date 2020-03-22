#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

mkfs.fat -F32 /dev/sda1

cryptsetup luksFormat -c aes-xts-plain64 -s 512 -h sha512 --use-random -i 100 /dev/sda2
#cryptsetup luksFormat -c aes-xts-plain64 -s 512 -h sha512 --use-random -i 100 /dev/sdb1

cryptsetup luksOpen /dev/sda2 lvm
#cryptsetup luksOpen /dev/sdb1 storage

pvcreate /dev/mapper/lvm
vgcreate arch /dev/mapper/lvm

lvcreate -L 80G arch -n root
lvcreate -L 8G arch -n swap
lvcreate -l 100%FREE arch -n home

mkfs.ext4 /dev/mapper/arch-root
mkfs.ext4 /dev/mapper/arch-home
mkswap /dev/mapper/arch-swap

mount /dev/mapper/arch-root /mnt

mkdir /mnt/home
mkdir /mnt/boot
mkdir -p /mnt/media/storage
mkdir /mnt/hostlvm

mount /dev/mapper/arch-home /mnt/home
mount /dev/sda1 /mnt/boot

swapon /dev/mapper/arch-swap
mount --bind /run/lvm /mnt/hostlvm

pacman -Sy reflector
reflector -c Brazil --save /etc/pacman.d/mirrorlist

pacstrap -i /mnt base base-devel bash-completion linux linux-headers linux-firmware mkinitcpio lvm2 --noconfirm

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt
