#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

getRepoName() {
  repoNameCheck=$(pwd | cut -c-20)
  if [[ $repoNameCheck == "/home/mamutal91/GitH" ]]; then
    repoName=$(pwd | cut -c24-300 | sed "s:/:_:g")
  elif [[ $repoNameCheck == "/mnt/storage/Kraken/" ]]; then
    repoName=$(pwd | cut -c21-300 | sed "s:/:_:g")
  elif [[ $repoNameCheck == "/mnt/storage/KrakenD" ]]; then
    repoName=$(pwd | cut -c24-300 | sed "s:/:_:g")
  else
    echo -e "\n${BOL_MAG} * ${BOL_RED}Eu não consegui capturar o nome do repo...${END}"
    echo -e "${BOL_MAG} * ${BOL_YEL}${repoName}${END}"
    repoName=$(pwd | cut -c17-300 | sed "s:/:_:g")
  fi
  replaceNameRepo() {
    [[ $repoName == "build_make" ]] && repoName="build"
    [[ $repoName == "hardware_qcom-caf_wlan" ]] && repoName="hardware_qcom_wlan" && branchDefault=twelve-caf
    [[ $repoName == "hardware_qcom-caf_bootctrl" ]] && repoName="hardware_qcom_bootctrl" && branchDefault=twelve-caf
    [[ $repoName == "hardware_qcom-caf_thermal" ]] && repoName="hardware_qcom_thermal"
    [[ $repoName == "vendor_qcom_opensource_commonsys-intf_bluetooth" ]] && repoName=vendor_qcom_opensource_bluetooth-commonsys-intf
    [[ $repoName == "vendor_qcom_opensource_commonsys-intf_display" ]] && repoName=vendor_qcom_opensource_display-commonsys-intf
    [[ $repoName == "vendor_qcom_opensource_commonsys_bluetooth_ext" ]] && repoName=vendor_qcom_opensource_bluetooth_ext
    [[ $repoName == "vendor_qcom_opensource_commonsys_packages_apps_Bluetooth" ]] && repoName=vendor_qcom_opensource_packages_apps_Bluetooth
    [[ $repoName == "vendor_qcom_opensource_commonsys_system_bt" ]] && repoName=vendor_qcom_opensource_system_bt
    [[ $repoName == "official_devices" ]] && branchDefault=master
    [[ $repoName == "crowdin" ]] && branchDefault=master
  }
}

pushGitHub() {
  repoName=${repoName} && replaceNameRepo
  pushGitHubArgument=${1}
  branchDefault="twelve"
  pushGitHubOrg="AOSPK-Next"
  pushGitHubHost=github
  if [[ $repoName == vendor_gapps ]]; then
    pushGitHubOrg="AOSPK"
    pushGitHubHost=gitlab
  fi
  if [[ -z ${pushGitHubArgument} ]]; then
    echo -e "${BLU}Usage:\n"
    echo -e "${CYA}  push ${RED}-?${YEL}"
    echo -e "              -f [force commit to AOSPK-Next]"
    echo -e "${END}"
  else
    if echo $repoName | grep xiaomi &> /dev/null; then
      if echo $repoName | grep vendor &> /dev/null; then
        pushGitHubOrg="TheBootloops"
      else
        pushGitHubOrg="AOSPK-Devices"
      fi
      echo -e "\n${BOL_BLU}(AOSPK-Devices/TheBootloops) Pushing to ${BOL_YEL}${pushGitHubHost}.com/${CYA}${pushGitHubOrg}/${MAG}${repoName}${END} ${YEL}${branchDefault}${END}\n"
      git push ssh://git@${pushGitHubHost}.com/${pushGitHubOrg}/${repoName} HEAD:refs/heads/${branchDefault} --force
    else
      echo -e "\n${BOL_BLU}Pushing to ${BOL_YEL}${pushGitHubHost}.com/${CYA}${pushGitHubOrg}/${MAG}${repoName}${END} ${YEL}${branchDefault}${END}\n"
      if [[ $repoName != "vendor_gapps" ]]; then
      gh repo create AOSPK/${repoName} --public --confirm &> /dev/null
      gh repo create AOSPK-Next/${repoName} --private --confirm &> /dev/null
    fi
      git push ssh://git@${pushGitHubHost}.com/${pushGitHubOrg}/${repoName} HEAD:refs/heads/${branchDefault} --force
      if [[ ${2} == "main" ]]; then
        echo OK
        git push ssh://git@${pushGitHubHost}.com/AOSPK/${repoName} HEAD:refs/heads/${branchDefault} --force
      fi
      gh api -XPATCH "repos/AOSPK/${repoName}" -f default_branch="${branchDefault}" &> /dev/null
      gh api -XPATCH "repos/AOSPK-Next/${repoName}" -f default_branch="${branchDefault}" &> /dev/null
    fi
    [[ $repo = manifest ]] && git push ssh://git@github.com/AOSPK-Next/manifest HEAD:refs/heads/twelve --force
  fi
}

pushGerrit() {
  repoName=${repoName} && replaceNameRepo
  pushGerritArgument=${2}
  pushGerritTopic=${3}
  branchDefault="twelve"
  [[ $repoName == official_devices ]] && branchDefault=master
  pushGerritUrlProject="gerrit.aospk.org"
  if [[ ${pushGerritArgument} == "-c" ]]; then
    pushGerritIdCommit=${3}
  fi
  if [[ -z ${pushGerritArgument} ]]; then
    echo -e "${BLU}Usage:\n"
    echo -e "${CYA}  push gerrit ${RED}-?${END} ${GRE}<topic>${END}${YEL}"
    echo -e "              -s [Submit automatic]"
    echo -e "              -v [Verified]"
    echo -e "              -c [Specific SHA ID commit]"
    echo -e "              -n [Nothin]"
    echo -e "              -p [Specifc project]"
    echo -e "${BOL_RED}              Use Project, example: ${BOL_YEL}: push gerrit -p ArrowOS arrow-12.0 topic"
    echo -e "${END}"
  else
    [[ ${pushGerritArgument} == -v ]] && pushGerritPush="HEAD:refs/for/${branchDefault}%l=Verified+1,l=Code-Review+2"
    [[ ${pushGerritArgument} == -s ]] && pushGerritPush="HEAD:refs/for/${branchDefault}%submit,l=Verified+1,l=Code-Review+2"
    [[ ${pushGerritArgument} == -c ]] && pushGerritPush="${pushGerritIdCommit}:refs/for/${branchDefault}"
    [[ ${pushGerritArgument} == -n ]] && pushGerritPush="HEAD:refs/for/${branchDefault}"
    if [[ ${pushGerritArgument} == -p ]]; then
      pushGerritProject=${3}
      branchDefault=${4}
      pushGerritTopic=${5}
        [[ ${3} == LineageOS ]] && pushGerritUrlProject="review.lineageos.org" && pushGerritPush="HEAD:refs/for/${branchDefault}" && repoName=${pushGerritProject}/${repoName}
        [[ ${3} == ArrowOS ]] && pushGerritUrlProject="review.arrowos.net" && pushGerritPush="HEAD:refs/for/${branchDefault}" && repoName=${pushGerritProject}/${repoName}
        [[ ${3} == PixelExperience ]] && pushGerritUrlProject="gerrit.pixelexperience.org" && pushGerritPush="HEAD:refs/for/${branchDefault}"
    fi
    [[ -z ${pushGerritArgument} ]] && pushGerritPush="HEAD:refs/for/${branchDefault}"
    if [[ ! -d .git ]]; then
      echo -e "${BOL_RED}You are not in a .git repository\n${RED}$(pwd)${END}"
    else
      scp -p -P 29418 mamutal91@${pushGerritUrlProject}:hooks/commit-msg $(git rev-parse --git-dir)/hooks/ &> /dev/null
      git commit --amend --no-edit &> /dev/null
      echo -e "\n${BOL_BLU}Pushing to ${BOL_YEL}${pushGerritUrlProject}/${MAG}${repoName}${END} ${YEL}${branchDefault}${END}\n"
      [[ ${pushGerritTopic} ]] && pushGerritTopicCmd=",topic=${pushGerritTopic}"
      git push ssh://mamutal91@${pushGerritUrlProject}:29418/${repoName} ${pushGerritPush}${pushGerritTopicCmd}
    fi
    [[ $repo = manifest ]] && git push ssh://git@github.com/AOSPK-Next/manifest HEAD:refs/heads/twelve --force
  fi
  if [[ ${pushGerritArgument} != "-p" ]]; then
    push -f
  fi
}

push (){
  m
  if [[ -z ${1} ]]; then
    echo -e "${BLU}Usage:\n"
    echo -e "${CYA}  push ${RED}-?${YEL}"
    echo -e "              gerrit [Submit gerrit]"
    echo -e "              -f [force commit to AOSPK-Next]"
    echo -e "${END}"
  else
    getRepoName
    [[ ${1} == gerrit ]] && pushGerrit ${1} ${2} ${3} ${4} ${5}
    [[ ${1} == -f ]] && pushGitHub ${1} ${2} ${3} ${4} ${5}
  fi
}
