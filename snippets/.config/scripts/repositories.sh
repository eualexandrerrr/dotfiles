#!/usr/bin/env bash

rm -rf $HOME/GitHub && mkdir -p $HOME/GitHub
rm -rf $HOME/AOSPK && mkdir -p $HOME/AOSPK

readonly aospk=(
    manifest
    docs
    official_devices
)

for i in "${aospk[@]}"; do
  git clone ssh://git@github.com/AOSPK/${i} $HOME/AOSPK/${i}
done

readonly mamutal91=(
    mamutal91.github.io
    mamutal91
    myarch
    infra
    custom-rom
    zsh-history
    language-swaywm
    shellscript-atom-snippets
    device_xiaomi_beryllium
    device_xiaomi_sdm845-common
)

cd $HOME/GitHub && mv mamutal91 readme
