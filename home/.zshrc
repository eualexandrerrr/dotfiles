#!/bin/bash
#github.com/mamutal91

# Themes https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"
ZSH=/usr/share/oh-my-zsh
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.zshrc_functionss
export EDITOR="nano"
export BROWSER="/usr/bin/google-chrome-stable"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"
export icons=$HOME/.config/files/icons
