#!/usr/bin/env bash

dir="/media/storage/GitHub/"
readonly repos=('iWantToSpeak')

date=$(date +"%Y-%m-%d-%H:%M")

function speak() {
  echo -e ""
  echo -e "#### $date"
  echo -e ""
  fortune
}

speak >> /media/storage/GitHub/iWantToSpeak/README.md

function commitspeak() {
  for i in "${repos[@]}"; do
			cd $dir/$i
			status=$(git add . -n)
			if [ ! -z "$status" ]; then
				c=$(echo $(git add . -n | tr '\r\n' ' '))
				m="$date"
				git add .
				git commit -m "$m" --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date '+%Y-%m-%d %H:%M:%S')"
				git push --force
			fi
done
}

commitspeak
