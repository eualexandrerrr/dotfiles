#!/usr/bin/env bash

icon="${iconpath}/bluetooth.svg"

bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent

device="F1:32:33:23:43:4C"

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
      bluetoothctl scan on && notify-send -i $icon "Bluetooth" "A lista de dispositivos disponíveis foi atualizada!";;
    $bt1)
      bt "F1:32:33:23:43:4C";;
    $bt2)
      bt "F1:32:33:23:43:4C";;
esac
exit 0;
























bt1="JBL"
bt2="KD"

bts="$b1\n$bt2"

chosen="$(echo -e "$bts" | wofi --lines 3 --sort-order=DEFAULT --dmenu -p " X Bluetooth")"
case $chosen in
    $bt1)
        bluetooth "X";;
    $bt2)
        bluetooth "F1:32:33:23:43:4C";;
esac
exit 0;
