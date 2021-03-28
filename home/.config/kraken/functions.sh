#!/usr/bin/env bash

function lmi() {
  cd $HOME && $HOME/.dotfiles/home/.config/kraken/lmi.sh
}

function beryllium() {
  pdw=$(pwd)
  cd $HOME
  rm -rf android_kernel_xiaomi_sdm845 proprietary_vendor_xiaomi vendor_xiaomi_beryllium vendor_xiaomi_sdm845-common

  git clone https://github.com/LineageOS/android_kernel_xiaomi_sdm845 -b lineage-18.1

  cd $HOME/android_kernel_xiaomi_sdm845
  git push ssh://git@github.com/AOSPK-Devices/kernel_xiaomi_sdm845 HEAD:refs/heads/eleven --force

  cd $HOME
  git clone https://gitlab.com/the-muppets/proprietary_vendor_xiaomi -b lineage-18.1
  mv proprietary_vendor_xiaomi vendor_xiaomi_beryllium
  cp -rf vendor_xiaomi_beryllium vendor_xiaomi_sdm845-common

  cd $HOME/vendor_xiaomi_beryllium
  git filter-branch --prune-empty --subdirectory-filter beryllium lineage-18.1
  git push ssh://git@gitlab.com/AOSPK-Devices/vendor_xiaomi_beryllium HEAD:refs/heads/eleven --force

  cd $HOME/vendor_xiaomi_sdm845-common
  git filter-branch --prune-empty --subdirectory-filter sdm845-common lineage-18.1
  git push ssh://git@gitlab.com/AOSPK-Devices/vendor_xiaomi_sdm845-common HEAD:refs/heads/eleven --force
}

function down() {
  pwd=$(pwd)
  rm -rf /mnt/roms/sites/private/*/*.zip &>/dev/null
  rm -rf /mnt/roms/sites/private/*/json/*.json &>/dev/null
  cd $pwd
}

function push() {
  REPO=$(pwd | sed "s/\/mnt\/roms\/jobs\/Kraken\///; s/\//_/g")
  GITHOST=github
  ORG=AOSPK-WIP
  BRANCH=eleven
  FORCE=${1}
  TOPIC=${2}

  if [[ $REPO = "vendor_google_gms" ]]; then
    GITHOST=gitlab
    ORG=AOSPK
  fi

  if [[ $REPO = "build_make" ]]; then
    REPO=build
  fi
  if [[ $REPO = "packages_apps_PermissionController" ]]; then
    REPO=packages_apps_PackageInstaller
  fi
  if [[ $REPO = "vendor_qcom_opensource_commonsys-intf_bluetooth" ]]; then
    REPO=vendor_qcom_opensource_bluetooth-commonsys-intf
  fi
  if [[ $REPO = "vendor_qcom_opensource_commonsys-intf_display" ]]; then
    REPO=vendor_qcom_opensource_display-commonsys-intf
  fi
  if [[ $REPO = "vendor_qcom_opensource_commonsys_bluetooth_ext" ]]; then
    REPO=vendor_qcom_opensource_bluetooth_ext
  fi
  if [[ $REPO = "vendor_qcom_opensource_commonsys_packages_apps_Bluetooth" ]]; then
    REPO=vendor_qcom_opensource_packages_apps_Bluetooth
  fi
  if [[ $REPO = "vendor_qcom_opensource_commonsys_system_bt" ]]; then
    REPO=vendor_qcom_opensource_system_bt
  fi

  if [[ ${1} = "gerrit" ]]; then
    echo "${BOL_BLU}Pushing to gerrit.aospk.org/${GRE}${ORG}${END}/${BLU}${REPO}${END} - ${BRANCH} ${RED}${FORCE}${END}"
    if [ -z "${TOPIC}" ]
    then
      git push ssh://mamutal91@gerrit.aospk.org:29418/${REPO} HEAD:refs/for/${BRANCH}%l=Verified+1,l=Code-Review+2
    else
      git push ssh://mamutal91@gerrit.aospk.org:29418/${REPO} HEAD:refs/for/${BRANCH}%l=Verified+1,l=Code-Review+2,topic=${TOPIC}
    fi
  else
    echo "${BOL_BLU}Pushing to ${GITHOST}.com/${GRE}${ORG}${END}/${BLU}${REPO}${END} - ${BRANCH} ${RED}${FORCE}${END}"
    git push ssh://git@${GITHOST}.com/${ORG}/${REPO} HEAD:refs/heads/${BRANCH} ${FORCE}
  fi
}

function clone() {
  if [[ "${1}" = "vendor_google_gms" ]]; then
    GITHOST=gitlab
  else
    GITHOST=github
  fi
  if [[ ${4} = "wip" ]]; then
    ORG=AOSPK-WIP
  else
    ORG=AOSPK
  fi
  echo "${BOL_BLU}Cloning ${GITHOST}.com/${ORG}/${GRE_BLU}${1}${END} - ${2} ${3}${END}"
  git clone ssh://git@${GITHOST}.com/${ORG}/${1} -b ${2} ${3} && cd ${3}
}

upstream() {
  cd $HOME && rm -rf ${1}
  echo "${BOL_CYA}Cloning LineageOS/android_${1} -b ${2}${END}"
  git clone https://github.com/LineageOS/android_${1} -b ${2} ${1}
  cd ${1} && git push ssh://git@github.com/AOSPK/${1} HEAD:refs/heads/${3} --force
  rm -rf $HOME/${1}
}

function up() {
  upstream ${1} lineage-18.1 eleven
  upstream ${1} lineage-17.1 ten
  upstream ${1} lineage-16.0 pie
  upstream ${1} lineage-15.1 oreo-mr1
  upstream ${1} cm-14.1 nougat
}

function hals() {
  $HOME/.config/kraken/hal/hal.sh apq8084
  $HOME/.config/kraken/hal/hal.sh msm8960
  $HOME/.config/kraken/hal/hal.sh msm8952
  $HOME/.config/kraken/hal/hal.sh msm8916
  $HOME/.config/kraken/hal/hal.sh msm8974
  $HOME/.config/kraken/hal/hal.sh msm8994
  $HOME/.config/kraken/hal/hal.sh msm8996
  $HOME/.config/kraken/hal/hal.sh msm8998
  $HOME/.config/kraken/hal/hal.sh sdm845
  $HOME/.config/kraken/hal/hal.sh sm8150
  $HOME/.config/kraken/hal/hal.sh sm8250

  $HOME/.config/kraken/hal/limp.sh pn5xx
  $HOME/.config/kraken/hal/limp.sh sn100x

  $HOME/.config/kraken/hal/caf.sh
}

function www() {
  pwd=$(pwd)
  cd $HOME && rm -rf downloadcenter
  git clone ssh://git@github.com/AOSPK/downloadcenter -b master downloadcenter
  sudo rm -rf /mnt/roms/sites/downloadcenter
  sudo mv downloadcenter /mnt/roms/sites
  cd /mnt/roms/sites/downloadcenter
  sudo npm i && sudo npm run build
  cd $pwd
}
