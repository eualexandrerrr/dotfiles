#!/usr/bin/env bash

atomPkgs=(
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
)

for i in "${atomPkgs[@]}"; do
  apm install ${i} --no-confirm
done
