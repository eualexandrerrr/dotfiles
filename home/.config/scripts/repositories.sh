#!/usr/bin/env bash

rm -rf $HOME/AOSPK && mkdir -p $HOME/AOSPK
rm -rf $HOME/GitHub && mkdir -p $HOME/GitHub

mamutal91=(
  mamutal91.github.io
  myarch
  custom-rom
  zsh-history
  language-swaywm
  shellscript-atom-snippets
  infra
  manifest
  docs
)

for i in "${mamutal91[@]}"; do
  account=mamutal91
  folder=GitHub
  if [[ ${i} == @("infra"|"manifest"|"docs") ]]; then
    account=AOSPK
    folder=AOSPK
  fi
  git clone ssh://git@github.com/${account}/${i} $HOME/${folder}/${i}
done

git clone ssh://git@github.com/BuildersBR/buildersbr $HOME/${folder}/buildersbr
