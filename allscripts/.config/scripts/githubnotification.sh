#!/usr/bin/env bash

source $HOME/.myTokens/tokens.sh &> /dev/null

count=$(curl -u username:${githubNotification} https://api.github.com/notifications | jq '. | length')

if [[ $count != "0"   ]]; then
    echo '{"text":'$count',"tooltip":"$tooltip","class":"$class"}'
fi
