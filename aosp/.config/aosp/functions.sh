#!/bin/bash
# github.com/mamutal91

export USE_CCACHE=1
export CCACHE_DIR="${HOME}/.ccache"
export CCACHE_EXEC="$(which ccache)"
# ccache -M 100G

export KBUILD_BUILD_USER=MaMuT
export KBUILD_BUILD_HOST=MaMuT
export SELINUX_IGNORE_NEVERALLOWS=true
export CUSTOM_BUILD_TYPE=OFFICIAL

export aospbuilding="/media/storage/aosp"

export branch="ten"
export los="lineage-17.1"

function tree () {
  rm -rf device/xiaomi/beryllium
  rm -rf device/xiaomi/sdm845-common
  git clone ssh://git@github.com/mamutal91/device_xiaomi_beryllium -b $branch device/xiaomi/beryllium
  git clone ssh://git@github.com/mamutal91/device_xiaomi_sdm845-common -b $branch device/xiaomi/sdm845-common
}

function tree_pull () {
  pwd_tree_pull=$(pwd)
  cd $aospbuilding/.pull_rebase
  rm -rf device_xiaomi_beryllium device_xiaomi_sdm845-common

  git clone ssh://git@github.com/mamutal91/device_xiaomi_beryllium -b $branch
  cd device_xiaomi_beryllium
  git pull --rebase https://github.com/AOSiP-Devices/device_xiaomi_beryllium -t ten && git rebase && git push && cd ..

  git clone ssh://git@github.com/mamutal91/device_xiaomi_sdm845-common -b $branch
  cd device_xiaomi_sdm845-common
  git pull --rebase https://github.com/AOSiP-Devices/device_xiaomi_sdm845-common -t ten && git rebase && git push && cd ..

  rm -rf device_xiaomi_beryllium device_xiaomi_sdm845-common
  cd $pwd_tree_pull
}

function tree_kernel () {
  rm -rf kernel/xiaomi
  git clone https://github.com/AOSiP-Devices/kernel_xiaomi_sdm845 -b ten kernel/xiaomi/sdm845
}

function tree_vendor () {
  pwd_tree_vendor=$(pwd)
  rm -rf vendor/xiaomi
  git clone https://github.com/AOSiP-Devices/proprietary_vendor_xiaomi -b ten vendor/xiaomi
  cd vendor/xiaomi
  rm -rf dipper jasmine_sprout mido msm8953-common platina raphael sdm660-common wayne wayne-common whyred
  cd $pwd_tree_vendor
}

function up () {
  cp -rf ${1} /var/www/mamutal91/
}

function upsf () {
  scp ${1} mamutal91@frs.sourceforge.net:/home/frs/project/aosp-forking/beryllium
}

function fetch () {
  echo "$los"
  git fetch https://github.com/LineageOS/android_${1} $los
}

function pull () {
  pwd_pull=$(pwd)
  cd $aospbuilding/.pull_rebase && rm -rf ${1}
  git clone ssh://git@github.com/mamutal91/${1} -b ten && cd ${1}
  git pull --rebase https://github.com/LineageOS/android_${2} -t lineage-17.1 && git rebase
  rm -rf ${1}
  cd $pwd_pull
}

function push () {
  git push ssh://git@github.com/mamutal91/${1} HEAD:refs/heads/${2} --force
  git push ssh://git@github.com/aosp-forking/${1} HEAD:refs/heads/${2} --force
}

function p () {
  git cherry-pick ${1}
}

function opengapps () {
  pwd_opengapps=$(pwd)
  cd $aospbuilding/vendor/opengapps/build && git lfs fetch --all && git lfs pull
  cd $aospbuilding/vendor/opengapps/sources/all && git lfs fetch --all && git lfs pull
  cd $aospbuilding/vendor/opengapps/sources/arm && git lfs fetch --all && git lfs pull
  cd $aospbuilding/vendor/opengapps/sources/arm64 && git lfs fetch --all && git lfs pull
  cd $aospbuilding/vendor/opengapps/sources/x86 && git lfs fetch --all && git lfs pull
  cd $aospbuilding/vendor/opengapps/sources/x86_64 && git lfs fetch --all && git lfs pull
  cd $pwd_opengapps
}
