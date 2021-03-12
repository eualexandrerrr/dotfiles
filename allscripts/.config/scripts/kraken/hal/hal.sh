#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

workingDir=$(mktemp -d) && cd $workingDir

repos=(
    hardware_qcom_audio
    hardware_qcom_display
    hardware_qcom_media
)

branchBase="lineage-19.0-caf-${1}"
branchKraken="twelve-caf-${1}"

for i in ${repos[@]}; do
  rm -rf ${i}
  echo -e "${BOL_GRE}LineageOS : ${BOL_YEL}$branchBase${END}"
  echo -e "${BOL_CYA}Kraken  : ${BOL_MAG}$branchKraken${END}"
  if curl --output /dev/null --silent --head --fail "https://github.com/LineageOS/android_${i}/commits/${branchBase}"; then
    git clone https://github.com/LineageOS/android_${i} -b $branchBase ${i}
    cd ${i} &> /dev/null
    git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$branchKraken --force &> /dev/null
    git push ssh://git@github.com/AOSPK-Next/${i} HEAD:refs/heads/$branchKraken --force &> /dev/null
  else
    echo -e "${BOL_RED}*** non-existent branch${END}\n" && continue
  fi
done

rm -rf $workingDir
