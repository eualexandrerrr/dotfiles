#!/usr/bin/env bash

packages=(
  # audio
  alsa alsa-firmware alsa-utils alsa-plugins
  pulseaudio pulseaudio-bluetooth pavucontrol
  sox

  # archlinux
  archlinux-keyring

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
  mako
  nano nano-syntax-highlighting neofetch
  reflector rsync
  stow sway swaybg shfmt
  tree thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman transmission-gtk
  waybar wayland wofi
  zsh-syntax-highlighting zip

  # bluetooth
  bluez bluez-libs bluez-tools bluez-utils

  # tools for android/mobile
  android-tools
  gvfs gvfs-mtp btrfs-progs dosfstools exfat-utils f2fs-tools e2fsprogs jfsutils nilfs-utils ntfs-3g reiserfsprogs udftools xfsprogs
  ntfs-3g

  # screenshots/cast
  grim
  imagemagick
  slurp
  wl-clipboard

  # drivers and dependencies
  mesa mpd mpv
  openssh
  python-setuptools
  sbc
  unrar unzip
  xorg-xwayland
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
  swaylock-effects-git
  translate-shell-git

  # tools
  hfsprogs
  laptop-mode-tools

  # 3D
  lib32-nvidia-utils lib32-opencl-nvidia
  xf86-video-nouveau mesa lib32-mesa # nvidia
  steam

  # dependencies
  python-ruamel-yaml
  selinux-python
  ttf-font-awesome ttf-dejavu
  wf-recorder-git
)
