#!/usr/bin/env bash
# github.com/mamutal91

dir="/media/storage/GitHub"
readonly repos=('mamutal91.github.io' 'custom-rom')

# gitcron
function gitcron() {
  for i in "${repos[@]}"; do
			cd $dir/$i
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
				c=$(echo $(git add . -n | tr '\r\n' ' '))
				m="Autocommit Git-Cron: $c"
				git add .
				git commit -m "$m" --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
				git push --force
			fi
done
}

gitcron

# zsh-history
cp -rf $HOME/.zsh_history /media/storage/GitHub/zsh-history/

readonly zshhistory=('zsh-history')

function zshhistory() {
  for i in "${zshhistory[@]}"; do
			cd $dir/$i
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
				c=$(echo $(git add . -n | tr '\r\n' ' '))
				m="Autocommit Git-Cron: $c"
				git add .
				git commit -m "$m" --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
				git push --force
			fi
done
}

zshhistory

readonly blog=('mamutal91.github.io')

function blog() {
  for i in "${blog[@]}"; do
			cd $dir/$i
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
				c=$(echo $(git add . -n | tr '\r\n' ' '))
				m="Autocommit post: $c"
				git add .
				git commit -m "$m" --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
				git push --force
			fi
done
}

blog
