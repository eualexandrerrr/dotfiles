#!/usr/bin/env bash

github=$HOME/GitHub

repo01="01.   dotfiles"
repo02="02.   infra"
repo03="03.   myarch"
repo04="04.   mytokens"
repo05="05.   custom-rom"
repo06="06.   shellscript-atom-snippets"
repo07="07.   mysyntaxtheme"

repo08="08.   build ( lmi )"
repo09="09.   build ( random )"
repo10="10.   build and sync"
repo11="11.   build, sync and make clean"
repo12="12.   build, sync and make installclean"
repo13="13.   make clean"
repo14="14.   only sync"
repo15="15.   stop"
repo16="16.   stop and clear"
repo17="17.   enable-jobs"
repo18="18.   disable-jobs"
repo19="19.   console"
repo20="20.   package"

menu="$repo01\n$repo02\n$repo03\n$repo04\n$repo05\n$repo06\n$repo07\n$repo08\n$repo09\n$repo10\n$repo11\n$repo12\n$repo13\n$repo14\n$repo15\n$repo16\n$repo17\n$repo18\n$repo19\n$repo20"

chosen="$(echo -e "$menu" | wofi --lines 20 --sort-order=alphabetical --dmenu -p "  myMenu")"
case $chosen in
  $repo01) alacritty -t mywindowfloat --working-directory $HOME/.dotfiles ;;
  $repo02) alacritty -t mywindowfloat --working-directory $github/infra ;;
  $repo03) alacritty -t mywindowfloat --working-directory $github/myarch ;;
  $repo04) alacritty -t mywindowfloat --working-directory $github/mytokens ;;
  $repo05) alacritty -t mywindowfloat --working-directory $github/custom-rom ;;
  $repo06) alacritty -t mywindowfloat --working-directory $github/shellscript-atom-snippets ;;
  $repo07) alacritty -t mywindowfloat --working-directory $github/mysyntaxtheme/ ;;

  $repo08) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh build ;;
  $repo09) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildRandom ;;
  $repo10) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSync ;;
  $repo11) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncClean ;;
  $repo12) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncInstallclean ;;
  $repo13) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh makeClean ;;
  $repo14) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopOnlySync ;;
  $repo15) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopJobs ;;
  $repo16) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopClear ;;
  $repo17) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh enableJobs ;;
  $repo18) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh disableJobs ;;
  $repo19) google-chrome-unstable https://ci.aospk.org/job/KrakenDev/lastBuild/console ;;
  $repo20) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh package ;;
esac
exit 0
