#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

repos=(
    hardware_qcom_audio
    hardware_qcom_display
    hardware_qcom_media

    hardware_qcom_bootctrl
    hardware_qcom_bt
    hardware_qcom_wlan
)

branchLOS="lineage-18.1-caf-${1}"
branchKK="eleven-caf-${1}"

tmp="/tmp/kraken-hals"
rm -rf $tmp && mkdir -p $tmp
cd $tmp

for i in "${repos[@]}"; do
  if [[ ${i} = hardware_qcom_bootctrl || ${i} = hardware_qcom_bt || ${i} = hardware_qcom_wlan ]]; then
    branchLOS="lineage-18.1-caf"
    branchKK="eleven-caf"
  fi

  rm -rf ${i}
  losURL="https://github.com/LineageOS/android_${i}"
  echo "-------------------------------------------------------------------------"
  echo "${BLU}Clonando $losURL -b $branchLOS em ${i}${END}"
  git clone $losURL -b $branchLOS ${i}
  echo
  echo "${GRE}Pushand -b $branchKK para ${i}${END}"
  cd ${i}
  git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/$branchKK --force
  git push ssh://git@github.com/AOSPK-WIP/${i} HEAD:refs/heads/$branchKK --force
  echo
done

function limp() {
  git clone https://github.com/LineageOS/android_vendor_nxp_opensource_halimpl -b lineage-18.1-pn5xx halimpl-pn5xx
  git clone https://github.com/LineageOS/android_vendor_nxp_opensource_halimpl -b lineage-18.1-sn100x halimpl-sn100x

  cd halimpl-pn5xx
  git push ssh://git@github.com/AOSPK/vendor_nxp_opensource_halimpl HEAD:refs/heads/eleven-pn5xx --force
  git push ssh://git@github.com/AOSPK-WIP/vendor_nxp_opensource_halimpl HEAD:refs/heads/eleven-pn5xx --force
  cd ../halimpl-sn100x
  git push ssh://git@github.com/AOSPK/vendor_nxp_opensource_halimpl HEAD:refs/heads/eleven-sn100x --force
  git push ssh://git@github.com/AOSPK-WIP/vendor_nxp_opensource_halimpl HEAD:refs/heads/eleven-sn100x --force

  cd ..
  git clone https://github.com/LineageOS/android_vendor_nxp_opensource_hidlimpl -b lineage-18.1-pn5xx hidlimpl-pn5xx
  git clone https://github.com/LineageOS/android_vendor_nxp_opensource_hidlimpl -b lineage-18.1-sn100x hidlimpl-sn100x

  cd hidlimpl-pn5xx
  git push ssh://git@github.com/AOSPK/vendor_nxp_opensource_hidlimpl HEAD:refs/heads/eleven-pn5xx --force
  git push ssh://git@github.com/AOSPK-WIP/vendor_nxp_opensource_hidlimpl HEAD:refs/heads/eleven-pn5xx --force
  cd ../hidlimpl-sn100x
  git push ssh://git@github.com/AOSPK/vendor_nxp_opensource_hidlimpl HEAD:refs/heads/eleven-sn100x --force
  git push ssh://git@github.com/AOSPK-WIP/vendor_nxp_opensource_hidlimpl HEAD:refs/heads/eleven-sn100x --force
}

limp &>/dev/null
