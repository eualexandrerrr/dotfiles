#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens &> /dev/null

infra() {
  echo -e "\n${BLU}Recloning ${CYA}infra ${BLU}to have the latest changes...${END}"
  ssh mamutal91@86.109.7.111 "cd $HOME && rm -rf /mnt/roms/infra && git clone ssh://git@github.com/AOSPK/infra /mnt/roms/infra" &> /dev/null
}

qemu() {
  $HOME/.config/scripts/qemu.sh ${1}
}

dot() {
  if [[ ${1} ]]; then
    cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc
  else
    echo -e "\n${BLU}Recloning ${CYA}dotfiles ${BLU}to have the latest changes...${END}"
    ssh mamutal91@86.109.7.111 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc" &> /dev/null
    ssh mamutal91@147.75.80.89 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc" &> /dev/null
  fi
}

bkp() {
  bash $HOME/.config/scripts/gitcron.sh ${1}
  ssh mamutal91@86.109.7.111 "bash $HOME/.config/scripts/gitcron.sh"
  ssh mamutal91@147.75.80.89 "bash $HOME/.config/scripts/gitcron.sh"
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
  git cherry-pick ${1}
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
  pwd=$(pwd | cut -c-24)

  blacklist() {
    [ $pwdFolder = manifest ] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && break &> /dev/null
    [ $pwdFolder = official_devices ] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && break &> /dev/null
  }

  if [[ $pwd == /mnt/roms/jobs/KrakenDev ]]; then
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

  [[ $pwdFolder == .dotfiles ]] && dot && exit
  [[ $pwdFolder == infra ]] && infra && exit
  [[ $pwdFolder == shellscript-atom-snippets ]] && export ATOM_ACCESS_TOKEN=${atomToken} && apm publish minor && sleep 5 && apm update mamutal91-shellscript-snippets-atom --no-confirm
  [[ $pwdFolder == mysyntaxtheme ]] && export ATOM_ACCESS_TOKEN=${atomToken} && apm publish minor && sleep 5 && apm update mysyntaxtheme --no-confirm
  [[ $pwdFolder == mytokens ]] && cp -rf $HOME/GitHub/mytokens/.myTokens $HOME &> /dev/null
  [[ $pwdFolder == downloadcenter ]] && www && exit
}

cm() {
  if [[ ! -d .git ]]; then
    echo "${BOL_RED}You are not in a .git repository${END}"
  else
    if [[ $(git status --porcelain) ]]; then
      translate
      if [[ ${1} ]]; then
        gitadd && git commit --message "${msg}" --signoff --date "$(date)" --author "${1}" && gitpush
      else
        gitadd && git commit --message "${msg}" --signoff --date "$(date)" --author "Alexandre Rangel <mamutal91@aospk.org>" && gitpush
      fi
    else
      echo "${BOL_RED}There are no local changes!!! leaving...${END}" && break &> /dev/null
    fi
  fi

}

amend() {
  if [[ ! -d .git ]]; then
    echo "${BOL_RED}You are not in a .git repository${END}"
  else
    if [[ ${1} ]]; then
      gitadd && git commit --amend --date "$(date)" --author "${1}" && gitpush force
    else
      lastAuthorName=$(git log -1 --pretty=format:'%an')
      lastAuthorEmail=$(git log -1 --pretty=format:'%ae')
      gitadd && git commit --amend --date "$(date)" --author "${lastAuthorName} <${lastAuthorEmail}>" && gitpush force
    fi
  fi
}

update() {
  $HOME/.config/scripts/update.sh
}
