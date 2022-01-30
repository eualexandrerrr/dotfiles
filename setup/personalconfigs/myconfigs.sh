#!/usr/bin/env bash

clear
source $HOME/.Xcolors &> /dev/null
pwd=$(pwd)
cd $HOME

# Git
git config --global user.email "mamutal91@gmail.com" && git config --global user.name "Alexandre Rangel"

# zsh history
if [[ ! -e $HOME/.zsh_history ]]; then
  pwd=$(pwd)
  rm -rf $HOME/.zsh_history* && cd $HOME && wget https://raw.githubusercontent.com/mamutal91/myhistory/master/.zsh_history
  cd $pwd
else
  echo -e "${BOL_RED}\n VOCÊ PRECISA BAIXAR O HISTÓRICO DO ZSH"
  echo -e "${BOL_GRE}rm -rf \$HOME/.zsh_history* && cd \$HOME && wget https://raw.githubusercontent.com/mamutal91/myhistory/master/.zsh_history"
fi

# Dirs
mkdir -p $HOME/{Pictures,Videos,GitHub} &> /dev/null

# My Tokens
checkTokens() {
  if [[ -d $HOME/.ssh ]]; then
    echo ".ssh já existe"
  else
    sudo rm -rf $HOME/GitHub/mytokens
    sudo rm -rf $HOME/.ssh/id_*
    git clone https://gitlab.com/mamutal91/mytokens $HOME/GitHub/mytokens
  fi
}
checkTokens

myTokensPerms() {
  pwd=$(pwd)
  sudo mkdir -p $HOME/.ssh
  sudo chown -R mamutal91:mamutal91 $HOME/.ssh
  sudo chmod 700 $HOME/.ssh
  cd $HOME/GitHub/mytokens/keys
  cp -rf * $HOME/.ssh
  sudo chmod 644 $HOME/.ssh/*.pub
  sudo chmod 600 $HOME/.ssh/id_ed25519
  sudo chmod 600 $HOME/.ssh/id_rsa
  sudo chmod 600 $HOME/.ssh/authorized_keys
  eval "$(ssh-agent -s)"
  cd $pwd
}
myTokensPerms &> /dev/null

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
cloneRepos() {
  rm -rf $HOME/GitHub/{myarch,myhistory,docker-files,shellscript-atom-snippets} && rm -rf $HOME/.scripter
  git clone ssh://git@github.com/mamutal91/scripter $HOME/.scripter
  git clone ssh://git@github.com/AOSPK/docker-files $HOME/GitHub/docker-files
  git clone ssh://git@github.com/mamutal91/myarch $HOME/GitHub/myarch
  git clone ssh://git@github.com/mamutal91/myhistory $HOME/GitHub/myhistory
  git clone ssh://git@github.com/mamutal91/shellscript-atom-snippets $HOME/GitHub/shellscript-atom-snippets
}
cloneRepos

cd $pwd
