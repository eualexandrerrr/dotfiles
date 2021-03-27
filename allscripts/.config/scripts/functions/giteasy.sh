#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

myGitUser="Alexandre Rangel <mamutal91@gmail.com>"

m() {
  echo -e "\n${BOL_MAG}-----------------------------------------\n"
  echo -e "${BOL_GRE}Changes:${END}"
  lastCommit=$(git log --format="%H" -n 1)
  for i in $(git diff-tree --no-commit-id --name-only -r $lastCommit); do
    cat ${i} | grep 'ARROW\|arrow\|ARROW_\|com.arrow' ${i} &> /dev/null
    if [[ $? -eq 0 ]]; then
      echo -e "${BOL_RED}  * DETECTED:    ${i}${END}"
      ag --color-line-number=30 -i ArRoW ${i}
      ag -s arrow ${i}
      echo
    else
      echo -e "${BOL_GRE} No detected - ${BOL_CYA}${i}${END}"
    fi
  done
  echo -e "\n${BOL_MAG}-----------------------------------------\n"
}

mm() {
  echo -e "${BOL_GRE}Changes:${END}"
  lastCommit=$(git log --format="%H" -n 1)

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
          ag --color-line-number=30 -i ArRoW ${i}
          ag -s arrow ${i}
          echo
        else
          echo -e "${BOL_GRE} No detected - ${BOL_CYA}${i}${END}"
        fi
      fi
    fi
  done
  echo -e "\n${BOL_RED}-----------------------------------------\n"
}

gitpushRules() {
  if [[ $USER == mamutal91 ]]; then
    [[ $pwdFolder == .dotfiles ]] && dot && exit
    [[ $pwdFolder == docker-files ]] && dockerfiles && exit
    [[ $pwdFolder == buildersbr ]] && buildersbr && exit
    [[ $pwdFolder == shellscript-atom-snippets ]] && export ATOM_ACCESS_TOKEN=${atomToken} && apm publish minor && sleep 5 && apm update mamutal91-shellscript-snippets-atom --no-confirm
    [[ $pwdFolder == mytokens ]] && cp -rf $HOME/GitHub/mytokens $HOME/.mytokens &> /dev/null
  fi
}

st () {
  git status
  m
}

f() {
  org=$(echo ${1} | cut -c1-5)
  if [[ $org == AOSPK ]]; then
    git fetch ssh://git@github.com/${1} ${2}
  else
    githost=github
    [ ${1} = the-muppets/proprietary_vendor_xiaomi ] && githost=gitlab
    git fetch https://${githost}.com/${1} ${2}
  fi
}

p() {
  argumentPick=${1}
  if [[ ${argumentPick} == "git" ]]; then
    bash $HOME/.dotfiles/allscripts/.config/scripts/functions/cherry-pick.sh ${1} ${2} ${3} ${4}
    m
    breack &> /dev/null
  else
    git cherry-pick ${1}
    m
  fi
}

pc() {
  git add . && git cherry-pick --continue
  m
}

rcontinue() {
  git add . && git rebase --continue
  m
}

ab() {
  git cherry-pick --abort
  git rebase --abort
  m
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
  pwdFolder=${PWD##*/}
  pwd=$(pwd | cut -c-19)

  blacklist() {
    [ $pwdFolder = manifest ] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && break &> /dev/null
    [ $pwdFolder = official_devices ] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && break &> /dev/null
  }

  if [[ $pwd == /mnt/storage/Kraken ]]; then
    echo "\n${BOL_RED}No push!${END}\n"
  else
    if [[ ${1} == force ]]; then
      echo -e "\n${BOL_YEL}Pushing with ${BOL_RED}force!${END}\n"
      blacklist
      git push -f
    else
      echo -e "\n${BOL_YEL}Pushing!${END}\n"
      blacklist
      git push
    fi
  fi
  gitpushRules
}

cm() {
  if [[ ! -d .git ]]; then
    echo -e "${BOL_RED}You are not in a .git repository\n${RED}$(pwd)${END}"
  else
    if [[ $(git status --porcelain) ]]; then
      pwdFolder=${PWD##*/}
      translate
      if [[ ${1} ]]; then
        gitadd && git commit --message "${msg}" --signoff --date "$(date)" --author "${1}" && gitpush
      else
        gitadd && git commit --message "${msg}" --signoff --date "$(date)" --author "${myGitUser}" && gitpush
      fi
    else
      echo "${BOL_RED}There are no local changes!!! leaving...${END}" && break &> /dev/null
    fi
  fi
  m
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
  m
}
