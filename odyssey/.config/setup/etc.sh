#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

# bbswitch
sudo rm -rf /etc/bbswitch
sudo cp -rf $HOME/.dotfiles/etc/bbswitch /etc

# systemd
sudo rm -rf /etc/systemd/system/getty@tty1.service.d
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo cp -rf $HOME/.dotfiles/etc/systemd/system/getty@tty1.service.d/override.conf /etc/systemd/system/getty@tty1.service.d/

sudo rm -rf /etc/systemd/logind.conf
sudo cp -rf $HOME/.dotfiles/etc/systemd/logind.conf /etc/systemd/

# X11
sudo rm -rf /etc/X11
sudo cp -rf $HOME/.dotfiles/etc/X11 /etc
