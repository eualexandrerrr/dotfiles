#!/usr/bin/env bash

source $HOME/.colors 2>/dev/null 

echo -e "${BOL_BLU}Starting script...${END}\n"
chmod +x $HOME/.scripter/scripter.sh

bash $HOME/.scripter/scripter.sh

echo -e "\n"
read -p "${BOL_RED}Exit?${END}" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]
then
    exit 1
fi
