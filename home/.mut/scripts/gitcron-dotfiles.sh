#!/bin/bash
# github.com/mamutal91

(cat ~/.cache/wal/sequences &)

git config --global user.email "mamutal91@gmail.com"
git config --global user.name "Alexandre Rangel"

dir="/home/mamutal91/"
repos=('.dotfiles')
remoto="mamutal91@archlinux"

app=git.png
icon=$iconsnotify/$app

atualiza() {
	if [ -d $1 ]; then
		if [ ! -f $1/.noup ]; then
			cd $1
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

if [ ! $1 ] || [ $1 == "-a" ]; then
	for r in "${repos[@]}";	do
		caminho="${dir}/${r}"
		atualiza "$caminho"
	done

	atualiza "${HOME}/github"
	[ "$1" == "-a" ] && ssh $remoto "/usr/local/scripts/git-http"
else
	caminho="$@"
	atualiza "$caminho"
fi
