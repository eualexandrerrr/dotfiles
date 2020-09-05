#!/bin/bash
# github.com/mamutal91

dir=/media/storage/GITHUB

repo0=" dotfiles"
repo1=" mamutal91.github.io"
repo2=" archlinux"

repos="$repo0\n$repo1\n$repo2"

chosen="$(echo -e "$repos" | rofi -lines 3 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory /home/mamutal91/.dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $dir/mamutal91.github.io;;
    $repo2)
        alacritty -t newcommit --working-directory $dir/archlinux;;

esac
