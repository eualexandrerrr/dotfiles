#!/bin/bash
# github.com/mamutal91

(cat ~/.cache/wal/sequences &)

git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

app=git.png
icon=$iconsnotify/$app

atualiza() {
	if [ -d $1 ]; then
		if [ ! -f $1/.noup ]; then
			cd /media/storage/GitHub/dotfiles
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
			git add .
			git commit -s --author="Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
			git push
			DISPLAY=:0 notify-send -i $icon "dotfiles atualizado."
			fi
		fi
	fi
}

atualiza
