#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

icon="$HOME/.config/assets/icons/backup.png"

dunstify -i $icon "GitCron" "Starting backups..." &> /dev/null

clear

# My history
if [[ $(cat /etc/hostname) == modinx ]]; then
  pwd=$(pwd)
  cd $HOME/GitHub/myhistory
  cp -rf $HOME/.zsh_history $HOME/GitHub/myhistory
  status=$(git add . -n)
  if [[ -n $status   ]]; then
    echo -e "${BOL_GRE}Copying .zsh_history${END}"
    m="Autocommit Git-Cron"
    git add .
    git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
    git push ssh://git@gitlab.com/mamutal91/myhistory HEAD:refs/heads/master # --force
  fi
  cd $pwd
fi
