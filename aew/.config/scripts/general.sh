#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

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
