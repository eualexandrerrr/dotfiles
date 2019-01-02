#!/bin/bash
# github.com/mamutal91

# curl -s -L http://bit.ly/mamutal91DOTFILES | bash

cd $HOME
rm -rf github
mkdir github && cd github
git clone https://github.com/mamutal91/dotfiles && cd dotfiles

cd scripts
./update.sh