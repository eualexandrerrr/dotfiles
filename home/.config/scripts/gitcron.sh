#!/usr/bin/env bash

HOSTNAME=$(cat /etc/hostname)

# My notebook
if [[ $HOSTNAME = odin ]]; then
  #MyApps
  apps=("Atom" "filezilla" "Thunar")

  for i in "${apps[@]}"; do

    cp -rf $HOME/.config/${i} $HOME/GitHub/myapps
    cp -rf $HOME/.atom/* $HOME/GitHub/myapps/.atom

    cd $HOME/GitHub/myapps
    status=$(git add . -n)
    if [[ ! -z "$status" ]]; then
      c=$(echo $(git add . -n | tr '\r\n' ' '))
      m="Autocommit Git-Cron: ${c}"
      git add .
      git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
      git push
    fi
    cd $HOME

  done

  #Commits
  repos=( "zsh-history" "custom-rom" ".atom")
  cp -rf $HOME/.zsh_history $HOME/GitHub/zsh-history/

  for i in "${repos[@]}"; do
    dir=$HOME/GitHub
    if [[ ${i} = ".atom" ]]; then
      dir=$HOME
    fi
  	cd ${dir}/${i}
  	status=$(git add . -n)
  	if [[ ! -z "$status" ]]; then
  		c=$(echo $(git add . -n | tr '\r\n' ' '))
  		m="Autocommit Git-Cron: ${c}"
  		git add .
  		git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
  		git push
  	fi
  done
fi

# Kraken
if [[ $HOSTNAME = mamutal91-v2 ]]; then
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
if [[ $HOSTNAME = buildersbr.ninja-v2 ]]; then
  m="Autocommit Git-Cron"
  pwd=$(pwd)
  sudo rm -rf /home/mamutal91/.jenkins
  git clone ssh://git@gitlab.com/buildersbr/jenkins -b backup /home/mamutal91/.jenkins
  cd /mnt/roms/backupJenkins && sudo cp -rf * /home/mamutal91/.jenkins
  cd /home/mamutal91/.jenkins
  git add . && git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && git push -f
  cd $pwd
fi
