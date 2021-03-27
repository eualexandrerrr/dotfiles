#!/usr/bin/env bash

# modprobe.d
if [[ $HOST = "odin" ]]; then
  echo "options ath10k_pci fwlps=0" | sudo tee -a /etc/modprobe.d/ath10k_pci.conf > /dev/null
fi

# systemd Auto Login
sudo rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USER --noclear %I $TERM" | sudo tee -a /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null
