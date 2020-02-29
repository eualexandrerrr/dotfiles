#!/bin/bash
# github.com/mamutal91

sudo dd if=/dev/urandom of=/root/keyfile bs=1024 count=4
sudo chmod 0400 /root/keyfile
sudo cryptsetup -v luksAddKey /dev/sdb1 /root/keyfile

echo "sudo vim /etc/crypttab"
echo "storage UUID=237c200d-3858-432c-b4cd-8e784bb8e605 /root/keyfile luks"
echo
echo "sudo vim /etc/fstab"
echo "/dev/mapper/storage  /media/storage     ext4    defaults        0       2"
