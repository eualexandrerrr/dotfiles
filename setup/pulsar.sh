#!/usr/bin/env bash

pulsarPkgs=(
  atom-beautify
  atom-material-syntax
  color-picker
  file-icons
  flatten-json
  ftp-remote-edit
  highlight-selected
  indent-sort
  language-i3wm
  mamutal91-shellscript-snippets-atom
  markdown-writer
  pigments
  save-workspace
  format-shell
  language-docker
)

for i in "${pulsarPkgs[@]}"; do
  if pulsar --package list | grep ${i}; then
    echo ${i} already installed, skiping...
  else
    pulsar --package install ${i} --no-confirm
  fi
done
