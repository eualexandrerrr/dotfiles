#!/bin/bash
# github.com/mamutal91

app=bluetooth-jbl.png
icon=$iconsnotify/$app

bluetoothctl power on
bluetoothctl connect 78:44:05:BE:8A:7E

DISPLAY=:0 dbus-launch notify-send -i $icon "BLUETOOTH" "Conectando headset JBL"
