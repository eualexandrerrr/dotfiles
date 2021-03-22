#!/usr/bin/env bash

# systemd
sudo rm -rf /etc/systemd/system/getty@tty1.service.d
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo cp -rf $HOME/.dotfiles/etc/systemd/system/getty@tty1.service.d/override.conf /etc/systemd/system/getty@tty1.service.d/

# modprobe.d
sudo rm -rf /etc/modprobe.d/ath10k_pci.conf
sudo mkdir -p /etc/modprobe.d/
sudo cp -rf $HOME/.dotfiles/etc/modprobe.d/ath10k_pci.conf /etc/modprobe.d/
