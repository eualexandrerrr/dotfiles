#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-G0
xrandr --auto

fc-cache -f -r -v

exec i3
