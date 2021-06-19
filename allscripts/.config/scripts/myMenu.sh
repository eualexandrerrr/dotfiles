#!/usr/bin/env bash

github=$HOME/GitHub

repo01="01.   dotfiles"
repo02="02.   infra"
repo03="03.   myarch"
repo04="04.   mytokens"
repo05="05.   custom-rom"
repo06="06.   shellscript-atom-snippets"
repo07="07.   ci | kraken"

menu="$repo01\n$repo02\n$repo03\n$repo04\n$repo05\n$repo06\n$repo07"

chosen="$(echo -e "$menu" | wofi --lines 7 --sort-order=alphabetical --dmenu -p "  myMenu")"
case $chosen in
  $repo01) alacritty -t mywindowfloat --working-directory $HOME/.dotfiles ;;
  $repo02) alacritty -t mywindowfloat --working-directory $github/infra ;;
  $repo03) alacritty -t mywindowfloat --working-directory $github/myarch ;;
  $repo04) alacritty -t mywindowfloat --working-directory $github/mytokens ;;
  $repo05) alacritty -t mywindowfloat --working-directory $github/custom-rom ;;
  $repo06) alacritty -t mywindowfloat --working-directory $github/shellscript-atom-snippets ;;
  $repo07) $HOME/.config/scripts/ciMenu.sh & ;;
esac
exit 0
