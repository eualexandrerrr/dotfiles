#!/usr/bin/env bash

archPath="$HOME/GitHub/archiso"

pendrive=sdb

# Remova as últimas iso
tmpTrash() {
  sudo rm -rf /tmp/tmp*
  sudo rm -rf $HOME/Downloads/Arch/*.iso
}

upstreamArchiso() {
  # Reinstalando archiso para obter últimas mudanças
  sudo pacman -Rncs archiso --noconfirm
  rm -rf /usr/share/archiso
  sudo pacman -S archiso --noconfirm

  # Copiando o novo template
  rm -rf ${archPath}
  mkdir -p ${archPath}
  pwd=$(pwd)
  cd /usr/share/archiso/configs/releng
  cp -rf * ${archPath}
  cd $pwd
  sudo chown -R $USER:$USER ${archPath}
}

addPkgs() {
  echo "git" | tee -a ${archPath}/packages.x86_64
  echo "reflector" | tee -a ${archPath}/packages.x86_64
  echo "expect" | tee -a ${archPath}/packages.x86_64
}

addOhMyZsh() {
  pwd=$(pwd)
  sudo rm -rf /tmp/*
  curl -s -L -o /tmp/oh-my-zsh.tar.gz https://github.com/robbyrussell/oh-my-zsh/archive/master.tar.gz
  cd /tmp
  tar xf oh-my-zsh.tar.gz
  mv ohmyzsh-master .oh-my-zsh
  mv .oh-my-zsh ${archPath}/airootfs/root/
  cd $pwd

echo "ZSH_THEME=\"robbyrussell\"
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
export PATH=\$HOME/bin:\$PATH
export TERMINAL=xst
export EDITOR=nano
export GPG_TTY=$(tty)
export GPG_AGENT_INFO=""
export ZSH=\$HOME/.oh-my-zsh
source \$ZSH/oh-my-zsh.sh" | tee ${archPath}/airootfs/root/.zshrc
}

pacmanConfigs() {
  sed -i "/\[multilib\]/,/Include/"'s/^#//' ${archPath}/pacman.conf
  sed -i 's/#UseSyslog/UseSyslog/' ${archPath}/pacman.conf
  sed -i 's/#Color/Color\\\nILoveCandy/' ${archPath}/pacman.conf
  sed -i 's/Color\\/Color/' ${archPath}/pacman.conf
  sed -i 's/#TotalDownload/TotalDownload/' ${archPath}/pacman.conf
  sed -i 's/#CheckSpace/CheckSpace/' ${archPath}/pacman.conf
  sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" ${archPath}/pacman.conf
  sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 20/g" ${archPath}/pacman.conf
}

myWifi() {
  mkdir -p ${archPath}/airootfs/var/lib/iwd
  sudo cp -rf $HOME/GitHub/mywifi/iwd/*.psk ${archPath}/airootfs/var/lib/iwd
  sed -i '$d' ${archPath}/profiledef.sh
  echo -e "  [\"/var/lib/iwd\"]=\"0:0:0700\"\n)" | tee -a ${archPath}/profiledef.sh &> /dev/null
}

scriptStartup() {
  echo -e "\n\n
  loadkeys br-abnt2
  sleep 5
  git clone https://github.com/mamutal91/myarch /root/myarch\n
  zsh" | tee -a ${archPath}/airootfs/root/.automated_script.sh &> /dev/null
}

build() {
  sudo rm -rf $HOME/Downloads/Arch/*.iso
  sudo mkarchiso -v -w $(mktemp -d) -o $HOME/Downloads/Arch ${archPath}
}

penBootable() {
  iso=$(ls -1 $HOME/Downloads/Arch/*.iso)
  sudo dd if=${iso} of=/dev/${pendrive} status=progress && sync
}

run() {
  tmpTrash
  upstreamArchiso
  addPkgs
  addOhMyZsh
  pacmanConfigs
  myWifi
  scriptStartup
  build
}
run "$@"

source $HOME/.dotfiles/aew/.config/scripts/general.sh
#qemu
penBootable
