#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-G0
xrandr --auto

xrdb -merge ~/.Xresources

fc-cache -f -r -v

exec i3
