#!/usr/bin/env bash

killall -q polybar

while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

polybar main -c ~/.config/polybar/config &
polybar down -c ~/.config/polybar/config &
