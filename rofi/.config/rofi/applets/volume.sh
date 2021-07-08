#!/usr/bin/env bash

formatStyle=square
rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/${formatStyle}/volume.rasi"

## Get Volume
#volume=$(amixer get Master | tail -n 1 | awk -F ' ' '{print $5}' | tr -d '[]%')
mute=$(amixer get Master | tail -n 1 | awk -F ' ' '{print $6}' | tr -d '[]%')

active=""
urgent=""

if [[ $mute == *"off"* ]]; then
    active="-a 1"
else
    urgent="-u 1"
fi

if [[ $mute == *"off"* ]]; then
    active="-a 1"
else
    urgent="-u 1"
fi

if [[ $mute == *"on"* ]]; then
    volume="$(amixer get Master | tail -n 1 | awk -F ' ' '{print $5}' | tr -d '[]%')%"
else
    volume="Mute"
fi

## Icons
iconUp=""
iconDown=""
iconMute=""

options="$iconUp\n$iconMute\n$iconDown"

## Main
chosen="$(echo -e "$options" | $rofi_command -p "$volume" -dmenu $active $urgent -selected-row 0)"
case $chosen in
    $iconUp)
        amixer -Mq set Master,0 5%+ unmute && dunstify -u low -t 1500 "Volume Up $iconUp"
        ;;
    $iconDown)
        amixer -Mq set Master,0 5%- unmute && dunstify -u low -t 1500 "Volume Down $iconDown"
        ;;
    $iconMute)
        amixer -q set Master toggle
        ;;
esac
