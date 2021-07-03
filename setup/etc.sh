#!/usr/bin/env bash

HOSTNAME=$(cat /etc/hostname)

# systemd Auto Login
sudo rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I $TERM" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null

sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp -rf $HOME/.dotfiles/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d
