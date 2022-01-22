#!/usr/bin/env bash

if [[ -z ${1} ]]; then
  echo "Especifique a iso"
  echo "    usage:"
  echo "        qemu Downloads/archlinux.iso"
  exit 0
fi

qemu-img create -f qcow2 /tmp/Image.img 10G

qemu-system-x86_64 \
    -enable-kvm \
    -cdrom ${1} \
    -boot menu=on \
    -drive file=/tmp/Image.img \
    -m 8G

rm -rf /tmp/Image.img
