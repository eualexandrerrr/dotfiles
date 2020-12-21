#!/usr/bin/env bash
# github.com/mamutal91

readonly PACKAGES=(
  # audio
  alsa alsa-firmware alsa-utils
  pulseaudio pulseaudio-bluetooth pulseeffects
  sox

  # archlinux
  archlinux-keyring

  # apps
  alacritty atom
  chromium cronie
  git gpicview
  mako
  nano nano-syntax-highlighting neofetch
  peek pinta
  stow sway
  telegram-desktop
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman transmission-gtk
  waybar wayland wofi
  zsh
  oh-my-zsh-git xorg-xwayland-git
  zsh-syntax-highlighting
  spotify

  # bluetooth
  bluez bluez-libs bluez-tools bluez-utils

  # tools for android/mobile
  android-tools
  gvfs gvfs-mtp
  ntfs-3g
  selinux-python

  # screenshots/cast
  ffmpeg
  grim
  imagemagick
  slurp
  wl-clipboard

  # drivers and dependencies
  mesa mpd mpv
  openssh
  python-ruamel-yaml python-setuptools
  sbc
  unrar unzip
  wget

  # fonts
  noto-fonts-emoji
  terminus-font ttf-liberation ttf-font-awesome ttf-dejavu ttf-wps-fonts

  # themes
  capitaine-cursors
  layan-gtk-theme-git
  papirus-icon-theme-git
)
