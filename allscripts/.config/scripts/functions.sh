#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.mytokens/.myTokens &> /dev/null

newuser(){
  user=${1}
  sudo useradd ${user}
  sudo passwd ${user}
  sudo mkdir -p /home/${user}
  sudo chown -R ${user}:${user} /home/${user}
}

infra() {
  echo -e "\n${BLU}Recloning ${CYA}infra ${BLU}to have the latest changes...${END}"
  ssh mamutal91@75.119.145.181 "cd $HOME && rm -rf /mnt/roms/infra && git clone ssh://git@github.com/AOSPK/infra /mnt/roms/infra" &> /dev/null
}

qemu() {
  $HOME/.config/scripts/qemu.sh ${1}
}

dot() {
  if [[ ${1} ]]; then
    cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc
  else
    echo -e "\n${BLU}Recloning ${CYA}dotfiles ${BLU}to have the latest changes...${END}"
    ssh mamutal91@75.119.145.181 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc" &> /dev/null
    ssh mamutal91@75.119.145.183 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc" &> /dev/null
  fi
}

bkp() {
  bash $HOME/.config/scripts/gitcron.sh
  ssh mamutal91@75.119.145.181 "bash $HOME/.config/scripts/gitcron.sh"
}

update() {
  $HOME/.config/scripts/update.sh
}
