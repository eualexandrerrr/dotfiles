#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/backlight.rasi"

# Error msg
msg() {
  rofi -theme "$HOME/.config/rofi/message.rasi" -e "$1"
}

## Icons
iconUP=""
iconDOWN=""
icon80=""

notify="dunstify -u low -t 1500"
options="$iconUP\n$icon80\n$iconDOWN"

## Main
chosen="$(echo -e "$options" | $rofi_command -p "Control" -dmenu -selected-row 1)"
case $chosen in
  $iconUP) echo $((`cat /sys/class/backlight/amdgpu_bl1/brightness` + 30)) | sudo tee /sys/class/backlight/amdgpu_bl1/brightness ;;
  $iconDOWN) echo $((`cat /sys/class/backlight/amdgpu_bl1/brightness` - 30)) | sudo tee /sys/class/backlight/amdgpu_bl1/brightness ;;
  $icon80) echo 206 | sudo tee /sys/class/backlight/amdgpu_bl1/brightness ;;
esac
