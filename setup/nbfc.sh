#!/usr/bin/env bash

sudo cp -rf $HOME/.dotfiles/assets/.config/assets/fans/Acer\ Nitro\ 5\ AN515-43.xml /opt/nbfc/Configs

nbfcService="nbfc"

sudo systemctl enable $nbfcService
sudo systemctl start $nbfcService

nbfc config -a "Acer Nitro 5 AN515-43"
