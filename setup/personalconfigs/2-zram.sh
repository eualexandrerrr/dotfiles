#!/usr/bin/env bash

# Desabilitar antes
sudo swapoff /dev/zram0
sudo rmmod zram
sudo systemctl disable zram.service

# Inicio
sudo modprobe zram
sudo sh -c "echo 'lz4' > /sys/block/zram0/comp_algorithm"
sudo sh -c "echo '16G' > /sys/block/zram0/disksize"
sudo mkswap --label zram0 /dev/zram0
sudo swapon --priority 100 /dev/zram0

echo '[Unit]
Description=zRam block devices swapping

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c "modprobe zram && echo lz4 > /sys/block/zram0/comp_algorithm && echo 16G > /sys/block/zram0/disksize && mkswap --label zram0 /dev/zram0 && swapon --priority 100 /dev/zram0"
ExecStop=/usr/bin/bash -c "swapoff /dev/zram0 && rmmod zram"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/zram.service

sudo systemctl enable zram
