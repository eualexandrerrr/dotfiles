#!/bin/bash
# github.com/mamutal91

# Mirrors
# sudo reflector -c Brazil --save /etc/pacman.d/mirrorlist
# sudo reflector -l 10 --sort rate --save /etc/pacman.d/mirrorlist

USER=mamutal91

sudo pacman -Sy

readonly PKGS_PACMAN=(
    alacritty android-tools archlinux-keyring atom bbswitch bluez bluez-utils bumblebee compton cronie dunst feh ffmpeg
    filezilla firefox firefox-i18n-pt-br galculator git gpicview gvfs gparted i3-gaps i3lock imagemagick jsoncpp
    lib32-libvdpau lib32-nvidia-utils lib32-opencl-nvidia lib32-virtualgl libreoffice-fresh libreoffice-fresh-pt-br
    linux-headers lxappearance maim mesa mpd mpv neofetch ntp numlockx
    nvidia nvidia-settings nvidia-utils opencl-nvidia
    openssh pinta pulseaudio pulseeffects python-setuptools qbittorrent reflector rofi scrot smplayer steam stow telegram-desktop
    terminus-font thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman ttf-liberation
    unrar unzip wget winetricks wireless_tools
    xautolock xclip xf86-video-intel xorg-server xorg-xbacklight xorg-xinit xorg-xprop xorg-xrandr
    zsh zsh-syntax-highlighting)

readonly PKGS_AUR=(
    arc-gtk-theme capitaine-cursors grive-git gvfs-mtp nvidia-xrun nerd-fonts-complete
#   paper-icon-theme-git
    polybar smplayer-skins smplayer-themes spotify ttf-dejavu ttf-font-awesome whatsapp-nativefier)

function install_pkgs_pacman(){
    for i in "${PKGS_PACMAN[@]}"; do
        sudo pacman -S ${i} --needed --noconfirm
    done
}

function install_pkgs_aur(){
    for i in "${PKGS_AUR[@]}"; do
        yay -S ${i} --needed --noconfirm
    done
}

function install_yay(){
    git clone https://aur.archlinux.org/yay.git /home/mamutal91/yay
    cd "/home/mamutal91/yay"
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

function winetricks(){
    winetricks --force directx9 vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 dotnet40 dotnet452 vb6 xact xna31 xna40 msl31 openal corefonts
}

function oh-my-zsh(){
    rm -rf $HOME/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

function config_system(){
    git config --global user.email "mamutal91@gmail.com"
    git config --global user.name "Alexandre Rangel"
    sudo ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
    sudo systemctl enable NetworkManager
    sudo systemctl enable cronie
    sudo systemctl enable ntpd
    sudo systemctl enable bumblebeed.service
    sudo systemctl enable bluetooth
    sudo chown -R $USER:$USER /home/$USER
    sudo gpasswd -a $USER bumblebee
    chmod +x /home/$USER
}

#winetricks
install_pkgs_pacman
install_yay
install_pkgs_aur
config_system
oh-my-zsh
