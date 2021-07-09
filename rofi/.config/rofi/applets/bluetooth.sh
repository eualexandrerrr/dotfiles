#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/bluetooth.rasi"

bluetoothctl power on
bluetoothctl agent on
bluetoothctl default-agent

# Error msg
msg() {
  rofi -theme "$HOME/.config/rofi/message.rasi" -e "$1"
}

bt() {
  #  bluetoothctl trust ${1}
  #  bluetoothctl pair ${1}
  bluetoothctl scan off
  bluetoothctl connect ${1}
}

scan=""
disconect="􏈄"
bt1=""
bt2=""

# Variable passed to rofi
options="$scan\n$disconect\n$bt1\n$bt2"

chosen="$(echo -e $options | $rofi_command -p "Stay rock'n'roll" -dmenu -selected-row 0)"
case $chosen in
  $scan) bluetoothctl scan on ;;
  $disconect) bluetoothctl disconect ;;
  $bt1) bt "78:44:05:BE:8A:7E" ;; # JBL T450BT
  $bt2) bt "70:99:1C:51:45:9B" ;; # JBL GO 2
esac
exit 0
