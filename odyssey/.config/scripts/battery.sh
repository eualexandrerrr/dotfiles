#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

icon="$HOME/.config/files/icons/battery.png"

bat="/sys/class/power_supply/BAT1"

while sleep 180
do
  LEVEL=$(cat "$bat"/capacity)
  STATUS=$(cat "$bat"/status)

  if [ "$STATUS" = "Discharging" ]; then
    if [ "$LEVEL" -le 15 ]; then
      DISPLAY=:0 dbus-launch notify-send -i $icon "Bateria está abaixo de 15%" "Precisa carregar! Por favor plugue-o na tomada!"
      canberra-gtk-play --file=$HOME/.config/files/sounds/battery.wav
    fi
  else
    echo "Charging..."
#    if [ "$LEVEL" -eq 98 ]; then
#      DISPLAY=:0 dbus-launch notify-send -i $icon "Bateria está carrega!" "Pode remover da tomada!"
#    elif [ "$LEVEL" -ge 80 ]; then
#      DISPLAY=:0 dbus-launch notify-send -i $icon "Bateria está carregando acima de 80%" "Por favor tire-o da tomada!"
#    fi
  fi
done
