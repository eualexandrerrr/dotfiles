#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

getRepoName(){
  repoName=$(pwd | cut -c21-300 | sed "s:/:_:g")
}

pushGitHub() {
  pushGitHubRepo=${repoName}
  pushGitHubArgument=${1}
  pushCommitBranch="twelve"
  pushGitHubOrg="AOSPK-Next"
  if [[ -z ${pushGitHubArgument} ]]; then
    echo -e "${BLU}Usage:\n"
    echo -e "${CYA}  push ${RED}-?${YEL}"
    echo -e "              -f [force commit to AOSPK-Next]"
    echo -e "${END}"
  else
    if echo $pushGitHubRepo | grep xiaomi &> /dev/null; then
      if echo $pushGitHubRepo | grep vendor &> /dev/null; then
        pushGitHubOrg="TheBootloops"
      else
        pushGitHubOrg="AOSPK-Devices"
      fi
      echo -e "\n${BOL_BLU}Pushing to ${BOL_YEL}github.com/${CYA}${pushGitHubOrg}/${MAG}${pushGitHubRepo}${END} ${YEL}${pushCommitBranch}${END}\n"
      git push ssh://git@github.com/${pushGitHubOrg}/${pushGitHubRepo} HEAD:refs/heads/${pushCommitBranch} --force
    else
      echo -e "\n${BOL_BLU}Pushing to ${BOL_YEL}github.com/${CYA}${pushGitHubOrg}/${MAG}${pushGitHubRepo}${END} ${YEL}${pushCommitBranch}${END}\n"
      gh repo create AOSPK/${repo} --public --confirm &> /dev/null
      gh repo create AOSPK-Next/${repo} --private --confirm &> /dev/null
      git push ssh://git@${githost}.com/${org}/${repo} HEAD:refs/heads/${branch} --force
      gh api -XPATCH "repos/AOSPK/${repo}" -f default_branch="${branch}" &> /dev/null
      gh api -XPATCH "repos/AOSPK-Next/${repo}" -f default_branch="${branch}" &> /dev/null
    fi
  fi
}

pushGerrit() {
  pushGerritRepo=${repoName}
  pushGerritArgument=${2}
  pushGerritProject=${3}
  pushGerritBranch="twelve"
  pushGerritUrlProject="gerrit.aospk.org"
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
    [[ ${pushGerritArgument} == -c ]] && pushGerritPush="${3}:refs/for/${pushGerritBranch}" && topic=${4}
    [[ ${pushGerritArgument} == -n ]] && pushGerritPush="HEAD:refs/for/${pushGerritBranch}"
    if [[ ${pushGerritArgument} == -p ]]; then
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
      echo -e "\n${BOL_BLU}Pushing to ${BOL_YEL}${pushGerritUrlProject}/${MAG}${pushGerritRepo}${END} ${YEL}${pushGerritBranch}${END}\n"
      scp -p -P 29418 mamutal91@${pushGerritUrlProject}:hooks/commit-msg $(git rev-parse --git-dir)/hooks/ &> /dev/null
      git commit --amend --no-edit &> /dev/null
      if [[ ${pushGerritTopic} ]]; then
        git push ssh://mamutal91@${pushGerritUrlProject}:29418/${pushGerritRepo} ${pushGerritPush},topic=${pushGerritTopic}
      else
        git push ssh://mamutal91@${pushGerritUrlProject}:29418/${pushGerritRepo} ${pushGerritPush}
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
