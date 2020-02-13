export ZSH="/home/mamutal91/.oh-my-zsh"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(git archlinux extract web-search)

source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export TERM="xterm-256color"
export EDITOR="nano"
export LANG="pt_BR.UTF-8"
export LC_ALL="pt_BR.UTF-8"
export LANGUAGE="pt_BR.UTF-8"
export LC_CTYPE="pt_BR.UTF-8"

export BROWSER=firefox
export icons_path="/home/mamutal91/.config/files/icons"

function push () {
  git push ssh://git@github.com/mamutal91/${1} HEAD:refs/heads/ten --force
  git push ssh://git@github.com/aosp-forking/${1} HEAD:refs/heads/ten --force
}

function p () {
  git cherry-pick ${1}
}
