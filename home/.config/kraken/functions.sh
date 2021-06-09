#!/usr/bin/env bash

function lmi() {
  cd $HOME && $HOME/.dotfiles/home/.config/kraken/lmi.sh
}

function beryllium() {
  cd $HOME && $HOME/.dotfiles/home/.config/kraken/beryllium.sh
}

function down() {
  pwd=$(pwd)
  rm -rf /mnt/roms/sites/private/builds/*/*.zip &>/dev/null
  rm -rf /mnt/roms/sites/private/builds/*/json/*.json &>/dev/null
  cd $pwd
}

function merge_aosp() {
  $HOME/.dotfiles/home/.config/kraken/merge_aosp.sh ${1}
}

function push() {
  HOSTNAME=$(cat /etc/hostname)
  if [[ $HOSTNAME = mamutal91-v2 ]]; then
    REPO=$(pwd | sed "s/\/mnt\/roms\/jobs\/KrakenDev\///; s/\//_/g")
  else
    REPO=$(basename "`pwd`")
  fi
  echo $REPO
  GITHOST=github
  ORG=AOSPK-WIP
  BRANCH=eleven
  FORCE=${1}
  TOPIC=${2}

  if [[ $REPO = "vendor_gapps" || $REPO = "vendor_google_gms" ]]; then
    GITHOST=gitlab
    ORG=AOSPK
  fi
  if [[ $REPO = "www" ]]; then
    ORG=AOSPK
    BRANCH=master
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
    echo "${BOL_BLU}Pushing to gerrit.aospk.org${END} - ${BRANCH} ${RED}${FORCE}${END}"
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

upstream() {
  cd $HOME && rm -rf ${1}
  GITHOST=github
  ORG=LineageOS
  REPO=android_${1}
  REPO_KK=$(echo $REPO | cut -c9-)
  BRANCH=${2}
  BRANCH_KK=${3}
  if [[ ${1} = vendor_google_pixel ]]; then
    ORG=ThankYouMario
    REPO=android_vendor_google_pixel
    BRANCH=ruby
  fi
  if [[ ${1} = packages_apps_FaceUnlockService ]]; then
    ORG=PixelExperience
    REPO=packages_apps_FaceUnlockService
    BRANCH=eleven
    rm -rf external_faceunlock
    git clone https://gitlab.pixelexperience.org/android/external_faceunlock -b eleven
    cd external_faceunlock && git push ssh://git@github.com/AOSPK/external_faceunlock HEAD:refs/heads/${BRANCH_KK} --force
    cd ..
  fi

  echo "${BOL_CYA}Cloning ${ORG}/${REPO} -b ${BRANCH}${END}"
  git clone https://${GITHOST}.com/${ORG}/${REPO} -b ${BRANCH} ${REPO}
  cd ${REPO} && git push ssh://git@${GITHOST}.com/AOSPK/${REPO_KK} HEAD:refs/heads/${BRANCH_KK} --force
  rm -rf $HOME/${REPO}
}

function up() {
  upstream ${1} lineage-18.1 eleven
#  upstream ${1} lineage-17.1 ten
#  upstream ${1} lineage-16.0 pie
#  upstream ${1} lineage-15.1 oreo-mr1
#  upstream ${1} cm-14.1 nougat
}

function hals() {
  pwd=$(pwd)

  $HOME/.dotfiles/home/.config/kraken/hal/caf.sh
  $HOME/.dotfiles/home/.config/kraken/hal/fixes.sh
  $HOME/.dotfiles/home/.config/kraken/hal/sepolicy.sh

  branch=(
    apq8084
    msm8960
    msm8952
    msm8916
    msm8974
    msm8994
    msm8996
    msm8998
    sdm845
    sm8150
    sm8250
    sm8350
  )

  for i in "${branch[@]}"; do
    $HOME/.dotfiles/home/.config/kraken/hal/hal.sh ${i}
  done

  cd $pwd
}

function www() {
  cd $HOME && rm -rf www
  git clone ssh://git@github.com/AOSPK/www -b master www
  sudo rm -rf /mnt/roms/sites/www
  sudo cp -rf www /mnt/roms/sites
  cd /mnt/roms/sites/www
  sudo npm i && sudo npm run build
  cd $HOME
}
