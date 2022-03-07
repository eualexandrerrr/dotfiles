#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

clear

if [[ ! -d $HOME/.dotfiles ]]; then
  echo "For you to use this dotfiles, it must be located in your HOME, and hidden, the correct path is: ~/.dotfiles"
  exit
fi

rm -rf $HOME/.bash_profile .bashrc .xinitrc .config/mimeapps.list

# Stow
cd $HOME/.dotfiles
for dotfiles in $(find . -maxdepth 1  -not -name ".*" ! -name "setup" -type d -printf '%f\n'); do
  stow --adopt $dotfiles || echo -e "${BOL_RED}Error on gnu/stow${END}"
  echo "${RED}$dotfiles ${GRE}stowed.${END}"
done

# etc
echo "${RED}/etc ${GRE}and ${RED}GTK ${GRE}configured.${END}"
bash $HOME/.dotfiles/setup/gtk-generator.sh
bash $HOME/.dotfiles/setup/etc.sh

# Restart sway
i3-msg reload &> /dev/null
fc-cache -f -r -v &> /dev/null
bash $HOME/.config/polybar/launch.sh
exit 0
