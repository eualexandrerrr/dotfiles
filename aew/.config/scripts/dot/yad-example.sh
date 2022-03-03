#!/usr/bin/env bash

form=$(
    yad --center --title="Gerrit Watcher" \
        --text="Qual repositório deseja abrir?" --text-align="center" \
        --form \
        --field="Repo  : " "" \
        --button gtk-add --buttons-layout="center"
)

repo=$(echo "$form" | cut -d "|" -f 1)

google-chrome-stable https://review.arrowos.net/q/project:ArrowOS/android_${repo}+branch:arrow-12.0+status:merged
