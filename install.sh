#!/bin/bash
# github.com/mamutal91

# This replaces a folder at home with a folder that makes changes to my dotfiles
rm -rf $HOME/.dotfiles && cp -rf /media/storage/GitHub/dotfiles $HOME/.dotfiles
rm -rf $HOME/.zshrc
cd $HOME/.dotfiles

function system() {
  # SYSTEMD
  sudo rm -rf /etc/systemd/logind.conf
  sudo cp -rf $HOME/.dotfiles/systemd/logind.conf /etc/systemd
  sudo rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
  sudo mkdir -p /etc/systemd/system/getty@tty1.service.d/
  sudo cp -rf $HOME/.dotfiles/systemd/override.conf /etc/systemd/system/getty@tty1.service.d/

  # X11
  sudo rm -rf /etc/X11/nvidia-xorg.conf.d
  sudo rm -rf /etc/X11/xorg.conf.d
  sudo cp -rf $HOME/.dotfiles/X11/* /etc/X11
}

function boot() {
  echo "Removing default configs..."
  cd $HOME/.config
  rm -rf alacritty compton dunst files gpicview i3 neofetch polybar rofi scripts setup
  rm -rf .crontab .nanorc .nvidia-xinitrc .Xresources .zlogin .zshrc
  cd /etc/X11 && sudo rm -rf *
}

# Uncomment only if first boot
#boot

cd $HOME/.dotfiles
stow alacritty
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
stow setup

sudo stow bbswitch -t /etc

system

canberra-gtk-play --file=$HOME/.config/files/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/polybar/launch.sh
