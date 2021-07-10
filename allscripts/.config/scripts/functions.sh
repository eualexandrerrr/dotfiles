#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens &> /dev/null

infra() {
  echo -e "\n${BLU}Recloning ${CYA}infra ${BLU}to have the latest changes...${END}"
  ssh mamutal91@86.109.7.111 "cd $HOME && rm -rf /mnt/roms/infra && git clone ssh://git@github.com/AOSPK/infra /mnt/roms/infra" &> /dev/null
}

qemu() {
  $HOME/.config/scripts/qemu.sh ${1}
}

spotify() {
  echo "Starting daemon!"
  killall spotifyd
  spotifyd --config-path $HOME/.spotifyUserAndPass.conf &
  spt --config .spotifyClientId.conf
}
dot() {
  if [[ ${1} ]]; then
    cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc
  else
    echo -e "\n${BLU}Recloning ${CYA}dotfiles ${BLU}to have the latest changes...${END}"
    ssh mamutal91@86.109.7.111 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc" &> /dev/null
    ssh mamutal91@147.75.80.89 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc" &> /dev/null
  fi
}

bkp() {
  bash $HOME/.config/scripts/gitcron.sh ${1}
  ssh mamutal91@86.109.7.111 "bash $HOME/.config/scripts/gitcron.sh"
  ssh mamutal91@147.75.80.89 "bash $HOME/.config/scripts/gitcron.sh"
}

update() {
  $HOME/.config/scripts/update.sh
}
