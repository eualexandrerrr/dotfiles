#!/usr/bin/env bash
# github.com/mamutal91

icon="${iconpath}/battery.svg"

bat="/sys/class/power_supply/BAT1"

while sleep 240
do
  level=$(cat "$bat"/capacity)
  status=$(cat "$bat"/status)

  if [ "$status" = "Discharging" ]; then
    if [ "$level" -le 10 ]; then
      notify-send -i $icon --urgency=low "Bateria está abaixo de 15%" "Por favor plugue-o na tomada!"
      play $HOME/.config/files/sounds/battery.wav
    fi
  else
    echo "Charging..."
    if [ "$level" -eq 98 ]; then
      notify-send -i $icon "Bateria está carrega!" "Pode remover da tomada!"
    elif [ "$level" -ge 80 ]; then
      notify-send -i $icon "Bateria está carregando acima de 80%" "Por favor tire-o da tomada!"
    fi
  fi
done
