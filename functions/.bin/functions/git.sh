#!/usr/bin/env bash

function p () {
  git cherry-pick ${1}
}

function translate () {
  typing=$(mktemp)
  rm -rf $typing && nano $typing
  msg=$(trans -b :en -i $typing)
}

if [ $HOST = "odin" ]; then
  function cm () {
    translate
    git add . && git commit --message $msg --author "Alexandre Rangel <mamutal91@gmail.com>" && git push -f
  }
  function c () {
    git add . && git commit --author "${1}" && git push -f
  }
  function amend () {
    git add . && git commit --amend && git push -f
  }
else
  function cm () {
    translate
    git add . && git commit --author "Alexandre Rangel <mamutal91@gmail.com>"
  }
  function c () {
    git add . && git commit --author "${1}"
  }
  function amend () {
    git add . && git commit --amend
  }
fi
