#!/usr/bin/env bash
# Roda depois da VM desligar: devolve a RTX 3090 pro host e sobe o SDDM de novo.
exec >>/var/log/libvirt/hooks-win11-redm.log 2>&1
echo "== stop $(date -Is)"

# Perfil "janela" (dotfiles vm/w11-janela.xml): sem hostdev PCI, a 3090 fica no host e nao ha o que fazer.
# O XML vem no stdin via dispatcher. Rodando na mao (stdin e terminal) assume perfil 3090.
XML=""; [[ -t 0 ]] || XML="$(cat)"
if [[ -n $XML ]] && ! grep -q "<hostdev mode='subsystem' type='pci'" <<<"$XML"; then
    echo "sem hostdev PCI no XML: perfil janela, nada a fazer"; exit 0
fi
set -x

systemctl stop "libvirt-nosleep@$1.service" || true

GPU_V="@GPU_V@"; AUD_V="@AUD_V@"

virsh nodedev-reattach "$GPU_V" || true
[[ -n $AUD_V ]] && { virsh nodedev-reattach "$AUD_V" || true; }
modprobe -r vfio-pci || true

echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind 2>/dev/null || true

for _ in $(seq 1 10); do
    modprobe nvidia && modprobe nvidia_modeset && modprobe nvidia_uvm && modprobe nvidia_drm && break
    sleep 1
done
for v in /sys/class/vtconsole/vtcon*; do echo 1 > "$v/bind" 2>/dev/null || true; done

systemctl start display-manager
echo "== stop ok"
