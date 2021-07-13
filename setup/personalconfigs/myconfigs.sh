#!/usr/bin/env bash

clear

source $HOME/.Xcolors &> /dev/null

pwd=$(pwd)
cd $HOME

# Git
git config --global user.email "mamutal91@aospk.org" && git config --global user.name "Alexandre Rangel"

# zsh history
pwd=$(pwd)
rm -rf $HOME/.zsh_history* && cd $HOME && wget https://raw.githubusercontent.com/mamutal91/myhistory/master/.zsh_history
cd $pwd

# Dirs
mkdir -p $HOME/{Images,Videos,GitHub} &> /dev/null

# My Tokens
rm -rf $HOME/GitHub/mytokens
if [[ -e $HOME/.ssh/id_rsa ]]; then
  git clone ssh://git@github.com/mamutal91/mytokens $HOME/GitHub/mytokens
else
  git clone https://github.com/mamutal91/mytokens $HOME/GitHub/mytokens
fi

pwd=$(pwd)
cp -rf $HOME/GitHub/mytokens $HOME && rm -rf $HOME/.mytokens && mv $HOME/mytokens $HOME/.mytokens
cd $HOME/GitHub/mytokens/.ssh
mkdir -p $HOME/.ssh
cp -rf id_rsa* $HOME/.ssh
sudo chmod 600 $HOME/.ssh/id_rsa*
cd $pwd

# Clone my important repos
cloneRepos() {
  rm -rf $HOME/GitHub/{myarch,myhistory,infra,custom-rom,shellscript-atom-snippets} && rm -rf $HOME/.scripter
  git clone ssh://git@github.com/mamutal91/scripter $HOME/.scripter
  git clone ssh://git@github.com/AOSPK/infra $HOME/GitHub/infra
  git clone ssh://git@github.com/mamutal91/myarch $HOME/GitHub/myarch
  git clone ssh://git@github.com/mamutal91/myhistory $HOME/GitHub/myhistory
  git clone ssh://git@github.com/mamutal91/custom-rom $HOME/GitHub/custom-rom
  git clone ssh://git@github.com/mamutal91/shellscript-atom-snippets $HOME/GitHub/shellscript-atom-snippets
}
cloneRepos

cd $pwd
