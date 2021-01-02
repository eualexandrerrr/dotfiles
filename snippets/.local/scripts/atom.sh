#!/usr/bin/env bash

# My favorites packages https://atom.io/packages/
# Check the package name in the GitHub repository, in the file `package.json` for install

packages='
  atom-beautify
  atom-material-syntax
  mamutal91-shellscript-snippets-atom
  color-picker
  file-icons
  flatten-json
  ftp-remote-edit
  highlight-selected
  indent-sort
  language-i3wm
  markdown-writer
  pigments
  save-workspace
  '
apm install $packages

#  language-swaywm
