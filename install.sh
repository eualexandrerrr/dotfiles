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

THEME="gtk-theme-name=$GTK_THEME\n
gtk-icon-theme-name=$GTK_ICON\n
gtk-cursor-theme-name=$GTK_CURSOR\n
gtk-font-name=$GTK_FONT\n"

mkdir -p $HOME/.config/gtk-3.0
echo -e "[Settings]\n" > $HOME/.config/gtk-3.0/settings.ini
echo -e $THEME > $HOME/.gtkrc-2.0
echo -e $THEME >> $HOME/.config/gtk-3.0/settings.ini

# Restart sway
play $HOME/.config/sounds/completed.wav &>/dev/null
swaymsg reload &>/dev/null
exit 0
