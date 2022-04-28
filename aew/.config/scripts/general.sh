#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

c() {
  if [[ ${2} == los ]]; then
    google-chrome-stable https://review.lineageos.org/q/project:LineageOS/android_${1}+branch:lineage-19.1+status:merged
  else
#    google-chrome-stable https://review.arrowos.net/q/project:ArrowOS/android_${1}+branch:arrow-12.1+status:merged
#    google-chrome-stable https://github.com/ArrowOS/android_${1}/commits/arrow-12.1
    google-chrome-stable https://github.com/AOSPK/${1}/commits/twelve
    google-chrome-stable https://github.com/AOSPK-Next/${1}/commits/twelve --new-window
  fi
}

iso() {
  bash $HOME/.dotfiles/aew/.config/scripts/archiso.sh
}

agg() {
  ag -S ${1} . --hidden
}

qemu() {
  sudo sed -i "s/#unix_sock_group/unix_sock_group/g" /etc/libvirt/libvirtd.conf
  sudo sed -i "s/#unix_sock_rw_perms/unix_sock_rw_perms/g" /etc/libvirt/libvirtd.conf
  $HOME/.config/scripts/dot/qemu.sh ${1}
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

sideload() {
  buildHour=${1}
  pathBuilds=$HOME/Builds
  if [[ -z ${1} ]]; then
    clear
    ls -1 $pathBuilds
  else
    if [[ ${1} == "magisk" ]]; then
      sudo adb sideload $HOME/Downloads/Magisk-v24.3.apk
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
        if (adb shell getprop ro.kraken.device | grep -q "${KRAKEN_BUILD}"); then
          echo "Rebooting to sideload for install"
          adb reboot sideload-auto-reboot
          adb wait-for-sideload
          adb sideload $zipPath
        else
          echo "The connected device does not appear to be ${BOL_RED}${KRAKEN_BUILD}${END}, run away!"
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
  bash $HOME/.config/scripts/dot/gitcron.sh
}

update() {
  $HOME/.config/scripts/dot/update.sh
}
