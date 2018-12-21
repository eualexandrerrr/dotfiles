#!/bin/bash
# github.com/mamutal91

MY_USER=mamutal91

readonly PACOTES=(
    "firefox")
    
function aur_helper_yay(){
    pacman -S git --needed --noconfirm
    git clone https://aur.archlinux.org/yay.git /home/${MY_USER}/yay
    cd "/home/${MY_USER}/yay"
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

function instalar_pacote(){
    for i in "${PACOTES[@]}"; do
        yay -S ${i} --needed --noconfirm
    done 
}

function configurar_sistema(){
    pacman -S git --needed --noconfirm
    git clone https://aur.archlinux.org/yay.git /home/${MY_USER}/yay
    cd "/home/${MY_USER}/yay"
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

instalar_pacote
instalar_pacote_aur


aur_helper_yay
configurar_sistema
