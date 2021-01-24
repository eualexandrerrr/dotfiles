#!/usr/bin/env bash

# pn5xx
# sn100x

readonly REPOS_HAL=(
    vendor_nxp_opensource_halimpl
    vendor_nxp_opensource_hidlimpl
)

LOS_HAL="lineage-18.1-${1}"
AOSPK_HAL="eleven-${1}"

tmp="/tmp/aospk-limp"
mkdir -p $tmp
cd $tmp

for i in "${REPOS_HAL[@]}"; do
  echo "${BOL_CYA}BRANCH - $LOS_HAL > $AOSPK_HAL${END}"
  echo "${BOL_CYA}${i}${END}"
  git clone https://github.com/LineageOS/android_${i} -b $LOS_HAL ${i}
  cd ${i} && echo
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$AOSPK_HAL --force
done

rm -rf $tmp
