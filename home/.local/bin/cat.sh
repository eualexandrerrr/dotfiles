#!/bin/bash
# github.com/mamutal91

cd $HOME/github/dotfiles/i3/.config/i3/

cat i3 rules > /tmp/i3config

sudo mv /tmp/i3config $HOME/.config/i3/config
