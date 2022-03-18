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

export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export BROWSER="/usr/bin/google-chrome-stable"
export EDITOR="nano"
export TERM="xterm-256color"
export STUDIO_JDK="/usr/lib/jvm/java-11-openjdk"
export PATH="/usr/share/:$PATH"
export CCACHE_EXEC="/usr/bin/ccache"

export BUILD_USERNAME="mamutal91"
export BUILD_HOSTNAME="nitro5"

# Aliases
alias nvidia="bash $HOME/.dotfiles/setup/nvidia.sh"
alias atom="atom --in-progress-gpu --no-sandbox -n=false"
alias poweroff="nbfc set -s 50 && sudo poweroff"
alias reboot="nbfc set -s 50 && sudo poweroff --reboot"
alias pacman="sudo pacman"
alias pacman-key="sudo pacman-key"
alias mkinitcpio="sudo mkinitcpio"
alias pkill="sudo pkill"
alias rm="sudo rm"
alias rsync="sudo rsync"
alias sed="sudo sed"
alias systemctl="sudo systemctl"
alias xprop="xprop | awk '/^WM_CLASS/{sub(/.* =/, \"instance:\"); sub(/,/, \"\nclass:\"); print} /^WM_NAME/{sub(/.* =/, \"title:\"); print}'"
alias notify-send="dunstify"
alias docker="sudo docker"
alias docker-compose="sudo docker-compose"

# Paths
alias x="cd $HOME/Kraken"
alias out="clear && cd $HOME/Kraken/out/target/product/lmi && ls -1"
alias d="cd /mnt/docker-files"

if [[ $USER == mamutal91 ]]; then
  git config --global user.email "mamutal91@gmail.com" && git config --global user.name "Alexandre Rangel"
  source $HOME/.config/scripts/builder.sh
  source $HOME/.config/scripts/general.sh
  source $HOME/.config/scripts/git.sh
fi
