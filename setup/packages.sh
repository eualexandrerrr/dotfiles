#!/usr/bin/env bash

# Dependencies for dotfiles
dependencies=(
  pulseaudio alsa-firmware alsa-utils alsa-plugins pulseaudio pulseaudio-bluetooth pavucontrol sox
  bluez bluez-libs bluez-tools bluez-utils

  i3-gaps i3lock feh rofi dunst picom alacritty stow nano nano-syntax-highlighting neofetch vlc gpicview zsh zsh-syntax-highlighting oh-my-zsh-git maim ffmpeg imagemagick slop
  polybar-git
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman

  flatery-icon-theme-git xcursor-breeze dracula-gtk-theme-git

  google-chrome telegram-desktop

  terminus-font noto-fonts-emoji ttf-dejavu ttf-liberation ttf-icomoon-feather ttf-font-awesome

  translate-shell-git

  xorg-server xorg-xrandr xorg-xbacklight xorg-xinit xorg-xprop xorg-server-devel xorg-xsetroot xclip xsel xautolock xidlehook xorg-xdpyinfo xorg-xinput xgetres
)

# My personal packages!!!
mypackages=(
  # Arch Utils
  archlinux-keyring gnupg cronie net-tools
  noip

  # ZenKernel
  linux-zen linux-zen-headers

  # Video/games
  nvidia-lts nvidia-utils nvidia-settings nvidia-utils nvidia-dkms nvidia-prime opencl-nvidia nbfc-git
  mesa mesa-demos vulkan-tools lib32-nvidia-utils lib32-opencl-nvidia lib32-virtualgl lib32-nvidia-utils lib32-libvdpau lib32-opencl-nvidia lib32-mesa
  steam wine winetricks lib32-gnutls wps-office ttf-wps-fonts

  atom silver-searcher-git discord diff-so-fancy filezilla git htop jdk-openjdk jq man man-pages-pt_br github-cli-git vkd3d lib32-vkd3d
  rsync shfmt tree qbittorrent zip scrcpy

  crowdin-cli lutris-git optipng bfg

  python python-pip python-pipenv-to-requirements python-pipx python-pip-api python-pipreqs python-pipenv python-pip-shims

  android-tools hfsprogs gvfs gvfs-mtp btrfs-progs dosfstools f2fs-tools e2fsprogs jfsutils nilfs-utils ntfs-3g reiserfsprogs udftools xfsprogs

  openssh python-setuptools sbc unrar unzip wget

  qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs

  python-ruamel-yaml
  selinux-python
  laptop-mode-tools acpi
)
