#!/usr/bin/env bash

clear

sudo pacman -Syyu --noconfirm

sudo pacman -S base-devel git wget multilib-devel cmake svn clang lzip patchelf inetutils python2-distlib ccache \
               gcc-multilib gcc-libs-multilib binutils-multilib libtool-multilib lib32-libusb lib32-libusb-compat \
               lib32-readline lib32-glibc lib32-zlib python2 perl git gnupg flex bison gperf zip unzip sdl wxgtk squashfs-tools \
               ncurses libpng zlib libusb libusb-compat readline inetutils android-sdk-platform-tools android-udev esd-oss pngcrush \
               repo tcp_wrappers termcap perl-switch

for package in ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel xml2 lineageos-devel; do
    git clone https://aur.archlinux.org/"${package}"
    cd "${package}" || continue
    makepkg -si --skippgpcheck --noconfirm
    cd - || break
    rm -rf "${package}"
done

sudo pacman -S android-tools android-udev --noconfirm
