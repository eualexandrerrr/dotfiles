#!/usr/bin/env bash
# Single GPU passthrough, RTX 3090, host Arch com SDDM + KDE Plasma Wayland.
# Roda antes da VM subir: tira a GPU do host e entrega pro vfio-pci.
# Placeholders preenchidos por install-hooks.sh: @GPU_V@ @AUD_V@ @USERNAME@
exec >>/var/log/libvirt/hooks-win11-redm.log 2>&1
echo "== start $(date -Is)"

# Perfil "janela" (dotfiles vm/w11-janela.xml): sem hostdev PCI, a 3090 fica no host e nao ha o que fazer.
# O XML vem no stdin via dispatcher. Rodando na mao (stdin e terminal) assume perfil 3090.
XML=""; [[ -t 0 ]] || XML="$(cat)"
if [[ -n $XML ]] && ! grep -q "<hostdev mode='subsystem' type='pci'" <<<"$XML"; then
    echo "sem hostdev PCI no XML: perfil janela, nada a fazer"; exit 0
fi
set -x

# Trava de suspensao enquanto a VM roda (unit em systemd/libvirt-nosleep@.service).
systemctl start "libvirt-nosleep@$1.service" || true

GPU_V="@GPU_V@"; AUD_V="@AUD_V@"; USERNAME="@USERNAME@"

# 1. KDE Plasma Wayland segura a GPU mesmo depois do SDDM parar (QaidVoid issue #31): derruba a sessao do usuario primeiro.
systemctl --user -M "${USERNAME}@" stop plasma-plasmashell.service plasma-kwin_wayland.service 2>/dev/null || true
loginctl terminate-user "$USERNAME" 2>/dev/null || true

# 2. Display manager.
systemctl stop display-manager
for _ in $(seq 1 20); do systemctl is-active --quiet display-manager || break; sleep 0.5; done
sleep 2

# 3. Consoles virtuais e framebuffer EFI (em kernel novo o efi-framebuffer pode nao existir: ignora).
for v in /sys/class/vtconsole/vtcon*; do echo 0 > "$v/bind" 2>/dev/null || true; done
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind 2>/dev/null || true

# 4. Descarrega a NVIDIA (nvidia-open-dkms usa os mesmos nomes). Retry: kwin as vezes demora a soltar.
for _ in $(seq 1 10); do
    modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia && break
    sleep 1
done
lsmod | grep -q '^nvidia' && { echo "nvidia ainda carregado, abortando"; exit 1; }

# 5. Solta os dispositivos e liga o vfio.
virsh nodedev-detach "$GPU_V"
[[ -n $AUD_V ]] && virsh nodedev-detach "$AUD_V"
modprobe vfio-pci
echo "== start ok"
