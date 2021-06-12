#!/usr/bin/env bash

rm -rf $HOME/AOSPK && mkdir -p $HOME/AOSPK
rm -rf $HOME/GitHub && mkdir -p $HOME/GitHub

repos=(
  mamutal91.github.io
  myarch
  userge-x
  custom-rom
  zsh-history
  language-swaywm
  shellscript-atom-snippets
  manifest
  docs
  scripttest
)

for i in "${repos[@]}"; do
  account=mamutal91
  folder=GitHub/${i}
  if [[ ${i} == @("infra"|"manifest"|"docs") ]]; then
    account=AOSPK
    folder=AOSPK
  fi
  if [[ ${i} = scripttest ]]; then
    folder=.scripttest
  fi
  git clone ssh://git@github.com/${account}/${i} $HOME/${folder}
done
