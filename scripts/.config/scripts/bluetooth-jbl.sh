#!/bin/bash
# github.com/mamutal91
# https://www.youtube.com/channel/UCbTjvrgkddVv4iwC9P2jZFw

app=bluetooth-jbl.png
icon=$icons/$app

var=${1}

if [ $var != "on" ]; then
  bluetoothctl power off
  DISPLAY=:0 dbus-launch notify-send -i $icon "BLUETOOTH" "Desconectando..."
else
  bluetoothctl power on
  bluetoothctl connect 78:44:05:BE:8A:7E
  DISPLAY=:0 dbus-launch notify-send -i $icon "BLUETOOTH" "Conectando headset JBL"
fi
