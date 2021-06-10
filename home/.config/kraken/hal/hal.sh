#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

workingDir="/tmp/kraken-hals"
rm -rf $workingDir && mkdir -p $workingDir
cd $workingDir

repos=(
    hardware_qcom_audio
    hardware_qcom_display
    hardware_qcom_media
)

branchLineage="lineage-18.1-caf-${1}"
branchKraken="eleven-caf-${1}"

for i in "${repos[@]}"; do
  rm -rf ${i}
  echo "${BLU}Clonando https://github.com/LineageOS/android_${i} -b $branchLineage em ${i}${END}"
  git clone https://github.com/LineageOS/android_${i} -b $branchLineage ${i}
  echo
  echo "${GRE}Pushand -b $branchKraken para ${i}${END}"
  cd ${i}
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$branchKraken --force
  git push ssh://git@github.com/AOSPK-DEV/${i} HEAD:refs/heads/$branchKraken --force
  echo
done
