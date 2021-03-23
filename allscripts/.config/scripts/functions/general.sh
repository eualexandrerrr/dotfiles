#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.mytokens/.myTokens &> /dev/null

c() {
  if [[ ${2} == open ]]; then
    google-chrome-stable https://review.arrowos.net/q/project:ArrowOS/android_${1}+branch:arrow-12.0+status:open
  else
    google-chrome-stable https://review.arrowos.net/q/project:ArrowOS/android_${1}+branch:arrow-12.0+status:merged
  fi
}

agg() {
  ag -s ${1} .
}

newuser(){
  clear
  user=${1}
  sudo useradd ${user}
  sudo passwd ${user}
  sudo mkdir -p /home/${user}/.ssh
  sudo chown -R ${user}:${user} /home/${user}
  sudo chmod 700 ${user}/.ssh
  sudo touch ${user}/.ssh/authorized_keys
  sudo chmod 600 ${user}/.ssh/authorized_keys
}

infra() {
  echo -e "\n${BLU}Recloning ${CYA}infra ${BLU}to have the latest changes...${END}"
  ssh mamutal91@88.99.4.77 "cd $HOME && rm -rf /mnt/roms/infra && git clone ssh://git@github.com/AOSPK/infra /mnt/roms/infra"
}

www() {
  pwd=$(pwd)
  cd /mnt/roms/sites/docker/
  rm -rf website
  git clone ssh://git@github.com/AOSPK/website-wip website
  cd website
  sudo docker-compose stop
  sudo docker-compose build
  sudo docker-compose up -d
  cd $pwd
}

gerrit() {
  pwd=$(pwd)
  if [[ ${1} == restart ]]; then
    cd /mnt/roms/sites/docker/docker-files/gerrit
    sudo docker-compose stop
    sudo docker-compose restart
  else
    cd /mnt/roms/sites/docker/docker-files/gerrit
    sudo bash repl.sh
  fi
  cd $pwd
}

qemu() {
  $HOME/.config/scripts/qemu.sh ${1}
}

sideload() {
  sudo adb sideload "$HOME/Builds/Kraken-12-GApps-$(date +"%Y%m%d")-${1}-lmi-BETA.zip"
}

dot() {
  if [[ ${1} ]]; then
    cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc
  else
    echo -e "\n${BLU}Recloning ${CYA}dotfiles ${BLU}to have the latest changes...${END}"
    ssh mamutal91@88.99.4.77 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc"
    ssh mamutal91@138.201.224.156 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc"
  fi
}

bkp() {
  bash $HOME/.config/scripts/gitcron.sh
  ssh mamutal91@88.99.4.77 "bash $HOME/.config/scripts/gitcron.sh"
}

update() {
  $HOME/.config/scripts/update.sh
}
