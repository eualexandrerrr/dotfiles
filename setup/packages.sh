#!/usr/bin/env bash

readonly PACKAGES=(
  # audio
  alsa alsa-firmware alsa-utils alsa-plugins
  pulseaudio pulseaudio-bluetooth pavucontrol
  sox

  # archlinux
  archlinux-keyring

  # apps
  alacritty atom
  cronie
  filezilla
  git gpicview
  htop
  lxappearance
  mako
  nano nano-syntax-highlighting
  reflector
  stow sway swaybg
  telegram-desktop tree thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman transmission-gtk
  waybar wayland wofi
  xorg-server-xwayland
  zsh-syntax-highlighting

  # bluetooth
  bluez bluez-libs bluez-tools bluez-utils

  # tools for android/mobile
  android-tools
  gvfs gvfs-mtp
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
  wget

  # fonts
  noto-fonts-emoji
  terminus-font ttf-liberation
)

readonly AUR=(
  # themes
  ant-dracula-gtk-theme
  capitaine-cursors
  papirus-icon-theme-git

  # apps
  google-chrome-beta
  oh-my-zsh-git
  swaylock-effects-git
  translate-shell-git
  zsh-syntax-highlighting

  # dependencies
  python-ruamel-yaml
  selinux-python
  ttf-font-awesome ttf-dejavu
  wf-recorder-git
)
