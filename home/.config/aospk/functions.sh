#!/usr/bin/env bash

function treeseba() {
  pdw=$(pwd)
  cd $HOME
  rm -rf android_device_xiaomi_lmi android_device_xiaomi_lmi-kernel android_device_xiaomi_sm8250-common
  rm -rf android_vendor_xiaomi vendor_xiaomi_lmi vendor_xiaomi_sm8250-common

  git clone https://github.com/xiaomi-sm8250-devs/android_device_xiaomi_lmi -b lineage-18.1
  git clone https://github.com/xiaomi-sm8250-devs/android_device_xiaomi_lmi-kernel -b lineage-18.1
  git clone https://github.com/xiaomi-sm8250-devs/android_device_xiaomi_sm8250-common -b lineage-18.1
  git clone https://git.rip/xiaomi-sm8250-devs/android_vendor_xiaomi -b lineage-18.1

  mv android_vendor_xiaomi vendor_xiaomi_lmi
  cp -rf vendor_xiaomi_lmi vendor_xiaomi_sm8250-common

  cd $HOME/android_device_xiaomi_lmi
  git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_lmi HEAD:refs/heads/eleven --force

  cd $HOME/android_device_xiaomi_lmi-kernel
  git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_lmi-kernel HEAD:refs/heads/eleven --force

  cd $HOME/android_device_xiaomi_sm8250-common
  git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_sm8250-common HEAD:refs/heads/eleven --force

  cd $HOME/vendor_xiaomi_lmi
  git filter-branch --prune-empty --subdirectory-filter lmi lineage-18.1
  git push ssh://git@gitlab.com/AOSPK-Devices/vendor_xiaomi_lmi HEAD:refs/heads/eleven --force

  cd $HOME/vendor_xiaomi_sm8250-common
  git filter-branch --prune-empty --subdirectory-filter sm8250-common lineage-18.1
  git push ssh://git@gitlab.com/AOSPK-Devices/vendor_xiaomi_sm8250-common HEAD:refs/heads/eleven --force
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

  if [[ $REPO = "vendor_google_gms" ]]; then
    GITHOST=gitlab
  fi

  if [[ ${1} = "gerrit" ]]; then
    echo "${BOL_BLU}Pushing to gerrit.aospk.org/${GRE}${ORG}${END}/${BLU}${REPO}${END} - ${BRANCH} ${RED}${FORCE}${END}"
    git push ssh://mamutal91@gerrit.aospk.org:29418/${REPO} HEAD:refs/for/${BRANCH}
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

function f() {
  git fetch https://github.com/${1} ${2}
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
  $HOME/.config/aospk/hal/hal.sh apq8084
  $HOME/.config/aospk/hal/hal.sh msm8960
  $HOME/.config/aospk/hal/hal.sh msm8952
  $HOME/.config/aospk/hal/hal.sh msm8916
  $HOME/.config/aospk/hal/hal.sh msm8974
  $HOME/.config/aospk/hal/hal.sh msm8994
  $HOME/.config/aospk/hal/hal.sh msm8996
  $HOME/.config/aospk/hal/hal.sh msm8998
  $HOME/.config/aospk/hal/hal.sh sdm845
  $HOME/.config/aospk/hal/hal.sh sm8150
  $HOME/.config/aospk/hal/hal.sh sm8250

  $HOME/.config/aospk/hal/limp.sh pn5xx
  $HOME/.config/aospk/hal/limp.sh sn100x

  $HOME/.config/aospk/hal/caf.sh
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
