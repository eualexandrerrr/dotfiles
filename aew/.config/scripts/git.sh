#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

myGitUserFull="Alexandre Rangel <mamutal91@gmail.com>"
myGitUser="mamutal91"

githost=github

getRepo() {
  repo=$(cat .git/config | grep url | cut -d "/" -f5)
  repoTest=$(echo $repo | cut -c1-8)
  if [[ $repoTest == "android_" ]]; then
    repo=$(echo $repo | cut -c9-1000)
    echo $repo
  fi
}

mc() {
  if [[ $(echo $PWD | cut -c1-22) == "/home/mamutal91/Kraken" ]]; then

    #        echo -e "\n${GRE}Checking files...${END}"
    #        find . -name "*${i}*" $(printf "! -name %s " $(cat $HOME/.dotfiles/aew/.config/scripts/kraken/ignore_files.txt))

    lastCommit=$(git log --format="%H" -n 1)
    echo -e "${YEL}Checking keywords from commit ${MAG}${lastCommit}${END}\n"
    for i in $(git diff-tree --no-commit-id --name-only -r $lastCommit); do
      roms=(arrow pixelexp awaken statix)
      for keywords in ${roms[@]}; do
        if [[ -f $i ]]; then
          if ag -S $keywords $i &> /dev/null; then
              echo -e "\n${RED}$i${END}"
              ag -S $keywords $i
          fi
        fi
      done
    done
  fi
}

gitBlacklist() {
  #  [[ $repo == manifest ]] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && export noPush=true
  [[ $repo == official_devices ]] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && export noPush=true
}

gitRules() {
  [[ $repo == .dotfiles ]] && dot && exit
  [[ $repo == docker-files ]] && dockerfiles && exit

  if [[ $repo == shellscript-atom-snippets ]]; then
    source $HOME/.myTokens/tokens.sh
    export ATOM_ACCESS_TOKEN=${atomToken}
    echo $ATOM_ACCESS_TOKEN
    apm publish minor
    sleep 5
    apm update mamutal91-shellscript-snippets-atom --no-confirm
  fi

  [[ $repo == official_devices ]] && branch=master

  [[ $repo == build_make ]] && repo=build
  [[ $repo == packages_apps_Updates ]] && repo=packages_apps_Updater

  [[ $repo == hardware_xiaomi ]] && org=AOSPK-Devices && orgBase=ArrowOS-Devices
  [[ $repo == hardware_motorola ]] && org=AOSPK-Devices && orgBase=ArrowOS-Devices
  [[ $repo == hardware_oneplus ]] && org=AOSPK-Devices && orgBase=ArrowOS-Devices
  [[ $repo == device_xiaomi_extras ]] && org=AOSPK-Devices && branch=twelve

  [[ $repo == device_xiaomi_lmi ]] && org=AOSPK-Devices && branch=twelve
  [[ $repo == device_xiaomi_sm8250-common ]] && org=AOSPK-Devices && branch=twelve
  [[ $repo == kernel_xiaomi_sm8250 ]] && org=AOSPK-Devices && branch=twelve
  [[ $repo == kernel_xiaomi_lmi ]] && org=AOSPK-Devices && branch=twelve
  [[ $repo == vendor_xiaomi_lmi ]] && org=TheBootloops && branch=twelve
  [[ $repo == vendor_xiaomi_sm8250-common ]] && org=TheBootloops && branch=twelve

  [[ $repo == vendor_gapps ]] && githost=gitlab && org=AOSPK-Next
}

gitLastCommitURL() {
  if [[ $(echo $PWD | cut -c1-22) == "/home/mamutal91/Kraken" ]]; then
    if [[ $githost == "github" ]]; then
      echo -e "\n 🔗 ${GRE}Commit\n ${BLU}https://github.com/${org}/${repo}/commit/$(git log --format="%H" -n 1)${END}\n"
    else
      echo -e "\n 🔗 ${GRE}Commit\n ${BLU}https://gitlab.com/$org/${repo}/-/commit/$(git log --format="%H" -n 1)${END}\n"
    fi
  else
    userGit=$(cat .git/config | grep url | cut -d "/" -f4)
    echo -e "\n 🔗 ${GRE}Commit\n ${BLU}https://github.com/${userGit}/${repo}/commit/$(git log --format="%H" -n 1)${END}\n"
  fi
}

cl() {
  git log -1
}

st() {
  git status
  mc
}

f() {
  getRepo
  gitRules
  [[ $repo == "vendor_aosp" ]] && repo=vendor_arrow
  if [[ -z ${1} ]]; then
    if [[ $repo == "kernel_xiaomi_sm8250" ]]; then
      git fetch https://github.com/Official-Ayrton990/android_kernel_xiaomi_sm8250 upstreamed-common
    elif [[ $repo == "vendor_gapps" ]]; then
      git fetch https://gitlab.com/PixelExperience/vendor_gapps twelve
    else
      git fetch https://github.com/ArrowOS/android_${repo} arrow-12.1
    fi
  else
    org=$(echo ${1} | cut -c1-5)
    if [[ $org == AOSPK ]]; then
      git fetch ssh://git@github.com/${1} ${2}
    else
      git fetch https://github.com/${1} ${2}
    fi
  fi
}

p() {
  argumentPick=${1}
  if [[ ${argumentPick} == "git" ]]; then
    git fetch ${3} ${4}
    git cherry-pick FETCH_HEAD
    mc
    return 1
  else
    git cherry-pick ${1}
    if [ $? -eq 0 ]; then
      echo -e "\n${BOL_GRE}Cherry-pick success${END}"
    else
      git cherry-pick -m 1 ${1}
      echo -e "\n${BOL_RED}Merge cherry-pick${END}"
    fi
    mc
    echo -e "\n${MAG}Last commit name:"
    git log --oneline -n 1
  fi
}

pp() {
  clear
  f
  git cherry-pick -m 1 ${1}
  git add . && git commit --amend --author "${myGitUserFull}" --no-edit
  push -f
}

add() {
  git add .
}

pc() {
  if git status | grep cherry-pick; then
    git add .
    git cherry-pick --continue
    mc
  else
    if git status | grep rebase; then
      git add .
      git commit --amend
      git rebase --continue
      mc
    fi
  fi
  mc
}

ab() {
  if git status | grep cherry-pick; then
    git cherry-pick --abort
  else
    if git status | grep rebase; then
      git rebase --abort
    fi
  fi
  return 0
  mc
}

translate() {
  typing=$(mktemp)
  rm -rf $typing && nano $typing
  msg=$(trans -b :en -no-auto -i $typing)
  typing=$(cat $typing)
  echo -e "\n${BOL_RED}Message: ${YEL}${msg}${END}\n"
}

gitadd() {
  git add .
}

gitpush() {
  gitBlacklist
  if echo $PWD | grep "$HOME/Kraken" &> /dev/null; then
    echo "\n${BOL_RED}No push!${END}\n"
  else
    if [[ ${1} == force ]]; then
      [[ $noPush == true ]] && return 0
      echo -e "\n${BOL_YEL}Pushing with ${BOL_RED}force!${END}\n"
      git push -f
    else
      [[ $noPush == true ]] && return 0
      echo -e "\n${BOL_YEL}Pushing!${END}\n"
      git push
    fi
  fi
  gitRules
}

cm() {
  if [[ ! -d .git ]]; then
    echo -e "${BOL_RED}You are not in a .git repository \n${YEL} # $PWD${END}"
    return 0
  else
    if [[ $(git status --porcelain) ]]; then
      repo=${PWD##*/}
      translate
      if [[ ${1} ]]; then
        gitadd && git commit --message "${msg}" --signoff --date "$(date)" --author "${1}" && gitpush
      else
        gitadd && git commit --message "${msg}" --signoff --date "$(date)" --author "${myGitUserFull}" && gitpush
      fi
    else
      echo "${BOL_RED}There are no local changes!!! leaving...${END}" && break &> /dev/null
    fi
  fi
  mc
}

amend() {
  getRepo
  if [[ ! -d .git ]]; then
    echo -e "${BOL_RED}You are not in a .git repository \n${YEL} # $PWD${END}"
    return 0
  else
    if [[ ${1} ]]; then
      gitadd && git commit --amend --date "$(date)" --author "${1} ${2} ${3}"
      gitpush force
    else
      lastAuthorName=$(git log -1 --pretty=format:'%an')
      lastAuthorEmail=$(git log -1 --pretty=format:'%ae')
      gitadd && git commit --amend --date "$(date)" --author "${lastAuthorName} <${lastAuthorEmail}>"
      gitpush force
    fi
  fi
  mc
}

push() {
  usage() {
    echo -e "${BLU}Usage:\n"
    echo -e "${CYA}  push gerrit ${RED}-?${END} ${GRE}<topic>${END}${YEL}"
    echo -e "              -s [Submit automatic]"
    echo -e "              -v [Verified]"
    echo -e "              -c [Specific SHA ID commit]"
    echo -e "              -n [Nothin]"
    echo -e "              -p [Specifc project]"
    echo -e "              -f [AOSPK-Next]"
    echo -e "${BOL_RED}              Use Project, example: ${BOL_YEL}: push gerrit -p LineageOS lineage-19.1 topic"
    echo -e "${END}"
    exit 1
  }

  export githost=github
  export org=AOSPK-Next
  export gerrit=gerrit.aospk.org
  export branch=twelve

  getRepo
  gitRules
  gitBlacklist

  pushGit() {
    if [[ ! -d .git ]]; then
      echo -e "${BOL_RED}You are not in a .git repository \n${YEL} # $PWD${END}"
      return 0
    else
      echo -e " ${BOL_BLU}\n 🆙 Pushing...${END}\n"
      echo -e " ${MAG}PROJECT : ${YEL}$org"
      echo -e " ${MAG}REPO    : ${GRE}$repo"
      echo -e " ${MAG}BRANCH  : ${CYA}${branch}${END}"
      if [[ ${githost} == "github" ]]; then
        echo -e " ${MAG}HOST    : ${BLU}${githost}.com${END}"
        echo -e " ${MAG}LINK    : ${BLU}https://github.com/${org}/${repo}/commits/${branch}${END}\n"
      else
        echo -e " ${MAG}HOST    : ${RED}${githost}.com${END}"
        echo -e " ${MAG}LINK    : ${BLU}https://gitlab.com/${org}/${repo}/-/commits/${branch}${END}\n"
      fi

      git push ssh://git@${githost}.com/${org}/${repo} HEAD:refs/heads/${branch} --force
      gh api -XPATCH "repos/${org}/${repo}" -f default_branch="${branch}" &> /dev/null # BRANCH DEFAUL
      [[ $repo == device_xiaomi_lmi ]] && git push ssh://git@github.com/AOSPK-Devices/device_xiaomi_lmi HEAD:refs/heads/twelve --force

      argMain=${2}

      if [[ $argMain == main ]]; then
        echo -e " ${BOL_BLU}\n ⛔ Pushing to ${BOL_RED}main org${END} ${BOL_YEL}AOSPK/${BOL_GRE}${repo}${END}\n"
        git push ssh://git@${githost}.com/AOSPK/${repo} HEAD:refs/heads/${branch} --force
        gh api -XPATCH "repos/AOSPK/${repo}" -f default_branch="${branch}" &> /dev/null
      fi
    fi
    gitLastCommitURL
  }

  while getopts "svnc:t:fp:" option; do
    case ${option} in
      s)
        argsGerrit="submit,l=Verified+1,l=Code-Review+2"
        ;;
      v)
        argsGerrit="l=Verified+1,l=Code-Review+2"
        ;;
      n)
        argsGerrit=""
        ;;
      c)
        iDcommit=$OPTARG
        ;;
      t)
        topicGerrit=$OPTARG
        ;;
      f)
        pushGit ${1} ${2}
        return 0
        ;;
      p)
        projectGerrit=$OPTARG
        ;;
      \?) # For invalid option
        usage
        ;;
    esac
  done

  if [[ -z ${1} && -d .git ]]; then
    usage
  else
    if [[ ! -d .git ]]; then
      echo -e "${BOL_RED}You are not in a .git repository \n${YEL} # $PWD${END}"
      return 0
    else
      echo -e " ${BOL_BLU}\nPushing to ${BOL_YEL}${gerrit}/${MAG}${repo}${END}\n"
      echo -e " ${MAG}PROJECT : ${YEL}$gerrit"
      echo -e " ${MAG}REPO    : ${BLU}$repo"
      echo -e " ${MAG}BRANCH  : ${CYA}$branch"
      gh api -XPATCH "repos/${org}/${repo}" -f default_branch="${branch}" &> /dev/null # BRANCH DEFAUL
      [[ -n $iDcommit ]] && echo -e " ${MAG}COMMIT  : ${RED}${iDcommit}${END}"
      [[ -n $topicGerrit ]] && echo -e " ${MAG}TOPIC   : ${RED}${topicGerrit}${END}\n" || echo -e " ${MAG}TOPIC   : ${RED}null${END}"

      gitdir=$(git rev-parse --git-dir)
      scp -p -P 29418 ${myGitUser}@${gerrit}:hooks/commit-msg ${gitdir}/hooks/ &> /dev/null
      git commit --amend --no-edit &> /dev/null

      [[ -z $iDcommit ]] && optHead=HEAD || optHead=$iDcommit

      if [[ -z $argsGerrit ]]; then
        if [[ -z $topicGerrit ]]; then
          git push ssh://${myGitUser}@${gerrit}:29418/${repo} ${optHead}:refs/for/${branch}
        else
          git push ssh://${myGitUser}@${gerrit}:29418/${repo} ${optHead}:refs/for/${branch}%topic=$topicGerrit
        fi
      else
        if [[ -n $topicGerrit ]]; then
          argsGerrit=$(echo $argsGerrit,topic=$topicGerrit)
        fi
        git push ssh://${myGitUser}@${gerrit}:29418/${repo} ${optHead}:refs/for/${branch}%${argsGerrit}
      fi
    fi
  fi
}

upstream() {
  workingDir=$(mktemp -d) && cd $workingDir

  orgBaseName=ArrowOS
  orgBase=ArrowOS/android_

  repo=${1}
  branchBase=${2}
  branch=${3}
  org=AOSPK
  githost=github

  if [[ ${4} == "main" ]]; then
    orgBaseName=AOSPK-Next
    orgBase=AOSPK-Next/
    branchBase=twelve
  fi

  if [[ ${4} == "pe" ]]; then
    orgBaseName=PixelExperience
    orgBase=PixelExperience/
    branchBase=twelve
  fi

  if [[ ${4} == "los" ]]; then
    orgBaseName=LineageOS
    orgBase=LineageOS/android_
    branchBase=lineage-19.1
  fi

  if [[ ${4} == "aosp" ]]; then
    echo "${BOL_RED}Forget everything above, I'm cloning it is straight from AOSP${END}"
    repoAOSP=$(echo $repo | sed "s/_/\//g")
    [[ $repoAOSP == hardware/libhardware/legacy ]] && repoAOSP="hardware/libhardware_legacy"
    tagAOSP=$(grep "default revision" $HOME/manifest/default.xml | tr -d '"' | cut -c31-100)
    echo -e "${BOL_RED}\n### ${BOL_YEL} ${tagAOSP}\n${END}"
    git clone https://android.googlesource.com/platform/${repoAOSP} -b ${tagAOSP} ${repo}
  else
    echo -e "\n${BOL_BLU}Cloning ${BOL_MAG}${orgBaseName}/${BOL_RED}${repo} ${BOL_BLU}branch ${BOL_YEL}${branchBase}${END}\n"
    git clone https://github.com/${orgBase}${repo} -b ${branchBase} ${repo} --single-branch
  fi
  cd ${repo}
  gitRules

  mainOrg() {
    if git ls-remote ssh://git@github.com/${org}/${repo} &> /dev/null; then
      echo "${BOL_BLU}* Repo already exist ${CYA}(${org}/${repo})${END}"
    else
      echo "${BOL_YEL}* Creating ${CYA}(AOSPK-Next/${repo})${END}"
      gh repo create ${org}/${repo} --public
    fi
    git push ssh://git@${githost}.com/${org}/${repo} HEAD:refs/heads/${branch} --force
    gh api -XPATCH "repos/${org}/${repo}" -f default_branch="${branch}" &> /dev/null
  }

  nextOrg() {
    if git ls-remote ssh://git@github.com/AOSPK-Next/${repo} &> /dev/null; then
      echo "${BOL_BLU}* Repo already exist ${CYA}(AOSPK-Next/${repo})${END}"
    else
      echo "${BOL_YEL}* Creating ${CYA}(AOSPK-Next/${repo})${END}"
      gh repo create AOSPK-Next/${repo} --private
    fi
    git push ssh://git@${githost}.com/AOSPK-Next/${repo} HEAD:refs/heads/${branch} --force
    gh api -XPATCH "repos/AOSPK-Next/${repo}" -f default_branch="${branch}" &> /dev/null
  }

  #mainOrg
  nextOrg

  rm -rf $workingDir
}

up() {
  upstream ${1} arrow-12.1 twelve ${2}
}

hals() {
  pwd=$(pwd)
  branch=(
    msm8996
    msm8998
    sdm660
    sdm845
    sm8150
    sm8250
    sm8350
  )
  for i in "${branch[@]}"; do
    $HOME/.dotfiles/aew/.config/scripts/kraken/hal/hal.sh ${i}
  done
  cd $pwd
}
