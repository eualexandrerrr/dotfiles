#!/usr/bin/env bash

readonly PACKAGES=(
  # audio
  alsa alsa-firmware alsa-utils
  pulseaudio pulseaudio-bluetooth pulseeffects
  sox

  # archlinux
  archlinux-keyring

  # apps
  alacritty atom
  cronie
  git gpicview gimp gimp-help-pt_br
  htop
  lxappearance
  mako
  nano nano-syntax-highlighting neofetch
  pinta
  reflector
  stow sway swaybg
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman transmission-gtk
  waybar wayland wofi
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
  terminus-font ttf-liberation ttf-wps-fonts
)

readonly AUR=(
  # themes
  ant-dracula-gtk-theme
  capitaine-cursors
  papirus-icon-theme-git

  # apps
  google-chrome-beta
  oh-my-zsh-git
  kotatogram-desktop-bin
  spotify swaylock-effects-git
  translate-shell-git
  wps-office
  zsh-syntax-highlighting

  # dependencies
  python-ruamel-yaml
  selinux-python
  ttf-font-awesome ttf-dejavu
  wf-recorder-git
  xorg-xwayland-git
)
