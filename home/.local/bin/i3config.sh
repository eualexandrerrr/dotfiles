#!/bin/bash
# github.com/mamutal91

cd $HOME/github/dotfiles/i3/.config/i3/

cat config \
    rules > /tmp/i3config

rm -rf $HOME/.config/i3/config
sudo mv /tmp/i3config $HOME/.config/i3/config