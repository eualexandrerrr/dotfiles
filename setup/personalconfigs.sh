#!/usr/bin/env bash

pwd=$(pwd) && cd $HOME

# Git
git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

# zsh history
rm -rf $HOME/.zsh_history && wget https://raw.githubusercontent.com/mamutal91/zsh-history/master/.zsh_history

# Dirs
mkdir -p $HOME/{Images,Videos} &>/dev/null

# SSH keys public
if [ -e "$HOME/.ssh/id_rsa" ]; then
  echo "SSH keys are already on the machine"
else
  mkdir -p $HOME/.ssh
  git clone https://github.com/mamutal91/ssh
  cd ssh/.ssh
  cp -rf id_rsa* $HOME/.ssh
  chmod 600 $HOME/.ssh/id_rsa*
  rm -rf $HOME/ssh
fi

# Atom configs
rm -rf $HOME/.atom
git clone ssh://git@github.com/mamutal91/atom $HOME/.atom

cd $pwd
