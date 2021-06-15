#!/usr/bin/env bash
source $HOME/.colors &>/dev/null
pwd=$(pwd)

cd $HOME

# Git
git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

# zsh history
rm -rf $HOME/.zsh_history* && wget https://raw.githubusercontent.com/mamutal91/myapps/master/zsh-history/.zsh_history?token=AH2IPGNC4IK6L42V26UFJ3LAZAFVY && mv .zsh_history?token=AH2IPGNC4IK6L42V26UFJ3LAZAFVY .zsh_history

# Dirs
mkdir -p $HOME/{Images,Videos,GitHub} &>/dev/null

# Clone my important repos
if [[ -e $HOME/.ssh/id_rsa ]]; then
  echo "${BOL_BLU}Cloning repos my repos with SSH${END}"
  typeClone=ssh://git@
else
  echo "${BOL_YEL}Cloning repos my repos with HTTPS${END}"
  typeClone=https://
fi

rm -rf $HOME/{GitHub,.scripttest}
git clone ${typeClone}github.com/mamutal91/scripttest $HOME/.scripttest
git clone ${typeClone}github.com/mamutal91/myarch $HOME/GitHub/myarch
git clone ${typeClone}github.com/mamutal91/myapps $HOME/GitHub/myapps
git clone ${typeClone}github.com/mamutal91/mytokens $HOME/GitHub/mytokens
git clone ${typeClone}github.com/mamutal91/custom-rom $HOME/GitHub/custom-rom
git clone ${typeClone}github.com/AOSPK/infra $HOME/GitHub/infra

# My Tokens
echo "${BOL_YEL}Copying SSH keys and .myTokens${END}"
pwd=$(pwd)
cd $HOME/GitHub/mytokens
cp -rf .myTokens $HOME
cd .ssh
mkdir -p $HOME/.ssh
cp -rf id_rsa* $HOME/.ssh
sudo chmod 600 $HOME/.ssh/id_rsa*
cd $pwd

# My Apps
echo "${BOL_CYA}Copying my apps${END}"
pwd=$(pwd)
cd $HOME/GitHub/myapps
rm -rf $HOME/.config/{Atom,filezilla,Thunar,google-chrome-beta}
rm -rf $HOME/.atom
cp -rf .atom $HOME
cp -rf Atom $HOME/.config
cp -rf filezilla $HOME/.config
cp -rf Thunar $HOME/.config
cp -rf google-chrome-beta $HOME/.config

cd $pwd
