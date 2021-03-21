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
    echo -e "\n\n${BOL_MAG}* * *${BOL_RED}Eu não consegui capturar o nome do repo...${END}"
    repoName=$(pwd | cut -c17-300 | sed "s:/:_:g")
    echo -e "\n\n${BOL_YEL}${repoName}${END}"
  fi
  replaceNameRepo() {
    [[ $repoName == "build_make" ]] && repoName="build"
  }
}

pushGitHub() {
  repoName=${repoName} && replaceNameRepo
  pushGitHubArgument=${1}
  pushCommitBranch="twelve"
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
      echo -e "\n${BOL_BLU}Pushing to ${BOL_YEL}${pushGitHubHost}.com/${CYA}${pushGitHubOrg}/${MAG}${repoName}${END} ${YEL}${pushCommitBranch}${END}\n"
      git push ssh://git@github.com/${pushGitHubOrg}/${repoName} HEAD:refs/heads/${pushCommitBranch} --force
    else
      echo -e "\n${BOL_BLU}Pushing to ${BOL_YEL}${pushGitHubHost}.com/${CYA}${pushGitHubOrg}/${MAG}${repoName}${END} ${YEL}${pushCommitBranch}${END}\n"
      gh repo create AOSPK/${repoName} --public --confirm &> /dev/null
      gh repo create AOSPK-Next/${repoName} --private --confirm &> /dev/null
      git push ssh://git@${pushGitHubHost}.com/${pushGitHubOrg}/${repoName} HEAD:refs/heads/${pushCommitBranch} --force
      gh api -XPATCH "repos/AOSPK/${repoName}" -f default_branch="${pushCommitBranch}" &> /dev/null
      gh api -XPATCH "repos/AOSPK-Next/${repoName}" -f default_branch="${pushCommitBranch}" &> /dev/null
    fi
  fi
}

pushGerrit() {
  repoName=${repoName} && replaceNameRepo
  pushGerritArgument=${2}
  pushGerritTopic=${3}
  pushGerritBranch="twelve"
  [[ $repoName == official_devices ]] && pushGerritBranch=master
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
    echo -e "${BOL_RED}              Use Project, example: ${BOL_YEL}: push gerrit -p LineageOS lineage-19.0"
    echo -e "${END}"
  else
    [[ ${pushGerritArgument} == -s ]] && pushGerritPush="HEAD:refs/for/${pushGerritBranch}%submit"
    [[ ${pushGerritArgument} == -v ]] && pushGerritPush="HEAD:refs/for/${pushGerritBranch}%l=Verified+1,l=Code-Review+2"
    [[ ${pushGerritArgument} == -c ]] && pushGerritPush="${pushGerritIdCommit}:refs/for/${pushGerritBranch}"
    [[ ${pushGerritArgument} == -n ]] && pushGerritPush="HEAD:refs/for/${pushGerritBranch}"
    if [[ ${pushGerritArgument} == -p ]]; then
      pushGerritProject=${3}
      pushGerritTopic=${4}
      if [[ -n ${pushGerritBranch} ]]; then
        echo -e "${BOL_RED}You need type ${BOL_YEL}branch!"
        sleep 100
        exit 0
      else
        [[ ${3} == LineageOS ]] && pushGerritUrlProject="review.lineageos.org" && pushGerritPush="HEAD:refs/for/${pushGerritBranch}" && pushGerritBranch=${4}
        [[ ${3} == ArrowOS ]] && pushGerritUrlProject="review.arrowos.net" && pushGerritPush="HEAD:refs/for/${pushGerritBranch}" && pushGerritBranch=${4}
        [[ ${3} == PixelExperience ]] && pushGerritUrlProject="gerrit.pixelexperience.org" && pushGerritPush="HEAD:refs/for/${pushGerritBranch}" && pushGerritBranch=${4}
      fi
    fi
    [[ -z ${pushGerritArgument} ]] && pushGerritPush="HEAD:refs/for/${pushGerritBranch}"
    if [[ ! -d .git ]]; then
      echo -e "${BOL_RED}You are not in a .git repository${END}"
    else
      scp -p -P 29418 mamutal91@${pushGerritUrlProject}:hooks/commit-msg $(git rev-parse --git-dir)/hooks/ &> /dev/null
      git commit --amend --no-edit &> /dev/null
      echo -e "\n${BOL_BLU}Pushing to ${BOL_YEL}${pushGerritUrlProject}/${MAG}${repoName}${END} ${YEL}${pushGerritBranch}${END}\n"
      if [[ ${pushGerritTopic} ]]; then
        git push ssh://mamutal91@${pushGerritUrlProject}:29418/${repoName} ${pushGerritPush},topic=${pushGerritTopic}
      else
        git push ssh://mamutal91@${pushGerritUrlProject}:29418/${repoName} ${pushGerritPush}
      fi
    fi
    [[ $repo = manifest ]] && echo ${BOL_RED}Pushing manifest to ORG DEV${END} && git push ssh://git@github.com/AOSPK-Next/manifest HEAD:refs/heads/twelve --force
  fi
}

push (){
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
