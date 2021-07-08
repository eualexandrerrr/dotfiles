#!/usr/bin/env bash

export CUSTOM_BUILD_TYPE=OFFICIAL
export CUSTOM_MAINTAINER=mamutal91
export TARGET_BOOT_ANIMATION_RES=1080
export CC=clang
export CCACHE_DIR=/mnt/storage/.ccache/Kraken
export LC_ALL=C
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1

cd /mnt/storage/Kraken

codename=lmi

if [[ ${1} == sync ]]; then
  repo init -u ssh://git@github.com/AOSPK-DEV/manifest -b eleven
  repo sync -c -j$(nproc --all) --no-clone-bundle --current-branch --no-tags --force-sync
else
  . build/envsetup.sh
  lunch aosp_${codename}-userdebug
  make -j$(nproc --all) bacon 2>&1 | tee log.txt
fi
