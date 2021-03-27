#!/usr/bin/env bash

clear

source $HOME/.colors &>/dev/null
rm -rf $HOME/.bash_profile .bashrc .config/mimeapps.list

cd $HOME/.dotfiles
for DOTFILES in $(find . -maxdepth 1  -not -name ".*" ! -name "setup" -type d -printf '%f\n')
do
  stow --adopt $DOTFILES || echo "Error on gnu/stow"
  echo "${RED}$DOTFILES ${GRE}stowed.${END}"
done

bash $HOME/.dotfiles/setup/etc.sh
echo "${RED}/etc/ ${GRE}configured.${END}"

play $HOME/.config/sounds/completed.wav &>/dev/null
swaymsg reload &>/dev/null
exit 0
