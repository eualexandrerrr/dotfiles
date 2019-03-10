#!/bin/bash
# github.com/mamutal91

killall -q polybar

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload up &
    MONITOR=$m polybar --reload down &
  done
else
  polybar --reload up &
  sleep 1s
  polybar --reload down &
fi
