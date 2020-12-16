#!/usr/bin/env bash
# github.com/mamutal91

clear

function boot() {
  cd $HOME/.config
  rm -rf alacritty dunst files gpicview i3 neofetch polybar picom rofi scripts mimeapps.list
  cd $HOME
  rm -rf .bashrc .xinitrc .Xresources .zlogin .zshrc .cmds.sh .nanorc
}

if [ "${1}" == "boot" ]; then boot; fi || echo "Error: boot"

cd $HOME/.dotfiles
for DOTFILES in \
  alacritty \
  dunst \
  exchange \
  gpicview \
  home \
  i3 \
  neofetch \
  picom \
  polybar \
  rofi
do
    stow $DOTFILES || echo "Error on gnu/stow"
done

# Remove files from the system, and copy mine!
source $HOME/.dotfiles/setup/etc.sh || echo "Error: etc"

play $HOME/.config/files/sounds/completed.wav
i3-msg restart
sleep 1
exit 0
