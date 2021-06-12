#!/usr/bin/env bash

# Autocommit
# manual-custom-rom

kraken=$HOME/AOSPK
github=$HOME/GitHub

repo1="dotfiles"
repo2="myarch"

repos="${repo1}\n${repo2}"

chosen="$(echo -e "$repos" | wofi --lines 5 --sort-order=DEFAULT --dmenu -p "  Commiter")"
case $chosen in
    $repo1)
        alacritty -t newcommit --working-directory $HOME/.dotfiles;;
    $repo2)
        alacritty -t newcommit --working-directory $github/mamutal91.github.io;;
esac
exit 0;
