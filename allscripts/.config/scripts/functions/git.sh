#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

myGitUserFull="Alexandre Rangel <mamutal91@gmail.com>"
myGitUser="mamutal91"

githost=github

getRepo() {
  repo=$(cat .git/config | grep url | cut -d "/" -f5)
}

mc() {
  if echo $PWD | grep "/mnt/nvme/Kraken" &> /dev/null; then
    lastCommit=$(git log --format="%H" -n 1)
    for i in $(git diff-tree --no-commit-id --name-only -r $lastCommit); do
      cat ${i} | grep 'ARROW\|arrow\|ARROW_\|com.arrow' ${i} &> /dev/null
      if [[ $? -eq 0 ]]; then
        echo -e "${BOL_GRE}\nChanges:${END}"
        haveArrowString=true
        echo -e "${BOL_RED}  * DETECTED:    ${i}${END}"
        ag --color-line-number=30 -i arrow ${i}
        echo
      fi
    done
    [[ $haveArrowString == true ]] && echo -e "\n${BOL_MAG}-----------------------------------------\n"
  fi
}

mmc() {
  echo -e "${BOL_GRE}Changes:${END}"
  lastComcit=$(git log --format="%H" -n 1)

  for i in $(find -L . | cut -c3-300); do
    check=$(echo ${i} | cut -c-2)
    if [[ $check == "./" ]]; then
      continue
    else
      if [[ -d ${i} ]]; then
        # is a directory
        continue
      else
        cat ${i} | grep 'ARROW\|arrow\|ARROW_\|com.arrow' ${i} &> /dev/null
        if [[ $? -eq 0 ]]; then
          echo -e "${BOL_RED}\n  * DETECTED:    ${i}${END}"
          ag --color-line-number=30 -i arrow ${i}
          echo
        else
          echo -e "${BOL_GRE} No detected - ${BOL_CYA}${i}${END}"
        fi
      fi
    fi
  done
  echo -e "\n${BOL_RED}-----------------------------------------\n"
}

gitBlacklist() {
  [[ $repo == manifest ]] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && export noPush=true
  [[ $repo == official_devices ]] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && export noPush=true
}

gitRules() {
  [[ $repo == .dotfiles ]] && dot && exit
  [[ $repo == docker-files ]] && dockerfiles && exit
  [[ $repo == shellscript-atom-snippets ]] && export ATOM_ACCESS_TOKEN=${atomToken} && apm publish minor && sleep 5 && apm update mamutal91-shellscript-snippets-atom --no-confirm
  [[ $repo == mytokens ]] && cp -rf $HOME/GitHub/mytokens $HOME/.mytokens &> /dev/null

  [[ $repo == build_make ]] && repo=build

  [[ $repo == hardware_xiaomi ]] && org=AOSPK-Devices && orgBase=ArrowOS-Devices
  [[ $repo == hardware_motorola ]] && org=AOSPK-Devices && orgBase=ArrowOS-Devices
  [[ $repo == hardware_oneplus ]] && org=AOSPK-Devices && orgBase=ArrowOS-Devices

  [[ $repo == device_xiaomi_lmi ]] && org=AOSPK-Devices
  [[ $repo == device_xiaomi_sm8250-common ]] && org=AOSPK-Devices
  [[ $repo == kernel_xiaomi_sm8250 ]] && org=AOSPK-Devices
  [[ $repo == vendor_xiaomi_lmi ]] && org=TheBootloops
  [[ $repo == vendor_xiaomi_sm8250-common ]] && org=TheBootloops

  [[ $repo == hardware_qcom_wlan ]] && branchBase="${branchBase}-caf" && branch="${branch}-caf"
  [[ $repo == hardware_qcom_bt ]] && branchBase="${branchBase}-caf" && branch="${branch}-caf"
  [[ $repo == hardware_qcom_bootctrl ]] && branchBase="${branchBase}-caf" && branch="${branch}-caf"

  [[ $repo == vendor_gapps ]] && githost=gitlab && org=AOSPK
}

st()  {
  git status
  mc
}

f() {
  getRepo
  gitRules
  if [[ -z ${1} ]]; then
    repo=$(echo $repo | sed "s:/:_:g")
    repo=$(echo $repo | sed -e "s/custom/arrow/g")
    repo=$(echo $repo | sed -e "s/Custom/Arrow/g")
    repo=$(echo $repo | sed -e "s/vendor_aosp/vendor_custom/g")
    git fetch https://github.com/ArrowOS/android_${repo} arrow-12.0
  else
    org=$(echo ${1} | cut -c1-5)
    if [[ $org == AOSPK ]]; then
      git fetch ssh://git@github.com/${1} ${2}
    else
      git fetch https://${githost}.com/${1} ${2}
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
    mc
  fi
}

add() {
  git add .
}

pc() {
  if git status | grep cherry-pick; then
    git add .
    git cherry-pick --continue
  else
    if git status | grep rebase; then
      git add .
      git commit --amend
      git rebase --continue
    fi
  fi
  return 0
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
  case $(basename "$(pwd)") in
    aosp | vendor_aosp)
      git add .
      git reset build/tools/roomservice.py
      ;;
    *)
      git add .
      ;;
  esac
}

gitpush() {
  gitBlacklist
  if echo $PWD | grep "/mnt/nvme/Kraken" &> /dev/null; then
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
  author=$(echo ${1} | awk '{ print $1 }' | cut -c1)
  if [[ ! -d .git ]]; then
    echo -e "${BOL_RED}You are not in a .git repository \n${YEL} # $PWD${END}"
    return 0
  else
    if [[ ${author} == "'" ]]; then
      gitadd && git commit --amend --date "$(date)" --author "${1}"
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
    echo -e "${BOL_RED}              Use Project, example: ${BOL_YEL}: push gerrit -p ArrowOS arrow-12.0 topic"
    echo -e "${END}"
    exit 1
  }

  githost=github
  org=AOSPK-Next
  gerrit=gerrit.aospk.org
  branch=twelve

  getRepo
  gitRules
  gitBlacklist

  pushGitHub() {
    if [[ ! -d .git ]]; then
      echo -e "${BOL_RED}You are not in a .git repository \n${YEL} # $PWD${END}"
      return 0
    else
      echo -e " ${BOL_BLU}\nPushing to ${BOL_YEL}${org}/${MAG}${repo}${END}\n"
      echo -e " ${MAG}PROJECT : ${YEL}$org"
      echo -e " ${MAG}REPO    : ${BLU}$repo"
      echo -e " ${MAG}BRANCH  : ${CYA}$branch${END}\n"

      git push ssh://git@${githost}.com/${org}/${repo} HEAD:refs/heads/${branch} --force
      gh api -XPATCH "repos/${org}/${repo}" -f default_branch="${branch}" &> /dev/null

      argMain=${2}
      if [[ $argMain == main ]]; then
        echo -e " ${BOL_BLU}\nPushing to ${BOL_YEL}AOSPK/${MAG}${repo}${END}\n"
        git push ssh://git@${githost}.com/AOSPK/${repo} HEAD:refs/heads/${branch} --force
        gh api -XPATCH "repos/AOSPK/${repo}" -f default_branch="${branch}" &> /dev/null
      fi
    fi
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
        pushGitHub ${1} ${2}
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
        if [[ -n $topicGerrit   ]]; then
          argsGerrit=$(echo $argsGerrit,topic=$topicGerrit)
        fi
        git push ssh://${myGitUser}@${gerrit}:29418/${repo} ${optHead}:refs/for/${branch}%${argsGerrit}
      fi
    fi
  fi
}

#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

upstream() {
  workingDir=$(mktemp -d) && cd $workingDir

  repo=${1}

  orgBaseName=ArrowOS
  orgBase=ArrowOS/android_
  branchBase=${2}
  branch=${3}
  org=AOSPK
  githost=github

  if [[ ${4} == "pe" ]]; then
    orgBaseName=PixelExperience
    orgBase=PixelExperience/
    branchBase=twelve
  fi

  if [[ ${4} == "los" ]]; then
    orgBaseName=LineageOS
    orgBase=LineageOS/android_
    branchBase=lineage-19.0
  fi

  if [[ ${4} == "aosp" ]]; then
    echo "${BOL_RED}Forget everything above, I'm cloning it is straight from AOSP${END}"
    repoAOSP=$(echo $repo | sed "s/_/\//g")
    [[ $repoAOSP == hardware/libhardware/legacy ]] && repoAOSP="hardware/libhardware_legacy"
    tagAOSP=android-12.0.0_r13
    echo -e "${BOL_RED}\n### ${BOL_YEL} ${tagAOSP}\n${END}"
    git clone https://android.googlesource.com/platform/${repoAOSP} -b ${tagAOSP} ${repo} &> /dev/null
  else
    echo -e "\n${BOL_BLU}Cloning ${BOL_MAG}${orgBaseName}/${BOL_RED}${repo} ${BOL_BLU}branch ${BOL_YEL}${branchBase}"
    git clone https://github.com/${orgBase}${repo} -b ${branchBase} ${repo} --single-branch
  fi
  cd ${repo}
  repo=$(echo $repo | sed -e "s/arrow/custom/g")
  repo=$(echo $repo | sed -e "s/Arrow/Custom/g")
  repo=$(echo $repo | sed -e "s/vendor_custom/vendor_aosp/g")
  gitRules

  if git ls-remote ssh://git@github.com/${org}/${repo} &> /dev/null; then
    echo "${BOL_BLU}* Repo already exist ${CYA}(${org}/${repo})${END}"
  else
    echo "${BOL_YEL}* Creating ${CYA}(AOSPK-Next/${repo})${END}"
    gh repo create ${org}/${repo} --public
  fi

  if git ls-remote ssh://git@github.com/AOSPK-Next/${repo} &> /dev/null; then
    echo "${BOL_BLU}* Repo already exist ${CYA}(AOSPK-Next/${repo})${END}"
  else
    echo "${BOL_YEL}* Creating ${CYA}(AOSPK-Next/${repo})${END}"
    gh repo create AOSPK-Next/${repo} --private
  fi

  git push ssh://git@${githost}.com/${org}/${repo} HEAD:refs/heads/${branch} --force
  git push ssh://git@${githost}.com/AOSPK-Next/${repo} HEAD:refs/heads/${branch} --force
  gh api -XPATCH "repos/${org}/${repo}" -f default_branch="${branch}" &> /dev/null
  gh api -XPATCH "repos/AOSPK-Next/${repo}" -f default_branch="${branch}" &> /dev/null
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
