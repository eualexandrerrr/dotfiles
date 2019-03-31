#!/bin/bash
# github.com/mamutal91

res=$(echo "Desligar;Bloquear;Encerrar;Reiniciar" | rofi -sep ";" -dmenu -p "Menu de energia" -bw 0 -separator-style none -location 0 -width 20 -lines 4 -padding 5)
if [ ! -z $res ]; then
  case $res in
    Desligar)
      poweroff
    ;;
    Bloquear)
      $HOME/.local/bin/i3lock.sh &
    ;;
    Encerrar)
      sudo pkill -9 -u $USER
    ;;
    Reiniciar)
      reboot
    ;;
  esac
fi
