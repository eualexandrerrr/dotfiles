#!/bin/bash
# github.com/mamutal91

export iconsnotify="/usr/share/icons/Paper/32x32/apps"

dir="/media/storage/github/"
readonly repos=('archlinux' 'buildroid' 'mamutal91.github.io' 'strojects')

app=git.png
icon=$iconsnotify/$app

function gitcron(){
    for i in "${repos[@]}"; do
			cd $dir/$i
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
				c=$(echo $(git add . -n | tr '\r\n' ' '))
				m="Autocommit Git-Cron: $c"
				DISPLAY=:0 dbus-launch notify-send -i $icon "Git-Cron Commits" "$(basename $i)"
				git add .
				git commit -m "$m" -s --author="Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
				git push
				DISPLAY=:0 dbus-launch notify-send -i $icon "Git-Cron" "$(basename $i) atualizado."
			fi
done
}

gitcron
