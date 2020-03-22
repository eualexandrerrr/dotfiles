#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

dir=/media/storage/GitHub

repo0=" dotfiles"
repo1=" mamutal91.github.io"

repos="$repo0\n$repo1"

chosen="$(echo -e "$repos" | rofi -lines 2 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        alacritty -t newcommit --working-directory $dir/dotfiles;;
    $repo1)
        alacritty -t newcommit --working-directory $dir/mamutal91.github.io;;
esac
