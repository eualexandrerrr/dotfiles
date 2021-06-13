#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"
icon="${iconpath}/computer.svg"

clear

# My notebook
if [[ $(cat /etc/hostname) = odin ]]; then
  #MyApps
  play $HOME/.config/sounds/gitcron.wav &>/dev/null
  notify-send -i $icon "GitCron" "Starting backups..."
  apps=("Atom" "filezilla" "Thunar" "google-chrome-beta")

  for i in "${apps[@]}"; do

    echo -e "${BOL_GRE}Copying .atom${END}"
    mkdir -p $HOME/GitHub/myapps/.atom
    cp -rf $HOME/.atom/* $HOME/GitHub/myapps/.atom
    echo -e "${BOL_BLU}Copying .zhs-history${END}"
    mkdir -p $HOME/GitHub/myapps/zsh-history
    cp -rf $HOME/.zsh_history $HOME/GitHub/myapps/zsh-history

    echo -e "${BOL_RED}Copying configs ${i}${END}"
    cp -rf $HOME/.config/${i} $HOME/GitHub/myapps

    pwd=$(pwd)
    cd $HOME/GitHub/myapps
    status=$(git add . -n)
    if [[ ! -z "$status" ]]; then
      m="Autocommit Git-Cron"
      git add .
      git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
      git push
    fi
    cd $pwd

  done
fi

# Kraken
if [[ $(cat /etc/hostname) = mamutal91-v2 ]]; then
  m="Autocommit Git-Cron"
  pwd=$(pwd)
  sudo rm -rf /home/mamutal91/.gerrit
  git clone ssh://git@github.com/AOSPK/gerrit -b backup /home/mamutal91/.gerrit
  cp -rf /mnt/roms/sites/docker/gerrit /home/mamutal91/.gerrit
  cd /home/mamutal91/.gerrit
  git add . && git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && git push -f

  sudo rm -rf /home/mamutal91/.jenkins
  git clone ssh://git@gitlab.com/AOSPK/jenkins -b backup /home/mamutal91/.jenkins
  cd /mnt/roms/backupJenkins && sudo cp -rf * /home/mamutal91/.jenkins
  cd /home/mamutal91/.jenkins
  git add . && git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && git push -f
  cd $pwd
fi

# BuildersBR
if [[ $(cat /etc/hostname) = buildersbr.ninja-v2 ]]; then
  m="Autocommit Git-Cron"
  pwd=$(pwd)
  sudo rm -rf /home/mamutal91/.jenkins
  git clone ssh://git@gitlab.com/buildersbr/jenkins -b backup /home/mamutal91/.jenkins
  cd /mnt/roms/backupJenkins && sudo cp -rf * /home/mamutal91/.jenkins
  cd /home/mamutal91/.jenkins
  git add . && git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && git push -f
  cd $pwd
fi
