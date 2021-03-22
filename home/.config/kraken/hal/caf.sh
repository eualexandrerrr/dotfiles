#!/bin/zsh

readonly REPOS_HAL=(
    hardware_qcom_bootctrl
    hardware_qcom_bt
    hardware_qcom_wlan
)

LOS_HAL="lineage-18.1-caf"
AOSPK_HAL="eleven-caf"

tmp="/tmp/kraken-hals"
mkdir -p $tmp
cd $tmp

for i in "${REPOS_HAL[@]}"; do
  echo "${BOL_CYA}BRANCH - $LOS_HAL > $AOSPK_HAL${END}"
  git clone https://github.com/LineageOS/android_${i} -b $LOS_HAL ${i}
  cd ${i} && echo
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$AOSPK_HAL --force
done

rm -rf $tmp
