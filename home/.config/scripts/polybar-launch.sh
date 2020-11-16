#!/bin/bash
# github.com/mamutal91

killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload up &
    MONITOR=$m polybar --reload down &
  done
else
  sleep 3
  polybar --reload up &
  polybar --reload down &
fi
