#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

caf() {
  limps=(
    "hardware_qcom_bootctrl"
    "hardware_qcom_wlan"
  )

  for i in "${limps[@]}"; do
    branchArrow=${1}
    branchKraken=${2}
    workingDir=$(mktemp -d) && cd $workingDir
    git clone https://github.com/ArrowOS/android_${i} -b ${branchArrow} ${i}
    cd ${i}
    git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/${branchKraken} --force
    git push ssh://git@github.com/AOSPK-Next/${i} HEAD:refs/heads/${branchKraken} --force
    cd $workingDir
  done
}

caf arrow-12.0 twelve
caf arrow-12.0-caf twelve-caf
