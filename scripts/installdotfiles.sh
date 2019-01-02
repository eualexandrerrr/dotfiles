#!/bin/bash
# github.com/mamutal91

# sh -c "$(wget http://bit.ly/mamutal91DOTFILES -O -)"

sudo -s

cd $HOME
rm -rf githubteste
mkdir githubteste && cd githubteste
git clone https://github.com/mamutal91/dotfiles && cd dotfiles

cd scripts
./update.sh