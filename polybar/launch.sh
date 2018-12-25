#!/bin/bash
# github.com/mamutal91

killall -q polybar

polybar cima &
polybar baixo &

echo "POLYBAR: Barras iniciadas..."