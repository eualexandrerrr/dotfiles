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
repo3="readme"
repo4="device_xiaomi_beryllium"
repo5="device_xiaomi_sdm845-common"
repo6="AOSPK/manifest"
repo7="AOSPK/docs"
repo8="AOSPK/tentacles"

repos="$repo0\n$repo1\n$repo2\n$repo3\n$repo4\n$repo5\n$repo6\n$repo7\n$repo8"

chosen="$(echo -e "$repos" | rofi -lines 9 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory /home/mamutal91/.dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $dir/mamutal91.github.io;;
    $repo2)
        alacritty -t newcommit --working-directory $dir/archlinux-installer;;
    $repo3)
        alacritty -t newcommit --working-directory $dir/readme;;
    $repo4)
        alacritty -t newcommit --working-directory $dir/device_xiaomi_beryllium;;
    $repo5)
        alacritty -t newcommit --working-directory $dir/device_xiaomi_sdm845-common;;
    $repo6)
        alacritty -t newcommit --working-directory $aospk/manifest;;
    $repo7)
        alacritty -t newcommit --working-directory $aospk/docs;;
    $repo8)
        alacritty -t newcommit --working-directory $aospk/tentacles;;
esac
exit 0;
