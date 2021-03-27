#!/usr/bin/env bash

source $HOME/.Xcolors &> /dev/null

clear

sudo pacman -Syyu --noconfirm

aurMsg() {
  echo -e "${BOL_BLU}\nThe ${BOL_YEL}$i ${BOL_BLU}package is not in the official ${BOL_GRE}ArchLinux ${BOL_BLU}repositories...\n${BOL_BLU}Searching ${BOL_BLU}AUR ${BOL_BLU}package ${BOL_BLU}with ${BOL_BLU}yay${END}\n"
}

builderPackages=(
  android-tools android-udev base-devel git wget multilib-devel cmake svn clang lzip patchelf inetutils ccache \
  gcc-multilib gcc-libs-multilib binutils libtool-multilib lib32-libusb \
  lib32-readline lib32-glibc lib32-zlib python2 perl git gnupg flex bison gperf zip unzip sdl squashfs-tools \
  ncurses libpng zlib libusb libusb-compat readline inetutils android-sdk-platform-tools android-udev esd-oss pngcrush \
  repo tcp_wrappers termcap perl-switch
  )

for i in "${builderPackages[@]}"; do
  sudo pacman -S ${i} --needed --noconfirm && continue || aurMsg && yay -S ${i} --needed --noconfirm
  if [[ $? -eq 0 ]]; then
    echo "${BOL_GRE}${i} installed${END}"
  else
    echo " ${BOL_RED}#*#*#*#*#*#*#*"
    echo "${CYA}${i} ${BOL_RED}FAILURE${END}"
    exit 1
  fi
done

# FAILURE
# python2-distlib wxgtk
