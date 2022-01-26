#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.config/scripts/git.sh

array=(
  $(grep -Po 'path=\"\K[^"]+(?=\")' $HOME/manifest/aosp.xml)
  $(grep -Po 'path=\"\K[^"]+(?=\")' $HOME/manifest/caf.xml)
  $(grep -Po 'path=\"\K[^"]+(?=\")' $HOME/manifest/extras.xml)
)

for i in ${array[@]}; do

  branch="twelve"

  cd $HOME/Kraken/${i}

  repo=$(cat .git/config | grep url | cut -d "/" -f5)

  echo -e "${BOL_GRE}$i\n${BOL_BLU}$repo${END}\n"

  [[ $repo == "manifest" ]] && continue

  [[ $repo == "hardware_qcom_audio" ]] && continue
  [[ $repo == "hardware_qcom_media" ]] && continue
  [[ $repo == "hardware_qcom_display" ]] && continue

  [[ $repo == "hardware_qcom_bootctrl" ]] && continue
  [[ $repo == "hardware_qcom_wlan" ]] && continue

  [[ $repo == "vendor_nxp_opensource_halimpl" ]] && continue
  [[ $repo == "vendor_nxp_opensource_hidlimpl" ]] && continue

  [[ $repo == "official_devices" ]] && continue
  [[ $repo == "vendor_gapps" ]] && continue

  [[ $repo == "hardware_qcom_bootctrl" ]] && continue
  [[ $repo == "hardware_qcom_wlan" ]] && continue

  git push ssh://git@github.com/AOSPK/${repo} HEAD:refs/heads/${branch} --force
  git push ssh://git@github.com/AOSPK-Next/${repo} HEAD:refs/heads/${branch} --force

  echo -e "\n${MAG}---------${END}\n"
done
