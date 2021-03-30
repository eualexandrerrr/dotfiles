#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

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

newuser() {
  clear
  user=${1}
  if [[ $(cat /etc/hostname) == "builders" ]]; then
    sudo adduser ${user}
  else
    sudo useradd ${user}
    sudo passwd ${user}
  fi
  sudo mkdir -p /home/${user}/.ssh &> /dev/null
  sudo chown -R ${user}:${user} /home/${user} &> /dev/null
  sudo chmod 700 ${user}/.ssh &> /dev/null
  sudo touch ${user}/.ssh/authorized_keys &> /dev/null
  sudo chmod 600 ${user}/.ssh/authorized_keys &> /dev/null
}

jenkins() {
  cd /mnt/docker-files/jenkins
  docker-compose build
  docker-compose up -d
}

dockerfiles() {
  echo -e "\n${BLU}Recloning ${CYA}docker-files ${BLU}to have the latest changes...${END}"
  ssh mamutal91@88.99.4.77 "cd $HOME && sudo rm -rf /mnt/docker-files && git clone ssh://git@github.com/AOSPK/docker-files /mnt/docker-files && source $HOME/.zshrc && jenkins &> /dev/null"
}

buildersbr() {
  echo -e "\n${BLU}Recloning ${CYA}buildersbr ${BLU}to have the latest changes...${END}"
  ssh mamutal91@138.201.224.156 "cd $HOME && sudo rm -rf /mnt/roms/buildersbr && git clone ssh://git@github.com/buildersbr/buildersbr /mnt/roms/buildersbr"
}

www() {
  pwd=$(pwd)
  cd /mnt/
  rm -rf website
  git clone ssh://git@github.com/AOSPK/website website
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
  cd $HOME/Builds
  if [[ ${1} == "overlays" ]]; then
    zip=Kraken_overlays.zip
  else
    zip=$(ls Kraken-12-*-*-${1}-lmi*.zip)
  fi
  sudo adb sideload ${zip}
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
