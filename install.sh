#!/usr/bin/env bash

clear

source $HOME/.colors &>/dev/null
rm -rf $HOME/.bash_profile .bashrc .config/mimeapps.list

# Stow
cd $HOME/.dotfiles
for DOTFILES in $(find . -maxdepth 1  -not -name ".*" ! -name "setup" -type d -printf '%f\n')
do
  stow --adopt $DOTFILES || echo "Error on gnu/stow"
  echo "${RED}$DOTFILES ${GRE}stowed.${END}"
done

bash $HOME/.dotfiles/setup/etc.sh
echo "${RED}/etc/ ${GRE}configured.${END}"

# GTK Generator
SWAY=$HOME/.config/sway/config
GTK_THEME=$(grep 'set $theme' $SWAY | awk '{ print $3 }')
GTK_ICON=$(grep 'set $icon' $SWAY | awk '{ print $3 }')
GTK_CURSOR=$(grep 'set $cursor' $SWAY | awk '{ print $3 }')
GTK_FONT=$(grep 'set $font' $SWAY | awk '{ print $3 }')

THEME_GTK2="gtk-theme-name=\"${GTK_THEME}\"\n
gtk-icon-theme-name=\"$GTK_ICON\"\n
gtk-cursor-theme-name=\"$GTK_CURSOR\"\n
gtk-font-name=\"$GTK_FONT\""

THEME_GTK3="[Settings]\n
gtk-theme-name=$GTK_THEME\n
gtk-icon-theme-name=$GTK_ICON\n
gtk-cursor-theme-name=$GTK_CURSOR\n
gtk-font-name=$GTK_FONT"

mkdir -p $HOME/.config/gtk-3.0
echo -e $THEME_GTK2 > $HOME/.gtkrc-2.0
echo -e $THEME_GTK3 > $HOME/.config/gtk-3.0/settings.ini
sed -i 's/^ //' $HOME/.gtkrc-2.0
sed -i 's/^ //' $HOME/.config/gtk-3.0/settings.ini
chmod 644 $HOME/.gtkrc-2.0
chmod 644 $HOME/.config/gtk-3.0/settings.ini

# Settings to use on my /root
if [[ $USER = mamutal91 ]]; then
  sudo cp -rf /home/mamutal91/.ssh /root
  sudo cp -rf /home/mamutal91/.dotfiles/home/.nanorc /root
fi

# Restart sway
play $HOME/.config/sounds/completed.wav &>/dev/null
swaymsg reload &>/dev/null
exit 0
