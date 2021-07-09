#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/volume.rasi"

## Icons
iconUp=""
iconDown=""
iconMute=""

options="$iconUp\n$iconMute\n$iconDown"

## Main
chosen="$(echo -e "$options" | $rofi_command -p "$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n 2 | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')%" -dmenu $active $urgent -selected-row 0)"
case $chosen in
    $iconUp)
        pactl set-sink-mute @DEFAULT_SINK@ false
        pactl set-sink-volume @DEFAULT_SINK@ +15%
        ;;
    $iconDown)
        pactl set-sink-mute @DEFAULT_SINK@ false
        pactl set-sink-volume @DEFAULT_SINK@ -15%
        ;;
    $iconMute)
        pactl set-sink-mute @DEFAULT_SINK@ true
        ;;
esac
