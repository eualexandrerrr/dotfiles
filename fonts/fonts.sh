#!/usr/bin/env bash

pwd=$(pwd)
cd $HOME/.dotfiles/fonts
cp -rf * $HOME/.local/share/fonts
fc-cache -fv
cd $pwd
