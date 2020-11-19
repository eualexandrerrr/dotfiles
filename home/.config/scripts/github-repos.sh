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

# DroidROM manifest
mkdir -p /media/storage/DroidROM && rm -rf /media/storage/DroidROM/manifest && git clone ssh://git@github.com/DroidROM/manifest /media/storage/DroidROM/manifest
