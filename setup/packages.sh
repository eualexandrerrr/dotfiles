#!/usr/bin/env bash

packages=(
  # audio
  alsa alsa-firmware alsa-utils alsa-plugins
  pulseaudio pulseaudio-bluetooth pavucontrol
  sox

  # archlinux
  archlinux-keyring

  # WM
  i3-gaps
  feh
  rofi
  dunst
  picom

  # Gamming
  bumblebee
  nvidia nvidia-utils nvidia-settings nvidia-utils nvidia-dkms opencl-nvidia
  lib32-nvidia-utils lib32-opencl-nvidia lib32-virtualgl lib32-nvidia-utils lib32-libvdpau lib32-opencl-nvidia lib32-mesa
  xorg-server xorg-xrandr xorg-xbacklight xorg-xinit xorg-xprop xorg-server-devel

  # apps
  alacritty atom
  cronie
  discord diff-so-fancy
  filezilla
  git
  htop
  imv
  jdk-openjdk jq
  krita
  maim
  nano nano-syntax-highlighting neofetch
  reflector rsync
  stow shfmt slop
  tree thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman transmission-gtk
  zsh-syntax-highlighting zip
  xclip xautolock
  winetricks

  # bluetooth
  bluez bluez-libs bluez-tools bluez-utils

  # tools for android/mobile
  android-tools
  gvfs gvfs-mtp btrfs-progs dosfstools exfat-utils f2fs-tools e2fsprogs jfsutils nilfs-utils ntfs-3g reiserfsprogs udftools xfsprogs
  ntfs-3g

  # screenshots/cast
  imagemagick

  # drivers and dependencies
  mesa mpd mpv
  openssh
  python-setuptools
  sbc
  unrar unzip
  wget

  # themes
  papirus-icon-theme

  # fonts
  noto-fonts-emoji
  terminus-font ttf-liberation

  # wine
  wine winetricks lib32-gnutls
)

aur=(
  # themes
  capitaine-cursors
  dracula-gtk-theme

  # apps
  google-chrome github-cli-git gitlab-glab-bin
  kotatogram-desktop-bin
  oh-my-zsh-git
  polybar
  translate-shell-git

  # tools
  hfsprogs
  laptop-mode-tools

  # Gamming
  steam
  nvidia-xrun

  # dependencies
  python-ruamel-yaml
  selinux-python
  ttf-font-awesome ttf-dejavu
)
