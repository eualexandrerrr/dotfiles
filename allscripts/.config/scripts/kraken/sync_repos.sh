#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

mkdir -p $HOME/tmp
cd $HOME/tmp
rm -rf aosp.xml custom.xml &> /dev/null
wget https://raw.githubusercontent.com/AOSPK/manifest/twelve/aosp.xml &> /dev/null
wget https://raw.githubusercontent.com/AOSPK/manifest/twelve/custom.xml &> /dev/null

clear

repoSync() {
  repo=($(grep -Po 'name=\"\K[^"]+(?=\")' $HOME/tmp/${1}.xml))

  for repo in ${repo[@]}; do
    branch="twelve"
    [[ $repo == "aospk" ]] && continue
    [[ $repo == "aospk-gitlab" ]] && continue
    [[ $repo == "hub-devices" ]] && continue
    [[ $repo == "blobs" ]] && continue
    [[ $repo == "github" ]] && continue
    [[ $repo == "gitlab" ]] && continue
    [[ $repo == "manifest" ]] && continue

    [[ $repo == "hardware_qcom_bootctrl" ]] && branch="twelve-caf"
    [[ $repo == "hardware_qcom_wlan" ]] && branch="twelve-caf"

    # Pular esses repositorios se for o custom.xml, no aosp.xml pode sincornizar, pois será a branch principal
    if [[ ${1} == "custom" ]]; then
      [[ $repo == "hardware_qcom_audio" ]] && continue
      [[ $repo == "hardware_qcom_display" ]] && continue
      [[ $repo == "hardware_qcom_media" ]] && continue
    fi

    [[ $repo == "vendor_gapps" ]] && continue
    [[ $repo == "vendor_nxp_opensource_hidlimpl" ]] && continue
    [[ $repo == "vendor_nxp_opensource_halimpl" ]] && continue

    [[ $repo == "frameworks_base" ]] && continue
    [[ $repo == "packages_apps_Settings" ]] && continue

    echo -e "\n${BOL_RED}REPO_AOSP : ${BOL_GRE}${repo}${END}"
    echo -e "${BOL_RED}BRANCH    : ${BOL_GRE}${branch}${END}"
    cd $HOME/tmp
    rm -rf $repo
    git clone ssh://git@github.com/AOSPK/${repo} -b ${branch} $repo --single-branch
    cd $repo
    gh repo create AOSPK-Next/${repo} --private --confirm &> /dev/null
    git push ssh://git@github.com/AOSPK-Next/${repo} HEAD:refs/heads/${branch} --force
  done
}

repoSync custom
repoSync aosp

repoSyncHAL() {
  hals=($(grep hardware_qcom_audio $HOME/tmp/custom.xml | awk '{ print $6 }' | cut -c22-300 | tr -d '"="'))

  for hal in ${hals[@]}; do
    branch="twelve"
    repos=('audio' 'media' 'display')
    for repo in ${repos[@]}; do
      echo -e "${BOL_RED}REPO_AOSP: ${BOL_GRE}${repo}${END}"
      cd $HOME/tmp
      rm -rf hardware_qcom_${repo}_${branch}-caf-${hal}
      git clone ssh://git@github.com/AOSPK/hardware_qcom_${repo} -b ${branch}-caf-${hal} hardware_qcom_${repo}_${branch}-caf-${hal}
      cd hardware_qcom_${repo}_${branch}-caf-${hal}
      gh repo create AOSPK-Next/hardware_qcom_${repo} --private --confirm &> /dev/null
      git push ssh://git@github.com/AOSPK-Next/hardware_qcom_${repo} HEAD:refs/heads/${branch}-caf-${hal} --force
    done
  done
}

repoSyncHAL

repoBig() {
  repoBig=${1}
  branch=twelve
  cd $HOME/tmp
  git clone ssh://git@github.com/AOSPK/${repoBig} -b ${branch} ${repoBig} --single-branch
  cd ${repoBig}
  gh repo create AOSPK-Next/${repoBig} --private --confirm &> /dev/null
  git push ssh://git@github.com/AOSPK-Next/${repoBig} HEAD:refs/heads/${branch} --force
}

repoBig packages_apps_Settings
repoBig frameworks_base
