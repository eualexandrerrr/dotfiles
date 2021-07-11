#!/usr/bin/env bash

# Dependencies for dotfiles
dependencies=(
  pulseaudio alsa-firmware alsa-utils alsa-plugins pulseaudio pulseaudio-bluetooth pavucontrol sox
  bluez bluez-libs bluez-tools bluez-utils

  nordic-theme-git

  i3-gaps i3lock feh rofi dunst picom polybar alacritty nano nano-syntax-highlighting neofetch vlc gpicview zsh zsh-syntax-highlighting oh-my-zsh-git maim ffmpeg imagemagick slop
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman
  papirus-icon-theme capitaine-cursors dracula-gtk-theme

  google-chrome kotatogram-desktop-bin

  noto-fonts-emoji ttf-dejavu terminus-font ttf-liberation ttf-iosevka-term-ss07 ttf-fantasque-sans-mono ttf-material-design-icons
  nerd-fonts-iosevka ttf-icomoon-feather ttf-icomoon-feather ttf-fantasque-sans-mono ttf-font-awesome

  xorg-server xorg-xrandr xorg-xbacklight xorg-xinit xorg-xprop xorg-server-devel xorg-xsetroot xclip xsel xautolock xidlehook xorg-xdpyinfo xgetres
)

# My perosnal packages!!!
mypackages=(
  archlinux-keyring cronie

  nvidia nvidia-utils nvidia-settings nvidia-utils nvidia-dkms nvidia-prime opencl-nvidia
  mesa mesa-demos vulkan-tools lib32-nvidia-utils lib32-opencl-nvidia lib32-virtualgl lib32-nvidia-utils lib32-libvdpau lib32-opencl-nvidia lib32-mesa
  steam wine winetricks lib32-gnutls

  atom discord diff-so-fancy filezilla git htop jdk-openjdk jq krita man man-pages-pt_br github-cli-git gitlab-glab-bin
  rsync stow shfmt tree transmission-gtk zip translate-shell-git

  android-tools hfsprogs gvfs gvfs-mtp btrfs-progs dosfstools exfat-utils f2fs-tools e2fsprogs jfsutils nilfs-utils ntfs-3g reiserfsprogs udftools xfsprogs ntfs-3g

  openssh python-setuptools sbc unrar unzip wget

  qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs

  spotifyd-full-git spotify-tui

  python-ruamel-yaml
  selinux-python
  laptop-mode-tools acpi
)
