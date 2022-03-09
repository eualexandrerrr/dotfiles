#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

repos=(
    hardware_qcom_bootctrl
    hardware_qcom_bt
    hardware_qcom_wlan
)

branchLOS="arrow-12.1-caf"
branchKK="thirteen-caf"

tmp="/tmp/kraken-hals"
rm -rf $tmp && mkdir -p $tmp
cd $tmp

for i in "${repos[@]}"; do
  rm -rf ${i}
  losURL="https://github.com/ArrowOS/android_${i}"
  krakenURL="ssh://git@github.com/MammothOS/${i}"
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
  branchLOS="arrow-12.1-caf"
  branchKK="thirteen-caf"
fi
