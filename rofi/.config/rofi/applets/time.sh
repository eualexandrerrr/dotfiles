#!/usr/bin/env bash

formatStyle=square
rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/${formatStyle}/time.rasi"

## Get time and date
TIME="$(date +"%I:%M %p")"
DN=$(date +"%A")
MN=$(date +"%B")
DAY="$(date +"%d")"
MONTH="$(date +"%m")"
YEAR="$(date +"%Y")"

options="$DAY\n$MONTH\n$YEAR"

## Main
chosen="$(echo -e "$options" | $rofi_command -p "   $DN, $TIME" -dmenu -selected-row 1)"
