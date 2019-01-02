#!/bin/bash
# github.com/mamutal91

# bash <(curl -s -L http://bit.ly/mamutal91DOTFILES)

cd $HOME
rm -rf .dotfiles
git clone https://github.com/mamutal91/dotfiles .dotfiles && cd .dotfiles/scripts

./stow.sh