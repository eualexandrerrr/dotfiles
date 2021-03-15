#!/usr/bin/env bash

HOST=$(cat /etc/hostname)

# My notebook
if [[ $HOST = odin ]]; then
  cp -rf $HOME/.zsh_history $HOME/GitHub/zsh-history/

  repos=( "zsh-history" "custom-rom" ".atom")

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

# Kraken VPS
if [[ $HOST = mamutal91 ]]; then
  m="Autocommit Git-Cron"
  pwd=$(pwd)
  sudo rm -rf /home/mamutal91/.jenkins
  git clone ssh://git@github.com/AOSPK/jenkins -b master /home/mamutal91/.jenkins
  sudo cp -rf /mnt/roms/backupJenkins/* /home/mamutal91/.jenkins
  cd /home/mamutal91/.jenkins
  sudo git add . && sudo git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && sudo git push -f

  sudo rm -rf /home/mamutal91/.gerrit
  git clone ssh://git@github.com/AOSPK/gerrit -b backup /home/mamutal91/.gerrit
  sudo cp -rf /mnt/roms/sites/docker/gerrit /home/mamutal91/.gerrit
  cd /home/mamutal91/.gerrit
  sudo git add . && sudo git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && sudo git push -f
  cd $pwd
fi

# BuildersBR
if [[ $HOST = buildersbr.ninja ]]; then
  m="Autocommit Git-Cron"
  pwd=$(pwd)
  sudo rm -rf /home/mamutal91/.jenkins
  git clone ssh://git@github.com/buildersbr/jenkins -b master /home/mamutal91/.jenkins
  sudo cp -rf /mnt/roms/backupJenkins/* /home/mamutal91/.jenkins
  cd /home/mamutal91/.jenkins
  sudo git add . && sudo git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && sudo git push -f
  cd $pwd
fi
