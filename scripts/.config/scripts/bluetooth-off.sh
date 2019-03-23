#!/bin/bash
# github.com/mamutal91

app=bluetooth-jbl.png
icon=$iconsnotify/$app

bluetoothctl power off

DISPLAY=:0 dbus-launch notify-send -i $icon "BLUETOOTH" "Desconectando..."
