#!/usr/bin/env bash
# github.com/mamutal91

# Autocommit
# iWantToSpeak
# manual-custom-rom

github=/media/storage/GitHub
aospk=/media/storage/AOSPK

repo0="dotfiles"
repo1="mamutal91.github.io"
repo2="archlinux-installer"
repo3="buildbot"
repo4="readme"
repo5="device_xiaomi_beryllium"
repo6="device_xiaomi_sdm845-common"
repo7="AOSPK/manifest"
repo8="AOSPK/docs"
repo9="AOSPK/tentacles"

repos="$repo0\n$repo1\n$repo2\n$repo3\n$repo4\n$repo5\n$repo6\n$repo7\n$repo8\n$repo9"

chosen="$(echo -e "$repos" | wofi -lines 10 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory /home/mamutal91/.dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $github/mamutal91.github.io;;
    $repo2)
        alacritty -t newcommit --working-directory $github/archlinux-installer;;
    $repo3)
        alacritty -t newcommit --working-directory $github/buildbot;;
    $repo4)
        alacritty -t newcommit --working-directory $github/readme;;
    $repo5)
        alacritty -t newcommit --working-directory $github/device_xiaomi_beryllium;;
    $repo6)
        alacritty -t newcommit --working-directory $github/device_xiaomi_sdm845-common;;
    $repo7)
        alacritty -t newcommit --working-directory $aospk/manifest;;
    $repo8)
        alacritty -t newcommit --working-directory $aospk/docs;;
    $repo9)
        alacritty -t newcommit --working-directory $aospk/tentacles;;
esac
exit 0;
