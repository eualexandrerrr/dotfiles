#!/usr/bin/env bash

args() {
  export CUSTOM_BUILD_TYPE=OFFICIAL
  export CUSTOM_MAINTAINER=mamutal91
  export TARGET_BOOT_ANIMATION_RES=1080
  export CC=clang
  export CCACHE_DIR=/mnt/storage/.ccache/Kraken
  export LC_ALL=C
  export CCACHE_EXEC=$(which ccache)
  export USE_CCACHE=1
}

ROM="/mnt/storage/Kraken"
codename=lmi

s() {
  cd $ROM
  rm -rf .repo/local_manifests
  sudo rm -rf device/{xiaomi,samsung,motorola,oneplus} &> /dev/null
  sudo rm -rf kernel/{xiaomi,samsung,motorola,oneplus} &> /dev/null
  sudo rm -rf vendor/{xiaomi,samsung,motorola,oneplus} &> /dev/null
  sudo rm -rf hardware/{xiaomi,samsung,motorola,oneplus} &> /dev/null
  sudo rm -rf hardware/qcom-caf/*-* &> /dev/null
  repo init -u ssh://git@github.com/AOSPK-Next/manifest -b twelve
  repo sync -c -j1 --no-clone-bundle --current-branch --no-tags --force-sync
}

b() {
  [[ -z ${1} ]] && task=bacon || task=${1}
  echo $task
  nbfc set -s 100
  cd $ROM
  args
  . build/envsetup.sh
  lunch aosp_${codename}-userdebug
  make -j$(nproc --all) ${task} 2>&1 | tee log.txt
  nbfc set -s 50
}

clean() {
  nbfc set -s 100
  cd $ROM
  args
  . build/envsetup.sh
  lunch aosp_${codename}-userdebug
  [[ ${1} == f ]] && make clean || make installclean
  nbfc set -s 50
}
