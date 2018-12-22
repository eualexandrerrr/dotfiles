#!/bin/bash
# github.com/mamutal91

echo :::::::::::::::::::::::: pt_BR.UTF-8
echo LANG=pt_BR.UTF-8 > /etc/locale.conf
echo archlinux > /etc/hostname

echo :::::::::::::::::::::::: Horário definido para America/Sao_Paulo
rm /etc/localtime
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

echo :::::::::::::::::::::::: Usuário criado
useradd -m -G wheel -s /bin/bash mamutal91