#!/usr/bin/env bash

archPath="$HOME/GitHub/archiso"

# Remvoa as últimas iso
sudo rm -rf $HOME/Downloads/Arch/*.iso

# Reinstalando archiso para obter últimas mudanças
sudo pacman -Rncs archiso --noconfirm &> /dev/null
rm -rf /usr/share/archiso
sudo pacman -S archiso --noconfirm &> /dev/null

# Copiando o novo template
rm -rf ${archPath}
cp -r /usr/share/archiso/configs/releng ${archPath}

# Adicionando pacotes
echo git >> ${archPath}/packages.x86_64
echo reflector >> ${archPath}/packages.x86_64

# Mudanças no pacman.conf da ISO (não é o do sistema que irá ser instalado)
sed -i "/\[multilib\]/,/Include/"'s/^#//' ${archPath}/pacman.conf
sed -i 's/#UseSyslog/UseSyslog/' ${archPath}/pacman.conf
sed -i 's/#Color/Color\\\nILoveCandy/' ${archPath}/pacman.conf
sed -i 's/Color\\/Color/' ${archPath}/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/' ${archPath}/pacman.conf
sed -i 's/#CheckSpace/CheckSpace/' ${archPath}/pacman.conf
sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" ${archPath}/pacman.conf
sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 3/g" ${archPath}/pacman.conf

# Copiando minhas redes wifi
mkdir -p ${archPath}/airootfs/var/lib/iwd
sudo cp -rf $HOME/GitHub/mywifi/iwd/*.psk ${archPath}/airootfs/var/lib/iwd

# Definindo permissão para que essas redes possam ser lidas na iso
sed -i '$d' ${archPath}/profiledef.sh
echo -e "  [\"/var/lib/iwd\"]=\"0:0:0700\"\n)" | tee -a ${archPath}/profiledef.sh &> /dev/null

# Criando um script que aparecerá no /root da iso
echo -e "\nsleep 5
git clone https://github.com/mamutal91/myarch /root/myarch" | tee -a ${archPath}/airootfs/root/.automated_script.sh &> /dev/null

cat ${archPath}/airootfs/root/myarch.sh

sudo rm -rf $HOME/Downloads/Arch/*.iso
sudo mkarchiso -v -w $(mktemp -d) -o $HOME/Downloads/Arch ${archPath}

iso=$(ls -1 $HOME/Downloads/Arch/*.iso)
sudo dd if=${iso} of=/dev/sdc status=progress && sync
