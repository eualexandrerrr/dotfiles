#!/usr/bin/env bash

iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"
icon="${iconpath}/battery.svg"

bat="/sys/class/power_supply/BAT1"

while sleep 120
do
  level=$(cat "$bat"/capacity)
  status=$(cat "$bat"/status)

  if [[ "$status" = "Discharging" ]]; then
    if [[ "$level" -le 15 ]]; then
      notify-send -i $icon --urgency=low "Bateria está abaixo de 15%" "Por favor plugue-o na tomada!"
      play $HOME/.config/sounds/battery.wav
    fi
  done
