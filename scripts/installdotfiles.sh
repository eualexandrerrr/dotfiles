#!/bin/bash
# github.com/mamutal91

# bash <(curl -s -L http://bit.ly/mamutal91DOTFILES)

cd $HOME
rm -rf githubteste
mkdir githubteste && cd githubteste
git clone https://github.com/mamutal91/dotfiles && cd dotfiles

cd scripts
./update.sh