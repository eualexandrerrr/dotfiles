#!/bin/bash
# github.com/mamutal91

icon="$HOME/.config/files/icons/bluetooth-jbl.png"

var=${1}

if [ $var != "on" ]; then
  bluetoothctl power off
  notify-send -i $icon "BLUETOOTH" "Desconectando..."
else
  bluetoothctl power on
  bluetoothctl connect 78:44:05:BE:8A:7E
  notify-send -i $icon "BLUETOOTH" "Conectando headset JBL"
fi
