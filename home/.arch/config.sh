#!/bin/bash
# github.com/mamutal91

echo LANG=pt_BR.UTF-8 > /etc/locale.conf
echo archlinux > /etc/hostname

rm /etc/localtime
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime