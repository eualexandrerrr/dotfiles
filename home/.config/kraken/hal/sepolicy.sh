#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

working_dir="/tmp/kraken-sepolicy-legacy-and-legacy-um"
rm -rf $working_dir && mkdir -p $working_dir
cd $working_dir

function sepolicyCustom() {
  git clone https://github.com/LineageOS/android_device_qcom_sepolicy -b lineage-18.1 device_qcom_sepolicy-default
  git clone https://github.com/LineageOS/android_device_qcom_sepolicy -b lineage-18.1-legacy device_qcom_sepolicy-lineage-18.1-legacy
  git clone https://github.com/LineageOS/android_device_qcom_sepolicy -b lineage-18.1-legacy-um device_qcom_sepolicy-lineage-18.1-legacy-um

  cd $working_dir/device_qcom_sepolicy-default
  git push ssh://git@github.com/AOSPK/device_qcom_sepolicy HEAD:refs/heads/eleven --force
  git push ssh://git@github.com/AOSPK-WIP/device_qcom_sepolicy HEAD:refs/heads/eleven --force

  cd $working_dir/device_qcom_sepolicy-lineage-18.1-legacy
  sed -i "s/device\/lineage/device\/custom/" sepolicy.mk
  git add . && git commit --message "legacy: Fix path" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"
  git push ssh://git@github.com/AOSPK/device_qcom_sepolicy HEAD:refs/heads/eleven-legacy --force
  git push ssh://git@github.com/AOSPK-WIP/device_qcom_sepolicy HEAD:refs/heads/eleven-legacy --force

  cd $working_dir/device_qcom_sepolicy-lineage-18.1-legacy-um
  sed -i "s/device\/lineage/device\/custom/" SEPolicy.mk
  git add . && git commit --message "legacy-um: Fix path" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"
  git push ssh://git@github.com/AOSPK/device_qcom_sepolicy HEAD:refs/heads/eleven-legacy-um --force
  git push ssh://git@github.com/AOSPK-WIP/device_qcom_sepolicy HEAD:refs/heads/eleven-legacy-um --force
}

sepolicyCustom
