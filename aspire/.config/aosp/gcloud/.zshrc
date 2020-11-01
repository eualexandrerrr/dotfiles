#!/bin/bash
# github.com/mamutal91
# Themes https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export TERM="xterm-256color"
export EDITOR="nano"
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk"

export PATH=$HOME/.bin:$PATH
export USE_CCACHE=1
export CCACHE_DIR="$HOME/.ccache"
export CCACHE_EXEC="$(which ccache)"

export SELINUX_IGNORE_NEVERALLOWS=true
export CUSTOM_BUILD_TYPE=OFFICIAL
export OPENGAPPS_TYPE=ALPHA

export aosp="$HOME/aosp"
export branch="eleven"
export los="lineage-18.0"

alias bp="cd $aosp && repo sync -c -j$(nproc --all) --no-clone-bundle --no-tags --force-sync && opengapps && . build/envsetup.sh && lunch aosp_beryllium-userdebug && make -j$(nproc --all) bacon 2>&1 | tee log.txt"
alias b="cd $aosp && . build/envsetup.sh && lunch aosp_beryllium-userdebug && make -j$(nproc --all) bacon 2>&1 | tee log.txt"
alias sf="scp ${1} mamutal91@frs.sourceforge.net:/home/frs/project/aosp-forking/beryllium"
alias p="git cherry-pick ${1}"

function update () {
  sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y
}

# Functions for git
function push () {
  echo "*********************************"
  echo "*** pushing for branch ELEVEN ***"
  git push ssh://git@github.com/aosp-forking/${1} HEAD:refs/heads/eleven --force
}

function commitm () {
  git add . && git commit --author "Alexandre Rangel <mamutal91@gmail.com>"
}

function commit () {
  git add . && git commit --author "${1}"
}

function amend () {
  git add . && git commit --amend
}

# Tree for beryllium
function tree () {
  cd $aosp
  rm -rf device/xiaomi/beryllium device/xiaomi/sdm845-common
  git clone ssh://git@github.com/mamutal91/device_xiaomi_beryllium -b $branch device/xiaomi/beryllium
  git clone ssh://git@github.com/mamutal91/device_xiaomi_sdm845-common -b $branch device/xiaomi/sdm845-common
}

function treex () {
  cd $aosp
  pwd_treex=$(pwd)
  rm -rf kernel/xiaomi vendor/xiaomi hardware/xiaomi
  git clone ssh://git@github.com/mamutal91/kernel_xiaomi_sdm845 -b $branch kernel/xiaomi/sdm845
  git clone ssh://git@github.com/mamutal91/vendor_xiaomi -b $branch vendor/xiaomi
  git clone https://github.com/LineageOS/android_hardware_xiaomi -b lineage-18.0 hardware/xiaomi
  cd vendor/xiaomi
  rm -rf dipper jasmine_sprout mido msm8953-common perseus platina phoenix raphael sdm660-common wayne wayne-common whyred
  cd $pwd_treex
}

function hal () {
  pwd_hal=$(pwd)
  cd $aosp/hardware/qcom/sdm845 && rm -rf Android.mk
  wget https://raw.githubusercontent.com/LineageOS/android_hardware_qcom-caf_common/lineage-17.1/os_pickup.mk
  mv os_pickup.mk Android.mk && chmod +x Android.mk
  cd $aosp

  rm -rf hardware/qcom-caf/sdm845 && mkdir -p hardware/qcom-caf/sdm845
  cd hardware/qcom-caf/sdm845
  wget https://raw.githubusercontent.com/LineageOS/android_hardware_qcom-caf_common/lineage-17.1/os_pickup.mk && mv os_pickup.mk Android.mk
  wget https://raw.githubusercontent.com/LineageOS/android_hardware_qcom-caf_common/lineage-17.1/os_pickup.bp && mv os_pickup.bp Android.bp
  chmod +x Android.bp Android.mk && cd $aosp

  rm -rf hardware/qcom-caf/sdm845
  mkdir -p hardware/qcom-caf/sdm845
  git clone https://github.com/LineageOS/android_hardware_qcom_audio -b lineage-17.1-caf-sdm845 hardware/qcom-caf/sdm845/audio
  git clone https://github.com/jjpprrrr/hardware_qcom-caf_sdm845_media hardware/qcom-caf/sdm845/media
  git clone https://github.com/jjpprrrr/hardware_qcom-caf_sdm845_display hardware/qcom-caf/sdm845/display
  cd $pwd_hal
}

# Sync Opengapps
function opengapps () {
  pwd_opengapps=$(pwd)
  cd $aosp/vendor/opengapps/build && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/all && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/arm && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/arm64 && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/x86 && git lfs fetch --all && git lfs pull && echo && pwd
  cd $aosp/vendor/opengapps/sources/x86_64 && git lfs fetch --all && git lfs pull && echo && pwd
  cd $pwd_opengapps
}

# Update scripts
function scripts () {
  scripts=$(pwd)
  cd $HOME
  rm -rf $HOME/.zshrc && wget https://raw.githubusercontent.com/mamutal91/dotfiles/master/aspire/.config/aosp/gcloud/.zshrc && source $HOME/.zshrc
#  rm -rf $HOME/.zsh_history && https://raw.githubusercontent.com/mamutal91/zsh-history/master/.zsh_history && source $HOME/.zsh_history
  rm -rf setup.sh && wget https://raw.githubusercontent.com/mamutal91/dotfiles/master/aspire/.config/aosp/gcloud/setup.sh && chmod +x setup.sh
  cd $scripts
}
