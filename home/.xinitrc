#!/bin/sh

xrandr --setprovideroutputsource modesetting NVIDIA-G0
xrandr --auto

exec i3
