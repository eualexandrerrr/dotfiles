ZSH=/usr/share/oh-my-zsh/
# More themes https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

plugins=(git archlinux extract)

export TERM="xterm-256color"
export EDITOR="nano"
export BROWSER="/usr/bin/google-chrome-stable"
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk

export IDIOMA="pt_BR.UTF-8"
export LANG=$IDIOMA
export LANGUAGE=$IDIOMA
export LC_ALL=$IDIOMA
export LC_CTYPE=$IDIOMA

export icons_path=$HOME/.config/files/icons

function p () {
  git cherry-pick ${1}
}
