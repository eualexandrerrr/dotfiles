#!/usr/bin/env bash

source $HOME/.Xconfigs # My general configs

HOST=$(cat /etc/hostname)

clear

if [[ ! -d $HOME/.dotfiles ]]; then
  echo "For you to use this dotfiles, it must be located in your HOME, and hidden, the correct path is: ~/.dotfiles"
  exit
fi

# Update packages and keys
sudo pacman -Syyu --noconfirm
sudo pacman-key --populate archlinux

# Load packages
source $HOME/.dotfiles/setup/packages.sh

# Install YAY AUR Manager
if [[ ! -f $(which yay) ]]; then
  pwd=$(pwd)
  sudo pacman -Sy base-devel --noconfirm
  rm -rf $HOME/yay && git clone https://aur.archlinux.org/yay.git $HOME/yay && cd $HOME/yay && makepkg -si --noconfirm && rm -rf $HOME/yay
  cd $pwd
fi

checkIfPackageInstalled() {
  if [ $? -eq 0 ]; then
    echo -e "\n${BOL_GRE}The package ${BOL_MAG}${i} ${BOL_GRE}was successfully installed\n${END}"
  else
    echo -e "\n${BOL_RED}The package ${BOL_MAG}${i} ${BOL_RED}failure\n\nTry AGAIN!!!\n${END}"
    sleep 2000000000000
  fi
}

installDependencies() {
  for i in "${dependencies[@]}"; do
    if sudo pacman -Ss ${i} &> /dev/null; then
      sudo pacman -S ${i} --noconfirm
      checkIfPackageInstalled
    else
      yay -S ${i} --noconfirm
      checkIfPackageInstalled
    fi
  done
}

installMyPackages() {
  for i in "${mypackages[@]}"; do
    if sudo pacman -Ss ${i} &> /dev/null; then
      sudo pacman -S ${i} --noconfirm
      checkIfPackageInstalled
    else
      yay -S ${i} --noconfirm
      checkIfPackageInstalled
    fi
  done
}

installBuilder() {
  for i in "${builder[@]}"; do
    if sudo pacman -Ss ${i} &> /dev/null; then
      sudo pacman -S ${i} --noconfirm
      checkIfPackageInstalled
    else
      yay -S ${i} --noconfirm
      checkIfPackageInstalled
    fi
  done
}

installDependencies

if [[ $HOST == "modinx" ]]; then
  installMyPackages
  installBuilder

  # Configs
  sudo sed -i "s/#unix_sock_group/unix_sock_group/g" /etc/libvirt/libvirtd.conf
  sudo sed -i "s/#unix_sock_rw_perms/unix_sock_rw_perms/g" /etc/libvirt/libvirtd.conf

  # Copy fan config control
  sudo cp -rf $HOME/.dotfiles/assets/.config/assets/fans/Acer\ Nitro\ 5\ AN515-43.xml /opt/nbfc/Configs
  nbfc config -a "Acer Nitro 5 AN515-43"

  # Personal configs
  for i in $(ls $HOME/.dotfiles/setup/modinx/*.sh); do
    chmod +x $i
    bash $i
  done
fi

# Enable systemd services
for services in \
    cronie \
    bluetooth \
    libvirtd.service \
    laptop-mode.service \
    nbfc \
    getty@ttyN.service; do
    sudo systemctl enable $services
    sudo systemctl start $services
done

# Fonts
sudo mkdir -p /usr/share/fonts/TTF &> /dev/null
sudo cp -rf $HOME/.dotfiles/assets/.config/assets/fonts/* /usr/share/fonts/TTF
fc-cache -f -r -v &> /dev/null

# Remove Kraken scripts
[[ $USER != mamutal91 ]] && rm -rf $HOME/.dotfiles/aew/.config/scripts/kraken && rm -rf $HOME/.config/scripts/kraken

# Permissions
sudo chown -R $USER:$USER /home/$USER

# Generate grub
sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Remove folder GO
rm -rf $HOME/go &> /dev/null

# My configs
bash $HOME/.dotfiles/setup/myconfigs.sh

# Chaotic kernel
bash $HOME/.dotfiles/setup/chaotic-kernel.sh

# Stow
bash $HOME/.dotfiles/install.sh
