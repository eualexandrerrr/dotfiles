#!/usr/bin/env bash

clear

source $HOME/.Xcolors &> /dev/null

pwd=$(pwd)
cd $HOME

# Git
git config --global user.email "mamutal91@gmail.com" && git config --global user.name "Alexandre Rangel"

# zsh history
pwd=$(pwd)
rm -rf $HOME/.zsh_history* && cd $HOME && wget https://raw.githubusercontent.com/mamutal91/myhistory/master/.zsh_history
cd $pwd

# Dirs
mkdir -p $HOME/{Pictures,Videos,GitHub} &> /dev/null

# My Tokens
sudo rm -rf $HOME/GitHub/mytokens
if [[ -e $HOME/.ssh/id_ed25519 ]]; then
  git clone ssh://git@gitlab.com/mamutal91/mytokens $HOME/GitHub/mytokens
else
  git clone https://gitlab.com/mamutal91/mytokens $HOME/GitHub/mytokens
fi

pwd=$(pwd)
sudo rm -rf $HOME/.mytokens
sudo mkdir -p $HOME/.mytokens
sudo mkdir -p $HOME/.ssh
sudo chown -R mamutal91:mamutal91 $HOME/.ssh
sudo chmod 700 $HOME/.ssh
sudo chmod 700 $HOME/.mytokens
sudo cp -rf $HOME/GitHub/mytokens/.myTokens $HOME/.mytokens
cd $HOME/GitHub/mytokens/keys
cp -rf * $HOME/.ssh
sudo chmod 777 -R $HOME/.mytokens
sudo chmod 644 $HOME/.ssh/*.pub
sudo chmod 600 $HOME/.ssh/id_ed25519
sudo chmod 600 $HOME/.ssh/id_rsa
sudo chmod 600 $HOME/.ssh/authorized_keys
eval "$(ssh-agent -s)"
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
