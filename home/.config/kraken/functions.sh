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

function push() {
  REPO=$(pwd | sed "s/\/mnt\/roms\/jobs\/Kraken\///; s/\//_/g")
  GITHOST=github
  ORG=AOSPK-WIP
  BRANCH=eleven
  FORCE=${1}
  TOPIC=${2}

  if [[ $REPO = "vendor_gapps" ]]; then
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
  )

  for i in "${branch[@]}"; do
    $HOME/.config/kraken/hal/hal.sh ${i}
  done

  $HOME/.config/kraken/hal/fixes.sh
}

function www() {
  pwd=$(pwd)
  cd $HOME && rm -rf www
  git clone ssh://git@github.com/AOSPK/www -b master www
  sudo rm -rf /mnt/roms/sites/www
  sudo mv www /mnt/roms/sites
  cd /mnt/roms/sites/www
  sudo npm i && sudo npm run build
  cd $pwd
}
