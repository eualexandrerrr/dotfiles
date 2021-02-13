#!/usr/bin/env bash

function down() {
  pwd=$(pwd)
  rm -rf /mnt/roms/sites/private/*/*.zip &>/dev/null
  rm -rf /mnt/roms/sites/private/*/json/*.json &>/dev/null
  cd $pwd
}

function gerrit() {
  xdg-open https://review.lineageos.org/q/project:LineageOS/android_${1}+status:merged+branch:lineage-18.1
}

function push() {
  if [[ "${3}" = true ]];
  then
    FORCE=" -f"
  fi
  if [[ "${2}" = "vendor_gapps" ]]; then
    echo "${BOL_GRE}Pushing gitlab.com/AOSPK/${1} - ${2}${END}"
    git push ssh://git@gitlab.com/AOSPK/${1} HEAD:refs/heads/${2} ${3}
  else
    echo "${BOL_GRE}Pushing github.com/AOSPK/${1} - ${2}${END}"
    git push ssh://git@github.com/AOSPK/${1} HEAD:refs/heads/${2} ${3}
  fi
}

function clone() {
  echo "${BOL_BLU}Cloning github.com/AOSPK/${1} - ${2} ${3}${END}"
  git clone ssh://git@github.com/AOSPK/${1} -b ${2} ${3} && cd ${1}
}

upstream() {
  cd $HOME && rm -rf ${1}
  echo "${BOL_CYA}Cloning LineageOS/android_${1} -b ${2}${END}"
  git clone https://github.com/LineageOS/android_${1} -b ${2} ${1}
  cd ${1} && push ${1} ${3}
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
