#!/usr/bin/env bash
# github.com/mamutal91

clear

function polybar() {
  cd $HOME/.dotfiles/polybar/.config/polybar
  rm -rf colors.conf
  cp -rf colors.save colors.conf
}

function boot() {
  cd $HOME/.config
  rm -rf alacritty dunst files gpicview i3 neofetch polybar picom rofi scripts mimeapps.list
  cd $HOME
  rm -rf .bashrc .xinitrc .Xresources .zlogin .zshrc .cmds.sh .nanorc
  polybar
}

if [ "${1}" == "boot" ]; then boot; fi || echo "Error: boot"

cd $HOME/.dotfiles
for DOTFILES in \
  alacritty \
  dunst \
  gpicview \
  home \
  i3 \
  neofetch \
  picom \
  polybar \
  rofi \
  scripts
do
    stow $DOTFILES || echo "Error on gnu/stow"
done

# Remove files from the system, and copy mine!
if [ "$USER" = "mamutal91" ];
then
  source $HOME/.dotfiles/setup/etc.sh || echo "Error: etc"
fi

$HOME/.dotfiles/polybar/.config/polybar/launch.sh || echo "Error: polybar"
play $HOME/.local/share/sounds/completed.wav
i3-msg restart
exit 0
