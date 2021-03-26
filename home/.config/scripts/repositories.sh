#!/usr/bin/env bash

rm -rf $HOME/AOSPK && mkdir -p $HOME/AOSPK
rm -rf $HOME/GitHub && mkdir -p $HOME/GitHub

readonly kraken=(
    manifest
    docs
)

for i in "${kraken[@]}"; do
  git clone ssh://git@github.com/AOSPK/${i} $HOME/AOSPK/${i}
done

readonly mamutal91=(
    mamutal91.github.io
    myarch
    infra
    custom-rom
    zsh-history
    language-swaywm
    shellscript-atom-snippets
)

for i in "${mamutal91[@]}"; do
  git clone ssh://git@github.com/mamutal91/${i} $HOME/GitHub/${i}
done

git clone ssh://git@github.com/BuildersBR/buildersbr $HOME/GitHub/buildersbr
