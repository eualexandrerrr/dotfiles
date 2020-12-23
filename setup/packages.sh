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
  dconf-editor
  git gpicview
  htop
  mako
  nano nano-syntax-highlighting neofetch
  peek pinta
  stow sway
  telegram-desktop
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman transmission-gtk
  waybar wayland wofi
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
  oh-my-zsh-git
  spotify
  zsh-syntax-highlighting

  # dependencies
  python-ruamel-yaml
  selinux-python
  ttf-font-awesome ttf-dejavu
  xorg-xwayland-git
)
