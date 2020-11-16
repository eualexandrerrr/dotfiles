#!/bin/bash
# github.com/mamutal91

rm -rf /media/storage/github && mkdir -p /media/storage/github

for github in \
    aosp-build \
    archlinux \
    mamutal91 \
    mamutal91.github.io \
    zsh-history \
    device_xiaomi_beryllium \
    device_xiaomi_sdm845-common
do
    git clone ssh://git@github.com/mamutal91/$github /media/storage/github/$github
done

# AOSPly manifest
mkdir -p /media/storage/AOSPly && rm -rf /media/storage/AOSPly/manifest && git clone ssh://git@github.com/AOSPly/manifest /media/storage/AOSPly/manifest
