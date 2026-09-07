#!/usr/bin/env bash
# Prende a RTX 3090 (10de:2204 + audio 10de:1aef) no vfio-pci desde o boot. SO RODE COM A
# SEGUNDA GPU MONTADA e o KDE rodando nela: com uma placa so, o proximo boot fica sem tela.
set -euo pipefail
n=$(lspci -nn | grep -ciE 'vga|3d'); (( n >= 2 )) || { echo "so $n GPU: sem a RX 550, isso deixa o host sem tela. Abortado."; exit 1; }
printf 'options vfio-pci ids=10de:2204,10de:1aef\nsoftdep nvidia pre: vfio-pci\nsoftdep drm pre: vfio-pci\n' | sudo tee /etc/modprobe.d/vfio.conf >/dev/null
sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(vfio_pci vfio vfio_iommu_type1 \1)/' /etc/mkinitcpio.conf
sudo sed -i 's/vfio_pci vfio vfio_iommu_type1 vfio_pci vfio vfio_iommu_type1 /vfio_pci vfio vfio_iommu_type1 /' /etc/mkinitcpio.conf
sudo mkinitcpio -P && echo "vfio ativo no proximo boot; kernel-nvidia e configure_nvidia() saem do install depois disso"
