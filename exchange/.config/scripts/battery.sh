#!/usr/bin/env bash
# github.com/mamutal91

icon="$HOME/.config/files/icons/battery.png"

bat="/sys/class/power_supply/BAT1"

while sleep 240
do
  LEVEL=$(cat "$bat"/capacity)
  STATUS=$(cat "$bat"/status)

  if [ "$STATUS" = "Discharging" ]; then
    if [ "$LEVEL" -le 10 ]; then
      notify-send -i $icon "Bateria está abaixo de 15%" "Por favor plugue-o na tomada!"
      play $HOME/.config/files/sounds/battery.wav
    fi
  else
    echo "Charging..."
#    if [ "$LEVEL" -eq 98 ]; then
#      notify-send -i $icon "Bateria está carrega!" "Pode remover da tomada!"
#    elif [ "$LEVEL" -ge 80 ]; then
#      notify-send -i $icon "Bateria está carregando acima de 80%" "Por favor tire-o da tomada!"
#    fi
  fi
done
