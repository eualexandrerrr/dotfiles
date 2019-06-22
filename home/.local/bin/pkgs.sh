#!/bin/bash
# github.com/mamutal91

# Mirrors
# sudo reflector -c Brazil --save /etc/pacman.d/mirrorlist
# sudo reflector -l 10 --sort rate --save /etc/pacman.d/mirrorlist

USER=mamutal91

sudo pacman -Sy

readonly PKGS_PACMAN=(
    archlinux-keyring git i3-gaps i3lock compton dunst rofi mpd maim ffmpeg reflector neofetch scrot lxappearance feh gpicview
    bluez bluez-utils
    python-setuptools openssh cronie stow jsoncpp
    pulseaudio pulseeffects
    zsh zsh-syntax-highlighting
    termite terminus-font
    telegram-desktop
    smplayer
    pinta
    thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman
    atom mpv smplayer qbittorrent galculator
    libreoffice-fresh libreoffice-fresh-pt-br
    firefox firefox-i18n-pt-br filezilla
    steam ttf-liberation
    winetricks
    nvidia nvidia-settings nvidia-utils lib32-virtualgl lib32-nvidia-utils opencl-nvidia lib32-libvdpau lib32-opencl-nvidia
    xf86-video-intel bumblebee mesa bbswitch
    xorg-server xorg-xrandr xorg-xbacklight xorg-xinit xorg-xprop xautolock xclip
    linux-headers android-tools wireless_tools numlockx gvfs ntp unrar unzip wget)

readonly PKGS_AUR=(
    nvidia-xrun
    polybar
    gvfs-mtp selinux-python
    arc-gtk-theme capitaine-cursors
    franz
    paper-icon-theme-git
    ttf-dejavu ttf-font-awesome
    Whatsie-bin spotify grive-git
    smplayer-skins smplayer-themes)

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
#oh-my-zsh
