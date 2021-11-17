#!/usr/bin/env bash

clear

sudo pacman -Syyu

aospPkgs=(
  base-devel repo android-tools android-udev git wget multilib-devel cmake svn clang lzip patchelf inetutils python2-distlib
  ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel android-tools android-udev
)

aurMsg() {
  echo -e "${BOL_RED}\nThe ${BOL_YEL}$i ${BOL_RED}package is not in the official ${BOL_GRE}ArchLinux ${BOL_RED}repositories...\n${BOL_RED}Searching ${BOL_BLU}AUR ${BOL_RED}package ${BOL_RED}with ${BOL_BLU}yay${END}\n"
}

echo -e "\n${BOL_MAG}Installing dependencies!${END}\n"
for i in "${aospPkgs[@]}"; do
  sudo pacman -S ${i} --needed --noconfirm && continue || aurMsg && yay -S ${i} --needed --noconfirm
done
