#!/bin/bash
# github.com/mamutal91

# Add linha no crontab 
# */5 * * * * sh -c "~/.local/bin/git-cron.sh" > /dev/null 2>&1

(cat ~/.cache/wal/sequences &)

dir="${HOME}/github"
repos=('archlinux' 'dotfiles' 'dirtyunicorns' 'mamutal91.github.io')
remoto="mamutal91@archlinux"

atualiza() {
	if [ -d $1 ]; then
		if [ ! -f $1/.noup ]; then
			cd $1
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
#			DISPLAY=:0 notify-send "Git-Cron Commits" "$(basename $1)"
			git add .
			git commit
			git push
			DISPLAY=:0 notify-send "Git-Cron Push" "$(basename $1) atualizado."
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