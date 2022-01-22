#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null
source $HOME/.myTokens/tokens.sh &> /dev/null

HOST=$(cat /etc/hostname)

clear

if [[ ! -d $HOME/.dotfiles ]]; then
  echo "For you to use this dotfiles, it must be located in your HOME, and hidden, the correct path is: ~/.dotfiles"
  exit
fi

# Install YAY AUR Manager
if [[ ! -f $(which yay) ]]; then
  pwd=$(pwd)
  sudo pacman -Sy base-devel --noconfirm
  rm -rf $HOME/yay && git clone https://aur.archlinux.org/yay.git $HOME/yay && cd $HOME/yay && makepkg -si --noconfirm && rm -rf $HOME/yay
  cd $pwd
fi

# pacman keys
sudo pacman-key --populate archlinux

# Load packages
source $HOME/.dotfiles/setup/packages.sh

aurMsg() {
  echo -e "${BOL_BLU}\nThe ${BOL_YEL}$i ${BOL_BLU}package is not in the official ${BOL_GRE}ArchLinux ${BOL_BLU}repositories...\n${BOL_BLU}Searching ${BOL_BLU}AUR ${BOL_BLU}package ${BOL_BLU}with ${BOL_BLU}yay${END}\n"
}

checkInstallPkg() {
  if [[ $? -eq 0 ]]; then
    echo "${BOL_GRE}${i} installed${END}"
  else
    echo " ${BOL_RED}#*#*#*#*#*#*#*"
    echo "${CYA}${i} ${BOL_RED}FAILURE${END}"
    exit 1
  fi
}

echo -e "\n${BOL_MAG}Installing dependencies!${END}\n"
for i in "${dependencies[@]}"; do
  sudo pacman -S ${i} --needed --noconfirm && continue || aurMsg && yay -S ${i} --needed --noconfirm
  checkInstallPkg
done


if [[ $HOST == modinx ]]; then
  for i in "${mypackages[@]}"; do
    sudo pacman -S ${i} --needed --noconfirm && continue || aurMsg && yay -S ${i} --needed --noconfirm
    checkInstallPkg
  done

  # Configs
  sudo sed -i "s/#unix_sock_group/unix_sock_group/g" /etc/libvirt/libvirtd.conf
  sudo sed -i "s/#unix_sock_rw_perms/unix_sock_rw_perms/g" /etc/libvirt/libvirtd.conf

  # Copy fan config control
  sudo cp -rf .dotfiles/assets/.config/assets/fans/Acer\ Nitro\ 5\ AN515-43.xml /opt/nbfc/Configs
  nbfc config -a "Acer Nitro 5 AN515-43"

  # Generate grub
  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Enable systemd services
for services in \
    cronie \
    bluetooth \
    mpd \
    mopidy \
    libvirtd.service \
    laptop-mode.service \
    nbfc \
    getty@ttyN.service; do
    sudo systemctl enable $services &> /dev/null
    sudo systemctl start $services &> /dev/null
done

# Remove folder GO
rm -rf $HOME/go &> /dev/null

# Fonts
sudo mkdir -p /usr/share/fonts/TTF &> /dev/null
sudo cp -rf $HOME/.dotfiles/assets/.config/assets/fonts/* /usr/share/fonts/TTF
fc-cache -f -r -v &> /dev/null

# Remove Kraken scripts
[[ $USER != mamutal91 ]] && rm -rf $HOME/.dotfiles/aew/.config/scripts/kraken && rm -rf $HOME/.config/scripts/kraken

if [[ $HOST == modinx ]]; then
  for i in $(ls $HOME/.dotfiles/setup/personalconfigs/*.sh); do
    chmod +x $i
    bash $i
  done
fi

sudo chown -R $USER:$USER /home/$USER

bash $HOME/.dotfiles/install.sh
