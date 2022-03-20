#!/usr/bin/env bash

sudo rm -rf /etc/X11/xorg.conf.d/20-nvidia-drm-outputclass.conf
sudo rm -rf /etc/modprobe.d/blacklist-nvidia-nouveau.conf

sudo mkdir -p /etc/pacman.d/hooks

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
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'" | sudo tee /etc/pacman.d/hooks/nvidia.hook &> /dev/null

echo 'blacklist nouveau
options nouveau modeset=0' | sudo tee /etc/modprobe.d/blacklist-nvidia-nouveau.conf &> /dev/null

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
EndSection' | sudo tee /etc/X11/xorg.conf.d/20-nvidia-drm-outputclass.conf &> /dev/null

# graphics driver
if [[ ! -n $(grep nvidia /etc/default/grub) ]]; then
  sudo sed -i 's/acpi_backlight=vendor/acpi_backlight=vendor nvidia-drm.modeset=1/g' /etc/default/grub
fi

if [[ ! -n $(grep nvidia /etc/mkinitcpio.conf) ]]; then
  sudo sed -i "s/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g" /etc/mkinitcpio.conf
fi

installNvidia() {
  pwd=$(pwd)
    sudo pacman -Sy mesa mesa-demos mesa-utils vulkan-tools lib32-mesa lib32-virtualgl lib32-libvdpau --noconfirm
    rm -rf $HOME/nvidia-all
    git clone https://github.com/Frogging-Family/nvidia-all.git $HOME/nvidia-all
    cd $HOME/nvidia-all
    makepkg -si
    rm -rf $HOME/nvidia-all
    sleep 200000
    sudo mkinitcpio -P
  cd $pwd
}
installNvidia
