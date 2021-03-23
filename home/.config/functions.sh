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
  echo "${BOL_RED}Message:${BOL_YEL}${msg}${END}"
}

function gitpush() {
  pwd=$(pwd | cut -c-9)
  if [[ $pwd = "/mnt/dev/" ]]; then
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
    git add . && git commit --author "${1}" --signoff --amend --date "$(date)" && gitpush amend
  else
    git add . && git commit --signoff --amend --date "$(date)" && gitpush amend
  fi
}

function update() {
  $HOME/.config/scripts/update.sh
}

function sshconfig() {
  email="mamutal91@gmail.com"
  if [[ ${1} = ed ]]; then
    ssh-keygen -t ed25519 -C "${email}"
    file="id_ed25519"
  else
    ssh-keygen -C "${email}"
    file="id_rsa"
  fi
  eval "$(ssh-agent -s)" && ssh-add -l
  if [[ $HOST == @("odin"|"buildersbr.ninja") ]]; then
    wl-copy < $HOME/.ssh/${file}.pub
    xdg-open https://github.com/settings/ssh/new
  else
    cat $HOME/.ssh/${file}.pub
    echo https://github.com/settings/ssh/new
  fi
}
