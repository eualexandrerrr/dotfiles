#!/usr/bin/env bash

readonly REPOS_HAL=(
    hardware_qcom_audio
    hardware_qcom_display
    hardware_qcom_media
)

LOS_HAL="lineage-18.1-caf-${1}"
AOSPK_HAL="eleven-caf-${1}"

tmp="/tmp/aospk-hals"
mkdir -p $tmp
cd $tmp

for i in "${REPOS_HAL[@]}"; do
  echo "${BOL_CYA}BRANCH - $LOS_HAL > $AOSPK_HAL${END}"
  git clone https://github.com/LineageOS/android_${i} -b $LOS_HAL ${i}
  cd ${i} && echo
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$AOSPK_HAL --force
done

rm -rf $tmp
