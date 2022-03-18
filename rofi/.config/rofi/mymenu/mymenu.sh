#!/usr/bin/env bash

github=$HOME/GitHub

repo01="01.   dotfiles"
repo02="02.   infra / docker-files"
repo03="03.   myarch"
repo04="04.   mytokens"
repo05="05.   shellscript-atom-snippets"

menu="$repo01\n$repo02\n$repo03\n$repo04\n$repo05"

chosen="$(echo -e "$menu" | rofi -dmenu -theme $HOME/.config/rofi/mymenu/style.rasi)"

case $chosen in
  $repo01) alacritty -t mywindowfloat --working-directory $HOME/.dotfiles ;;
  $repo02) alacritty -t mywindowfloat --working-directory $github/docker-files ;;
  $repo03) alacritty -t mywindowfloat --working-directory $github/myarch ;;
  $repo04) alacritty -t mywindowfloat --working-directory $github/mytokens ;;
  $repo05) alacritty -t mywindowfloat --working-directory $github/shellscript-atom-snippets ;;
esac
exit 0
