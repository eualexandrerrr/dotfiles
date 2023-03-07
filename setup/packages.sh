#!/usr/bin/env bash

# Dependencies for dotfiles
dependencies=(
  alsa-firmware alsa-utils alsa-plugins pulseaudio pulseaudio-bluetooth pavucontrol sox
  bluez bluez-libs bluez-tools bluez-utils

  i3-gaps i3lock feh rofi dunst picom alacritty stow nano nano-syntax-highlighting neofetch vlc gpicview zsh zsh-syntax-highlighting
  oh-my-zsh-git
  maim ffmpeg imagemagick slop
  polybar-git

  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman

  flatery-icon-theme-git xcursor-breeze dracula-gtk-theme-git

  google-chrome telegram-desktop

  terminus-font noto-fonts-emoji ttf-dejavu ttf-liberation ttf-icomoon-feather ttf-font-awesome

  xorg-server xorg-xrandr xorg-xbacklight xorg-xinit xorg-xprop xorg-server-devel xorg-xsetroot xclip xsel xautolock xorg-xdpyinfo xorg-xinput xgetres
  xidlehook
)

mypackages=(
  archlinux-keyring gnupg cronie net-tools
  translate-shell-git

  amd-ucode lm_sensors zenpower-dkms

  steam mesa mesa-demos lib32-mesa lib32-libvdpau
  dmidecode nbfc-git i8kutils
  wine winetricks lib32-gnutls wps-office ttf-wps-fonts

  pulsar-bin
  the_silver_searcher discord diff-so-fancy filezilla git gotop jdk-openjdk jq man man-pages-pt_br
  github-cli
  vkd3d lib32-vkd3d
  rsync shfmt tree qbittorrent zip scrcpy

  crowdin-cli
  optipng bfg

  makepkg-optimize
  python python-pip python-pipenv-to-requirements python-pipx python-pip-api python-pipreqs python-pipenv python-pip-shims

  android-tools hfsprogs gvfs gvfs-mtp btrfs-progs dosfstools f2fs-tools e2fsprogs jfsutils nilfs-utils ntfs-3g reiserfsprogs udftools xfsprogs

  qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs

  openssh python-setuptools sbc unrar unzip wget

  selinux-python

  python-ruamel-yaml
  laptop-mode-tools acpi
  ddrescue
)

builder=(
  ncurses ncurses5-compat-libs lib32-ncurses5-compat-libs aosp-devel lineageos-devel curl
  bc rsync lib32-ncurses lib32-gcc-libs schedtool fontconfig ttf-droid
  android-tools android-udev base-devel wget multilib-devel cmake svn clang lzip patchelf inetutils ccache
  gcc gcc-multilib gcc-libs-multilib binutils libtool-multilib lib32-libusb libxcrypt-compat
  lib32-readline lib32-glibc lib32-zlib python2 perl git gnupg flex bison gperf zip unzip sdl squashfs-tools
  libpng zlib libusb libusb-compat readline inetutils android-sdk-platform-tools android-udev esd-oss pngcrush
  repo tcp_wrappers perl-switch wxgtk2 libxslt xml2 termcap jdk8-openjdk llvm p7zip
)
