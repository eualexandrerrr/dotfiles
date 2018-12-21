#!/bin/bash
# github.com/mamutal91

readonly PACOTES=(
    "firefox")
    
function configurar_teclado(){
    localectl set-x11-keymap br abnt2
    localectl set-keymap br abnt2
    timedatectl set-local-rtc 1 --adjust-system-clock
}


function instalar_aur_helper(){
    pacman -S git --needed --noconfirm
    su ${MY_USER} -c "git clone https://aur.archlinux.org/yay.git /home/${MY_USER}/yay"
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

function clonar_dotfiles(){
    su ${MY_USER} -c "cd /home/${MY_USER} && rm -rf .[^.] .??*" &> /dev/null
    su ${MY_USER} -c "cd /home/${MY_USER} && git clone --bare https://github.com/andreluizs/dotfiles.git /home/${MY_USER}/.dotfiles" 
    su ${MY_USER} -c "cd /home/${MY_USER} && /usr/bin/git --git-dir=/home/${MY_USER}/.dotfiles/ --work-tree=/home/${MY_USER} checkout"
}

#instalar_aur_helper
#clonar_dotfiles
#configurar_teclado
instalar_pacote
