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
    git add . && git commit --message $msg --signoff --author "Alexandre Rangel <mamutal91@gmail.com>" && git push -f
  }
  function c() {
    git add . && git commit --author "${1}" && git push -f
  }
  function amend() {
    git add . && git commit --signoff --amend && git push -f
  }
else
  function cm() {
    translate
    git add . && git commit --message $msg --signoff --author "Alexandre Rangel <mamutal91@gmail.com>"
  }
  function c() {
    git add . && git commit --author "${1}"
  }
  function amend() {
    git add . && git commit --amend
  }
fi

function update() {
  $HOME/.config/scripts/pacman-update.sh
}

function wifi() {
  interface=$(cat /proc/net/wireless | perl -ne '/(\w+):/ && print $1')
  iwctl station $interface scan && sleep 3
  iwctl station $interface get-networks
  echo "${BLU}Which network do you want to connect to?${END} "; read wifi
  iwctl station $interface connect "${wifi}"
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
