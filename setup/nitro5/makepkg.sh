#!/usr/bin/env bash

yay -S ananicy-cpp irqbalance memavaild nohang preload prelockd uresourced --noconfirm

sudo systemctl disable systemd-oomd
sudo systemctl enable ananicy-cpp
sudo systemctl enable irqbalance
sudo systemctl enable memavaild
sudo systemctl enable nohang
sudo systemctl enable preload
sudo systemctl enable prelockd
sudo systemctl enable uresourced

sudo sed -i 's|CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fno-plt -fexceptions|CFLAGS="-march=native -mtune=native -O2 -pipe -fno-plt -fexceptions|g' /etc/makepkg.conf
sudo sed -i 's|.*#RUSTFLAGS=.*|RUSTFLAGS="-C opt-level=2 -C target-cpu=native"|' /etc/makepkg.conf
sudo sed -i 's|.*MAKEFLAGS=.*|MAKEFLAGS="-j32"|' /etc/makepkg.conf
sudo sed -i 's|.*BUILDDIR=.*|BUILDDIR=/tmp/makepkg|' /etc/makepkg.conf
sudo sed -i 's|.*COMPRESSGZ=.*|COMPRESSGZ=(pigz -c -f -n)|' /etc/makepkg.conf
sudo sed -i 's|.*COMPRESSBZ2=.*|COMPRESSBZ2=(pbzip2 -c -f)|' /etc/makepkg.conf
sudo sed -i 's|.*COMPRESSXZ=.*|COMPRESSXZ=(xz -c -z --threads=0 -)|' /etc/makepkg.conf
sudo sed -i 's|.*COMPRESSZST=.*|COMPRESSZST=(zstd -c -z -q --threads=0 -)|' /etc/makepkg.conf
sudo sed -i 's|.*PKGEXT=.*|PKGEXT=".pkg.tar"|' /etc/makepkg.conf
