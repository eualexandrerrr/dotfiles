#!/bin/bash
# github.com/mamutal91

# Add linha no crontab
# */5 * * * * sh -c "~/.local/bin/gitcron.sh" > /dev/null 2>&1

dir="${HOME}/github"
repos=('archlinux' 'backups' 'dirtyunicorns' 'mamutal91.github.io')
remoto="mamut@35.229.107.212"

app=git.png
icon=$iconsnotify/$app
committemp="$(cat ~/.commit)"

function atualiza() {
	if [ -d $1 ]; then
		if [ ! -f $1/.noup ]; then
			cd $1
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
			c=$(echo $(git add . -n | tr '\r\n' ' '))
			m="Autocommit Git-Cron: $c"
			DISPLAY=:0 notify-send -i $icon "Git-Cron Commits" "$(basename $1)"
			git add .
			git commit -m "$m" -m "$committemp"
			git push
			DISPLAY=:0 notify-send -i $icon "Git-Cron Push" "$(basename $1) atualizado."
			fi
		fi
	fi
}

atualiza "$caminho"
