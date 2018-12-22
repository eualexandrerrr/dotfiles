#!/bin/bash
# github.com/mamutal91

MY_USER=mamutal91

readonly PACOTES_PACMAN=(
    code dunst firefox firefox-i18n-pt-br flat-remix-git git gpciview i3-gaps i3lock iw libreoffice-fresh libreoffice-fresh-pt-br linux-headers lxappearance maim neofetch networkmanager numlockx pinta pulseeffects pulsemixer rambox-bin rofi scrot telegram-desktop teamviewer terminus-font termite thunar thunar-archive-plugin ttf-dejavu tt-font-awesome ttf-liberation spotify unrar unzip vlc wget xf86-video-intel xorg-server xorg-xrandr xorg-xblacklight xorg-xinit xclip)

readonly PACOTES_AUR=(
    nvidia-xrun polybar grive-git)

function aur_helper_yay(){
    sudo pacman -S git --needed --noconfirm
    git clone https://aur.archlinux.org/yay.git /home/${MY_USER}/yay
    cd "/home/${MY_USER}/yay"
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

function zsh(){
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

function instalar_pacotes_pacman(){
    for i in "${PACOTES_PACMAN[@]}"; do
        sudo pacman -S ${i} --needed --noconfirm
    done 
}

function instalar_pacotes_aur(){
    for i in "${PACOTES_AUR[@]}"; do
        yay -S ${i} --needed --noconfirm
    done 
}

function configurar_sistema(){
    sudo systemctl enable NetworkManager
    sudo systemctl enable cronie
    sudo chown -R $MY_USER:$MY_USER /home/$MY_USER
}

echo :::::::::::::::::::::::: YAY - ZSH
#aur_helper_yay
zsh

echo :::::::::::::::::::::::: PACMAN
instalar_pacotes_pacman

echo :::::::::::::::::::::::: AUR
instalar_pacotes_aur

echo :::::::::::::::::::::::: Configurando sistema
configurar_sistema