#!/usr/bin/env bash

rm -rf $HOME/GitHub && mkdir -p $HOME/GitHub
rm -rf $HOME/AOSPK && mkdir -p $HOME/AOSPK

for github in \
    mamutal91.github.io \
    myarch \
    infra \
    custom-rom \
    zsh-history \
    language-swaywm \
    shellscript-atom-snippets \
    device_xiaomi_beryllium \
    device_xiaomi_sdm845-common
do
  git clone ssh://git@github.com/mamutal91/$github $HOME/GitHub/$github
done

# Readme
git clone ssh://git@github.com/mamutal91/mamutal91 $HOME/GitHub/readme

# AOSPK manifest
rm -rf $HOME/AOSPK/manifest && git clone ssh://git@github.com/AOSPK/manifest $HOME/AOSPK/manifest
