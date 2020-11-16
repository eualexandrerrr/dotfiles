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

mv /media/storage/github/mamutal91 /media/storage/github/readme

# PurityAndroid manifest
mkdir -p /media/storage/PurityAndroid && rm -rf /media/storage/PurityAndroid/manifest && git clone ssh://git@github.com/PurityAndroid/manifest /media/storage/PurityAndroid/manifest
