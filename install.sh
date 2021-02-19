#!/usr/bin/env bash

clear

source $HOME/.colors &>/dev/null
rm -rf $HOME/.bash_profile .bashrc

cd $HOME/.dotfiles
for DOTFILES in $(find . -maxdepth 1  -not -name "etc" ! -name ".*" ! -name "kraken" ! -name "setup" -type d -printf '%f\n')
do
  stow --adopt $DOTFILES || echo "Error on gnu/stow"
  echo "${RED}$DOTFILES ${GRE}stowed.${END}"
done

# etc
if [[ "$USERNAME" = "mamutal91" ]];
then
  $HOME/.dotfiles/setup/etc.sh || echo "Error configure etc"
  echo "${RED}/etc/ ${GRE}configured.${END}"
fi

play $HOME/.config/sounds/completed.wav &>/dev/null
swaymsg reload &>/dev/null
exit 0
