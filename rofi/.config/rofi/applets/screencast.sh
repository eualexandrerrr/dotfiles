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
      $HOME/.config/scripts/dot/screencast.sh f
    ;;
  $window)
      $HOME/.config/scripts/dot/screencast.sh w
    ;;
  $stop)
      $HOME/.config/scripts/dot/screencast.sh stop
    ;;
esac
