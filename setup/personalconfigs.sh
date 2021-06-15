#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

pwd=$(pwd)

cd $HOME

# Git
git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

# zsh history
pwd=$(pwd)
rm -rf $HOME/.zsh_history* && cd $HOME && wget https://raw.githubusercontent.com/mamutal91/myhistory/master/.zsh_history
cd $pwd

# Dirs
mkdir -p $HOME/{Images,Videos,GitHub} &>/dev/null

# My Tokens
rm -rf $HOME/GitHub/mytokens
if [ -e $HOME/.ssh/id_rsa ]; then
  echo "${BOL_BLU}Cloning repos my * T O K E N S * with ${BOL_YEL}SSH${END}"
  git clone ssh://git@github.com/mamutal91/mytokens $HOME/GitHub/mytokens
else
  echo "${BOL_BLU}Cloning repos my * T O K E N S * with ${BOL_CYA}HTTPS${END}"
  git clone https://github.com/mamutal91/mytokens $HOME/GitHub/mytokens
fi

echo "${BOL_YEL}Copying SSH keys and .myTokens${END}"
pwd=$(pwd)
cd $HOME/GitHub/mytokens
cp -rf .myTokens $HOME
cd .ssh
mkdir -p $HOME/.ssh
cp -rf id_rsa* $HOME/.ssh
sudo chmod 600 $HOME/.ssh/id_rsa*
cd $pwd

# Clone my important repos
function cloneRepos() {
  rm -rf $HOME/GitHub/{myarch,myhistory,infra,custom-rom,shellscript-atom-snippets} && rm -rf $HOME/.scripter
  git clone ssh://git@github.com/mamutal91/scripter $HOME/.scripter
  git clone ssh://git@github.com/AOSPK/infra $HOME/GitHub/infra
  git clone ssh://git@github.com/mamutal91/myarch $HOME/GitHub/myarch
  git clone ssh://git@github.com/mamutal91/myhistory $HOME/GitHub/myhistory
  git clone ssh://git@github.com/mamutal91/custom-rom $HOME/GitHub/custom-rom
  git clone ssh://git@github.com/mamutal91/shellscript-atom-snippets $HOME/GitHub/shellscript-atom-snippets

  # myapps
  if [ ! -d "$HOME/GitHub/myapps" ]; then
    echo "${BOL_YEL}Copying myapps${END}"
    git clone ssh://git@github.com/mamutal91/myapps $HOME/GitHub/myapps # O últomo a ser clonado devido o tamanho...
    if [ $? -eq 0 ]; then
      echo "${GRE}Clone myapps success${END}"
    else
      echo "${RED}Clone myapps failure${END}"
      exit 1
    fi
  else
    echo "${BOL_RED}myapps already exists, I won't clone...${END}"
  fi
}
cloneRepos

# My Apps
echo "${BOL_CYA}Copying my apps${END}"
pwd=$(pwd)
cd $HOME/GitHub/myapps
rm -rf $HOME/.config/{Atom,filezilla,Thunar}
rm -rf $HOME/.atom
cp -rf .atom $HOME
cp -rf Atom $HOME/.config
cp -rf filezilla $HOME/.config
cp -rf Thunar $HOME/.config

cd $pwd
