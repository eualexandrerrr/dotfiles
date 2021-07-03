#!/usr/bin/env bash

HOSTNAME=$(cat /etc/hostname)

# systemd Auto Login
sudo rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I $TERM" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null

# Xorg
sudo rm -rf /etc/X11/* &> /dev/null
yay -S nvidia-xrun --noconfirm &> /dev/null

sudo mkdir -p /etc/X11/nvidia-xorg.conf.d
sudo mkdir -p /etc/X11/xorg.conf.d
sudo mkdir -p /etc/modprobe.d
sudo mkdir -p /etc/modules-load.d

sudo rm -rf /etc/X11/nvidia-xorg.conf.d/*
sudo rm -rf /etc/X11/xorg.conf.d/*
sudo cp -rf $HOME/.dotfiles/etc/X11/nvidia-xorg.conf.d/* /etc/X11/nvidia-xorg.conf.d
sudo cp -rf $HOME/.dotfiles/etc/X11/xorg.conf.d/* /etc/X11/nvidia-xorg.conf.d
sudo cp -rf $HOME/.dotfiles/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d

sudo rm -rf /etc/modprobe.d/*
sudo rm -rf /etc/modules-load.d/*
sudo cp -rf $HOME/.dotfiles/etc/modprobe.d/* /etc/modprobe.d
sudo cp -rf $HOME/.dotfiles/etc/modules-load.d/* /etc/modules-load.d

sudo mkdir -p /etc/X11/xorg.conf.d
