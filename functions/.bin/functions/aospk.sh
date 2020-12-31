#!/usr/bin/env bash

function s() {
  repo init -u ssh://git@github.com/AOSPK/manifest -b eleven
  repo sync -c -j$(nproc --all) --no-clone-bundle --no-tags --force-sync
}

function b() {
  mkdir /home/ccache/AOSPK &>/dev/null
  export CCACHE_EXEC=$(which ccache)
  export USE_CCACHE=1
  export CCACHE_DIR=/home/ccache/AOSPK
  ccache -M 300G &>/dev/null
  . build/envsetup.sh
  lunch aosp_beryllium-userdebug
  make -j$(nproc --all) bacon 2>&1 | tee log.txt
}

function bp() {
  s && b
}

function tree () {
  rm -rf device/xiaomi/beryllium device/xiaomi/sdm845-common hardware/xiaomi
  git clone ssh://git@github.com/mamutal91/device_xiaomi_beryllium -b eleven device/xiaomi/beryllium
  git clone ssh://git@github.com/mamutal91/device_xiaomi_sdm845-common -b eleven device/xiaomi/sdm845-common
  git clone https://github.com/LineageOS/android_hardware_xiaomi -b lineage-18.1 hardware/xiaomi
}

function kernel () {
  rm -rf kernel/xiaomi
  git clone ssh://git@github.com/mamutal91/kernel_xiaomi_sdm845 -b eleven kernel/xiaomi/sdm845
}

function vendor () {
  rm -rf vendor/xiaomi
  git clone ssh://git@github.com/mamutal91/vendor_xiaomi -b eleven vendor/xiaomi
}

function push () {
  if [ "${3}" = true ];
  then
    FORCE="&& git push -f"
  fi
  echo "${BOL_GRE}Pushing github.com/AOSPK/${1} - ${2}${END}"
  git push ssh://git@github.com/AOSPK/${1} HEAD:refs/heads/${2} ${3}
}

function clone () {
  echo "${BOL_BLU}Cloning github.com/AOSPK/${1} - ${2}${END}"
  git clone ssh://git@github.com/AOSPK/${1} -b ${2}
}

function los () {
  echo "Cloning github.com/LineageOS/android_${1} - ${2}"
  rm -rf ${1} && git clone https://github.com/LineageOS/android_${1} -b ${2} ${1} && cd ${1}
}

upstream () {
  cd $HOME && rm -rf ${1}
  echo "${BOL_CYA}Cloning LineageOS/android_${1} -b ${2}${END}"
  git clone https://github.com/LineageOS/android_${1} -b ${2} ${1}
  cd ${1} && push ${1} ${3}
  rm -rf $HOME/${1}
}

function up () {
  upstream ${1} lineage-18.1 eleven
  upstream ${1} lineage-17.1 ten
  upstream ${1} lineage-16.0 pie
  upstream ${1} lineage-15.1 oreo-mr1
  upstream ${1} cm-14.1 nougat
}

function hals () {
  /home/buildbot/scripts/hal/hal.sh apq8084
  /home/buildbot/scripts/hal/hal.sh msm8960
  /home/buildbot/scripts/hal/hal.sh msm8916
  /home/buildbot/scripts/hal/hal.sh msm8974
  /home/buildbot/scripts/hal/hal.sh msm8996
  /home/buildbot/scripts/hal/hal.sh msm8998
  /home/buildbot/scripts/hal/hal.sh sdm845
  /home/buildbot/scripts/hal/hal.sh sm8150
  /home/buildbot/scripts/hal/hal.sh sm8250

  /home/buildbot/scripts/hal/limp.sh pn5xx
  /home/buildbot/scripts/hal/limp.sh sn100x
}

function www() {
  pwd=$(pwd)
  cd $HOME && rm -rf www
  git clone ssh://git@github.com/AOSPK/www
  sudo rm -rf /home/www
  sudo mv www ..
  cd /home/www
  sudo npm i && sudo npm run build
  cd $pwd
}
