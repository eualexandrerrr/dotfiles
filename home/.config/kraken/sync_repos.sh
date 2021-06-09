#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

clear

pwd=$(pwd)

replace(){
  if [ $repoPath = build_make ]; then
    repoName=build
  fi
  if [ $repoPath = packages_apps_PermissionController ]; then
    repoName=packages_apps_PackageInstaller
  fi
  if [ $repoPath = vendor_qcom_opensource_commonsys-intf_bluetooth ]; then
    repoName=vendor_qcom_opensource_bluetooth-commonsys-intf
  fi
  if [ $repoPath = vendor_qcom_opensource_commonsys-intf_display ]; then
    repoName=vendor_qcom_opensource_display-commonsys-intf
  fi
  if [ $repoPath = vendor_qcom_opensource_commonsys_bluetooth_ext ]; then
    repoName=vendor_qcom_opensource_bluetooth_ext
  fi
  if [ $repoPath = vendor_qcom_opensource_commonsys_packages_apps_Bluetooth ]; then
    repoName=vendor_qcom_opensource_packages_apps_Bluetooth
  fi
  if [ $repoPath = vendor_qcom_opensource_commonsys_system_bt ]; then
    repoName=vendor_qcom_opensource_system_bt
  fi
}

remote=aospk
branch=eleven

workingDir=/mnt/roms/jobs/Kraken
orgDeOrigem=AOSPK
orgDeDestino=AOSPK-DEV

cd $workingDir
echo -e "${BLU}Org de origem: ${orgDeOrigem}\nOrg de destino: ${orgDeDestino}${END}"
echo "${RED}Go to ${BLU}$(pwd)${END}"
echo "${CYA}Syncing...${END}"

repo init -u git://github.com/AOSPK/manifest -b eleven
repo sync -c -j$(nproc --all) --no-clone-bundle --current-branch --no-tags --force-sync >> /dev/null

function go() {
  for repo in $(grep "remote=\"${remote}\"" ${workingDir}/manifest/${1}.xml | awk '{print $2 $3}'); do
    cd $workingDir
    repoPath=$(echo $repo | cut -d'"' -f2)
    repoName=$(echo $repo | cut -d'"' -f4)

    replace
    [ $repoName = manifest ] && continue
    [ $repoName = device_qcom_sepolicy ] && continue
    [ $repoName = hardware_qcom_audio ] && continue
    [ $repoName = hardware_qcom_bootctrl ] && continue
    [ $repoName = hardware_qcom_bt ] && continue
    [ $repoName = hardware_qcom_display ] && continue
    [ $repoName = hardware_qcom_media ] && continue
    [ $repoName = hardware_qcom_wlan ] && continue
    [ $repoName = vendor_gapps ] && continue
    [ $repoName = vendor_nxp_opensource_halimpl ] && continue
    [ $repoName = vendor_nxp_opensource_hidlimpl ] && continue

    # Executar tarefas
    cd $repoPath
    echo
    echo $repoName
    gh repo create ${orgDeDestino}/${repoName} --private --confirm &>/dev/null
    git remote add old https://github.com/${orgDeOrigem}/${repoName} &>/dev/null
    git fetch --unshallow old &>/dev/null
    git push ssh://git@github.com/${orgDeDestino}/${repoName} HEAD:refs/heads/${branch} --force
    cd $workingDir
  done
}

go aosp
go custom

cd $pwd
