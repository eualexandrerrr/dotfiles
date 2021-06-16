#!/usr/bin/env bash

clear

source $HOME/.colors 2>/dev/null 
rm -rf $HOME/.bash_profile .bashrc .config/mimeapps.list

# Stow
cd $HOME/.dotfiles
for DOTFILES in $(find . -maxdepth 1  -not -name ".*" ! -name "setup" -type d -printf '%f\n')
do
  stow --adopt $DOTFILES || echo -e "${BOL_RED}Error on gnu/stow${END}"
  echo "${RED}$DOTFILES ${GRE}stowed.${END}"
done

# GTK
echo "${RED}gtk ${GRE}configured.${END}"
bash $HOME/.dotfiles/setup/gtk.sh

# etc
echo "${RED}/etc/ ${GRE}configured.${END}"
bash $HOME/.dotfiles/setup/etc.sh

# Settings to use on my /root
[ $USER = mamutal91 ] && sudo cp -rf $HOME/.dotfiles/home/.nanorc /root 2>/dev/null 

# Copy my tokens
[ $(cat /etc/hostname) = mamutal91-v2 ] && rm -rf $HOME/.mytokensfolder && git clone ssh://git@github.com/mamutal91/mytokens $HOME/.mytokensfolder && cp -rf $HOME/.mytokensfolder/.myTokens $HOME 2>/dev/null 
[ $(cat /etc/hostname) = odin ] && cp -rf $HOME/GitHub/mytokens/.myTokens $HOME 2>/dev/null 

# Restart sway
play $HOME/.config/sounds/completed.wav 2>/dev/null 
swaymsg reload 2>/dev/null 
exit
