#!/usr/bin/env bash

archPath="$HOME/GitHub/archiso"

# Remova as últimas iso
tmpTrash() {
  sudo rm -rf /tmp/tmp*
  sudo rm -rf $HOME/Downloads/Arch/*.iso
}

upstreamArchiso() {
  # Reinstalando archiso para obter últimas mudanças
  sudo pacman -Rncs archiso --noconfirm &> /dev/null
  rm -rf /usr/share/archiso
  sudo pacman -S archiso --noconfirm &> /dev/null

  # Copiando o novo template
  rm -rf ${archPath}
  cp -r /usr/share/archiso/configs/releng ${archPath}
}

addPkgs() {
  echo git >> ${archPath}/packages.x86_64
  echo reflector >> ${archPath}/packages.x86_64
}

addOhMyZsh() {
  echo "Adding oh-my-zsh"
  mkdir -p ${archPath}/airootfs/etc/skel/.oh-my-zsh
  [ -f /tmp/oh-my-zsh.tar.gz ] || curl -s -L -o /tmp/oh-my-zsh.tar.gz https://github.com/robbyrussell/oh-my-zsh/archive/master.tar.gz
  [ -d /tmp/ohmyzsh-master ] || (cd /tmp && tar xf oh-my-zsh.tar.gz)
  cp -rf /tmp/ohmyzsh-master ${archPath}/airootfs/etc/root/.oh-my-zsh

  # Remover grml-zsh-config, já tenho como padrão em .zshrc
  sed -i 's/grml-zsh-config//g' ${archPath}/packages.x86_64

cat << EOF | tee ${archPath}/airootfs/etc/root/.zshrc
export PATH=\$HOME/bin:\$PATH
export PATH="\$PATH:\$(ruby -e 'puts Gem.user_dir')/bin"
export TERMINAL=xst
export GPG_TTY=\$(tty)
export GPG_AGENT_INFO=""
export ZSH=\$HOME/.oh-my-zsh
# Oh-my-zsh
ZSH_THEME="robbyrussell"
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
source \$ZSH/oh-my-zsh.sh
alias vifm=vifmrun
EOF
}

pacmanConfigs() {
  sed -i "/\[multilib\]/,/Include/"'s/^#//' ${archPath}/pacman.conf
  sed -i 's/#UseSyslog/UseSyslog/' ${archPath}/pacman.conf
  sed -i 's/#Color/Color\\\nILoveCandy/' ${archPath}/pacman.conf
  sed -i 's/Color\\/Color/' ${archPath}/pacman.conf
  sed -i 's/#TotalDownload/TotalDownload/' ${archPath}/pacman.conf
  sed -i 's/#CheckSpace/CheckSpace/' ${archPath}/pacman.conf
  sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" ${archPath}/pacman.conf
  sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 3/g" ${archPath}/pacman.conf
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
  sudo dd if=${iso} of=/dev/sdc status=progress && sync
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
  penBootable
}
run "$@"
