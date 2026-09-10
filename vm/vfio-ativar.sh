#!/usr/bin/env bash
# Prende a RTX 3090 (10de:2204 + audio 10de:1aef) no vfio-pci desde o boot. SO RODE COM A
# RX 550 MONTADA e o desktop desenhando nela: com uma placa so, o proximo boot fica sem tela.
set -euo pipefail

n=$(lspci -nn | grep -ciE 'vga|3d'); (( n >= 2 )) || { echo "so $n GPU: sem a RX 550, isso deixa o host sem tela. Abortado."; exit 1; }

# Contar duas placas nao basta: a RX 550 pode estar enumerada e sem driver (riser mal
# encaixado). O que salva o host e o amdgpu estar de fato desenhando.
grep -qs amdgpu /sys/class/drm/card*/device/uevent || { echo "amdgpu nao esta em uso: a RX 550 nao esta desenhando. Abortado."; exit 1; }

printf 'options vfio-pci ids=10de:2204,10de:1aef\nsoftdep nvidia pre: vfio-pci\nsoftdep drm pre: vfio-pci\n' | sudo tee /etc/modprobe.d/vfio.conf >/dev/null
sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(vfio_pci vfio vfio_iommu_type1 \1)/' /etc/mkinitcpio.conf
sudo sed -i 's/vfio_pci vfio vfio_iommu_type1 vfio_pci vfio vfio_iommu_type1 /vfio_pci vfio vfio_iommu_type1 /' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# Rota de recuperacao no menu do systemd-boot. O arch-fallback.conf NAO serve pra isso: ele
# so troca o initramfs, e carrega os mesmos parametros -- se o vfio pegar a 3090 e o host
# ficar sem tela, os dois bootam igual. module_blacklist=vfio_pci vale mesmo com o modulo
# dentro do initramfs, entao esta entrada devolve a placa pro nvidia.
opts="$(sudo sed -n 's/^options //p' /boot/loader/entries/arch.conf)"
printf 'title   Arch Linux (zen, sem vfio)\nlinux   /vmlinuz-linux-zen\ninitrd  /amd-ucode.img\ninitrd  /initramfs-linux-zen.img\noptions %s module_blacklist=vfio_pci\n' \
    "$opts" | sudo tee /boot/loader/entries/arch-sem-vfio.conf >/dev/null

echo
echo "confira ANTES de reiniciar -- os tres tem que bater:"
grep . /etc/modprobe.d/vfio.conf
grep ^MODULES /etc/mkinitcpio.conf
printf 'vfio no initramfs: %s\n' "$(sudo lsinitcpio /boot/initramfs-linux-zen.img 2>/dev/null | grep -c vfio)"
echo
echo "se algo falhar no boot, escolha 'Arch Linux (zen, sem vfio)' no menu do systemd-boot."
echo "com o vfio funcionando, kernel-nvidia e configure_nvidia() saem do install."
