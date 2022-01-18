#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

clear

replace() {
  [[ $repoPath == build_make ]] && repoName=build
  [[ $repoPath == packages_apps_PermissionController ]] && repoName=packages_apps_PackageInstaller
  [[ $repoPath == vendor_qcom_opensource_commonsys-intf_bluetooth ]] && repoName=vendor_qcom_opensource_bluetooth-commonsys-intf
  [[ $repoPath == vendor_qcom_opensource_commonsys-intf_display ]] && repoName=vendor_qcom_opensource_display-commonsys-intf
  [[ $repoPath == vendor_qcom_opensource_commonsys_bluetooth_ext ]] && repoName=vendor_qcom_opensource_bluetooth_ext
  [[ $repoPath == vendor_qcom_opensource_commonsys_packages_apps_Bluetooth ]] && repoName=vendor_qcom_opensource_packages_apps_Bluetooth
  [[ $repoPath == vendor_qcom_opensource_commonsys_system_bt ]] && repoName=vendor_qcom_opensource_system_bt
}

remote=aospk
branch=twelve

go() {
  cd /mnt/roms/jobs/Kraken
  for repo in $(grep "remote=\"${remote}\"" manifest/${1}.xml | awk '{print $2 $3}'); do
    repoPath=$(echo $repo | cut -d'"' -f2)
    repoName=$(echo $repo | cut -d'"' -f4)

    replace
    echo -e "${RED}Changing default branch: ${GRE}${repoName}${END}"
    gh api -XPATCH "repos/AOSPK/${repoName}" -f default_branch="${branch}" &> /dev/null
    gh api -XPATCH "repos/AOSPK-Next/${repoName}" -f default_branch="${branch}" &> /dev/null
  done
}

go aosp
go custom

cd $pwd
