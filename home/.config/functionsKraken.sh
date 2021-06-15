#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

[ $(cat /etc/hostname) = mamutal91-v2 ] && HOME=/home/mamutal91

function lmi() {
  dot
  ssh mamutal91@86.109.7.111 "bash $HOME/.dotfiles/home/.config/kraken/lmi.sh"
}

function gerrit() {
  ssh mamutal91@86.109.7.111 "cd /mnt/roms/sites/docker/docker-files/gerrit && sudo ./repl.sh"
}

function down() {
  ssh mamutal91@86.109.7.111 "rm -rf /mnt/roms/sites/private/builds/*/*.zip &>/dev/null && rm -rf /mnt/roms/sites/private/builds/*/json/*.json &>/dev/null"
}

function sync_repos() {
  ssh mamutal91@86.109.7.111 "bash $HOME/.dotfiles/home/.config/kraken/sync_repos.sh"
}

function push() {
  if [[ $(cat /etc/hostname) = mamutal91-v2 ]]; then
    repo=$(pwd | sed "s/\/mnt\/roms\/jobs\/KrakenDev\///; s/\//_/g")
  else
    repo=$(basename "`pwd`")
  fi
  github=github
  org=AOSPK-DEV
  branch=eleven
  force=${1}
  topic=${2}

  if [[ $repo = vendor_gapps || $repo = vendor_google_gms ]]; then
    github=gitlab
    org=AOSPK
  fi
  if [[ $repo = www ]]; then
    org=AOSPK
    branch=master
  fi
  if [[ $repo = build_make ]]; then
    repo=build
  fi
  if [[ $repo = packages_apps_PermissionController ]]; then
    repo=packages_apps_PackageInstaller
  fi
  if [[ $repo = vendor_qcom_opensource_commonsys-intf_bluetooth ]]; then
    repo=vendor_qcom_opensource_bluetooth-commonsys-intf
  fi
  if [[ $repo = vendor_qcom_opensource_commonsys-intf_display ]]; then
    repo=vendor_qcom_opensource_display-commonsys-intf
  fi
  if [[ $repo = vendor_qcom_opensource_commonsys_bluetooth_ext ]]; then
    repo=vendor_qcom_opensource_bluetooth_ext
  fi
  if [[ $repo = vendor_qcom_opensource_commonsys_packages_apps_Bluetooth ]]; then
    repo=vendor_qcom_opensource_packages_apps_Bluetooth
  fi
  if [[ $repo = vendor_qcom_opensource_commonsys_system_bt ]]; then
    repo=vendor_qcom_opensource_system_bt
  fi

  if [[ ${1} = gerrit ]]; then
    echo "${BOL_BLU}Pushing to ${BOL_BLU}gerrit.aospk.org${END} - ${branch} ${RED}${force}${END}"
    if [[ -z ${topic} ]]; then
      git push ssh://mamutal91@gerrit.aospk.org:29418/${repo} HEAD:refs/for/${branch}%l=Verified+1,l=Code-Review+2,topic=${topic}
    else
      git push ssh://mamutal91@gerrit.aospk.org:29418/${repo} HEAD:refs/for/${branch}%l=Verified+1,l=Code-Review+2,topic=${topic}
    fi
  else
    echo "${BOL_BLU}Pushing to ${github}.com/${GRE}${org}${END}/${BLU}${repo}${END} - ${branch} ${RED}${force}${END}"
    git push ssh://git@${github}.com/${org}/${repo} HEAD:refs/heads/${branch} ${force}
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
  cd ${repo} && git push ssh://git@github.com/AOSPK/${i} HEAD:refs/heads/eleven --force

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
