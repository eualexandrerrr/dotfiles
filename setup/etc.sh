#!/usr/bin/env bash
# github.com/mamutal91

cd /etc/X11 && sudo rm -rf *

# systemd
sudo rm -rf /etc/systemd/system/getty@tty1.service.d
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo cp -rf $HOME/.dotfiles/etc/systemd/system/getty@tty1.service.d/override.conf /etc/systemd/system/getty@tty1.service.d/

sudo rm -rf /etc/systemd/logind.conf
sudo cp -rf $HOME/.dotfiles/etc/systemd/logind.conf /etc/systemd/

# X11
sudo rm -rf /etc/X11
sudo cp -rf $HOME/.dotfiles/etc/X11 /etc
