#!/usr/bin/env bash

# Themes https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

ZSH=/usr/share/oh-my-zsh/
ZSH_THEME="robbyrussell"
plugins=(git)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
export TERM="xterm-256color"
export EDITOR="nano"
export BROWSER="/usr/bin/chromium"
export iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"

export MOZ_ENABLE_WAYLAND=1
export GDK_SCALE=0.8
export GDK_DPI_SCALE=0.5

# sudo easy
alias chmod="sudo chmod"
alias mv="sudo mv"
alias pacman="sudo pacman"
alias pkill="sudo pkill"
alias rm="sudo rm"
alias systemctl="sudo systemctl"
alias sed="sudo sed"

# paths
alias dot="cd /home/mamutal91/.dotfiles && clear && ls -1"
alias github="cd $HOME/GitHub && clear && ls -1"
alias aospk="cd $HOME/AOSPK && clear && ls -1"
alias x="cd /home/rom/AOSPK"
alias buildbot="cd /home/buildbot"

source $HOME/.bin/functions/aospk.sh
source $HOME/.bin/functions/colors.sh
source $HOME/.bin/functions/git.sh
source $HOME/.bin/functions/personal.sh

function dotfiles() {
  pwd=$(pwd)
  cd $HOME
  rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles
  ./.dotfiles/install.sh
  source .zshrc
  cd $pwd
}

function vm () {
  pwd=$(pwd)
  cd $HOME && sudo rm -rf /home/buildbot $HOME/buildbot && git clone https://github.com/mamutal91/buildbot && sudo mv buildbot /home/
  cd $pwd
}
