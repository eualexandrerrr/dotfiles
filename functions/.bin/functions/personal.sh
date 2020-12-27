#!/usr/bin/env bash

function blog () {
  $HOME/.bin/scripts/blog.sh
}

function sshgithub() {
  ssh-keygen -t ed25519 -C "mamutal91@github.com"
  eval "$(ssh-agent -s)" && ssh-add -l
  cat $HOME/.ssh/id_rsa.pub | wl-copy
  xdg-open https://github.com/settings/ssh/new
}
