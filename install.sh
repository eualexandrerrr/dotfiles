#!/bin/bash
# github.com/mamutal91

function stows(){
    cd $HOME/.dotfiles
    stow compton
    stow dunst
    stow gpicview
    stow home
    stow i3
    stow neofetch
    stow polybar
    stow rofi
    stow termite
}

function mamutal91(){
    rm -rf $HOME/.dotfiles && cp -rf /media/storage/github/dotfiles $HOME/.dotfiles
    stows
    sudo stow bbswitch -t /etc
    sudo stow X11 -t /etc/X11

    sudo rm -rf /etc/systemd/logind.conf && sudo cp -rf systemd/logind.conf /etc/systemd
}

function first_boot() {
  cd /home/mamutal91/.config
  rm -rf compton dunst gpicview i3 neofetch polybar rofi termite
  cd /etc/X11 && sudo rm -rf *
  cd /home/mamutal91/
  rm -rf .crontab .nanorc .nvidia-xinitrc .Xresources .zlogin .zshrc
}

#first_boot

[[ $USER == "mamutal91" ]] && mamutal91 || stows

canberra-gtk-play --file=$HOME/.local/share/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh
