#!/bin/bash
# github.com/mamutal91

dir="${HOME}/github"
repos=('archlinux' 'backups' 'backups' 'dirtyunicorns' 'mamutal91.github.io')
remoto="mamutal91@archlinux"

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