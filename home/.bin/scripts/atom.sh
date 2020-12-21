#!/usr/bin/env bash
# github.com/mamutal91

# My favorites packages https://atom.io/packages/
# Check the package name in the GitHub repository, in the file `package.json` for install

pwd_atom_packages=$(pwd)

rm -rf $HOME/.tmp && mkdir $HOME/.tmp && cd $HOME/.tmp

for package in \
    atom-material/atom-material-syntax \
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
    zhuochun/md-writer \
    KunihikoKido/atom-flatten-json
do
    git clone https://github.com/$package
done

package='
  atom-material-syntax
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
  flatten-json
  '
apm install $package

cd $pwd_atom_packages
