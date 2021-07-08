#!/usr/bin/env bash

killall -q polybar
polybar -q main -c $HOME/.config/polybar/config.ini &
