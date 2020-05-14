#!/bin/bash
# github.com/mamutal91


dir="/media/storage/GitHub/"
readonly repos=('archlinux' 'mamutal91.github.io' 'ubuntu')

app=git.png
icon=$icons/$app

function gitcron() {
  for i in "${repos[@]}"; do
			cd $dir/$i
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
				c=$(echo $(git add . -n | tr '\r\n' ' '))
				m="Autocommit Git-Cron: $c"
				git add .
				git commit -m "$m" --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
				git push --force
			fi
done
}

gitcron
