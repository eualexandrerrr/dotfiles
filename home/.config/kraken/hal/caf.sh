#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

workingDir="/tmp/kraken-caf-repos"
rm -rf $workingDir && mkdir -p $workingDir
cd $workingDir

function caf() {
  cd $workingDir
  git clone https://github.com/LineageOS/android_hardware_qcom_bootctrl -b lineage-18.1-caf hardware_qcom_bootctrl-caf
  git clone https://github.com/LineageOS/android_hardware_qcom_bt -b lineage-18.1-caf hardware_qcom_bt-caf
  git clone https://github.com/LineageOS/android_hardware_qcom_wlan -b lineage-18.1-caf hardware_qcom_wlan-caf

  cd $workingDir/hardware_qcom_bootctrl-caf
  git push ssh://git@github.com/AOSPK/hardware_qcom_bootctrl HEAD:refs/heads/eleven-caf --force
  git push ssh://git@github.com/AOSPK-DEV/hardware_qcom_bootctrl HEAD:refs/heads/eleven-caf --force

  cd $workingDir/hardware_qcom_bt-caf
  git push ssh://git@github.com/AOSPK/hardware_qcom_bt HEAD:refs/heads/eleven-caf --force
  git push ssh://git@github.com/AOSPK-DEV/hardware_qcom_bt HEAD:refs/heads/eleven-caf --force

  cd $workingDir/hardware_qcom_wlan-caf
  git push ssh://git@github.com/AOSPK/hardware_qcom_wlan HEAD:refs/heads/eleven-caf --force
  git push ssh://git@github.com/AOSPK-DEV/hardware_qcom_wlan HEAD:refs/heads/eleven-caf --force
}

function limp() {
  cd $workingDir
  git clone https://github.com/LineageOS/android_vendor_nxp_opensource_halimpl -b lineage-18.1-pn5xx halimpl-pn5xx
  git clone https://github.com/LineageOS/android_vendor_nxp_opensource_halimpl -b lineage-18.1-sn100x halimpl-sn100x
  git clone https://github.com/LineageOS/android_vendor_nxp_opensource_hidlimpl -b lineage-18.1-pn5xx hidlimpl-pn5xx
  git clone https://github.com/LineageOS/android_vendor_nxp_opensource_hidlimpl -b lineage-18.1-sn100x hidlimpl-sn100x

  cd ${workingDir}/halimpl-pn5xx
  git push ssh://git@github.com/AOSPK/vendor_nxp_opensource_halimpl HEAD:refs/heads/eleven-pn5xx --force
  git push ssh://git@github.com/AOSPK-DEV/vendor_nxp_opensource_halimpl HEAD:refs/heads/eleven-pn5xx --force

  cd ${workingDir}/halimpl-sn100x
  git push ssh://git@github.com/AOSPK/vendor_nxp_opensource_halimpl HEAD:refs/heads/eleven-sn100x --force
  git push ssh://git@github.com/AOSPK-DEV/vendor_nxp_opensource_halimpl HEAD:refs/heads/eleven-sn100x --force

  cd ${workingDir}/hidlimpl-pn5xx
  git push ssh://git@github.com/AOSPK/vendor_nxp_opensource_hidlimpl HEAD:refs/heads/eleven-pn5xx --force
  git push ssh://git@github.com/AOSPK-DEV/vendor_nxp_opensource_hidlimpl HEAD:refs/heads/eleven-pn5xx --force

  cd ${workingDir}/hidlimpl-sn100x
  git push ssh://git@github.com/AOSPK/vendor_nxp_opensource_hidlimpl HEAD:refs/heads/eleven-sn100x --force
  git push ssh://git@github.com/AOSPK-DEV/vendor_nxp_opensource_hidlimpl HEAD:refs/heads/eleven-sn100x --force
}

function halDefault() {
  cd $workingDir
  git clone https://github.com/LineageOS/android_hardware_qcom_audio -b lineage-18.1 hardware_qcom_audio-eleven-default
  git clone https://github.com/LineageOS/android_hardware_qcom_display -b lineage-18.1 hardware_qcom_display-eleven-default
  git clone https://github.com/LineageOS/android_hardware_qcom_media -b lineage-18.1 hardware_qcom_media-eleven-default

  cd ${workingDir}/hardware_qcom_audio-eleven-default
  git push ssh://git@github.com/AOSPK/hardware_qcom_audio HEAD:refs/heads/eleven --force
  git push ssh://git@github.com/AOSPK-DEV/hardware_qcom_audio HEAD:refs/heads/eleven --force

  cd ${workingDir}/hardware_qcom_display-eleven-default
  git push ssh://git@github.com/AOSPK/hardware_qcom_display HEAD:refs/heads/eleven --force
  git push ssh://git@github.com/AOSPK-DEV/hardware_qcom_display HEAD:refs/heads/eleven --force

  cd ${workingDir}/hardware_qcom_media-eleven-default
  git push ssh://git@github.com/AOSPK/hardware_qcom_media HEAD:refs/heads/eleven --force
  git push ssh://git@github.com/AOSPK-DEV/hardware_qcom_media HEAD:refs/heads/eleven --force
}

caf
limp
halDefault
