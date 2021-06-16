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
alias cp -rf="sudo rsync -av --progress"
alias mv="sudo rsync -av --progress --remove-source-files"
alias pacman="sudo pacman"
alias pkill="sudo pkill"
alias rm="sudo rm"
alias systemctl="sudo systemctl"
alias sed="sudo sed"

# paths
alias x="cd /mnt/roms/jobs/KrakenDev"
alias c="cd $HOME/GitHub"

source $HOME/.config/functions.sh
source $HOME/.config/functionsKraken.sh
