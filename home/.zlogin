#!/usr/bin/env bash
# github.com/mamutal91

if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway
fi
