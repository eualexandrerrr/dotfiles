#!/bin/bash
# github.com/mamutal91

dir=/media/storage/GitHub

repo0="dotfiles"
repo1="archlinux"
repo2="mamutal91.github.io"
repo3="vps"

repos="$repo0\n$repo1\n$repo2\n$repo3"

chosen="$(echo -e "$repos" | rofi -lines 4 -dmenu -p "Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory $dir/dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $dir/archlinux;;
    $repo2)
        alacritty -t newcommit --working-directory $dir/mamutal91.github.io;;
		$repo3)
        alacritty -t newcommit --working-directory $dir/vps;;
esac
