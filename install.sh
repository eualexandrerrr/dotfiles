#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

# This replaces a folder at home with a folder that makes changes to my dotfiles
rm -rf $HOME/.dotfiles && cp -rf /media/storage/GitHub/dotfiles $HOME/.dotfiles

function boot() {
  cd $HOME/.config
  rm -rf alacritty compton dunst files gpicview i3 neofetch polybar rofi scripts setup
  rm -rf .crontab .nanorc .nvidia-xinitrc .Xresources .zlogin .zshrc .zshrc_functions
  cd /etc/X11 && sudo rm -rf *
}

# Uncomment only if first boot
#boot

rm -rf $HOME/.zshrc
cd $HOME/.dotfiles

stow alacritty
stow compton
stow dunst
stow gpicview
stow home
stow i3
stow neofetch
stow odyssey
stow polybar
stow rofi

# Remove files from the system, and copy mine!
source $HOME/.dotfiles/odyssey/.config/setup/etc.sh

# End
canberra-gtk-play --file=$HOME/.config/files/sounds/completed.wav
i3-msg restart
sleep 1s
$HOME/.config/scripts/polybar-launch.sh
