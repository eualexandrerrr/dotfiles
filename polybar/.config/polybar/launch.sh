#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch polybar (depending on multiple monitors or not)
if type "xrandr"; then
	for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
		MONITOR=$m polybar --reload cima &
		MONITOR=$m polybar --reload baixo &
	done
else
	polybar cima &
	polybar baixo &
fi