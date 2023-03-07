#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

clear

pwd=$(pwd)
cd $HOME

# Git
git config --global user.email "mamutal91@gmail.com" && git config --global user.name "Alexandre Rangel"

# Dirs
mkdir -p $HOME/{Images,Downloads/Arch,Videos,GitHub,.ssh} &> /dev/null

# My Tokens
tokens() {
    sudo rm -rf $HOME/GitHub/mytokens
    sudo rm -rf $HOME/.ssh/id_*
    echo -e "\n${BOL_GRE}Será necessário autenticar a conta do ${BOL_MAG}GITLAB ${BOL_GRE}mamualmente...${END}\n"
    git clone https://gitlab.com/mamutal91/mytokens $HOME/GitHub/mytokens
    sed -i "s|https://gitlab|ssh://git@gitlab|g" $HOME/GitHub/mytokens/.git/config
    if [ $? -eq 0 ]; then
      echo -e "\n${BOL_GRE}The repo ${BOL_MAG}mytokens ${BOL_GRE}was successfully cloned\n${END}"
    else
      echo -e "\n${BOL_RED}The repo ${BOL_MAG}mytokens ${BOL_RED}cloned failure\n\nTry AGAIN!!!\n${END}"
      sleep 2000000000000
    fi

    sleep 2

    pwd=$(pwd)

    sudo chown -R mamutal91:mamutal91 $HOME/.ssh
    sudo chmod 700 $HOME/.ssh

    cd $HOME/GitHub/mytokens/keys
    cp -rf * $HOME/.ssh
    sudo chmod 644 $HOME/.ssh/*.pub
    sudo chmod 600 $HOME/.ssh/id_ed25519
    sudo chmod 600 $HOME/.ssh/authorized_keys
    eval "$(ssh-agent -s)"

    mkdir -p $HOME/.myTokens
    cd $HOME/GitHub/mytokens
    cp -rf tokens.sh $HOME/.myTokens
    chmod +x $HOME/.myTokens/tokens.sh

    cd $pwd
}
tokens

# Clone my important repos
repos=(myhistory mywifi myarch mamutal91 scripter)

for repo in ${repos[@]}; do
  gitUser="mamutal91"
  gitHost="github"
  gitFolder="$HOME/GitHub/${repo}"

  [[ $repo == "myhistory" ]] && gitHost="gitlab"
  [[ $repo == "mywifi" ]] && gitHost="gitlab"
  [[ $repo == "scripter" ]] && gitFolder="$HOME/.scripter"

  echo -e "\n${BOL_GRE}Cloning ${MAG}${repo}${END}"
  rm -rf $HOME/GitHub/${repo}
  rm -rf $HOME/.scripter

  git clone ssh://git@${gitHost}.com/${gitUser}/${repo} ${gitFolder}
done

echo -e "\n${BOL_GRE}Restaurando meu ${BOL_MAG}.zsh_history${END}\n"
cd $HOME/GitHub/myhistory
rm -rf $HOME/.zsh_history && cp -rf .zsh_history $HOME

echo -e "\n${BOL_GRE}Restaurando minhas redes ${BOL_MAG}Wifi${END}\n"
sudo rm -rf /var/lib/iwd/*
sudo mkdir -p /var/lib/iwd
sudo chmod 700 /var/lib/iwd
sudo cp -rf $HOME/GitHub/mywifi/iwd/*.psk /var/lib/iwd

cd $pwd
