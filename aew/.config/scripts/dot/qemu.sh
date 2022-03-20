#!/usr/bin/env bash

iso=${1}

iso=$HOME/Downloads/Arch/*.iso

if [[ -z ${iso} ]]; then
  echo "Especifique a iso"
  echo "    usage:"
  echo "        qemu Downloads/Arch/archlinux.iso"
  exit 0
fi

qemu-img create -f qcow2 /tmp/Image.img 30G

qemu-system-x86_64 \
    -enable-kvm \
    -cdrom ${iso} \
    -boot menu=on \
    -drive file=/tmp/Image.img,if=none,id=NVME1 \
    --device nvme,drive=NVME1,serial=nvme-1 \
    -display vnc=:11
    -m 20G

rm -rf /tmp/Image.img
