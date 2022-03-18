#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

clear

pwd=$(pwd)
cd $HOME

# Git
git config --global user.email "mamutal91@gmail.com" && git config --global user.name "Alexandre Rangel"

# Dirs
mkdir -p $HOME/{Images,Videos,GitHub,.ssh} &> /dev/null

# My Tokens
checkTokens() {
  if test -f "$HOME/.ssh/id_ed25519"; then
    echo -e "\n${BOL_RED} .ssh já existe${END}\n"
  else
    sudo rm -rf $HOME/GitHub/mytokens
    sudo rm -rf $HOME/.ssh/id_*
    echo -e "\n${BOL_GRE}É NECESSÁRIO AUTENTICAR SUA CONTA ${BOL_MAG}GITLAB ${BOL_GRE}MANUALMENTE${END}\n"
    git clone https://gitlab.com/mamutal91/mytokens $HOME/GitHub/mytokens
    if [ $? -eq 0 ]; then
      echo -e "\n${BOL_GRE}The repo ${BOL_MAG}mytokens ${BOL_GRE}was successfully cloned\n${END}"
    else
      echo -e "\n${BOL_RED}The repo ${BOL_MAG}mytokens ${BOL_RED}cloned failure\n\nTry AGAIN!!!\n${END}"
      sleep 2000000000000
    fi
    pwd=$(pwd)
    sudo chown -R mamutal91:mamutal91 $HOME/.ssh
    sudo chmod 700 $HOME/.ssh
    cd $HOME/GitHub/mytokens/keys
    cp -rf * $HOME/.ssh
    sudo chmod 644 $HOME/.ssh/*.pub
    sudo chmod 600 $HOME/.ssh/id_ed25519
    sudo chmod 600 $HOME/.ssh/authorized_keys
    eval "$(ssh-agent -s)"
    cd $pwd
  fi
}
checkTokens

copyTokens() {
  pwd=$(pwd)
  mkdir -p $HOME/.myTokens
  cd $HOME/GitHub/mytokens
  cp -rf tokens.sh $HOME/.myTokens
  chmod +x $HOME/.myTokens/tokens.sh
  cd $pwd
}
copyTokens

# Clone my important repos
repos=(myhistory myarch docker-files shellscript-atom-snippets crowdin)

for repo in ${repos[@]}; do
  gitUser=mamutal91

  [[ $repo == "docker-files" ]] && gitUser=AOSPK
  [[ $repo == "crowdin" ]] && gitUser=AOSPK

  echo -e "\n${BOL_GRE}Cloning ${MAG}${repo}${END}"
  rm -rf $HOME/GitHub/${repo}
  if [[ $repo == "myhistory" ]]; then
    echo -e "\n${BOL_GRE}É NECESSÁRIO AUTENTICAR SUA CONTA ${BOL_MAG}GITLAB ${BOL_GRE}MANUALMENTE${END}\n"
    git clone https://gitlab.com/mamutal91/myhistory $HOME/GitHub/myhistory
  else
    git clone ssh://git@github.com/${gitUser}/${repo} $HOME/GitHub/${repo}
  fi
done

# zsh history
cd $HOME/GitHub/myhistory
rm -rf $HOME/.zsh_history && cp -rf .zsh_history $HOME

cd $pwd
