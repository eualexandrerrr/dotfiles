#!/usr/bin/env bash

pwd=$(pwd) && cd $HOME

# Git
git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

# zsh history
rm -rf $HOME/.zsh_history && wget https://raw.githubusercontent.com/mamutal91/myapps/master/zsh-history/.zsh_history

# Dirs
mkdir -p $HOME/{Images,Videos} &>/dev/null

# SSH keys public
mkdir -p $HOME/.ssh
git clone https://github.com/mamutal91/ssh
cd ssh/.ssh
cp -rf id_rsa* $HOME/.ssh
chmod 600 $HOME/.ssh/id_rsa*
rm -rf $HOME/ssh

# Copy config my apps
bash $HOME/.dotfiles/home/.config/scripts/repositories.sh
cd $HOME/GitHub/myapps

rm -rf $HOME/.config/{Atom,filezilla,Thunar,google-chrome-beta}
rm -rf $HOME/.atom
cp -rf .atom $HOME
cp -rf Atom $HOME/.config
cp -rf filezilla $HOME/.config
cp -rf Thunar $HOME/.config
cp -rf google-chrome-beta $HOME/.config

cd $pwd
