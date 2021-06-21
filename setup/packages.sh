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
  git gpicview
  htop
  jdk-openjdk jq
  mako
  nano nano-syntax-highlighting neofetch
  reflector rsync
  stow sway swaybg shfmt
  tree thunar transmission-gtk
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
  google-chrome-dev github-cli-git gitlab-glab-bin
  kotatogram-desktop-bin
  oh-my-zsh-git
  swaylock-effects-git spotify-snap
  translate-shell-git

  # dependencies
  python-ruamel-yaml
  selinux-python
  ttf-font-awesome ttf-dejavu
  wf-recorder-git
)
