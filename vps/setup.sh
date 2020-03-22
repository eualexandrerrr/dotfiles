#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

# Based on https://wiki.archlinux.org/index.php/Android#Building

# Enable multilib
sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

sudo pacman -Syyu --color auto

PACKAGES='
  base base-devel bash-completion git git-lfs nano repo ttf-droid vim wget
  maven gradle lib32-gcc-libs
'
sudo pacman -Syy $PACKAGES --noconfirm --needed --color auto

# Install YAY
git clone https://aur.archlinux.org/yay.git $HOME/yay && cd $HOME/yay && makepkg -si --noconfirm && cd .. && rm -rf $HOME/yay

AUR='
  aosp-devel lineageos-devel
'
yay -S $AUR --needed --noconfirm --color auto

# Start git lfs
git-lfs install

# Config repo and others
rm -rf $HOME/.bin && mkdir $HOME/.bin
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $HOME/.bin/repo
ln -s /bin/python3.8 $HOME/.bin/python
chmod a+x $HOME/.bin/repo

if [[ $USER == "mamutal91" ]]; then
  ./.mysetup.sh
fi
