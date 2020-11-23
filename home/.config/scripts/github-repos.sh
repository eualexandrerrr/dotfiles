#!/usr/bin/env bash
# github.com/mamutal91

rm -rf /media/storage/GitHub && mkdir -p /media/storage/GitHub

for github in \
    android \
    aosp-build \
    archlinux-installer \
    mamutal91 \
    mamutal91.github.io \
    manual-custom-rom \
    iWantToSpeak \
    zsh-history \
    device_xiaomi_beryllium \
    device_xiaomi_sdm845-common
do
    git clone ssh://git@github.com/mamutal91/$github /media/storage/GitHub/$github
done

mv /media/storage/GitHub/mamutal91 /media/storage/GitHub/readme

# DroidROM manifest
mkdir -p /media/storage/DroidROM && rm -rf /media/storage/DroidROM/manifest && git clone ssh://git@github.com/DroidROM/manifest /media/storage/DroidROM/manifest
