#!/usr/bin/env bash

cd $HOME

rm -rf AOSPK && mkdir -p AOSPK
rm -rf GitHub && mkdir -p GitHub

rm -rf $HOME/.scripttest

if [[ -e $HOME/.ssh/id_rsa ]]; then
  echo "Cloning repos my repos with SSH"
  typeClone=ssh://git@github
else
  echo "Cloning repos my repos with HTTPS"
  typeClone=https://github
fi

git clone ${typeClone}.com/mamutal91/myarch GitHub/myarch
git clone ${typeClone}.com/mamutal91/myapps GitHub/myapps
git clone ${typeClone}.com/mamutal91/custom-rom GitHub/custom-rom
git clone ${typeClone}.com/mamutal91/scripttest $HOME/.scripttest
