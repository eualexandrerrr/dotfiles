#!/usr/bin/env bash

iso=$HOME/Downloads/Arch/*.iso

qemu-img create -f qcow2 /tmp/QemuImage.img 30G

qemu-system-x86_64 \
    -enable-kvm \
    -cdrom ${iso} \
    -boot menu=on \
    -drive file=/tmp/QemuImage.img,if=none,id=NVME1 \
    --device nvme,drive=NVME1,serial=nvme-1 \
    -m 20G

rm -rf /tmp/QemuImage.img
