#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.mytokens/.myTokens &> /dev/null

infra() {
  echo -e "\n${BLU}Recloning ${CYA}infra ${BLU}to have the latest changes...${END}"
  ssh mamutal91@86.109.7.111 "cd $HOME && rm -rf /mnt/roms/infra && git clone ssh://git@github.com/AOSPK/infra /mnt/roms/infra" &> /dev/null
}

qemu() {
  $HOME/.config/scripts/qemu.sh ${1}
}

dot() {
  if [[ ${1} ]]; then
    cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc
  else
    echo -e "\n${BLU}Recloning ${CYA}dotfiles ${BLU}to have the latest changes...${END}"
    ssh mamutal91@86.109.7.111 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc" &> /dev/null
    ssh mamutal91@5.217.146.43 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc" &> /dev/null
  fi
}

bkp() {
  bash $HOME/.config/scripts/gitcron.sh ${1}
  ssh mamutal91@86.109.7.111 "bash $HOME/.config/scripts/gitcron.sh"
  ssh mamutal91@5.217.146.43 "bash $HOME/.config/scripts/gitcron.sh"
}

update() {
  $HOME/.config/scripts/update.sh
}
