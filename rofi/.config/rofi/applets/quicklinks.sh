#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/quicklinks.rasi"

# Error msg
msg() {
  rofi -theme "$HOME/.config/rofi/message.rasi" -e "$1"
}

atom=""
steam=""
spotify=""
telegram=""
mail=""
youtube=""

# Variable passed to rofi
options="$atom\n$steam\n$spotify\n$telegram\n$mail\n$youtube"

chosen="$(echo -e "$options" | $rofi_command -p "Fast click" -dmenu -selected-row 0)"
case $chosen in
    $atom)
        atom &
        ;;
    $steam)
        steam &
        ;;
    $spotify)
        echo 1;
        ;;
    $telegram)
        kotatogram-desktop &
        ;;
    $mail)
        google-chrome-stable https://www.gmail.com &
        ;;
    $youtube)
        google-chrome-stable https://www.youtube.com &
        ;;
esac
