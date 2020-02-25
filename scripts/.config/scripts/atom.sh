#!/bin/bash
# github.com/mamutal91

# My favorites packages https://atom.io/packages/
# Check the package name in the GitHub repository, in the file `package.json` for install

pwd_atom_packages=$(pwd)

rm -rf ~/.tmp && mkdir ~/.tmp && cd ~/.tmp

for PACKAGE in \
    abe33/atom-pigments \
    bhaskardabhi/atom-translator \
    denieler/save-workspace-atom-plugin \
    file-icons/atom \
    Glavin001/atom-beautify \
    h3imdall/ftp-remote-edit \
    rgbkrk/atom-script \
    taylon/language-i3wm \
    thomaslindstrom/color-picker
do
    git clone https://github.com/$PACKAGE
done

PACKAGE='
  pigments
  atom-beautify
  atom-translator
  save-workspace
  file-icons
  ftp-remote-edit
  language-i3wm
  color-picker script
'
apm install $PACKAGE

cd $pwd_atom_packages
