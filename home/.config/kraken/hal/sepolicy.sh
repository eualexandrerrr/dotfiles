#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

pwd=$(pwd)

tmp="/tmp/kraken-sepolicy"
rm -rf $tmp && mkdir -p $tmp
cd $tmp

git clone https://github.com/LineageOS/android_device_qcom_sepolicy -b lineage-18.1-legacy device_qcom_sepolicy-lineage-18.1-legacy
git clone https://github.com/LineageOS/android_device_qcom_sepolicy -b lineage-18.1-legacy-um device_qcom_sepolicy-lineage-18.1-legacy-um

cd $tmp/device_qcom_sepolicy-lineage-18.1-legacy
sed -i "s/device\/lineage/device\/custom/" sepolicy.mk
git add . && git commit --message "Fix path" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"
git push ssh://git@github.com/AOSPK/device_qcom_sepolicy HEAD:refs/heads/eleven-legacy --force
git push ssh://git@github.com/AOSPK-WIP/device_qcom_sepolicy HEAD:refs/heads/eleven-legacy --force

cd $tmp/device_qcom_sepolicy-lineage-18.1-legacy-um
sed -i "s/device\/lineage/device\/custom/" SEPolicy.mk
git add . && git commit --message "Fix path" --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"
git push ssh://git@github.com/AOSPK/device_qcom_sepolicy HEAD:refs/heads/eleven-legacy-um --force
git push ssh://git@github.com/AOSPK-WIP/device_qcom_sepolicy HEAD:refs/heads/eleven-legacy-um --force

cd $pwd
