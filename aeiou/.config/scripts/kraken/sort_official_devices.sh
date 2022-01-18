#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

devices=$HOME/GitHub/official_devices/devices.json
maintainers=$HOME/GitHub/official_devices/team/maintainers.json

echo -e "${BOL_RED}\nSort alphabetic json!!!${END}\n"

cat $devices | jq -r 'map(select(.brand != null)) | sort_by(.brand, .name)' | tee $devices &> /dev/null
cat $maintainers | jq -r 'map(select(.name != null)) | sort_by(.name)' | tee $maintainers &> /dev/null
