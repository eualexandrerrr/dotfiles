#!/bin/bash
# github.com/mamutal91

MY_USER=mamutal91

readonly PACOTES=(
    "firefox")
    
function configurar_teclado(){
    localectl set-x11-keymap br abnt2
    localectl set-keymap br abnt2
    timedatectl set-local-rtc 1 --adjust-system-clock
}


function instalar_aur_helper(){
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


instalar_aur_helper
configurar_teclado
instalar_pacote
