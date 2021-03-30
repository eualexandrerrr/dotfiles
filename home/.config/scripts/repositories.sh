#!/usr/bin/env bash

rm -rf $HOME/AOSPK && mkdir -p $HOME/AOSPK
rm -rf $HOME/GitHub && mkdir -p $HOME/GitHub

ACCOUNT=mamutal91
FOLDER=GitHub

readonly mamutal91=(
    mamutal91.github.io
    myarch
    infra
    custom-rom
    zsh-history
    language-swaywm
    shellscript-atom-snippets
    manifest
    docs
    infra
)

for i in "${mamutal91[@]}"; do
  if [[ ${i} = manifest || ${i} = docs || ${i} = infra ]]; then
    ACCOUNT=AOSPK
    FOLDER=AOSPK
  fi

  git clone ssh://git@github.com/${ACCOUNT}/${i} $HOME/${FOLDER}/${i}
done

git clone ssh://git@github.com/BuildersBR/buildersbr $HOME/${FOLDER}/buildersbr
