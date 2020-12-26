#!/usr/bin/env bash
# github.com/mamutal91

if [[ $USER = "mamutal91" ]]; then
  ssh-keygen -t rsa -b 4096 -C "mamutal91@gmail.com"
  eval "$(ssh-agent -s)" && ssh-add -l
  cat $HOME/.ssh/id_rsa.pub | wl-copy
  xdg-open https://github.com/settings/ssh/new
fi
