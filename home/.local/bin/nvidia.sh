#!/bin/bash
# github.com/mamutal91

sudo rm -rf /etc/X11/xorg.conf.d/20-intel.conf

sudo mkdir -p /etc/X11/xorg.conf.d/
sudo cp -r nvidia/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/

sudo rm -rf /etc/X11/nvidia-xorg.conf.d/30-nvidia.conf
sudo rm -rf /etc/modules-load.d/bbswitch.conf
sudo rm -rf /etc/modprobe.d/bbswitch.conf

sudo mkdir -p /etc/modules-load.d/
sudo mkdir -p /etc/modprobe.d/
sudo mkdir -p /etc/X11/nvidia-xorg.conf.d/
sudo cp -r nvidia/etc/X11/nvidia-xorg.conf.d/30-nvidia.conf /etc/X11/nvidia-xorg.conf.d/
sudo cp -r nvidia/etc/modules-load.d/bbswitch.conf /etc/modules-load.d/
sudo cp -r nvidia/etc/modprobe.d/bbswitch.conf /etc/modprobe.d/