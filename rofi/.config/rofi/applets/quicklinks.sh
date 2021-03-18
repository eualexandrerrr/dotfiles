#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/quicklinks.rasi"

# Error msg
msg() {
  rofi -theme "$HOME/.config/rofi/message.rasi" -e "$1"
}

atom=""
discord=""
steam=""
spotify=""
fancontrol=""
youtube=""

# Variable passed to rofi
options="$atom\n$discord\n$steam\n$spotify\n$fancontrol\n$youtube"

chosen="$(echo -e "$options" | $rofi_command -p "Fast click" -dmenu -selected-row 0)"
case $chosen in
  $atom) atom & ;;
  $discord) discord & ;;
  $steam) nbfc set -s 100 && steam & ;;
  $spotify) spotify & ;;
  $fancontrol) $HOME/.config/scripts/fancontrol.sh ;;
  $youtube) google-chrome-stable https://www.youtube.com & ;;
esac
