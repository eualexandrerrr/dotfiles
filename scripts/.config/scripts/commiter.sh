#!/bin/bash
# github.com/mamutal91

repo0=" dotfiles"
repo1=" archlinux"
repo2=" mamutal91.github.io"
repo3=" vps"

repos="$repo0\n$repo1\n$repo2\n$repo3"

chosen="$(echo -e "$repos" | rofi -lines 4 -width 20% -dmenu -p "  Commiter")"
case $chosen in
    $repo0)
        urxvt -title newcommit -cd /media/storage/GitHub/dotfiles;;
    $repo1)
        urxvt -title newcommit -cd /media/storage/GitHub/archlinux;;
    $repo2)
        urxvt -title newcommit -cd /media/storage/GitHub/mamutal91.github.io;;
		$repo3)
        urxvt -title newcommit -cd /media/storage/GitHub/vps;;
esac
