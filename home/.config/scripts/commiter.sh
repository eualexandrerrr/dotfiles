#!/bin/bash
# github.com/mamutal91

dir=/media/storage/github

repo0="dotfiles"
repo1="mamutal91.github.io"
repo2="archlinux"
repo3="readme (mamutal91)"
repo4="aosp-build"
repo5="PurityAndroid/manifest"
repo6="device_xiaomi_beryllium"
repo7="device_xiaomi_sdm845-common"

repos="$repo0\n$repo1\n$repo2\n$repo3\n$repo4\n$repo5\n$repo6\n$repo7"

chosen="$(echo -e "$repos" | rofi -lines 8 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory /home/mamutal91/.dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $dir/mamutal91.github.io;;
    $repo2)
        alacritty -t newcommit --working-directory $dir/archlinux;;
    $repo3)
        alacritty -t newcommit --working-directory $dir/readme;;
    $repo4)
        alacritty -t newcommit --working-directory $dir/aosp-build;;
    $repo5)
        alacritty -t newcommit --working-directory /media/storage/PurityAndroid/manifest;;
    $repo6)
        alacritty -t newcommit --working-directory $dir/device_xiaomi_beryllium;;
    $repo7)
        alacritty -t newcommit --working-directory $dir/device_xiaomi_sdm845-common;;

esac
