#!/bin/bash
# github.com/mamutal91

mkdir -p /media/storage/.ccache
mkdir -p $aosp_dir/.pull_rebase

readonly PKGS_PACMAN=(
  bc bison
  ccache curl
  flex
  git-lfs gnupg gperf gradle
  imagemagick
  lib32-gcc-libs lib32-ncurses lib32-readline lib32-zlib libxslt lzop
  maven
  ncurses
  perl-switch pngcrush python2-virtualenv
  repo rsync
  schedtool sdl squashfs-tools
  unzip
  wxgtk2
  zip zlib)

readonly PKGS_AUR=(
  lib32-ncurses5-compat-libs lineageos-devel
  ncurses5-compat-libs
  xml2)

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
