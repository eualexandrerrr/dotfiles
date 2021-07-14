#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-G0
xrandr --auto

xrdb -merge $HOME/.Xresources

exec i3
