#!/usr/bin/env bash

function blog () {
  $HOME/.local/share/scripts/blog.sh
}

function sshgithub() {
  ssh-keygen -t ed25519 -C "mamutal91@github.com"
  eval "$(ssh-agent -s)" && ssh-add -l
  cat $HOME/.ssh/id_ed25519.pub | wl-copy
  xdg-open https://github.com/settings/ssh/new
}
