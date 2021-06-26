#!/usr/bin/env bash

source $HOME/.colors &> /dev/null

clear

replace() {
  if [[ $repoPath == build_make ]]; then
    repoName=build
  fi
  if [[ $repoPath == packages_apps_PermissionController ]]; then
    repoName=packages_apps_PackageInstaller
  fi
  if [[ $repoPath == vendor_qcom_opensource_commonsys-intf_bluetooth ]]; then
    repoName=vendor_qcom_opensource_bluetooth-commonsys-intf
  fi
  if [[ $repoPath == vendor_qcom_opensource_commonsys-intf_display ]]; then
    repoName=vendor_qcom_opensource_display-commonsys-intf
  fi
  if [[ $repoPath == vendor_qcom_opensource_commonsys_bluetooth_ext ]]; then
    repoName=vendor_qcom_opensource_bluetooth_ext
  fi
  if [[ $repoPath == vendor_qcom_opensource_commonsys_packages_apps_Bluetooth ]]; then
    repoName=vendor_qcom_opensource_packages_apps_Bluetooth
  fi
  if [[ $repoPath == vendor_qcom_opensource_commonsys_system_bt ]]; then
    repoName=vendor_qcom_opensource_system_bt
  fi
}

remote=aospk
branch=eleven

go() {
  cd /mnt/roms/jobs/Kraken
  for repo in $(grep "remote=\"${remote}\"" manifest/${1}.xml | awk '{print $2 $3}'); do
    repoPath=$(echo $repo | cut -d'"' -f2)
    repoName=$(echo $repo | cut -d'"' -f4)

    replace
    echo -e "${RED}Changing default branch: ${GRE}${repoName}${END}"
    gh api -XPATCH "repos/AOSPK/${repoName}" -f default_branch="${branch}" &> /dev/null
    gh api -XPATCH "repos/AOSPK-DEV/${repoName}" -f default_branch="${branch}" &> /dev/null
  done
}

go aosp
go custom

cd $pwd
