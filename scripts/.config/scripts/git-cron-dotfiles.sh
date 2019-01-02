#!/bin/bash
# github.com/mamutal91

# Add linha no crontab 
# */5 * * * * sh -c "~/.config/scripts/git-cron.sh" > /dev/null 2>&1

export EDITOR="nano"

git config --global user.name "mamutal91" 
git config --global user.email "mamutal91@gmail.com"

cd $HOME/.dotfiles

atualiza() {
		status=$(git add . -n)
		if [ ! -z "$status" ]; then
			c=$(echo $(git add . -n | tr '\r\n' ' '))
			m="Autocommit Git-Cron: $c"
			DISPLAY=:0 notify-send "Git-Cron Commits"
			git add .
			git commit -m "$m"
			git push
			DISPLAY=:0 notify-send "Git-Cron Push atualizado."
		fi
}

atualiza