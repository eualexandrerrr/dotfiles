#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.dotfiles/allscripts/.config/scripts/kraken/builderFunctions.sh

tree() {
  cd /mnt/roms/jobs/KrakenDev
  rm -rf device/xiaomi vendor/xiaomi kernel/xiaomi hardware/xiaomi
  git clone ssh://git@github.com/AOSPK-Devices/device_xiaomi_lmi --single-branch -b twelve device/xiaomi/lmi
  git clone ssh://git@github.com/AOSPK-Devices/device_xiaomi_sm8250-common --single-branch -b twelve device/xiaomi/sm8250-common
  git clone ssh://git@github.com/AOSPK-Devices/kernel_xiaomi_sm8250 --single-branch -b twelve kernel/xiaomi/sm8250
  git clone ssh://git@github.com/TheBootloops/vendor_xiaomi_lmi --single-branch -b twelve vendor/xiaomi/lmi
  git clone ssh://git@github.com/TheBootloops/vendor_xiaomi_sm8250-common --single-branch -b twelve vendor/xiaomi/sm8250-common
  git clone ssh://git@github.com/AOSPK/hardware_xiaomi --single-branch -b twelve hardware/xiaomi

#  git clone ssh://git@github.com/AOSPK-Devices/device_xiaomi_ysl --single-branch -b twelve device/xiaomi/ysl
#  git clone ssh://git@github.com/AOSPK-Devices/device_xiaomi_msm8953-common --single-branch -b twelve device/xiaomi/msm8953-common
#  git clone https://github.com/NOtreallydust/kernel_xiaomi_ysl-1 --single-branch -b eleven kernel/xiaomi/msm8953
#  git clone ssh://git@github.com/TheBootloops/vendor_xiaomi_msm8953-common --single-branch -b twelve vendor/xiaomi/ysl-temp
#  cd /mnt/roms/jobs/KrakenDev/vendor/xiaomi/ysl-temp
#  mv msm8953-common ..
#  mv ysl ..
#  cd ..
#  rm -rf ysl-temp
  cd /mnt/roms/jobs/KrakenDev
}

gerrit() {
  ssh mamutal91@88.99.4.77 "cd /mnt/roms/sites/docker/docker-files/gerrit && sudo ./repl.sh"
}

down() {
  ssh mamutal91@88.99.4.77 "rm -rf /mnt/roms/jobs/Kraken && rm -rf device/xiaomi kernel/xiaomi vendor/xiaomi &> /dev/null"
  }

push() {
  if [[ $(pwd | cut -c1-15) == /mnt/roms/jobs/ ]]; then
    repo=$(pwd | sed "s/\/mnt\/roms\/jobs\///; s/\//_/g" | sed "s/KrakenDev_/_/g" | sed "s/Kraken_/_/g" | sed 's/.//')
  else
    repo=$(basename "$(pwd)")
  fi
  githost=github
  org=AOSPK-Next
  branch=twelve

  [ $repo = build_make ] && repo=build
  [ $repo = packages_apps_PermissionController ] && repo=packages_apps_PackageInstaller
  [ $repo = vendor_qcom_opensource_commonsys-intf_bluetooth ] && repo=vendor_qcom_opensource_bluetooth-commonsys-intf
  [ $repo = vendor_qcom_opensource_commonsys-intf_display ] && repo=vendor_qcom_opensource_display-commonsys-intf
  [ $repo = vendor_qcom_opensource_commonsys_bluetooth_ext ] && repo=vendor_qcom_opensource_bluetooth_ext
  [ $repo = vendor_qcom_opensource_commonsys_packages_apps_Bluetooth ] && repo=vendor_qcom_opensource_packages_apps_Bluetooth
  [ $repo = vendor_qcom_opensource_commonsys_system_bt ] && repo=vendor_qcom_opensource_system_bt
  [ $repo = vendor_gapps ] && githost=gitlab && org=AOSPK

  [ $repo = device_xiaomi_lmi ] && org=AOSPK-Devices
  [ $repo = device_xiaomi_sm8250-common ] && org=AOSPK-Devices
  [ $repo = kernel_xiaomi_sm8250 ] && org=AOSPK-Devices
  [ $repo = vendor_xiaomi_lmi ] && org=AOSPK-Devices
  [ $repo = vendor_xiaomi_sm8250-common ] && org=AOSPK-Devices

  [ $repo = official_devices ] && branch=master

  # To Gerrit
  if [[ ${1} == gerrit ]]; then
    topic=${3}

    if [[ -z ${2} ]]; then
      echo -e "${BLU}Usage:\n"
      echo "${CYA}  push gerrit ${RED}-?${END} ${GRE}<topic>${END}${YEL}"
      echo "              -s [Submit automatic]"
      echo "              -v [Verified]"
      echo "              -c [Specific SHA ID commit]"
      echo "              -n [Nothin]"
      echo "${END}"
    else
      [[ ${2} == -s ]] && gerritPush="HEAD:refs/for/${branch}%submit"
      [[ ${2} == -v ]] && gerritPush="HEAD:refs/for/${branch}%l=Verified+1,l=Code-Review+2"
      [[ ${2} == -c ]] && gerritPush="${3}:refs/for/${branch}" && topic=${4}
      [[ ${2} == -n ]] && gerritPush="HEAD:refs/for/${branch}"
      [[ -z ${2} ]] && gerritPush="HEAD:refs/for/${branch}"

      if [[ ! -d .git ]]; then
        echo "${BOL_RED}You are not in a .git repository${END}"
      else
        echo "${BOL_BLU}Pushing to ${BOL_YEL}gerrit-staging.pixelexperience.org/${MAG}${repo}${END} ${CYA}${branch}${END}"
        scp -p -P 29418 mamutal91@gerrit-staging.pixelexperience.org:hooks/commit-msg $(git rev-parse --git-dir)/hooks/ &> /dev/null
        git commit --amend --no-edit &> /dev/null
        if [[ $topic ]]; then
          git push ssh://mamutal91@gerrit-staging.pixelexperience.org:29419/${repo} $gerritPush,topic=${topic}
        else
          git push ssh://mamutal91@gerrit-staging.pixelexperience.org:29419/${repo} $gerritPush
        fi
      fi
#      [ $repo = manifest ] && echo ${BOL_RED}Pushing manifest to ORG DEV${END} && git push ssh://git@github.com/AOSPK-Next/manifest HEAD:refs/heads/twelve --force
    fi
  fi

  # To GitHub/GitLab
  if [[ ${1} == -f ]]; then
    echo "${BOL_BLU}Pushing to ${BOL_YEL}${githost}.com/${BOL_RED}${org}/${MAG}${repo}${END} ${CYA}${branch}${END}"
    gh repo create AOSPK-Next/${repo} --private --confirm &> /dev/null
    git push ssh://git@${githost}.com/AOSPK/${repo} HEAD:refs/heads/${branch} --force # REMOVERRRRRRRR APOS BRINGUP <<<<<<<<<<
    git push ssh://git@${githost}.com/${org}/${repo} HEAD:refs/heads/${branch} --force
  fi
  gh api -XPATCH "repos/AOSPK/${repo}" -f default_branch="${branch}" &> /dev/null
  gh api -XPATCH "repos/AOSPK-Next/${repo}" -f default_branch="${branch}" &> /dev/null
}

upstream() {
  repo=${1}
  orgBase=ArrowOS
  [[ ${4} != "-f" ]] && branchBase=${2} || branchBase=arrow-11.0
  [[ ${4} == "-l" ]] && orgBase=LineageOS && branchBase=lineage-18.1
  branchKraken=${3}
  [[ $repo == hardware_qcom_wlan ]] && branchBase="${branchBase}-caf" && branchKraken="${branchKraken}-caf"
  [[ $repo == hardware_qcom_bt ]] && branchBase="${branchBase}-caf" && branchKraken="${branchKraken}-caf"
  [[ $repo == hardware_qcom_bootctrl ]] && branchBase="${branchBase}-caf" && branchKraken="${branchKraken}-caf"
  workingDir=$(mktemp -d) && cd $workingDir
  echo -e "\n${BOL_BLU}Cloning ${BOL_RED}${repo} ${BOL_BLU}branch ${BOL_YEL}${branchBase} ${BOL_BLU}to ${BOL_YEL}${branchKraken}${END}\n"
  if [[ ${4} == "aosp" ]]; then
    echo "${BOL_RED}Forget everything above, I'm cloning it is straight from AOSP${END}"
    repoAOSP=$(echo $repo | sed "s/_/\//g")
    [[ $repoAOSP == hardware/libhardware/legacy ]] && repoAOSP="hardware/libhardware_legacy"
    git clone https://android.googlesource.com/platform/${repoAOSP} -b android-12.0.0_r2 ${repo}
  else
    git clone https://github.com/${orgBase}/android_${repo} -b ${branchBase} ${repo}
  fi
  cd ${repo}
  repo=$(echo $repo | sed -e "s/arrow/custom/g")
  repo=$(echo $repo | sed -e "s/Arrow/Custom/g")
  gh repo create AOSPK/${repo} --public --confirm
  gh repo create AOSPK-Next/${repo} --private --confirm
  git push ssh://git@github.com/AOSPK/${repo} HEAD:refs/heads/${branchKraken} --force
  git push ssh://git@github.com/AOSPK-Next/${repo} HEAD:refs/heads/${branchKraken} --force
  gh api -XPATCH "repos/AOSPK/${repo}" -f default_branch="${branchKraken}" &> /dev/null
  gh api -XPATCH "repos/AOSPK-Next/${repo}" -f default_branch="${branchKraken}" &> /dev/null
  rm -rf $workingDir
}

up() {
  upstream ${1} arrow-12.0 twelve ${2}
  # upstream ${1} lineage-18.1 eleven
  #  upstream ${1} lineage-17.1 ten
  #  upstream ${1} lineage-16.0 pie
  #  upstream ${1} lineage-15.1 oreo-mr1
  #  upstream ${1} cm-14.1 nougat
}

hals() {
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
      $HOME/.dotfiles/allscripts/.config/scripts/kraken/hal/hal.sh ${i}
    done
    $HOME/.dotfiles/allscripts/.config/scripts/kraken/hal/devicesettings-custom.sh
    cd $pwd
}
