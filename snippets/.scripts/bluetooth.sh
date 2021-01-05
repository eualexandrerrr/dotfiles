#!/usr/bin/env bash

iconpath="/usr/share/icons/Papirus-Dark/32x32/devices"
icon="${iconpath}/bluetooth.svg"

bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent

function bt() {
  bluetoothctl trust ${1}
  bluetoothctl pair ${1}
  bluetoothctl connect ${1}
}

scan="Scan devices"
bt1="JBL T450BT"
bt2="KD-750"
bt3="Scania BT"
bt4="JBL GO"

devices="$scan\n$bt1\n$bt2\n$bt3\n$bt4"

chosen="$(echo -e "$devices" | wofi --lines 5 --sort-order=DEFAULT --dmenu -p "  Bluetooth")"
case $chosen in
    $scan)
      bluetoothctl scan on;;
    $bt1)
      bt "78:44:05:BE:8A:7E";; # JBL T450BT
    $bt2)
      bt "F1:32:33:23:43:4C";; # KD-750
    $bt3)
      bt "28:56:C1:0C:9C:93";; # Scania BT
    $bt4)
      bt "78:44:05:86:21:18";; # JBL GO
esac
exit 0;
