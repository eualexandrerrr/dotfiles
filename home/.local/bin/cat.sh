#!/bin/bash
# github.com/mamutal91

sudo -s
cat /home/mamutal91/github/dotfiles/i3/.config/i3/config \
    /home/mamutal91/github/dotfiles/i3/.config/i3/rules > /home/mamutal91/.config/i3/config
#exec /usr/bin/i3