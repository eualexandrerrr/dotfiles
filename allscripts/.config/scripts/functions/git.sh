#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

myGitUserFull="Alexandre Rangel <mamutal91@gmail.com>"
myGitUser="mamutal91"

getRepo() {
  repoCheck=$(pwd | cut -c-20)

  if [[ $repoCheck == "/home/mamutal91/GitH" ]]; then
    repo=$(pwd | cut -c24-300 | sed "s:/:_:g")
  elif [[ $repoCheck == "/mnt/storage/Kraken/" ]]; then
    repo=$(pwd | cut -c21-300 | sed "s:/:_:g")
  elif [[ $repoCheck == "/mnt/roms/Jobs/KrakenD" ]]; then
    repo=$(pwd | cut -c24-300 | sed "s:/:_:g")
  else
    repo=$(pwd | cut -c17-300 | sed "s:/:_:g")
  fi
}

mc() {
  lastCommit=$(git log --format="%H" -n 1)
  for i in $(git diff-tree --no-commit-id --name-only -r $lastCommit); do
    cat ${i} | grep 'ARROW\|arrow\|ARROW_\|com.arrow' ${i} &> /dev/null
    if [[ $? -eq 0 ]]; then
      echo -e "${BOL_GRE}Changes:${END}"
      haveArrowString=true
      echo -e "${BOL_RED}  * DETECTED:    ${i}${END}"
      ag --color-line-number=30 -i arrow ${i}
      sed -i "s/.arrow./.kraken./" ${i}
      sed -i "s/ArrowUtils/KrakenUtils/" ${i}
      sed -i "s/ARROW/KRAKEN/" ${i}
      echo
    fi
  done
  [[ $haveArrowString == true ]] && echo -e "\n${BOL_MAG}-----------------------------------------\n"
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

gitRules() {
  [[ $repo == .dotfiles ]] && dot && exit
  [[ $repo == docker-files ]] && dockerfiles && exit
  [[ $repo == buildersbr ]] && buildersbr && exit
  [[ $repo == shellscript-atom-snippets ]] && export ATOM_ACCESS_TOKEN=${atomToken} && apm publish minor && sleep 5 && apm update mamutal91-shellscript-snippets-atom --no-confirm
  [[ $repo == mytokens ]] && cp -rf $HOME/GitHub/mytokens $HOME/.mytokens &> /dev/null
}

gitBlacklist() {
  [[ $repo == manifest ]] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && break &> /dev/null
  [[ $repo == official_devices ]] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && break &> /dev/null
}

st()  {
  git status
  mc
}

f() {
  if [[ -z ${1} ]]; then
    repo=$(pwd | cut -c21-300)
    repo=$(echo $repo | sed "s:/:_:g")
    git fetch https://github.com/ArrowOS/android_${repo} arrow-12.0
  else
    org=$(echo ${1} | cut -c1-5)
    if [[ $org == AOSPK ]]; then
      git fetch ssh://git@github.com/${1} ${2}
    else
      gitHost=github
      [ ${1} = the-muppets/proprietary_vendor_xiaomi ] && gitHost=gitlab
      git fetch https://${gitHost}.com/${1} ${2}
    fi
  fi
}

p() {
  argumentPick=${1}
  if [[ ${argumentPick} == "git" ]]; then
    bash $HOME/.dotfiles/allscripts/.config/scripts/functions/cherry-pick.sh ${1} ${2} ${3} ${4}
    mc
    breack &> /dev/null
  else
    git cherry-pick ${1}
    mc
  fi
}

pc() {
  git add . && git cherry-pick --continue
  mc
}

rcontinue() {
  git add . && git rebase --continue
  mc
}

ab() {
  git cherry-pick --abort
  git rebase --abort
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
  repo=${PWD##*/}
  pwd=$(pwd | cut -c-19)

  if [[ $pwd == /mnt/storage/Kraken ]]; then
    echo "\n${BOL_RED}No push!${END}\n"
  else
    if [[ ${1} == force ]]; then
      echo -e "\n${BOL_YEL}Pushing with ${BOL_RED}force!${END}\n"
      gitBlacklist
      git push -f
    else
      echo -e "\n${BOL_YEL}Pushing!${END}\n"
      gitBlacklist
      git push
    fi
  fi
  gitRules
}

cm() {
  if [[ ! -d .git ]]; then
    echo -e "${BOL_RED}You are not in a .git repository\n${RED}$(pwd)${END}"
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
  author=$(echo ${1} | awk '{ print $1 }' | cut -c1)
  if [[ ! -d .git ]]; then
    echo "${BOL_RED}You are not in a .git repository${END}"
  else
    if [[ ${author} == "'" ]]; then
      gitadd && git commit --amend --date "$(date)" --author "${1}" && gitpush force
    else
      lastAuthorName=$(git log -1 --pretty=format:'%an')
      lastAuthorEmail=$(git log -1 --pretty=format:'%ae')
      gitadd && git commit --amend --date "$(date)" --author "${lastAuthorName} <${lastAuthorEmail}>" && gitpush force
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
    echo -e "${BOL_RED}              Use Project, example: ${BOL_YEL}: push gerrit -p ArrowOS arrow-12.0 topic"
    echo -e "${END}"
    exit 1
  }

  gitHost=github
  org=AOSPK-Next
  gerrit=gerrit.aospk.org
  branch=twelve

  getRepo
  gitRules

  pushGitHub() {
    if [[ ! -d .git ]]; then
      echo -e "${BOL_RED}You are not in a .git repository: ${YEL}$(pwd)${END}\n"
    else
      echo -e " ${BOL_BLU}\nPushing to ${BOL_YEL}${org}/${MAG}${repo}${END}\n"
      echo -e " ${MAG}PROJECT : ${YEL}$org"
      echo -e " ${MAG}REPO    : ${BLU}$repo"
      echo -e " ${MAG}BRANCH  : ${CYA}$branch${END}\n"

      [[ $repo == vendor_gapps ]] && gitHost=gitlab

      gh repo create ${org}/${repo} --private --confirm &> /dev/null
      git push ssh://git@${gitHost}.com/${org}/${repo} HEAD:refs/heads/${branch} --force
      gh api -XPATCH "repos/${org}/${repo}" -f default_branch="${branch}" &> /dev/null

      if [[ ${2} == main ]]; then
        echo -e " ${BOL_BLU}\nPushing to ${BOL_YEL}AOSPK/${MAG}${repo}${END}\n"
        gh repo create AOSPK/${repo} --public --confirm &> /dev/null
        git push ssh://git@github.com/AOSPK/${repo} HEAD:refs/heads/${branch} --force
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

  if [[ -z ${1} && -d .git ]] ; then
    usage
  else
    if [[ ! -d .git ]]; then
      echo -e "${BOL_RED}You are not in a .git repository: ${YEL}$(pwd)${END}\n"
    else

    echo -e " ${BOL_BLU}\nPushing to ${BOL_YEL}${gerrit}/${MAG}${repo}${END}\n"
    echo -e " ${MAG}PROJECT : ${YEL}$gerrit"
    echo -e " ${MAG}REPO    : ${BLU}$repo"
    echo -e " ${MAG}BRANCH  : ${CYA}$branch"
    [[ ! -z $iDcommit ]] && echo -e " ${MAG}COMMIT  : ${RED}${iDcommit}${END}"
    [[ ! -z $topicGerrit ]] && echo -e " ${MAG}TOPIC   : ${RED}${topicGerrit}${END}\n" || echo -e " ${MAG}TOPIC   : ${RED}null${END}"

    gitdir=$(git rev-parse --git-dir); scp -p -P 29418 ${myGitUser}@${gerrit}:hooks/commit-msg ${gitdir}/hooks/ &> /dev/null
    git commit --amend --no-edit &> /dev/null

      [[ -z $iDcommit ]] && optHead=HEAD || optHead=$iDcommit

      if [[ -z $argsGerrit ]]; then
        if [[ -z $topicGerrit ]]; then
          git push ssh://${myGitUser}@${gerrit}:29418/${repo} ${optHead}:refs/for/${branch}
        else
          git push ssh://${myGitUser}@${gerrit}:29418/${repo} ${optHead}:refs/for/${branch}%topic=$topicGerrit
        fi
      else
        if [[ ! -z $topicGerrit ]]; then
          argsGerrit=$(echo $argsGerrit,topic=$topicGerrit)
        fi
        git push ssh://${myGitUser}@${gerrit}:29418/${repo} ${optHead}:refs/for/${branch}%${argsGerrit}
      fi
    fi
  fi
}
