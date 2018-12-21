#!/bin/bash
# github.com/mamutal91

export EDITOR="nano"

git config --global user.name "mamutal91" 
git config --global user.email "mamutal91@gmail.com"

dir="${HOME}/github"

repos=('dotfiles' 'docs' 'mamutal91.github.io')

atualiza() {
	if [ -d $1 ]; then
		if [ ! -f $1/.noup ]; then
			cd $1
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
			git add .
			git commit
			git push
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

canberra-gtk-play --file=$HOME/.local/share/sounds/concluido.wav sting from the

notify-send "Git Hub - Commits realizados"