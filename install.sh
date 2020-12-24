#!/usr/bin/env bash
# github.com/mamutal91

clear

function boot() {
  cd $HOME/.config
  rm -rf alacritty gpicview gtk* mako neofetch sway waybar wofi mimeapps.list
  cd $HOME
  rm -rf .bashrc .bash_profile .zshrc .cmds.sh .nanorc
}

if [ "${1}" == "boot" ]; then boot; fi || echo "Error: boot"

cd $HOME/.dotfiles
for DOTFILES in \
  alacritty \
  gpicview \
  gtk \
  home \
  mako \
  neofetch \
  sway \
  waybar \
  wofi
do
    stow $DOTFILES || echo "Error on gnu/stow"
done

# Remove files from the system, and copy mine!
if [ "$USER" = "mamutal91" ];
then
  source $HOME/.dotfiles/setup/etc.sh || echo "Error: etc"
fi

play $HOME/.bin/sounds/completed.wav
swaymsg reload
pkill waybar && exec waybar
exit 0
