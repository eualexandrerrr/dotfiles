#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/quicklinks.rasi"

# Error msg
msg() {
  rofi -theme "$HOME/.config/rofi/message.rasi" -e "$1"
}

atom=""
steam=""
spotify=""
fancontrol=""
mail=""
youtube=""

# Variable passed to rofi
options="$atom\n$steam\n$spotify\n$fancontrol\n$mail\n$youtube"

chosen="$(echo -e "$options" | $rofi_command -p "Fast click" -dmenu -selected-row 0)"
case $chosen in
    $atom)
        atom &
        ;;
    $steam)
        steam &
        ;;
    $spotify)
        spotify &
        ;;
    $fancontrol)
        $HOME/.config/scripts/fancontrol.sh
        ;;
    $mail)
        google-chrome-stable https://www.gmail.com &
        ;;
    $youtube)
        google-chrome-stable https://www.youtube.com &
        ;;
esac
