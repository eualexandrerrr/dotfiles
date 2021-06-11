#!/usr/bin/env bash

source $HOME/.colors &>/dev/null

function dot() {
  if [[ ${1} ]]; then
    cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc
  else
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
  pwd=$(pwd | cut -c-24)
  if [[ $pwd = "/home/mamutal91/AOSPK/manifest" ]]; then
    exit
  fi
  if [[ $pwd = "/mnt/roms/jobs/KrakenDev" ]]; then
    echo "${BOL_RED}No push!${END}"
  else
    if [[ ${1} = force ]]; then
      echo "${BOL_YEL}Pushing with --force!${END}"
      git push -f
    else
      echo "${BOL_YEL}Pushing!${END}"
      git push
    fi
  fi
  if [[ $(pwd) = /home/mamutal91/.dotfiles ]]; then
    echo "${BOL_MAG}Updating dotfiles!${END}"
    dot &>/dev/null
    [ $(cat /etc/hostname) = odin ] && exit
  fi
  [ $(cat /etc/hostname) = odin ] && sleep 3 && exit
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
    git add . && git commit --author "${1}" --amend --author "Alexandre Rangel <mamutal91@gmail.com>" --date "$(date)" && gitpush force
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
