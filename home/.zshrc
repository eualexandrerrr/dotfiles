#!/usr/bin/env bash

# Themes https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

ZSH="/usr/share/oh-my-zsh/"
ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX=true
HIST_STAMPS="dd/mm/yyyy"
plugins=(git)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export BROWSER="/usr/bin/google-chrome-beta"
export EDITOR="nano"
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
export TERM="xterm-256color"
export STUDIO_JDK=/usr/lib/jvm/java-11-openjdk

# sudo easy
alias chmod="sudo chmod"
alias mv="sudo mv"
alias pacman="sudo pacman"
alias pkill="sudo pkill"
alias rm="sudo rm"
alias systemctl="sudo systemctl"
alias sed="sudo sed"

# paths
alias aospk="cd $HOME/AOSPK"
alias x="cd /mnt/roms/jobs/Kraken"

source $HOME/.config/functions.sh
source $HOME/.config/aospk/functions.sh

function fetch() {
  ./.dotfiles/home/.config/scripts/fetch.sh gnu
}

function dot() {
  pwd=$(pwd)
  cd $HOME
  rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles
  ./.dotfiles/install.sh
  source .zshrc
  cd $pwd
}

function infra() {
  pwd=$(pwd)
  cd $HOME
  echo "infra cloned."
  sudo rm -rf /mnt/roms/infra
  git clone ssh://git@github.com/mamutal91/infra && sudo mv infra /mnt/roms
  cd $pwd
}


function builders() {
  pwd=$(pwd)
  cd $HOME
  echo "buildersbr cloned."
  sudo rm -rf /mnt/roms/buildersbr
  git clone ssh://git@github.com/BuildersBR/buildersbr && sudo mv buildersbr /mnt/roms
  cd $pwd
}
