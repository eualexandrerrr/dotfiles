#!/usr/bin/env bash

rofi_command="rofi -theme $HOME/.config/rofi/applets/styles/bluetooth.rasi"

# Error msg
msg() {
  rofi -theme "$HOME/.config/rofi/message.rasi" -e "$1"
}

btConnect() {
  bluetoothctl power on
  bluetoothctl agent on
  bluetoothctl default-agent
  dunstify -i $HOME/.config/assets/icons/bluetooth.png "Bluetooth" "Scanning devices"
  timeout 5s bluetoothctl scan on
  bluetoothctl connect ${1}
  if [[ $? -eq 0 ]]; then
    dunstify -i $HOME/.config/assets/icons/bluetooth-${2}.png "Bluetooth" "${2} connected"
  else
    dunstify -i $HOME/.config/assets/icons/bluetooth.png "Bluetooth" "Connection failed!"
    exit 1
  fi

}

btOn() {
  bluetoothctl power on
  bluetoothctl agent on
  bluetoothctl default-agent
  timeout 10s bluetoothctl scan on
  dunstify -i $HOME/.config/assets/icons/bluetooth.png "Bluetooth" "Scanned devices"
}

btOff() {
  bluetoothctl power off
  dunstify -i $HOME/.config/assets/icons/bluetooth.png "Bluetooth" "Device off"
}

scan=""
disconect="􏈄"
bt1=""
bt2=""

# Variable passed to rofi
options="$bt1\n$bt2"

chosen="$(echo -e $options | $rofi_command -p "Rock'n'roll" -dmenu -selected-row 0)"
case $chosen in
  $bt1) btConnect "78:44:05:BE:8A:7E" headphone ;; # JBL T450BT
  $bt2) btConnect "70:99:1C:51:45:9B" JBLGo2 ;; # JBL GO 2
esac
exit 0
