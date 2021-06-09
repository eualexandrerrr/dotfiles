#!/usr/bin/env bash

clear

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

working_dir=/mnt/roms/jobs/Kraken

cd $working_dir
#repo sync -c --force-sync >> /dev/null

function go() {
  cd $working_dir
  for repo in $(grep "remote=\"${remote}\"" ${working_dir}/manifest/${1}.xml | awk '{print $2 $3}'); do
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
    gh repo create AOSPK-WIP/${repoName} --private --confirm &>/dev/null
    git remote add old https://github.com/AOSPK/${repoName} &>/dev/null
    git fetch --unshallow old &>/dev/null
    git push ssh://git@github.com/AOSPK-WIP/${repoName} HEAD:refs/heads/${branch} --force
    cd $working_dir
  done
}

go aosp
go custom
