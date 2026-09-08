#!/usr/bin/env bash
# Depois que a VM desliga: a 3090 volta pro vfio-pci (nao pro host) e o Hyprland nunca
# parou, entao so ha a trava de suspensao pra soltar.
exec >>/var/log/libvirt/hooks-win11-redm.log 2>&1
echo "== stop $(date -Is)"

XML=""; [[ -t 0 ]] || XML="$(cat)"
if [[ -n $XML ]] && ! grep -q "<hostdev mode='subsystem' type='pci'" <<<"$XML"; then
    echo "sem hostdev PCI no XML: perfil janela, nada a fazer"; exit 0
fi
set -x

systemctl stop "libvirt-nosleep@$1.service" || true
echo "== stop ok"
