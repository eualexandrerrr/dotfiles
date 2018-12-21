#!/bin/bash
# github.com/mamutal91

res=$(echo "Desligar;Bloquear;Reiniciar" | rofi -sep ";" -dmenu -p "Menu de energia" -bw 0 -separator-style none -location 0 -width 20 -lines 3 -padding 5)
if [ ! -z $res ]; then
  case $res in
    Desligar)
      sudo poweroff
    ;;
    Bloquear)
      cd $HOME/.config/scripts/ && ./i3lock.sh &
    ;;
    Reiniciar)
      sudo reboot
    ;;
  esac
fi
