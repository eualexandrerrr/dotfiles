#!/usr/bin/env bash

clear

if [[ ! -d $HOME/.dotfiles ]]; then
  echo "For you to use this dotfiles, it must be located in your HOME, and hidden, the correct path is: ~/.dotfiles"
  exit
fi

source $HOME/.Xcolors &> /dev/null
rm -rf $HOME/.bash_profile .bashrc .xinitrc .config/mimeapps.list

# Stow
cd $HOME/.dotfiles
for dotfiles in $(find . -maxdepth 1  -not -name ".*" ! -name "setup" -type d -printf '%f\n'); do
  stow --adopt $dotfiles || echo -e "${BOL_RED}Error on gnu/stow${END}"
  echo "${RED}$dotfiles ${GRE}stowed.${END}"
done

# Styles
echo "${RED}styles, themes and gtk ${GRE}configured.${END}"
bash $HOME/.dotfiles/setup/scripts/theme_generator_colors.sh
bash $HOME/.dotfiles/setup/scripts/theme_generator_gtk.sh
bash $HOME/.dotfiles/polybar/.config/polybar/scripts/style-switch-generator.sh

# etc
echo "${RED}/etc/ ${GRE}configured.${END}"
bash $HOME/.dotfiles/setup/scripts/etc.sh

# Settings to use on my /root
sudo cp -rf $HOME/.dotfiles/home/.nanorc /root &> /dev/null

# Copy my tokens
if [[ $USER == mamutal91 ]]; then
  if [[ $(cat /etc/hostname) == mamutal91-v2 ]]; then
    git clone ssh://git@github.com/mamutal91/mytokens $HOME
    cp -rf $HOME/mytokens $HOME
  else
    cp -rf $HOME/GitHub/mytokens $HOME
  fi
  rm -rf $HOME/.mytokens
  mv $HOME/mytokens $HOME/.mytokens
fi

# Restart sway
i3-msg reload &> /dev/null
fc-cache -f -r -v &> /dev/null
bash $HOME/.config/polybar/launch.sh &> /dev/null
exit 0
