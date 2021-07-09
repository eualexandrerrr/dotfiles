#!/usr/bin/env bash

# Dependencies for dotfiles
dependencies=(
  i3-gaps i3lock feh rofi dunst picom polybar
  alacritty nano nano-syntax-highlighting neofetch vlc gpicview simplescreenrecorder
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman
  papirus-icon-theme capitaine-cursors dracula-gtk-theme

  maim ffmpeg imagemagick slop

  noto-fonts-emoji ttf-dejavu terminus-font ttf-liberation ttf-iosevka-term-ss07 ttf-fantasque-sans-mono ttf-material-design-icons
  nerd-fonts-iosevka ttf-icomoon-feather ttf-icomoon-feather ttf-fantasque-sans-mono ttf-font-awesome

  xorg-server xorg-xrandr xorg-xbacklight xorg-xinit xorg-xprop xorg-server-devel xorg-xsetroot xclip xautolock xidlehook xorg-xdpyinfo xgetres
)

# My perosnal packages!!!
mypackages=(
  pulseaudio alsa-firmware alsa-utils alsa-plugins pulseaudio pulseaudio-bluetooth pavucontrol sox

  archlinux-keyring cronie

  nvidia nvidia-utils nvidia-settings nvidia-utils nvidia-dkms nvidia-prime opencl-nvidia
  mesa mesa-demos vulkan-tools lib32-nvidia-utils lib32-opencl-nvidia lib32-virtualgl lib32-nvidia-utils lib32-libvdpau lib32-opencl-nvidia lib32-mesa
  steam wine winetricks lib32-gnutls

  atom discord diff-so-fancy filezilla git htop jdk-openjdk jq krita man man-pages-pt_br google-chrome github-cli-git gitlab-glab-bin
  rsync stow shfmt tree transmission-gtk
  zsh-syntax-highlighting zip kotatogram-desktop-bin oh-my-zsh-git translate-shell-git

  bluez bluez-libs bluez-tools bluez-utils

  android-tools hfsprogs gvfs gvfs-mtp btrfs-progs dosfstools exfat-utils f2fs-tools e2fsprogs jfsutils nilfs-utils ntfs-3g reiserfsprogs udftools xfsprogs ntfs-3g

  openssh python-setuptools sbc unrar unzip wget

  qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libguestfs
  $(sudo sed -i "s/#unix_sock_group/unix_sock_group/g" /etc/libvirt/libvirtd.conf)
  $(sudo sed -i "s/#unix_sock_rw_perms/unix_sock_rw_perms/g" /etc/libvirt/libvirtd.conf)

  spotifyd-full-git spotify-tui

  python-ruamel-yaml
  selinux-python
  laptop-mode-tools acpi
)
