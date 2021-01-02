#!/usr/bin/env bash

icon="${iconpath}/battery.svg"

bat="/sys/class/power_supply/BAT1"

while sleep 120
do
  level=$(cat "$bat"/capacity)
  status=$(cat "$bat"/status)

  if [[ "$status" = "Discharging" ]]; then
    if [[ "$level" -le 15 ]]; then
      notify-send -i $icon --urgency=low "Bateria está abaixo de 15%" "Por favor plugue-o na tomada!"
      play $HOME/.sounds/battery.wav
    fi
  done
