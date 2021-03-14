#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.dotfiles/allscripts/.config/scripts/kraken/builderFunctions.sh

tree() {
  echo "REBASE TREE LMI"
  bash $HOME/.dotfiles/allscripts/.config/scripts/kraken/lmi.sh
}

c() {
  repo=${1}
  [[ ${2} == o ]] && statusCommit=open || statusCommit=merged
  google-chrome-stable https://review.arrowos.net/q/project:ArrowOS/android_${repo}+branch:arrow-12.0+status:${statusCommit} &> /dev/null
  [[ $statusCommit=merge ]] && google-chrome-stable --new-window https://github.com/ArrowOS/android_${repo}/commits/arrow-12.0
  clear
}

gerrit() {
  ssh mamutal91@147.75.35.163 "cd /mnt/roms/sites/docker/docker-files/gerrit && sudo ./repl.sh"
}

down() {
  ssh mamutal91@147.75.35.163 "rm -rf /mnt/roms/jobs/Kraken && rm -rf device/xiaomi kernel/xiaomi vendor/xiaomi &> /dev/null"
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
        echo "${BOL_BLU}Pushing to ${BOL_YEL}gerrit.aospk.org/${MAG}${repo}${END} ${CYA}${branch}${END}"
        scp -p -P 29418 mamutal91@gerrit.aospk.org:hooks/commit-msg $(git rev-parse --git-dir)/hooks/ &> /dev/null
        git commit --amend --no-edit &> /dev/null
        if [[ $topic ]]; then
          git push ssh://mamutal91@gerrit.aospk.org:29418/${repo} $gerritPush,topic=${topic}
        else
          git push ssh://mamutal91@gerrit.aospk.org:29418/${repo} $gerritPush
        fi
      fi
      [[ $repo = manifest ]] && echo ${BOL_RED}Pushing manifest to ORG DEV${END} && git push ssh://git@github.com/AOSPK-Next/manifest HEAD:refs/heads/twelve --force
    fi
  fi

  # To GitHub/GitLab
  if [[ ${1} == -f ]]; then
    echo "${BOL_BLU}Pushing to ${BOL_YEL}${githost}.com/${BOL_RED}${org}/${MAG}${repo}${END} ${CYA}${branch}${END}"
    gh repo create AOSPK/${repo} --public --confirm &> /dev/null
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
  repo=$(echo $repo | sed -e "s/vendor_custom/vendor_aosp/g")
  gh repo create AOSPK-Next/${repo} --private --confirm
  git push ssh://git@github.com/AOSPK-Next/${repo} HEAD:refs/heads/${branchKraken} --force
  gh api -XPATCH "repos/AOSPK-Next/${repo}" -f default_branch="${branchKraken}" &> /dev/null

#  if [[ ${4} == "-m" ]]; then
    echo -e "${BOL_RED}Warning ! ${BOL_BLU}Pushing to main org github.com/AOSPK ${END}"
    gh repo create AOSPK/${repo} --public --confirm
    git push ssh://git@github.com/AOSPK/${repo} HEAD:refs/heads/${branchKraken} --force
    gh api -XPATCH "repos/AOSPK/${repo}" -f default_branch="${branchKraken}" &> /dev/null
#  fi

  rm -rf $workingDir
}

up() {
  upstream ${1} arrow-12.0 twelve ${2}
}

hals() {
    pwd=$(pwd)
    branch=(
      msm8998
      sdm660
      sdm845
      sm8150
      sm8250
      sm8350
    )
    for i in "${branch[@]}"; do
      $HOME/.dotfiles/allscripts/.config/scripts/kraken/hal/hal.sh ${i}
    done
#    $HOME/.dotfiles/allscripts/.config/scripts/kraken/hal/devicesettings-custom.sh
    cd $pwd
}
