#!/usr/bin/env bash

# Autocommit
# manual-custom-rom

github=$HOME/GitHub
aospk=$HOME/AOSPK

repo1="dotfiles"
repo2="mamutal91.github.io"
repo3="myarch"
repo4="buildbot"
repo5="readme"
repo6="device_xiaomi_beryllium"
repo7="device_xiaomi_sdm845-common"
repo8="language-swaywm"
repo9="shellscript-atom-snippets"
repo10="AOSPK/manifest"

repos="$repo1\n$repo2\n$repo3\n$repo4\n$repo5\n$repo6\n$repo7\n$repo8\n$repo9\n$repo10"

chosen="$(echo -e "$repos" | wofi --lines 10 --sort-order=DEFAULT --dmenu -p "  Commiter")"
case $chosen in
    $repo1)
        alacritty -t newcommit --working-directory $HOME/.dotfiles;;
    $repo2)
        alacritty -t newcommit --working-directory $github/mamutal91.github.io;;
    $repo3)
        alacritty -t newcommit --working-directory $github/myarch;;
    $repo4)
        alacritty -t newcommit --working-directory $github/buildbot;;
    $repo5)
        alacritty -t newcommit --working-directory $github/readme;;
    $repo6)
        alacritty -t newcommit --working-directory $github/device_xiaomi_beryllium;;
    $repo7)
        alacritty -t newcommit --working-directory $github/device_xiaomi_sdm845-common;;
    $repo8)
        alacritty -t newcommit --working-directory $github/language-swaywm;;
    $repo9)
        alacritty -t newcommit --working-directory $github/shellscript-atom-snippets;;
    $repo10)
        alacritty -t newcommit --working-directory $aospk/manifest;;
esac
exit 0;
