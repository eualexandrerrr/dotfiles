#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/screencast.rasi"

# Options
fullscreen=""
window=""
stop=""

# Variable passed to rofi
options="$fullscreen\n$window\n$stop"

chosen="$(echo -e "$options" | $rofi_command -p 'ffmpeg' -dmenu -selected-row 1)"
case $chosen in
  $fullscreen)
      $HOME/.config/scripts/screencast.sh fullscreen
    ;;
  $window)
      $HOME/.config/scripts/screencast.sh window
    ;;
  $stop)
      $HOME/.config/scripts/screencast.sh stop
    ;;
esac
