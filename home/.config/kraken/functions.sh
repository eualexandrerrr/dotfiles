#!/usr/bin/env bash

if [[ $(cat /etc/hostname) = mamutal91-v2 ]]; then
  HOME=/home/mamutal91
fi

function lmi() {
  if [[ $(cat /etc/hostname) = mamutal91-v2 ]]; then
    $HOME/.dotfiles/home/.config/kraken/lmi.sh
  else
    ssh mamutal91@86.109.7.111 "$HOME/.dotfiles/home/.config/kraken/lmi.sh"
  fi
}

function beryllium() {
  cd $HOME && $HOME/.dotfiles/home/.config/kraken/beryllium.sh
}

function gerrit() {
  if [[ $(cat /etc/hostname) = mamutal91-v2 ]]; then
    pwd=$(pwd)
    cd /mnt/roms/sites/docker/docker-files/gerrit
    sudo ./repl.sh
    cd $pwd
  else
    ssh mamutal91@86.109.7.111 "source $HOME/.zshrc && gerrit"
  fi
}

function down() {
  if [[ $(cat /etc/hostname) = mamutal91-v2 ]]; then
    pwd=$(pwd)
    rm -rf /mnt/roms/sites/private/builds/*/*.zip &>/dev/null
    rm -rf /mnt/roms/sites/private/builds/*/json/*.json &>/dev/null
    cd $pwd
  else
    ssh mamutal91@86.109.7.111 "source $HOME/.zshrc && down"
  fi
}


function merge_aosp() {
  $HOME/.dotfiles/home/.config/kraken/merge_aosp.sh
}

function sync_repos() {
  $HOME/.dotfiles/home/.config/kraken/sync_repos.sh
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
  ORG=AOSPK-DEV
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
      git push ssh://mamutal91@gerrit.aospk.org:29418/${REPO} HEAD:refs/for/${BRANCH}%l=Verified+1,l=Code-Review+2,topic=${TOPIC}
    else
      git push ssh://mamutal91@gerrit.aospk.org:29418/${REPO} HEAD:refs/for/${BRANCH}%l=Verified+1,l=Code-Review+2,topic=${TOPIC}
    fi
  else
    echo "${BOL_BLU}Pushing to ${GITHOST}.com/${GRE}${ORG}${END}/${BLU}${REPO}${END} - ${BRANCH} ${RED}${FORCE}${END}"
    git push ssh://git@${GITHOST}.com/${ORG}/${REPO} HEAD:refs/heads/${BRANCH} ${FORCE}
  fi
}

function m() {
  git add . && git commit --amend --no-edit
  sleep 2

  pwd=$(pwd)
  cd .git
  sudo rm -rf /tmp/COMMIT_EDITMSG
  sudo cp -rf COMMIT_EDITMSG /tmp/
  cd $pwd

  pathRepo=$(pwd | cut -c26-)

  msgMerge="Merge tag 'android-11.0.0_r38' of https://android.googlesource.com/platform/${pathRepo} into HEAD"

  echo $msgMerge > /tmp/NEW_COMMITMSG
  cat /tmp/NEW_COMMITMSG

  sudo sed -i '1d' /tmp/COMMIT_EDITMSG
  sed -i "s/haggertk/AOSPK-DEV/g" /tmp/COMMIT_EDITMSG
  sed -i "s/android_//g" /tmp/COMMIT_EDITMSG
  sed -i "s/lineage-18.1/eleven/g" /tmp/COMMIT_EDITMSG
  cat /tmp/COMMIT_EDITMSG >> /tmp/NEW_COMMITMSG

  echo -e "\n\nCONTEÚDO:\n$(cat /tmp/NEW_COMMITMSG)"

  msg=$(cat /tmp/NEW_COMMITMSG)

  git add . && git commit --message "${msg}" --amend --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
  push gerrit android-11.0.0_r38
  sleep 3 && clear
}

upstream() {
  workingDir=$(mktemp -d) && cd $workingDir

  git clone https://github.com/LineageOS/android_${1} -b ${2} ${1}
  cd ${1}
  gh repo create AOSPK/${i} --public --confirm &>/dev/null
  gh repo create AOSPK-DEV/${i} --private --confirm &>/dev/null
  cd ${REPO} && git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/eleven --force

  rm -rf $workingDir
}

function up() {
  upstream ${1} lineage-18.1 eleven
#  upstream ${1} lineage-17.1 ten
#  upstream ${1} lineage-16.0 pie
#  upstream ${1} lineage-15.1 oreo-mr1
#  upstream ${1} cm-14.1 nougat
}

function hals() {
  if [[ $(cat /etc/hostname) = mamutal91-v2 ]]; then
    pwd=$(pwd)
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

    $HOME/.dotfiles/home/.config/kraken/hal/caf.sh
    $HOME/.dotfiles/home/.config/kraken/hal/chromium.sh
    $HOME/.dotfiles/home/.config/kraken/hal/faceunlock.sh
    $HOME/.dotfiles/home/.config/kraken/hal/sepolicy.sh

    cd $pwd
  else
    ssh mamutal91@86.109.7.111 "source $HOME/.zshrc && hals"
  fi
}

function www() {
  if [[ $(cat /etc/hostname) = mamutal91-v2 ]]; then
    cd $HOME && rm -rf www
    git clone ssh://git@github.com/AOSPK/www -b master www
    sudo rm -rf /mnt/roms/sites/www
    sudo cp -rf www /mnt/roms/sites
    cd /mnt/roms/sites/www
    sudo npm i && sudo npm run build
    cd $HOME
  else
    ssh mamutal91@86.109.7.111 "source $HOME/.zshrc && www"
  fi
}
