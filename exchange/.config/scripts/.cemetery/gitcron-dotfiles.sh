#!/usr/bin/env bash
# github.com/mamutal91

dotfiles() {
	if [ -d $1 ]; then
		if [ ! -f $1/.noup ]; then
			cd /media/storage/GitHub/dotfiles
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
			git add .
			git commit --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
			git push
			fi
		fi
	fi
}

dotfiles
