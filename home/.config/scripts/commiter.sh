#!/usr/bin/env bash

# Autocommit
# manual-custom-rom

kraken=$HOME/AOSPK
github=$HOME/GitHub

repo1="dotfiles"
repo2="mamutal91.github.io"
repo3="myarch"
repo4="infra"
repo5="language-swaywm"
repo6="shellscript-atom-snippets"
repo7="AOSPK/manifest"
repo8="Poco F2/device_xiaomi_lmi"
repo9="Poco F2/device_xiaomi_sm8250-common"
repo10="BuildersBR/buildersbr"

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
        alacritty -t newcommit --working-directory $kraken/infra;;
    $repo5)
        alacritty -t newcommit --working-directory $github/language-swaywm;;
    $repo6)
        alacritty -t newcommit --working-directory $github/shellscript-atom-snippets;;
    $repo7)
        alacritty -t newcommit --working-directory $kraken/manifest;;
    $repo8)
        alacritty -t newcommit --working-directory $github/device_xiaomi_lmi;;
    $repo9)
        alacritty -t newcommit --working-directory $github/device_xiaomi_sm8250-common;;
    $repo10)
        alacritty -t newcommit --working-directory $github/buildersbr;;
esac
exit 0;
