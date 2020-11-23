#!/usr/bin/env bash
# github.com/mamutal91

dir=/media/storage/GitHub

repo0="dotfiles"
repo1="mamutal91.github.io"
repo2="android"
repo3="archlinux-installer"
repo4="readme (mamutal91)"
repo5="device_xiaomi_beryllium"
repo6="device_xiaomi_sdm845-common"
repo7="DroidROM/manifest"

repos="$repo0\n$repo1\n$repo2\n$repo3\n$repo4\n$repo5\n$repo6\n$repo7"

chosen="$(echo -e "$repos" | rofi -lines 8 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory /home/mamutal91/.dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $dir/mamutal91.github.io;;
    $repo2)
        alacritty -t newcommit --working-directory $dir/android;;
    $repo3)
        alacritty -t newcommit --working-directory $dir/archlinux-installer;;
    $repo4)
        alacritty -t newcommit --working-directory $dir/readme;;
    $repo5)
        alacritty -t newcommit --working-directory $dir/device_xiaomi_beryllium;;
    $repo6)
        alacritty -t newcommit --working-directory $dir/device_xiaomi_sdm845-common;;
    $repo7)
        alacritty -t newcommit --working-directory /media/storage/DroidROM/manifest;;

esac
exit 0;
