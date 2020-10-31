#!/bin/bash
# github.com/mamutal91

dir=/media/storage/GITHUB

repo0=" dotfiles"
repo1=" mamutal91.github.io"
repo2=" archlinux"
repo3=" manifest"

repos="$repo0\n$repo1\n$repo2\n$repo3"

chosen="$(echo -e "$repos" | rofi -lines 4 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory /home/mamutal91/.dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $dir/mamutal91.github.io;;
    $repo2)
        alacritty -t newcommit --working-directory $dir/archlinux;;
    $repo3)
        alacritty -t newcommit --working-directory /media/storage/aosp-forking/manifest;;

esac
