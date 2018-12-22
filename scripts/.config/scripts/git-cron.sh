#!/bin/bash
# github.com/mamutal91

# Add linha no crontab
# */5 * * * * sh -c "~/.config/scripts/git-cron.sh" > /dev/null 2>&1

export EDITOR="nano"

git config --global user.name "mamutal91" 
git config --global user.email "mamutal91@gmail.com"

dir="${HOME}/github"
repos=('dotfiles' 'strojects' 'mamutal91.github.io')
remoto="mamutal91@archlinux"

atualiza() {
	if [ -d $1 ]; then
		if [ ! -f $1/.noup ]; then
			cd $1
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
			c=$(echo $(git add . -n | tr '\r\n' ' '))
			m="Autocommit Git-Cron: $c"
			git add .
			git commit -m "$m"
			git push
			notify-send "Git-Cron" "Repo <b>$(basename $1)</b> atualizado."
			fi
		fi
	fi
}

if [ ! $1 ] || [ $1 == "-a" ]; then
	for r in "${repos[@]}";	do
		caminho="${dir}/${r}"
		atualiza "$caminho"
	done

	atualiza "${HOME}/dotfiles"
	[ "$1" == "-a" ] && ssh $remoto "/usr/local/scripts/git-http"
else
	caminho="$@"
	atualiza "$caminho"
fi
