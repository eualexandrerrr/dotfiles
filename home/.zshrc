export ZSH="/home/mamutal91/.oh-my-zsh"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(git archlinux extract web-search)

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source $HOME/.config/aosp/functions.sh

export TERM="xterm-256color"
export EDITOR="nano"
export BROWSER="firefox"

export IDIOMA="pt_BR.UTF-8"
export LANG=$IDIOMA
export LANGUAGE=$IDIOMA
export LC_ALL=$IDIOMA
export LC_CTYPE=$IDIOMA

export icons_path="/home/mamutal91/.config/files/icons"

function storage () {
  cd /media/storage
}
