#!/usr/bin/env bash

if [[ $USER = "mamutal91" ]]; then
  pwd=$(pwd) && cd $HOME
  git config --global user.email "mamutal91@gmail.com"
  git config --global user.name "Alexandre Rangel"
  git config --global http.postBuffer 524288000
  rm -rf $HOME/.zsh_history && wget https://raw.githubusercontent.com/mamutal91/zsh-history/master/.zsh_history
  sudo cp -rf /home/mamutal91/.dotfiles/home/.nanorc /root
  mkdir -p $HOME/{Images,Videos} &>/dev/null
  cd $pwd
fi

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

chsh -s $(which zsh)
