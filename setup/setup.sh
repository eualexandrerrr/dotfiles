#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens &> /dev/null

sudo pacman -Syyu --noconfirm

# Install YAY AUR Manager
if [[ ! -f $(which yay) ]]; then
  pwd=$(pwd)
  sudo pacman -Sy base-devel --noconfirm
  rm -rf $HOME/yay && git clone https://aur.archlinux.org/yay.git $HOME/yay && cd $HOME/yay && makepkg -si --noconfirm && rm -rf $HOME/yay
  cd $pwd
fi

# Install packages
echo "Install pkgs"
source $HOME/.dotfiles/setup/packages.sh
function installPkgs() {
  for i in "${!array[@]}"; do
    if [[ $USER == mamutal91 ]]; then
      sudo pacman -S ${array[i]} ${array2[i]} --needed --noconfirm && continue || echo -e "\n${BOL_RED}The package is not in the official repositories\n${BOL_BLU}Trying with ${BOL_YEL}YAY${END}\n" && yay -S ${array[i]} ${array2[i]} --needed --noconfirm
    else
      sudo pacman -S ${array[i]} --needed --noconfirm && continue || echo -e "\n${BOL_RED}The package is not in the official repositories\n${BOL_BLU}Trying with ${BOL_YEL}YAY${END}\n" && yay -S ${array[i]} --needed --noconfirm
    fi
  done
}
installPkgs

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

for i in $(ls $HOME/.dotfiles/setup/*.sh); do
  chmod +x $i
  [[ $i == packages.sh ]] && continue
  [[ $i == setup.sh ]] && continue
  bash $i
done

if [[ $USER == mamutal91 ]]; then
  for i in $(ls $HOME/.dotfiles/setup/personalconfigs/*.sh); do
    chmod +x $i
    [[ $i == packages.sh ]] && continue
    [[ $i == setup.sh ]] && continue
    bash $i
  done
fi

# Fonts
mkdir -p /usr/share/fonts/TTF &> /dev/null
cp -rf $HOME/.dotfiles/assets/.config/assets/fonts/* /usr/share/fonts/TTF
fc-cache -f -r -v

# Permissions
sudo chown -R $USER:$USER $HOME

# Remove Kraken scripts
[[ $USER != mamutal91 ]] && rm -rf $HOME/.dotfiles/allscripts/.config/scripts/kraken && rm -rf $HOME//.config/scripts/kraken

# zsh default
chsh -s $(which zsh)
