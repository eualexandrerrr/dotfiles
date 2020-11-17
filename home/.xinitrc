#!/bin/bash
# github.com/mamutal91

xrdb -merge ~/.Xresources
exec i3
xinput --set-prop 13 'libinput Accel Speed' 0.5
