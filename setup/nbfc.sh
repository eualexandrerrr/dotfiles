#!/usr/bin/env bash

sudo cp -rf $HOME/.dotfiles/assets/.config/assets/fans/Acer\ Nitro\ 5\ AN515-43.xml /opt/nbfc/Configs
nbfc config -a "Acer Nitro 5 AN515-43"

nbfc
sudo systemctl enable nbfc
sudo systemctl start nbfc
