#!/usr/bin/env bash

iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"
icon="${iconpath}/bluetooth.svg"

bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent

function bt() {
  bluetoothctl connect ${1}
}

scan="Scan devices"
bt1="JBL"
bt2="KD-750"

devices="$scan\n$bt1\n$bt2"

chosen="$(echo -e "$devices" | wofi --lines 3 --sort-order=DEFAULT --dmenu -p "  Bluetooth")"
case $chosen in
    $scan)
      bluetoothctl scan on;;
    $bt1)
      bt "F1:32:33:23:43:4C";;
    $bt2)
      bt "F1:32:33:23:43:4C";;
esac
exit 0;
