#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens &> /dev/null

clear

sudo pacman -Syyu --noconfirm

# Install YAY AUR Manager
if [[ ! -f $(which yay) ]]; then
  pwd=$(pwd)
  sudo pacman -Sy base-devel --noconfirm
  rm -rf $HOME/yay && git clone https://aur.archlinux.org/yay.git $HOME/yay && cd $HOME/yay && makepkg -si --noconfirm && rm -rf $HOME/yay
  cd $pwd
fi

# Load packages
source $HOME/.dotfiles/setup/packages.sh

aurMsg() {
  echo -e "${BOL_RED}\nThe ${BOL_YEL}$i ${BOL_RED}package is not in the official ${BOL_GRE}ArchLinux ${BOL_RED}repositories...\n${BOL_RED}Searching ${BOL_BLU}AUR ${BOL_RED}package ${BOL_RED}with ${BOL_BLU}yay${END}\n"
}

echo -e "\n${BOL_RED}Installing dependencies!${END}\n"
for i in "${dependencies[@]}"; do
  sudo pacman -S ${i} --needed --noconfirm && continue || aurMsg && yay -S ${i} --needed --noconfirm
done

if [[ $USER == mamutal91 ]]; then
  for i in "${mypackages[@]}"; do
    sudo pacman -S ${i} --needed --noconfirm && continue || aurMsg && yay -S ${i} --needed --noconfirm
  done
fi

# Enable systemd services
for services in \
    cronie \
    bluetooth \
    mpd \
    mopidy \
    libvirtd.service \
    laptop-mode.service \
    getty@ttyN.service; do
    sudo systemctl enable $services &> /dev/null
    sudo systemctl start $services &> /dev/null
done

# Remove folder GO
rm -rf $HOME/go &> /dev/null

for i in $(ls $HOME/.dotfiles/setup/scripts/*.sh); do
  chmod +x $i
  bash $i
done

if [[ $USER == mamutal91 ]]; then
  for i in $(ls $HOME/.dotfiles/setup/personalconfigs/*.sh); do
    chmod +x $i
    bash $i
  done
fi

# Fonts
sudo mkdir -p /usr/share/fonts/TTF &> /dev/null
sudo cp -rf $HOME/.dotfiles/assets/.config/assets/fonts/* /usr/share/fonts/TTF
fc-cache -f -r -v

# Permissions
sudo chown -R $USER:$USER $HOME

# Remove Kraken scripts
[[ $USER != mamutal91 ]] && rm -rf $HOME/.dotfiles/allscripts/.config/scripts/kraken && rm -rf $HOME//.config/scripts/kraken

# zsh default
chsh -s $(which zsh)
