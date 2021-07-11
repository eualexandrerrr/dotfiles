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
  repo init -u ssh://git@github.com/AOSPK-DEV/manifest -b eleven
  repo sync -c -j1 --no-clone-bundle --current-branch --no-tags --force-sync
}

b() {
  cd $ROM
  args
  . build/envsetup.sh
  lunch aosp_${codename}-userdebug
  make -j$(nproc --all) bacon 2>&1 | tee log.txt
}

clean() {
  cd $ROM
  args
  . build/envsetup.sh
  lunch aosp_${codename}-userdebug
  [[ ${1} == f ]] && make clean || make installclean
}
