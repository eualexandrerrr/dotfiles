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
  cat $typing
}

if [ $HOST = "odin" ]; then
  function cm() {
    translate
    git add . && git commit --message $msg --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && git push -f
  }
  function c() {
    git add . && git commit --author "${1}" --date "$(date)" && git push -f
  }
  function amend() {
    git add . && git commit --signoff --amend --date "$(date)" && git push -f
  }
else
  function cm() {
    translate
    git add . && git commit --message $msg --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)"
  }
  function c() {
    git add . && git commit --author "${1}" --date "$(date)"
  }
  function amend() {
    pwd=$(pwd)
    if [[ $pwd = "/home/mamutal91/jenkins" ]]; then
      sudo git add . && sudo git commit --amend --date "$(date)" && sudo git push -f
    else
      git add . && git commit --amend --date "$(date)"
    fi
  }
fi

function update() {
  $HOME/.config/scripts/pacman-update.sh
}

function sshconfig() {
  email="mamutal91@gmail.com"
  if [[ ${1} = ed ]]; then
    ssh-keygen -t ed25519 -C "$email"
    file="id_ed25519"
  else
    ssh-keygen -C "$email"
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
