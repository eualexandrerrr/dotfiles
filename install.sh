#!/bin/bash
# github.com/mamutal91

function install(){
    rm -rf $HOME/.dotfiles && cp -rf /media/storage/GitHub/dotfiles $HOME/.dotfiles
    rm -rf $HOME/.zshrc
    cd $HOME/.dotfiles

    stow alacritty
    sudo stow bbswitch -t /etc
    stow compton
    stow dunst
    stow files
    stow gpicview
    stow home
    stow i3
    stow neofetch
    stow polybar
    stow rofi
    stow scripts
    stow thunar
    sudo stow X11 -t /etc/X11

    sudo rm -rf /etc/systemd/logind.conf && sudo cp -rf systemd/logind.conf /etc/systemd
}

function first_boot() {
  cd /home/mamutal91/.config
  rm -rf compton dunst gpicview i3 neofetch polybar rofi alacritty
  cd /etc/X11 && sudo rm -rf *
  cd /home/mamutal91/
  rm -rf .crontab .nanorc .nvidia-xinitrc .Xresources .zlogin .zshrc
}

#first_boot

install

canberra-gtk-play --file=$HOME/.config/files/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh
