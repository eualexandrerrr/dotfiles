#!/usr/bin/env bash

source $HOME/.colors &>/dev/null
source $HOME/.myTokens &>/dev/null # $myUser $myPass

[ $USER = "mamutal91" ] && source $HOME/.dotfiles/setup/personalconfigs.sh

sudo pacman -Syyu --noconfirm

# Install YAY AUR Manager
pwd=$(pwd)
rm -rf $HOME/yay && git clone https://aur.archlinux.org/yay.git $HOME/yay && cd $HOME/yay && makepkg -si --noconfirm && rm -rf $HOME/yay
cd $pwd

# Load packages
source $HOME/.dotfiles/setup/packages.sh

# GPG Key Spotify
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import -

# Install packages
for i in "${packages[@]}"; do
  sudo pacman -Sy ${i} --needed --noconfirm
done

for i in "${aur[@]}"; do
  yay -Sy ${i} --needed --noconfirm
done

# Atom packages
atom="
  atom-beautify
  atom-material-syntax
  color-picker
  file-icons
  flatten-json
  ftp-remote-edit
  highlight-selected
  indent-sort
  language-i3wm
  language-swaywm
  mamutal91-shellscript-snippets-atom
  markdown-writer
  pigments
  save-workspace"

apm install $atom

# Enable systemd services
for services in \
    cronie \
    bluetooth \
    getty@ttyN.service
do
    sudo systemctl enable $services
    sudo systemctl start $services
done

source $HOME/.dotfiles/setup/etc.sh
source $HOME/.dotfiles/install.sh

chsh -s $(which zsh)
