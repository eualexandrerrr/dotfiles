#!/bin/bash
# github.com/mamutal91

dir="/media/storage/GitHub/"
readonly repos=('archlinux-building' 'archlinux' 'mamutal91.github.io')

app=git.png
icon=$icons_path/$app

function gitcron(){
  for i in "${repos[@]}"; do
			cd $dir/$i
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
				c=$(echo $(git add . -n | tr '\r\n' ' '))
				m="Autocommit Git-Cron: $c"
				DISPLAY=:0 dbus-launch notify-send -i $icon "Git-Cron Commits" "$(basename $i)"
				git add .
				git commit -m "$m" --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
				git push --force
				DISPLAY=:0 dbus-launch notify-send -i $icon "Git-Cron" "$(basename $i) atualizado."
			fi
done
}

gitcron
