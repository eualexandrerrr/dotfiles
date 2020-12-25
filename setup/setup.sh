#!/usr/bin/env bash
# github.com/mamutal91

function personalconfig() {
  pwd=$(pwd) && cd $HOME
  git config --global user.email "mamutal91@gmail.com"
  git config --global user.name "Alexandre Rangel"
  rm -rf $HOME/.zsh_history && wget https://raw.githubusercontent.com/mamutal91/zsh-history/master/.zsh_history
  cd $pwd
}

sudo pacman -Sy --noconfirm

# Install YAY and PACAUR AUR Manager
pwd=$(pwd)
git clone https://aur.archlinux.org/yay.git $HOME/yay && cd "$HOME/yay" && makepkg -si --noconfirm && rm -rf $HOME/yay
cd $pwd

# Load packages
source $HOME/.dotfiles/setup/packages.sh

# GPG Key Spotify
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import -

# Install packages
for i in "${PACKAGES[@]}"; do
  sudo pacman -S ${i} --needed --noconfirm
done

for i in "${AUR[@]}"; do
  yay -S ${i} --needed --noconfirm
done

# Enable systemd services
for SERVICES in \
    dhcpcd \
    NetworkManager \
    cronie \
    bluetooth
do
    sudo systemctl enable $SERVICES
    sudo systemctl start $SERVICES
done

source $HOME/.dotfiles/setup/etc.sh

if [[ $USER = "mamutal91" ]]; then
  personalconfig
fi
