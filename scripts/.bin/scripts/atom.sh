#!/usr/bin/env bash
# github.com/mamutal91

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
#  language-swaywm
  markdown-writer
  pigments
  save-workspace
  '
apm install $packages
