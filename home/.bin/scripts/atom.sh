#!/usr/bin/env bash
# github.com/mamutal91

# My favorites packages https://atom.io/packages/
# Check the package name in the GitHub repository, in the file `package.json` for install

packages='
  atom-material-syntax
  atom-beautify
  color-picker
  file-icons
  ftp-remote-edit
  indent-sort
  language-swaywm
  language-i3wm
  markdown-writer
  pigments
  save-workspace
  set-syntax
  flatten-json
  fonts
  highlight-selected
  '
apm install $packages
