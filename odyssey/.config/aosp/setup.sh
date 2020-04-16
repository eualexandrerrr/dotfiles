#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

# Based on https://wiki.archlinux.org/index.php/Android#Building

sudo pacman -Syyu

# Load packages
source $HOME/.dotfiles/odyssey/.config/aosp/packages.sh

# Install my packages
for i in "${PACKAGES[@]}"; do
  sudo pacman -S ${i} --needed --noconfirm
done

for i in "${AUR[@]}"; do
  yay -S ${i} --needed --noconfirm
done

# Start git lfs
git-lfs install

# Set java default
sudo archlinux-java set java-8-openjdk/jre

# Config repo and others
rm -rf $HOME/.bin && mkdir $HOME/.bin
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $HOME/.bin/repo
ln -s /bin/python3.8 $HOME/.bin/python
chmod a+x $HOME/.bin/repo
