#!/usr/bin/env bash

dir="$HOME/GitHub"
cp -rf $HOME/.zsh_history $HOME/GitHub/zsh-history/

readonly repos=('zsh-history' 'custom-rom')

function gitcron() {
  for i in "${repos[@]}"; do
			cd $dir/$i
			status=$(git add . -n)
			if [[ ! -z "$status" ]]; then
				c=$(echo $(git add . -n | tr '\r\n' ' '))
				m="Autocommit Git-Cron: $c"
				git add .
				git commit -m "$m" --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
				git push --force
			fi
done
}

gitcron
