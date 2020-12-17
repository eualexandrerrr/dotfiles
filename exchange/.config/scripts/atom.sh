#!/usr/bin/env bash
# github.com/mamutal91

# My favorites packages https://atom.io/packages/
# Check the package name in the GitHub repository, in the file `package.json` for install

pwd_atom_packages=$(pwd)

rm -rf $HOME/.tmp && mkdir $HOME/.tmp && cd $HOME/.tmp

for package in \
    Glavin001/atom-beautify \
    Overload119/indent-sort \
    abe33/atom-pigments \
    bhaskardabhi/atom-translator \
    denieler/save-workspace-atom-plugin \
    file-icons/atom \
    h3imdall/ftp-remote-edit \
    lee-dohm/set-syntax \
    taylon/language-i3wm \
    thomaslindstrom/color-picker \
    zhuochun/md-writer
do
    git clone https://github.com/$package
done

package='
  atom-beautify
  atom-translator
  color-picker
  file-icons
  ftp-remote-edit
  indent-sort
  language-i3wm
  markdown-writer
  pigments
  save-workspace
  set-syntax
  '
apm install $package

cd $pwd_atom_packages
