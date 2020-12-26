#!/usr/bin/env bash
# github.com/mamutal91

icon="${iconpath}/battery.svg"

bat="/sys/class/power_supply/BAT1"

while sleep 120
do
  level=$(cat "$bat"/capacity)
  status=$(cat "$bat"/status)

  if [ "$status" = "Discharging" ]; then
    if [ "$level" -le 15 ]; then
      notify-send -i $icon --urgency=low "Bateria está abaixo de 15%" "Por favor plugue-o na tomada!"
      play $HOME/.bin/sounds/battery.wav
    fi
  else
    echo "Charging..."
    if [ "$level" -eq 80 ]; then
      notify-send -i $icon "Bateria está 80% carregada!" "Pode remover da tomada!"
    fi
  fi
done
