#!/usr/bin/env bash

HOSTNAME=$(cat /etc/hostname)

# My notebook
if [[ $HOSTNAME = odin ]]; then
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
if [[ $HOSTNAME = mamutal91-v2 ]]; then
  m="Autocommit Git-Cron"
  pwd=$(pwd)
  rm -rf /home/mamutal91/.gerrit
  git clone ssh://git@github.com/AOSPK/gerrit -b backup /home/mamutal91/.gerrit
  cp -rf /mnt/roms/sites/docker/gerrit /home/mamutal91/.gerrit
  cd /home/mamutal91/.gerrit
  git add . && git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && git push -f
  cd $pwd

  rm -rf /home/mamutal91/.jenkins
  git clone ssh://git@github.com/AOSPK/jenkins -b master /home/mamutal91/.jenkins
  cp -rf /mnt/roms/backupJenkins/* /home/mamutal91/.jenkins
  cd /home/mamutal91/.jenkins
  git add . && git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && git push -f
fi

# BuildersBR
if [[ $HOSTNAME = buildersbr.ninja-v2 ]]; then
  m="Autocommit Git-Cron"
  pwd=$(pwd)
  rm -rf /home/mamutal91/.jenkins
  git clone ssh://git@github.com/buildersbr/jenkins -b master /home/mamutal91/.jenkins
  cp -rf /mnt/roms/backupJenkins/* /home/mamutal91/.jenkins
  cd /home/mamutal91/.jenkins
  git add . && git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && git push -f
  cd $pwd
fi
