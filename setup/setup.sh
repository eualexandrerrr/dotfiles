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

# Fonts
echo -e "\n${BOL_GRE}Copying fonts${END}\n"
sudo mkdir -p /usr/share/fonts/TTF &> /dev/null
sudo cp -rf $HOME/.dotfiles/assets/.config/assets/fonts/* /usr/share/fonts/TTF
fc-cache -f -r -v &> /dev/null

# Install packages
InstallPacAur() {
  failed=()
  success=()

  packages=("$@")
  for package in "${packages[@]}"; do
    echo -e "\n${BLU}PACKAGE: ${BOL_BLU}${package}${END}"
    sudo pacman -S --needed --noconfirm ${package}
    RESULT=$?
    if [[ $RESULT -eq 0 ]]; then
      echo -e "${GRE}Pacman successfully installed ${MAG}${package}${END}"
      success+=($package)
    else
      echo -e "${RED}Pacman failed to install ${MAG}${package}${END} ${RED}trying to install with ${YEL}AUR${END}"
      yay -S --needed --noconfirm ${package}
      RESULT=$?
      if [[ $RESULT -eq 0 ]]; then
        echo -e "${GRE}AUR successfully installed ${MAG}${package}${END}"
        success+=($package)
      else
        echo -e "\n${BOL_RED} * Error:\n ${BOL_RED}* ${RED}AUR failed to install ${YEL}${package}${END}"
        failed+=($package)
      fi
    fi
  done
}

echo -e "\n${BOL_GRE}Installing packages${END}\n${MAG}"

InstallPkgs() {
  if [[ $USER != "mamutal91" ]]; then
    InstallPacAur ${dependencies[@]}
  else
    InstallPacAur ${dependencies[@]}
    InstallPacAur ${mypackages[@]}
    InstallPacAur ${builder[@]}
  fi
}
InstallPkgs

if [[ $HOST == "nitro5" ]]; then
  echo -e "\n${BOL_GRE}Installing packages ATOM${END}\n${MAG}"
  bash $HOME/.dotfiles/setup/atom.sh
  echo -e "${END}"

  # Copy fan config control
  sudo cp -rf $HOME/.dotfiles/assets/.config/assets/fans/Acer\ Nitro\ 5\ AN515-43.xml /opt/nbfc/Configs
  nbfc config -a "Acer Nitro 5 AN515-43"

  # Personal configs
  echo -e "\n${BOL_GRE}Running scripts for ${CYA}nitro5${END}\n"
  for i in $(ls $HOME/.dotfiles/setup/nitro5/*.sh); do
    chmod +x $i
    bash $i
  done
fi

# Enable systemd services
echo -e "\n${BOL_GRE}Enabling services ${CYA}nitro5${END}\n"
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

# Remove Kraken scripts
[[ $USER != "mamutal91" ]] && rm -rf $HOME/.dotfiles/aew/.config/scripts/kraken && rm -rf $HOME/.config/scripts/kraken

# Permissions
echo -e "\n${BOL_GRE}Set permissions${END}\n"
sudo chown -R $USER:$USER /home/$USER

# My configs
if [[ $USER == "mamutal91" ]]; then
  echo -e "\n${BOL_MAG}Você deseja reconfigurar suas ${BOL_CYA}configurações pessoais? ${GRE}(y/n) ${RED}[enter=no] ${END}\n"
  read answer
  if [[ $answer != ${answer#[Yys]} ]]; then
    echo -e "${BOL_GRE}Ok, reconfigurando ${BOL_MAG}configurações pessoais${END}\n"
    bash $HOME/.dotfiles/setup/myconfigs.sh
  else
    echo -e "${BOL_RED}Ok, não irei reconfigurar suas ${BOL_MAG}configurações pessoais${END}\n"
  fi

  # Chaotic kernel
  echo -e "\n${BOL_MAG}Você deseja instalar o kernel da ${BOL_CYA}chaotic? ${GRE}(y/n) ${RED}[enter=no] ${END}\n"
  read answer
  if [[ $answer != ${answer#[Yys]} ]]; then
    echo -e "${BOL_GRE}Ok, instalando kernel da ${BOL_MAG}chaotic${END}\n"
    bash $HOME/.dotfiles/setup/chaotic-kernel.sh
  else
    echo -e "${BOL_RED}Ok, não irei instalar o kernel da ${BOL_MAG}chaotic${END}\n"
  fi
fi

# Nvidia
echo -e "\n${BOL_MAG}Você deseja instalar o driver da ${BOL_CYA}nvidia? ${GRE}(y/n) ${RED}[enter=no] ${END}\n"
read answer
if [[ $answer != ${answer#[Yys]} ]]; then
  echo -e "${BOL_GRE}Ok, instalando drivers da ${BOL_MAG}nvidia${END}\n"
  bash $HOME/.dotfiles/setup/nvidia.sh
else
  echo -e "${BOL_RED}Ok, não irei instalar o driver da ${BOL_MAG}nvidia${END}\n"
fi

# Generate grub
echo -e "\n${BOL_MAG}Você deseja instalar gerar novamente o ${BOL_CYA}mkinitcpio/grub? ${GRE}(y/n) ${RED}[enter=no] ${END}\n"
read answer
if [[ $answer != ${answer#[Yys]} ]]; then
  echo -e "${BOL_GRE}Ok, gerando ${BOL_MAG}mkinitcpio/grub${END}\n"
  sudo mkinitcpio -P
  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
else
  echo -e "${BOL_RED}Ok, não irei gerar o ${BOL_MAG}mkinitcpio/grub${END}\n"
fi

# Remove folder GO
rm -rf $HOME/go &> /dev/null

# Stow
bash $HOME/.dotfiles/install.sh

# Resultados finais
echo -e "\n\n${BOL_GRE}Packages success:${GRE}\n"
for i in ${success[@]}; do
  echo -e "$i"
done
echo -e "${END}"

echo -e "\n\n${BOL_RED}Packages failed:${RED}\n"
for i in ${failed[@]}; do
  echo -e "$i"
done
echo -e "${END}"
