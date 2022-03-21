#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

clear

pwd=$(pwd)

workingDir=$(mktemp -d) && cd $workingDir

echo -e "${BOL_GRE}Cloning MammothOS/official_devices\n"
git clone ssh://git@github.com/MammothOS/official_devices &> /dev/null
clear
cd official_devices

if [[ $(
        cat ${workingDir}/official_devices/devices.json | jq empty > /dev/null 2>&1
                                                                                     echo $?
) -eq 0                                                                                             ]]; then
  echo -e "${MAG}devices.json ${GRE}JSON is valid${END}\n"
else
  echo -e "${YEL}devices.json ${RED}JSON is invalid${END}\n"
fi

for file in $(ls ${workingDir}/official_devices/**/**/*.json); do
  if [[ $(
          cat $file | jq empty > /dev/null 2>&1
                                                 echo $?
  ) -eq 0                                                       ]]; then
    echo -e "${BLU}$file ${GRE}JSON is valid${END}"
  else
    echo -e "${YEL}$file ${RED}JSON is invalid${END}"
  fi
  echo
done

cd $pwd

rm -rf $workingDir
