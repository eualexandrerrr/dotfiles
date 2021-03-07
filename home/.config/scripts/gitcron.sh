#!/usr/bin/env bash

HOST=$(cat /etc/hostname)

# My notebook
if [[ $HOST = odin ]]; then
  cp -rf $HOME/.zsh_history $HOME/GitHub/zsh-history/

  repos=( "zsh-history" "custom-rom" )

  for i in "${repos[@]}"; do
    dir=$HOME/GitHub
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
  kraken=( "gerrit" "jenkins" )

  for i in "${kraken[@]}"; do
  	sudo rm -rf /home/mamutal91/.${i}
    git clone ssh://git@github.com/AOSPK/gerrit -b backup $HOME/.gerrit
    git clone ssh://git@github.com/AOSPK/jenkins -b backup $HOME/.jenkins
    if [[ ${i} = gerrit ]]; then
      sudo cp -rf /mnt/roms/sites/docker/${i}/* /home/mamutal91/.${i}
    fi
    if [[ ${i} = jenkins ]]; then
      sudo cp -rf /var/lib/jenkins/* /home/mamutal91/.${i}
    fi
  	cd $HOME/.${i}
  	status=$(sudo git add . -n)
  	if [[ ! -z "$status" ]]; then
  		c=$(echo $(sudo git add . -n | tr '\r\n' ' '))
  		m="Autocommit Git-Cron: ${c}"
  		sudo git add .
      sudo git commit -m "${m}" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
  		sudo git push -f
  	fi
  done
fi
