#!/usr/bin/env bash

echo '# Enable debug mode for this module
# Set to 1 if you want to debug this module
DEBUG=0

#
# Should laptop mode tools control LCD brightness?
#
CONTROL_BRIGHTNESS=1


#
# Commands to execute to set the brightness on your LCD
#
BATT_BRIGHTNESS_COMMAND="echo 206"
BATT_BRIGHTNESS_COMMAND="echo 206"
NOBATT_BRIGHTNESS_COMMAND="echo 206"
BRIGHTNESS_OUTPUT="/sys/class/backlight/amdgpu_bl0/brightness"' | sudo tee /etc/laptop-mode/laptop-mode.conf &> /dev/null
