#!/usr/bin/env bash

sudo mkdir -p /etc/pacman.d/hooks

rm -rf /etc/X11/xorg.conf.d/20-nvidia-drm-outputclass.conf
rm -rf /etc/modprobe.d/blacklist-nvidia-nouveau.conf

echo "[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Change the linux part above and in the Exec line if a different kernel is used

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'" | sudo tee /etc/pacman.d/hooks/nvidia.hook

echo 'blacklist nouveau
options nouveau modeset=0' | sudo tee /etc/modprobe.d/blacklist-nvidia-nouveau.conf

echo 'Section "OutputClass"
    Identifier "amd"
    MatchDriver "amdgpu"
    Driver "modesetting"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    Option "Backlight"  "amdgpu_bl1"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-nvidia-drm-outputclass.conf
