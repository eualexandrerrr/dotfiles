#!/usr/bin/env bash

source $HOME/.colors &> /dev/null
source $HOME/.myTokens &> /dev/null

[ ${1} ] && source $HOME/.dotfiles/setup/personalconfigs.sh && source $HOME/.dotfiles/setup/laptop-mode.sh

sudo pacman -Syyu --noconfirm &> /dev/null

# Install YAY AUR Manager
pwd=$(pwd)
rm -rf $HOME/yay && git clone https://aur.archlinux.org/yay.git $HOME/yay && cd $HOME/yay && makepkg -si --noconfirm && rm -rf $HOME/yay
cd $pwd

# Load packages
source $HOME/.dotfiles/setup/packages.sh

# GPG Key Spotify
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import -

# Install packages
for i in ${packages[@]}; do
  sudo pacman -Sy ${i} --needed --noconfirm
done

for i in ${aur[@]}; do
  yay -Sy ${i} --needed --noconfirm
done

# Winetricks
#winetricks --force directx9 vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 dotnet40 dotnet452 vb6 xact xna31 xna40 msl31 openal corefonts

# gdrive
pwd=$(pwd)
cd $HOME
wget https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_amd64.tar.gz
tar -xvzf gdrive*.tar.gz
chmod +x gdrive
install gdrive /usr/local/bin/gdrive
rm -rf gdrive*
cd $pwd

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
  mamutal91-shellscript-snippets-atom
  markdown-writer
  pigments
  save-workspace"

# apm install $atom --noconfirm

# Enable systemd services
for services in \
    cronie \
    bluetooth \
    mpd \
    laptop-mode.service \
    getty@ttyN.service; do
    sudo systemctl enable $services
    sudo systemctl start $services
done

# Remove folder GO
rm -rf $HOME/go

bash $HOME/.dotfiles/setup/etc.sh
bash $HOME/.dotfiles/setup/nvidia.sh
bash $HOME/.dotfiles/install.sh

chsh -s $(which zsh)
