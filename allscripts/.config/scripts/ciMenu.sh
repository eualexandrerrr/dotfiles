#!/usr/bin/env bash

repo01="01.   build ( lmi )"
repo02="02.   build ( random )"
repo03="03.   build and sync"
repo04="04.   build, sync and make clean"
repo05="05.   build, sync and make installclean"
repo06="06.   make clean"
repo07="07.   only sync"
repo08="08.   stop/parar"
repo09="09.   stop and clear/limpar queue"
repo10="10.   enable-jobs"
repo11="11.   disable-jobs"

menu="$repo01\n$repo02\n$repo03\n$repo04\n$repo05\n$repo06\n$repo07\n$repo08\n$repo09\n$repo10\n$repo11"

chosen="$(echo -e "$menu" | wofi --lines 11 --sort-order=alphabetical --dmenu -p "  CI | Kraken")"
case $chosen in
  $repo01) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh build ;;
  $repo02) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildRandom ;;
  $repo03) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSync ;;
  $repo04) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncClean ;;
  $repo05) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncInstallclean ;;
  $repo06) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh makeClean ;;
  $repo07) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopOnlySync ;;
  $repo08) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopJobs ;;
  $repo09) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopClear ;;
  $repo10) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh enableJobs ;;
  $repo11) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh disableJobs ;;
esac
exit 0
