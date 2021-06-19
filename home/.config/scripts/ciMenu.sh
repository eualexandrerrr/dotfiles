#!/usr/bin/env bash

github=$HOME/GitHub
# depois 7
repo01="01.   dsadsadsadsa"
repo02="02.   infra"
repo03="03.   build ( lmi )"
repo04="04.   build ( random )"
repo05="05.   build and sync"
repo06="06.   build, sync and make clean"
repo07="07.   build, sync and make installclean"
repo08="08.   make clean"
repo09="09.   only sync"
repo10="10.   stop/parar"
repo11="11.   stop and clear/limpar queue"
repo12="12.   enable-jobs"
repo13="13.   disable-jobs"
repo14="14.   myarch"
repo15="15.   mytokens"
repo16="16.   custom-rom"
repo17="17.   shellscript-atom-snippets"

menu="$repo01\n$repo02\n$repo03\n$repo04\n$repo05\n$repo06\n$repo07\n$repo08\n$repo09\n$repo10\n$repo11\n$repo12\n$repo13\n$repo14\n$repo15\n$repo16\n$repo17"

chosen="$(echo -e "$menu" | wofi --lines 17 --sort-order=alphabetical --dmenu -p "  myMenu")"
case $chosen in
  $repo01) alacritty -t mywindowfloat --working-directory $HOME/.dotfiles ;;
  $repo02) alacritty -t mywindowfloat --working-directory $github/infra ;;
  $repo03) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh build ;;
  $repo04) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildRandom ;;
  $repo05) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSync ;;
  $repo06) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncClean ;;
  $repo07) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncInstallclean ;;
  $repo08) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh makeClean ;;
  $repo09) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopOnlySync ;;
  $repo10) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopJobs ;;
  $repo11) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopClear ;;
  $repo12) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh enableJobs ;;
  $repo13) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh disableJobs ;;
  $repo14) alacritty -t mywindowfloat --working-directory $github/myarch ;;
  $repo15) alacritty -t mywindowfloat --working-directory $github/mytokens ;;
  $repo16) alacritty -t mywindowfloat --working-directory $github/custom-rom ;;
  $repo17) alacritty -t mywindowfloat --working-directory $github/shellscript-atom-snippets ;;
esac
exit 0
