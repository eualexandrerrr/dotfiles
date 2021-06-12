#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

echo -e "${BOL_BLU}Starting script...${END}\n\n"
chmod +x $HOME/.script.sh
bash $HOME/.script.sh

echo -e "\n"
read -p "${BOL_RED}Exit?${END}" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
