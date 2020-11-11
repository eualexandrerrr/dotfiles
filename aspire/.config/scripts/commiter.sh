#!/bin/bash
# github.com/mamutal91

dir=/media/storage/github

repo0=" dotfiles"
repo1=" mamutal91.github.io"
repo2=" archlinux"
repo3=" mamutal91"
repo4=" aosp"
repo5=" manifest"

repos="$repo0\n$repo1\n$repo2\n$repo3\n$repo4\n$repo5"

chosen="$(echo -e "$repos" | rofi -lines 6 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory /home/mamutal91/.dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $dir/mamutal91.github.io;;
    $repo2)
        alacritty -t newcommit --working-directory $dir/archlinux;;
    $repo3)
        alacritty -t newcommit --working-directory $dir/mamutal91;;
    $repo4)
        alacritty -t newcommit --working-directory $dir/aosp;;
    $repo5)
        alacritty -t newcommit --working-directory /media/storage/camalleonandroid/manifest;;

esac
