#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

workingDir=$(mktemp -d) && cd $workingDir

repos=(
    hardware_qcom_audio
    hardware_qcom_display
    hardware_qcom_media
)

branchBase="arrow-12.0-caf-${1}"
branchKraken="twelve-caf-${1}"
branchBaseLos="lineage-19.0-caf-${1}"

for i in ${repos[@]}; do
  rm -rf ${i}
  echo -e "${BOL_GRE}Repo    : ${BOL_YEL}${i}${END}"
  echo -e "${BOL_GRE}ArrowOS : ${BOL_YEL}$branchBase${END}"
  echo -e "${BOL_CYA}Kraken  : ${BOL_MAG}$branchKraken${END}"

  git clone https://github.com/ArrowOS/android_${i} -b ${branchBase} ${i}
  if [ $? -eq 0 ]; then
    echo "${BOL_GRE}Success${END}"
  else
    git clone https://github.com/LineageOS/android_${i} -b ${branchBaseLos} ${i}
  fi

  cd ${i}
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/${branchKraken} --force
  git push ssh://git@github.com/AOSPK-Next/${i} HEAD:refs/heads/${branchKraken} --force

  echo -e "${BOL_GRE}-----------------------------------------------"
done

rm -rf $workingDir
