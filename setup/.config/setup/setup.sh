#!/bin/bash
# github.com/mamutal91

# Mirrors
# sudo reflector -c Brazil --save /etc/pacman.d/mirrorlist
# sudo reflector -l 10 --sort rate --save /etc/pacman.d/mirrorlist

# Config my system
USER=mamutal91
git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"
sudo ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
sudo chown -R $USER:$USER /home/$USER
sudo gpasswd -a $USER bumblebee
chmod +x /home/$USER

# GPG keys import for SPOTIFY
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 931FF8E79F0876134EDDBDCCA87FF9DF48BF1C90
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys 2EBF997C15BDA244B6EBF5D84773BD5E130D1D45

sudo pacman -Syyu --color auto

# Install YAY AUR Manager
git clone https://aur.archlinux.org/yay.git ~/yay && cd "~/yay" && makepkg -si --noconfirm && rm -rf ~/yay

# Load packages
source ~/.config/setup/packages.sh

# Install my packages
sudo pacman -S $PACKAGE --needed --noconfirm --color auto
yay -S $AUR --needed --noconfirm --color auto

# Enable systemd services
for SERVICE in \
    dhcpcd \
    NetworkManager \
    cronie \
    bumblebeed.service \
    bluetooth
do
    sudo systemctl enable $SERVICE
    sudo systemctl start $SERVICE
done

# Install oh-my-zsh
/usr/share/oh-my-zsh/tools/install.sh

# Dependencies for GTA V on SteamPlay (Proton)
# winetricks --force directx9 vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 dotnet40 dotnet452 vb6 xact xna31 xna40 msl31 openal corefonts
