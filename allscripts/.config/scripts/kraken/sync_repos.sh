#!/usr/bin/env bash

source $HOME/.colors &> /dev/null

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
branch=eleven

workingDir=/mnt/roms/jobs/Kraken
orgDeOrigem=AOSPK
orgDeDestino=AOSPK-DEV

cd $workingDir
echo -e '[Repo] $ Syncing...'

repo init -u git://github.com/AOSPK/manifest -b eleven >> /dev/null
repo sync -c -j$(nproc --all) --no-clone-bundle --current-branch --no-tags --force-sync >> /dev/null

go() {
  for repo in $(grep "remote=\"${remote}\"" ${workingDir}/manifest/${1}.xml | awk '{print $2 $3}'); do
    cd $workingDir
    repoPath=$(echo $repo | cut -d'"' -f2)
    repoName=$(echo $repo | cut -d'"' -f4)

    replace
    [[ $repoName == manifest ]] && continue
    [[ $repoName == device_qcom_sepolicy ]] && continue
    [[ $repoName == hardware_qcom_audio ]] && continue
    [[ $repoName == hardware_qcom_bootctrl ]] && continue
    [[ $repoName == hardware_qcom_bt ]] && continue
    [[ $repoName == hardware_qcom_display ]] && continue
    [[ $repoName == hardware_qcom_media ]] && continue
    [[ $repoName == hardware_qcom_wlan ]] && continue
    [[ $repoName == vendor_gapps ]] && continue
    [[ $repoName == vendor_nxp_opensource_halimpl ]] && continue
    [[ $repoName == vendor_nxp_opensource_hidlimpl ]] && continue
    [[ $repoName == external_chromium-webview ]] && continue

    # Executar tarefas
    cd $repoPath
    echo
    echo $repoName
    gh repo create AOSPK/${repoName} --public --confirm &> /dev/null
    gh repo create AOSPK-DEV/${repoName} --private --confirm &> /dev/null
    git remote add old https://github.com/${orgDeOrigem}/${repoName} &> /dev/null
    git fetch --unshallow old &> /dev/null
    git push ssh://git@github.com/${orgDeDestino}/${repoName} HEAD:refs/heads/${branch} --force
    cd $workingDir
  done
}

go aosp
go custom

cd $pwd
