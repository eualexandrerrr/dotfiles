#!/usr/bin/env bash

function blog() {
  $HOME/.scripts/blog.sh
}

function update() {
  $HOME/.scripts/pacman-update.sh
}

function sshgithub() {
  ssh-keygen -t ed25519 -C "mamutal91@github.com"
  eval "$(ssh-agent -s)" && ssh-add -l
  cat $HOME/.ssh/id_ed25519.pub | wl-copy
  xdg-open https://github.com/settings/ssh/new
}

function createuser() {
  sudo useradd -m -G wheel -s /bin/bash ${1}
  sudo mkdir -p /home/${1}
  sudo passwd ${1}
}
