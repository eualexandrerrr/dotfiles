#!/usr/bin/env bash

rm -rf $HOME/AOSPK && mkdir -p $HOME/AOSPK
rm -rf $HOME/GitHub && mkdir -p $HOME/GitHub

repos=(
  mamutal91.github.io
  myarch
  custom-rom
  zsh-history
  language-swaywm
  shellscript-atom-snippets
  infra
  manifest
  docs
  buildersbr
)

for i in "${repos[@]}"; do
  account=mamutal91
  folder=GitHub
  if [[ ${i} == @("infra"|"manifest"|"docs") ]]; then
    account=AOSPK
    folder=AOSPK
  fi
  if [[ ${i} = buildersbr ]]; then
    account=BuildersBR
  fi
  git clone ssh://git@github.com/${account}/${i} $HOME/${folder}/${i}
done
