#!/usr/bin/env bash

github=$HOME/GitHub

repo01="01.   dotfiles"
repo02="02.   infra"
repo03="03.   build ( lmi )"
repo04="04.   build ( random )"
repo05="05.   build and sync"
repo06="06.   build, sync and make clean"
repo07="07.   build, sync and make installclean"
repo08="09.   only sync"
repo09="09.   stop/parar"
repo10="10.   stop and clear/limpar queue"
repo11="11.   enable-jobs"
repo12="12.   disable-jobs"
repo13="13.   myarch"
repo14="14.   mytokens"
repo15="15.   custom-rom"
repo16="16.   shellscript-atom-snippets"

menu="$repo01\n$repo02\n$repo03\n$repo04\n$repo05\n$repo06\n$repo07\n$repo08\n$repo09\n$repo10\n$repo11\n$repo12\n$repo13\n$repo14\n$repo15\n$repo16"

chosen="$(echo -e "$menu" | wofi --lines 16 --sort-order=alphabetical --dmenu -p "  myMenu")"
case $chosen in
  $repo01) alacritty -t mywindowfloat --working-directory $HOME/.dotfiles;;
  $repo02) alacritty -t mywindowfloat --working-directory $github/infra;;
  $repo03) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh build;;
  $repo04) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildRandom;;
  $repo05) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSync;;
  $repo06) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncClean;;
  $repo07) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh buildSyncInstallclean;;
  $repo08) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopOnlySync;;
  $repo09) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopJobs;;
  $repo10) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh stopClear;;
  $repo11) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh enableJobs;;
  $repo12) alacritty -t mywindowfloat -e $HOME/.config/scripts/runCI.sh disableJobs;;
  $repo13) alacritty -t mywindowfloat --working-directory $github/myarch;;
  $repo14) alacritty -t mywindowfloat --working-directory $github/mytokens;;
  $repo15) alacritty -t mywindowfloat --working-directory $github/custom-rom;;
  $repo16) alacritty -t mywindowfloat --working-directory $github/shellscript-atom-snippets;;
esac
exit 0;
