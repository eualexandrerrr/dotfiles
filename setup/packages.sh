#!/usr/bin/env bash

# Dependencies for dotfiles
array=(
  # WM
  alacritty
  i3-gaps i3lock feh rofi dunst
  mpc mpd ncmpcpp mopidy picom acpi polybar

  nano nano-syntax-highlighting neofetch
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman

  # screenshots/cast
  maim ffmpeg imagemagick slop

  # fonts
  noto-fonts-emoji ttf-dejavu terminus-font ttf-liberation ttf-iosevka-term-ss07 ttf-fantasque-sans-mono ttf-material-design-icons nerd-fonts-iosevka
  ttf-icomoon-feather ttf-icomoon-feather ttf-fantasque-sans-mono

  # xorg
  xorg-server xorg-xrandr xorg-xbacklight xorg-xinit xorg-xprop xorg-server-devel xorg-xsetroot xclip xautolock xidlehook xorg-xdpyinfo xgetres
)

# My perosnal packages!!!
array2=(
  # audio
  pulseaudio alsa-firmware alsa-utils alsa-plugins pulseaudio pulseaudio-bluetooth pavucontrol sox

  # archlinux
  archlinux-keyring cronie

  # Gamming
  nvidia nvidia-utils nvidia-settings nvidia-utils nvidia-dkms nvidia-prime opencl-nvidia
  mesa mesa-demos vulkan-tools lib32-nvidia-utils lib32-opencl-nvidia lib32-virtualgl lib32-nvidia-utils lib32-libvdpau lib32-opencl-nvidia lib32-mesa

  # apps
  atom discord diff-so-fancy filezilla git htop gpicview jdk-openjdk jq krita man man-pages-pt_br google-chrome github-cli-git gitlab-glab-bin
   reflector rsync stow shfmt tree transmission-gtk
  zsh-syntax-highlighting zip kotatogram-desktop-bin oh-my-zsh-git translate-shell-git

  # bluetooth
  bluez bluez-libs bluez-tools bluez-utils

  # tools for android/mobile
  android-tools hfsprogs gvfs gvfs-mtp btrfs-progs dosfstools exfat-utils f2fs-tools e2fsprogs jfsutils nilfs-utils ntfs-3g reiserfsprogs udftools xfsprogs ntfs-3g

  # drivers and dependencies
  openssh python-setuptools sbc unrar unzip wget

  # qemu
  qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs
  $(sudo sed -i "s/#unix_sock_group/unix_sock_group/g" /etc/libvirt/libvirtd.conf)
  $(sudo sed -i "s/#unix_sock_rw_perms/unix_sock_rw_perms/g" /etc/libvirt/libvirtd.conf)

  # themes
  papirus-icon-theme capitaine-cursors dracula-gtk-theme

  # steam
  $(curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import -)
  spotify-snap

  # Gamming
  steam wine winetricks lib32-gnutls

  # dependencies
  python-ruamel-yaml
  selinux-python
  laptop-mode-tools
)
