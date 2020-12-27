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
  cronie
  firefox firefox-i18n-pt-br fortune-mod
  git gpicview
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
  selinux-python

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
  oh-my-zsh-git
  kotatogram-desktop-bin
  spotify swaylock-effects-git
  translate-shell-git
  zsh-syntax-highlighting

  # dependencies
  python-ruamel-yaml
  selinux-python
  ttf-font-awesome ttf-dejavu
  wf-recorder-git
  xorg-xwayland-git
)
