#!/usr/bin/env bash

# Autocommit
# manual-custom-rom

kraken=$HOME/AOSPK
github=$HOME/GitHub

repo1="dotfiles"
repo2="myarch"
repo3="custom-rom"

repos="${repo1}\n${repo2}\n${repo3}"

chosen="$(echo -e "$repos" | wofi --lines 3 --sort-order=DEFAULT --dmenu -p "  Commiter")"
case $chosen in
    $repo1)
        alacritty -t newcommit --working-directory $HOME/.dotfiles;;
    $repo2)
        alacritty -t newcommit --working-directory $github/myarch;;
    $repo3)
        alacritty -t newcommit --working-directory $github/custom-rom;;
esac
exit 0;
