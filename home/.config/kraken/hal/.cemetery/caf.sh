#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

readonly repos=(
    hardware_qcom_bootctrl
    hardware_qcom_bt
    hardware_qcom_wlan
)

branchLOS="lineage-18.1-caf"
branchKK="eleven-caf"

tmp="/tmp/kraken-hals"
rm -rf $tmp && mkdir -p $tmp
cd $tmp

for i in "${repos[@]}"; do
  rm -rf ${i}
  losURL="https://github.com/LineageOS/android_${i}"
  krakenURL="ssh://git@github.com/AOSPK/${i}"
  echo "-------------------------------------------------------------------------"
  echo "${BLU}Clonando $losURL -b $branchLOS em ${i}${END}"
  git clone $losURL -b $branchLOS ${i}
  echo
  echo "${GRE}Pushand $krakenURL -b $branchKK para ${i}${END}"
  cd ${i}
  git push $krakenURL HEAD:refs/heads/$branchKK --force
  echo
done

if [[ ${i} = hardware_qcom_bootctrl || ${i} = hardware_qcom_bt || ${i} = hardware_qcom_wlan ]]; then
  branchLOS="lineage-18.1-caf"
  branchKK="eleven-caf"
fi
