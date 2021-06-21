#!/usr/bin/env bash

github=$HOME/GitHub

repo01="01.   dotfiles"
repo02="02.   infra"
repo03="03.   myarch"
repo04="04.   mytokens"
repo05="05.   custom-rom"
repo06="06.   shellscript-atom-snippets"

repo07="07.   build ( lmi )"
repo08="08.   build ( random )"
repo09="09.   build and sync"
repo10="10.   build, sync and make clean"
repo11="11.   build, sync and make installclean"
repo12="12.   make clean"
repo13="13.   only sync"
repo14="14.   stop"
repo15="15.   stop and clear"
repo16="16.   enable-jobs"
repo17="17.   disable-jobs"
repo18="18.   console"
repo19="19.   package"

menu="$repo01\n$repo02\n$repo03\n$repo04\n$repo05\n$repo06\n$repo07\n$repo08\n$repo09\n$repo10\n$repo11\n$repo12\n$repo13\n$repo14\n$repo15\n$repo16\n$repo17\n$repo18\n$repo19"

chosen="$(echo -e "$menu" | wofi --lines 19 --sort-order=alphabetical --dmenu -p "  myMenu")"
case $chosen in
  $repo01) alacritty -t mywindowfloat --working-directory $HOME/.dotfiles ;;
  $repo02) alacritty -t mywindowfloat --working-directory $github/infra ;;
  $repo03) alacritty -t mywindowfloat --working-directory $github/myarch ;;
  $repo04) alacritty -t mywindowfloat --working-directory $github/mytokens ;;
  $repo05) alacritty -t mywindowfloat --working-directory $github/custom-rom ;;
  $repo06) alacritty -t mywindowfloat --working-directory $github/shellscript-atom-snippets ;;

  $repo07) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh build ;;
  $repo08) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildRandom ;;
  $repo09) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSync ;;
  $repo10) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncClean ;;
  $repo11) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncInstallclean ;;
  $repo12) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh makeClean ;;
  $repo13) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopOnlySync ;;
  $repo14) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopJobs ;;
  $repo15) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopClear ;;
  $repo16) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh enableJobs ;;
  $repo17) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh disableJobs ;;
  $repo18) google-chrome-unstable https://ci.aospk.org/job/KrakenDev/lastBuild/console ;;
  $repo19) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh package ;;
esac
exit 0
