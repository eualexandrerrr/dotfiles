#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

function f() {
  git fetch https://github.com/${1} ${2}
}

function p() {
  git cherry-pick ${1}
}

function cc() {
  git add . && git cherry-pick --continue
}

function a() {
  git cherry-pick --abort
}

function translate() {
  typing=$(mktemp)
  rm -rf $typing && nano $typing
  msg=$(trans -b :en -no-auto -i $typing)
  typing=$(cat $typing)
  echo "${BOL_RED}Message: ${BOL_YEL}${msg}${END}"
}

function gitpush() {
  pwd=$(pwd | cut -c-9)
  if [[ $pwd = "/home/mamutal91/AOSPK/manifest" ]]; then
    exit
  fi
  if [[ $pwd = "/mnt/roms/jobs/" ]]; then
    echo "${BOL_RED}No push!${END}"
  else
    if [[ ${1} = amend ]]; then
      echo "${BOL_YEL}Pushing with --force!${END}"
      git push -f
    else
      echo "${BOL_YEL}Pushing!${END}"
      git push
    fi
  fi
}

function cm() {
  translate
  if [[ ${1} ]]; then
    git add . && git commit --author "${1}" --date "$(date)" && gitpush
  else
    git add . && git commit --message $msg --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && gitpush
  fi
}

function amend() {
  if [[ ${1} ]]; then
    git add . && git commit --author "${1}" --amend --date "$(date)" && gitpush amend
  else
    git add . && git commit --amend --date "$(date)" && gitpush amend
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
