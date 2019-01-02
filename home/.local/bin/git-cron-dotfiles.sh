#!/bin/bash
# github.com/mamutal91

# Add linha no crontab
# */5 * * * * sh -c "~/.config/scripts/git-cron.sh" > /dev/null 2>&1

export EDITOR="nano"

cd $HOME/.dotfiles

atualiza() {
	status=$(git add . -n)
	if [ ! -z "$status" ]; then
		c=$(echo $(git add . -n | tr '\r\n' ' '))
		m="Autocommit Git-Cron: $c"
		DISPLAY=:0 notify-send "Git-Cron Commits" ".dotfiles"
		git add .
		git commit -m "$m"
		git push
		DISPLAY=:0 notify-send "Git-Cron Push" ".dotfiles"
	fi
}

atualiza