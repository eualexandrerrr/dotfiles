#!/usr/bin/env bash

formatStyle=square
rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/${formatStyle}/screencast.rasi"

# Error msg
msg() {
  rofi -theme "$HOME/.config/rofi/message.rasi" -e "Please install 'ffpmeg' first."
}

# Options
fullscreen=""
window=""
stop=""

# Variable passed to rofi
options="$fullscreen\n$window\n$stop"

chosen="$(echo -e "$options" | $rofi_command -p 'ffmpeg' -dmenu -selected-row 1)"
case $chosen in
  $fullscreen)
    if [[ -f /usr/bin/ffmpeg ]]; then
      sleep 1
      $HOME/.config/scripts/screencast.sh fullscren
    else
      msg
    fi
    ;;
  $window)
    if [[ -f /usr/bin/ffmpeg ]]; then
      $HOME/.config/scripts/screencast.sh window
    else
      msg
    fi
    ;;
  $stop)
      sleep 1
      $HOME/.config/scripts/screencast.sh stop
    ;;
esac
