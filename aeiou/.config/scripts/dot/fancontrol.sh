#!/usr/bin/env bash

myconfig="Acer Nitro 5 AN515-43"

if [[ $(nbfc status -f | grep 'Target fan speed' | awk 'NR==1{print $5}') != 100.00 ]]; then
  nbfc config -a "${myconfig}" && nbfc set -s 100
else
  nbfc config -a "${myconfig}" && nbfc set -s 50
fi
