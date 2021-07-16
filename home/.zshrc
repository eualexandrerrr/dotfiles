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

export BROWSER="/usr/bin/google-chrome-stable"
export EDITOR="nano"
export LS_COLORS="$LS_COLORS:ow=1;34:tw=1;34:"
export TERM="xterm-256color"
export STUDIO_JDK=/usr/lib/jvm/java-11-openjdk
export PATH="/usr/share/:$PATH"

# Aliases
alias pacman="sudo pacman"
alias pacman-key="sudo pacman-key"
alias pkill="sudo pkill"
alias rm="sudo rm"
alias rsync="sudo rsync"
alias sed="sudo sed"
alias systemctl="sudo systemctl"
alias xprop="xprop | awk '/^WM_CLASS/{sub(/.* =/, \"instance:\"); sub(/,/, \"\nclass:\"); print} /^WM_NAME/{sub(/.* =/, \"title:\"); print}'"
alias notify-send="dunstify"

# Paths
[[ $(cat /etc/hostname) == odin ]] && alias x="cd /mnt/storage/Kraken" || alias x="cd /mnt/roms/jobs/KrakenDev"

if [[ $USER == mamutal91 ]]; then
  git config --global user.email "mamutal91@gmail.com" && git config --global user.name "Alexandre Rangel"
  source $HOME/.config/scripts/functions.sh
  source $HOME/.config/scripts/functionsKraken.sh
  source $HOME/.config/scripts/git.sh
fi
