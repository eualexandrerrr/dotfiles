#!/usr/bin/env bash

#cp -rf $HOME/.zsh_history $HOME/GitHub/zsh-history/

[ ! -d $HOME/.gerrit ] && git clone ssh://git@github.com/AOSPK/gerrit $HOME/.gerrit
[ ! -d $HOME/.jenkins ] && git clone ssh://git@github.com/AOSPK/jenkins $HOME/.jenkins
[ ! -d $HOME/.userge-x ] && git clone ssh://git@github.com/mamutal91/userge-x $HOME/.userge-x

repos=(
#  "$HOME/GitHub/zsh-history"
#  "$HOME/GitHub/custom-rom"
  "$HOME/.gerrit"
  "$HOME/.jenkins"
  "$HOME/.userge-x"
)

for i in "${repos[@]}"; do
  dir=$HOME/GitHub
  if [[ ${i} = gerrit ]]; then
    cp -rf /mnt/roms/sites/docker/gerrit/* $HOME/.gerrit
  fi
  if [[ ${i} = jenkins ]]; then
    cp -rf /var/lib/jenkins/* $HOME/.jenkins
  fi
  if [[ ${i} = userge-x ]]; then
    cp -rf /mnt/roms/sites/docker/userge-x/* $HOME/.userge-x
  fi
	cd $i
	status=$(git add . -n)
	if [[ ! -z "$status" ]]; then
		c=$(echo $(git add . -n | tr '\r\n' ' '))
		m="Autocommit Git-Cron: $c"
		git add .
		git commit -m "$m" --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
		git push
	fi
done
