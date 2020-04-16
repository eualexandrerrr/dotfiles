#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

# Themes https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

export ZSH="/home/mamutal91/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.config/aosp/zsh

export TERM="xterm-256color"
export EDITOR="nano"
export BROWSER="/usr/bin/google-chrome-stable"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"

alias nano="sudo nano"
alias pacman="sudo pacman"
alias systemctl="sudo systemctl"
alias p="git cherry-pick ${1}"
alias rm="sudo rm"
alias pkill="sudo pkill"
