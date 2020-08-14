#!/bin/bash
# github.com/mamutal91


# Based on https://wiki.archlinux.org/index.php/Android#Building

# Create folders
mkdir -p $HOME/.ccache
mkdir -p $HOME/.pull_rebase

# PGP keys need importing required by: ncurses5-compat-libs lib32-ncurses5-compat-libs
gpg --keyserver pgpkeys.mit.edu --recv-key C52048C0C0748FEE227D47A2702353E0F7E48EDB
gpg --keyserver pgp.mit.edu --recv-keys 79BE3E4300411886

# Load packages
source $HOME/.dotfiles/aspire/.config/aosp/packages.sh

# Install my packages
for i in "${PACKAGES[@]}"; do
  sudo pacman -S ${i} --needed --noconfirm
done

for i in "${AUR[@]}"; do
  yay --skippgpcheck -S ${i} --needed --noconfirm
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
