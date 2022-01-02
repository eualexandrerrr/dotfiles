#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

c() {
  if [[ ${2} == open ]]; then
    google-chrome-stable https://gerrit.pixelexperience.org/q/project:${1}+branch:twelve+status:open
  else
    google-chrome-stable https://gerrit.pixelexperience.org/q/project:${1}+branch:twelve+status:merged
  fi
}

agg() {
  ag -S ${1} .
}

sx() {
  echo -e "${BOL_RED}Verificando strings da PE${END}\n"
  ag -S pixelexp . --ignore-dir=out
  find . -name "pixelexp*"
  if [[ ${1} == -f ]]; then
    for i in $(ag -S pixelexp . -l --ignore-dir=out); do
      sed -i "s/The PixelExperience Project/The XXX Project/" ${i} &> /dev/null
      sed -i "s/PixelExperience/Kraken/" ${i} &> /dev/null
      sed -i "s/pixelExperience/kraken/" ${i} &> /dev/null
      sed -i "s/Pixelexperience/Kraken/" ${i} &> /dev/null
      sed -i "s/org.pixelexperience/org.pixelexperience/" ${i} &> /dev/null
      sed -i "s/pixelexperience/kraken/" ${i} &> /dev/null
      sed -i "s/The XXX Project/The PixelExperience Project/" ${i} &> /dev/null
    done
    echo -e "\n${BOL_RED}Status:${END}"
    git status  
  fi
}

newuser() {
  clear
  user=${1}
  sudo useradd ${user}
  sudo passwd ${user}
  sudo mkdir -p /home/${user}/.ssh &> /dev/null
  sudo chown -R ${user}:${user} /home/${user} &> /dev/null
  sudo chmod 700 ${user}/.ssh &> /dev/null
  sudo touch ${user}/.ssh/authorized_keys &> /dev/null
  sudo chmod 600 ${user}/.ssh/authorized_keys &> /dev/null
}

dockerfiles() {
  echo -e "\n${BLU}Recloning ${CYA}docker-files ${BLU}to have the latest changes...${END}"
#  ssh mamutal91@88.198.53.190 "cd $HOME && sudo rm -rf /mnt/docker-files && git clone ssh://git@github.com/AOSPK/docker-files /mnt/docker-files"
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
  ssh mamutal91@88.198.53.190 "cd /mnt/docker-files/gerrit && sudo docker-compose build && sudo docker-compose up -d"
}

qemu() {
  $HOME/.config/scripts/qemu.sh ${1}
}

sideload() {
  buildHour=${1}
  pathBuilds=$HOME/Builds
  if [[ -z ${1} ]]; then
    clear
    ls -1 $pathBuilds
  else
    if [[ ${1} == "-r" ]]; then
      buildHour=${2}
      zipPath=$(ls -tr "${pathBuilds}"/Kraken-*${buildHour}*.zip | tail -1)
      adb sideload $zipPath
    else
      if [ "${pathBuilds}" ]; then
        if [ ! -f $zipPath ]; then
          echo "Nothing to eat"
          return 1
        fi
        zipPath=$(ls -tr "${pathBuilds}"/Kraken-*${buildHour}*.zip | tail -1)
        echo "Waiting for device..."
        adb wait-for-device-recovery
        echo "Found device"
        if (adb shell getprop org.kraken.device | grep -q "${CUSTOM_BUILD}"); then
          echo "Rebooting to sideload for install"
          adb reboot sideload-auto-reboot
          adb wait-for-sideload
          adb sideload $zipPath
        else
          echo "The connected device does not appear to be ${BOL_RED}${CUSTOM_BUILD}${END}, run away!"
        fi
          return $?
      else
          echo "Nothing to eat"
          return 1
      fi
    fi
  fi
}

dot() {
  if [[ ${1} ]]; then
    cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && source $HOME/.zshrc
  else
    echo -e "\n${BLU}Recloning ${CYA}dotfiles ${BLU}to have the latest changes...${END}"
#    ssh mamutal91@88.198.53.190 "cd $HOME && rm -rf .dotfiles && git clone ssh://git@github.com/mamutal91/dotfiles .dotfiles && bash $HOME/.dotfiles/install.sh && source $HOME/.zshrc"
  fi
}

bkp() {
  bash $HOME/.config/scripts/gitcron.sh
}

update() {
  $HOME/.config/scripts/update.sh
}
