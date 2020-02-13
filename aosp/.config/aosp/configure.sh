#!/bin/bash
# github.com/mamutal91

mkdir -p /media/storage/.ccache
mkdir -p $aosp_dir/.pull_rebase

readonly PKGS_PACMAN=(
  repo lib32-gcc-libs git gnupg flex bison gperf sdl wxgtk2 squashfs-tools curl ncurses zlib schedtool
  perl-switch zip unzip libxslt python2-virtualenv bc rsync lib32-zlib lib32-ncurses lib32-readline lzop pngcrush imagemagick)

readonly PKGS_AUR=(
  ncurses5-compat-libs lib32-ncurses5-compat-libs xml2 lineageos-devel)

function install_pkgs_pacman(){
  for i in "${PKGS_PACMAN[@]}"; do
    sudo pacman -S ${i} --needed --noconfirm
  done
}

function install_pkgs_aur(){
  for i in "${PKGS_AUR[@]}"; do
    yay -S ${i} --needed --noconfirm
  done
}

gpg --keyserver pgp.mit.edu --search C52048C0C0748FEE227D47A2702353E0F7E48EDB # Required by ncurses5-compat-libs and lib32-ncurses5-compat-libs

install_pkgs_pacman
install_pkgs_aur
