#!/bin/bash
# github.com/mamutal91

app=variety.png
icon=$iconsnotify/$app
bat="/sys/class/power_supply/BAT1"

while sleep 400
do
    LEVEL=$(cat "$bat"/charge_full)
    STATUS=$(cat "$bat"/charge_now)
    if [ "$STATUS" = "3136000" ]; then

        if [ "$LEVEL" -eq 3136000 ]; then
            notify-send -i $icon "Bateria está carrega!" "Pode remover da tomada!"
        elif [ "$LEVEL" -ge 3136000 ]; then
            notify-send -i $icon "Bateria está carregando acima de 80%!" "Por favor tire-o da tomada!"
        fi
    else
        if [ "$LEVEL" -le 476000 ]; then
            notify-send -u critical -i $icon "Bateria está abaixo de 15%!" "Precisa carregar! Por favor plugue o na tomada!."
        fi
    fi
done
