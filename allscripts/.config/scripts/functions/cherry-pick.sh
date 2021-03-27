#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

replacePaths() {
  [[ $path == "build" ]] && path="build/make"
  [[ $path == "system/update/engine" ]] && path="system/update_engine"
}

if [[ ${1} == "git" ]]; then
  commandGerrit="${1} ${2} ${3} ${4}"
  path=$(echo $commandGerrit | awk '{ print $3 }' | tr -d '" ' | cut -c44-300 | sed "s:_:/:g") && replacePaths
  commandGerrit=$(echo $commandGerrit | tr -d '|"')
  commandGerritUrl=$(echo $commandGerrit | awk '{ print $3 }' | cut -c9-300)
  commandGerritChange=$(echo $commandGerrit | awk '{ print $4 }')
else
  yad=$(
    yad --center --title="Gerrit" \
      --text="Seu commit:" --text-align="center" \
      --form \
      --field="Check-pick: " "" \
      --button "PICK" --buttons-layout="center"
      )
  commandGerrit=$(echo "$yad")
  clear
  path=$(echo $commandGerrit | awk '{ print $3 }' | tr -d '" ' | cut -c44-300 | sed "s:_:/:g") && replacePaths
  commandGerrit=$(echo $commandGerrit | tr -d '|"')
  commandGerritUrl=$(echo $commandGerrit | awk '{ print $3 }' | cut -c9-300)
  commandGerritChange=$(echo $commandGerrit | awk '{ print $4 }')
fi

cd /mnt/storage/Kraken/${path}

echo -e "\n${BOL_CYA}Pick in ${BOL_YEL}$PWD${END}\n"
git fetch https://${commandGerritUrl} ${commandGerritChange} && git cherry-pick FETCH_HEAD
if [[ $? -eq 0 ]]; then
  echo -e "\n${BOL_GRE}Cherry-pick success!${END}\n"
else
  echo -e "\n${BOL_RED}Cherry-pick failure!${END}\n"
fi
