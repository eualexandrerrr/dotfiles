#!/bin/bash
# github.com/mamutal91

sudo rm -rf /etc/X11/xorg.conf.d/10-evdev.conf
sudo rm -rf /etc/X11/xorg.conf.d/20-intel.conf
    sudo rm -rf /etc/X11/xorg.conf.d/30-touchpad.conf
    sudo cp -r etc/X11/xorg.conf.d/10-evdev.conf /etc/X11/xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/
    sudo cp -r etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/

    sudo rm -rf /etc/X11/nvidia-xorg.conf.d/30-nvidia.conf
    sudo rm -rf /etc/modules-load.d/bbswitch.conf
    sudo rm -rf /etc/modprobe.d/bbswitch.conf
    sudo cp -r etc/X11/nvidia-xorg.conf.d/30-nvidia.conf /etc/X11/nvidia-xorg.conf.d/
    sudo cp -r etc/modules-load.d/bbswitch.conf /etc/modules-load.d/
    sudo cp -r etc/modprobe.d/bbswitch.conf /etc/modprobe.d/