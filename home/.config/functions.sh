#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

function dot() {
  if [[ ${1} ]]; then
    cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc
  else
    ssh mamutal91@86.109.7.111 "cd $HOME && rm -rf /mnt/roms/infra && git clone ssh://git@github.com/AOSPK/infra /mnt/roms/infra"
    ssh mamutal91@86.109.7.111 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc"
    ssh mamutal91@147.75.80.89 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc"
    source $HOME/.zshrc
  fi
}

function changelog() {
  # Git config
  git config --global user.email "krakengerrit@gmail.com"
  git config --global user.name "Kraken Project Bot"

  cd $HOME/AOSPK/official_devices
  date=$(cat -n $HOME/AOSPK/official_devices/changelogs/changelog.md | grep -n ^ | grep ^3 | awk '{print $4}')

  git add . && git commit --message "[KRAKEN-CI]: Changelog (eleven) #${date}" --author "Kraken Project Bot <krakengerrit@gmail.com>" && git push
  git config --global user.email "mamutal91@gmail.com"
  git config --global user.name "Alexandre Rangel"
}

function fetch() {
  $HOME/.config/scripts/fetch.sh gnu
}

function f() {
  git fetch https://github.com/${1} ${2}
}

function p() {
  git cherry-pick ${1}
}

function translate() {
  typing=$(mktemp)
  rm -rf $typing && nano $typing
  msg=$(trans -b :en -no-auto -i $typing)
  typing=$(cat $typing)
  echo -e "${BOL_RED}Message commit:\n${BOL_YEL}${msg}${END}"
}

function gitpush() {
  pwdFolder=${PWD##*/}
  pwd=$(pwd | cut -c-24)

  blacklist(){
    [ $pwdFolder = manifest ] && echo "${BOL_RED}Blacklist detected, no push!!!${END}" && break &>/dev/null
  }

  if [[ $pwd = "/mnt/roms/jobs/KrakenDev" ]]; then
    echo "${BOL_RED}No push!${END}"
  else
    if [[ ${1} = force ]]; then
      echo "${BOL_YEL}Pushing with --force!${END}"
      blacklist
      git push -f
    else
      echo "${BOL_YEL}Pushing!${END}"
      blacklist
      git push
    fi
  fi

  [ $pwdFolder = .dotfiles ] && echo "${BOL_BLU}Cloning dotfiles and infra in servers...${END}" && dot && exit
  [ $pwdFolder = infra ] && echo "${BOL_BLU}Cloning dotfiles and infra in servers...${END}" && dot && exit
}

function cm() {
  [ -z $(git add . -n) ] && echo "${BOL_RED}There are no local changes... leaving...${END}" && break &>/dev/null
  translate
  if [[ ${1} ]]; then
    git add . && git commit --signoff --date "$(date)" --author "${1}" && gitpush
  else
    git add . && git commit --message "${msg}" --signoff --date "$(date)" --author "Alexandre Rangel <mamutal91@gmail.com>" && gitpush
  fi
}

function amend() {
  if [[ ${1} ]]; then
    git add . && git commit --amend --signoff --date "$(date)" --author "${1}" && gitpush force
  else
    git add . && git commit --amend --date "$(date)" && gitpush force
  fi
}

function update() {
  $HOME/.config/scripts/update.sh
}

function infra() {
  pwd=$(pwd)
  cd $HOME
  HOSTNAME=$(cat /etc/hostname)
  if [[ $HOSTNAME = odin ]]; then
    echo "Você não está em um host adequado!"
    exit
  else
    if [[ $HOSTNAME = buildersbr.ninja-v2 ]]; then
      org=buildersbr
      repo=buildersbr
    else
      org=AOSPK
      repo=infra
    fi
    echo "${repo} cloned."
    sudo rm -rf /mnt/roms/${repo}
    git clone ssh://git@github.com/${org}/${repo} && sudo mv ${repo} /mnt/roms
  fi
  cd $pwd
}
