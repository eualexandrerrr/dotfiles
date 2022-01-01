#!/usr/bin/env bash

# Dependencies for dotfiles
dependencies=(
  pulseaudio alsa-firmware alsa-utils alsa-plugins pulseaudio pulseaudio-bluetooth pavucontrol sox
  bluez bluez-libs bluez-tools bluez-utils

  i3-gaps i3lock feh rofi dunst picom polybar-git alacritty stow nano nano-syntax-highlighting neofetch vlc gpicview zsh zsh-syntax-highlighting oh-my-zsh-git maim ffmpeg imagemagick slop
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman

  flatery-icon-theme-git xcursor-breeze dracula-gtk-theme-git

  google-chrome telegram-desktop

  terminus-font noto-fonts-emoji ttf-dejavu ttf-liberation ttf-icomoon-feather ttf-font-awesome

  translate-shell-git

  xorg-server xorg-xrandr xorg-xbacklight xorg-xinit xorg-xprop xorg-server-devel xorg-xsetroot xclip xsel xautolock xidlehook xorg-xdpyinfo xorg-xinput xgetres
)

# My perosnal packages!!!
mypackages=(
  archlinux-keyring gnupg cronie

  nvidia nvidia-utils nvidia-settings nvidia-utils nvidia-dkms nvidia-prime opencl-nvidia nbfc-git
  mesa mesa-demos vulkan-tools lib32-nvidia-utils lib32-opencl-nvidia lib32-virtualgl lib32-nvidia-utils lib32-libvdpau lib32-opencl-nvidia lib32-mesa
  steam wine winetricks lib32-gnutls

  atom silver-searcher-git discord diff-so-fancy filezilla git htop jdk-openjdk jq man man-pages-pt_br github-cli-git vkd3d lib32-vkd3d
  rsync shfmt tree qbittorrent zip scrcpy python-pip crowdin-cli lutris-git

  android-tools hfsprogs gvfs gvfs-mtp btrfs-progs dosfstools exfat-utils f2fs-tools e2fsprogs jfsutils nilfs-utils ntfs-3g reiserfsprogs udftools xfsprogs

  openssh python-setuptools sbc unrar unzip wget

  qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs

  python-ruamel-yaml
  selinux-python
  laptop-mode-tools acpi
)

builder=(
  android-tools android-udev base-devel git wget multilib-devel cmake svn clang lzip patchelf inetutils ccache \
  gcc-multilib gcc-libs-multilib binutils libtool-multilib lib32-libusb \
  lib32-readline lib32-glibc lib32-zlib python2 perl git gnupg flex bison gperf zip unzip sdl squashfs-tools \
  ncurses libpng zlib libusb libusb-compat readline inetutils android-sdk-platform-tools android-udev esd-oss pngcrush \
  repo tcp_wrappers termcap perl-switch
)
