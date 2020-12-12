#!/usr/bin/env bash
# github.com/mamutal91

dir="/media/storage/AOSPK"
aospk="$dir/aospk.github.io"
vuedev="$dir/vue-dev"

cd $dir
rm -rf $aospk

git clone ssh://git@github.com/AOSPK/aospk.github.io -b master aospk.github.io

cd $aospk && rm -rf *
cd $vuedev && npm i && npm run build
cd dist && cp -rf * $aospk

cd $aospk && git add . && git commit --amend -m "Autocommit" --author "Alexandre Rangel <mamutal91@gmail.com>" && git push -f
