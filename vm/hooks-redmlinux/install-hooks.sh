#!/usr/bin/env bash
# RedMLinux plano B: instala os hooks do libvirt pra single GPU passthrough da RTX 3090.
# Detecta o PCI ID da 3090 e do audio HDMI, grava o dispatcher /etc/libvirt/hooks/qemu e os scripts
# start.sh / stop.sh em /etc/libvirt/hooks/qemu.d/<VM>/, adaptados pra SDDM + Hyprland.
#
# Uso: sudo ./install-hooks.sh [nome-da-vm] [usuario]     (padrao: win11-redm alexandre)
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "rode com sudo"; exit 1; }
VM="${1:-win11-redm}"; USERNAME="${2:-${SUDO_USER:-alexandre}}"
HERE="$(cd "$(dirname "$0")" && pwd)"

GPU="$(lspci -Dnn | awk '/10de:2204/{print $1}' | head -1)"
AUD="$(lspci -Dnn | awk '/10de:1aef/{print $1}' | head -1)"
[[ -n $GPU ]] || { echo "RTX 3090 (10de:2204) nao encontrada"; exit 1; }
[[ -n $AUD ]] || { echo "audio HDMI da 3090 (10de:1aef) nao encontrado; seguindo so com a GPU"; }
to_virsh() { echo "pci_$(echo "$1" | tr ':.' '__')"; }
GPU_V="$(to_virsh "$GPU")"; AUD_V="${AUD:+$(to_virsh "$AUD")}"
echo "GPU $GPU ($GPU_V)  audio ${AUD:-nenhum} (${AUD_V:-})  usuario $USERNAME  vm $VM"

install -Dm755 "$HERE/hooks/qemu" /etc/libvirt/hooks/qemu
install -Dm644 "$HERE/systemd/libvirt-nosleep@.service" /etc/systemd/system/libvirt-nosleep@.service
systemctl daemon-reload
for f in prepare/begin/start.sh release/end/stop.sh; do
    dst="/etc/libvirt/hooks/qemu.d/$VM/$f"
    install -Dm755 "$HERE/hooks/qemu.d/win11-redm/$f" "$dst"
    sed -i -e "s|@GPU_V@|$GPU_V|g" -e "s|@AUD_V@|$AUD_V|g" -e "s|@USERNAME@|$USERNAME|g" "$dst"
done
echo "hooks em /etc/libvirt/hooks/qemu.d/$VM/"

echo
echo "Teclado/mouse por evdev (opcional): cole em 'virsh edit $VM' antes de </domain>, e adicione os caminhos em cgroup_device_acl no /etc/libvirt/qemu.conf"
for d in /dev/input/by-id/*-event-kbd /dev/input/by-id/*-event-mouse; do
    [[ -e $d ]] || continue
    case "$d" in *kbd)   echo "    <qemu:arg value='-object'/><qemu:arg value='input-linux,id=kbd1,evdev=$d,grab_all=on,repeat=on'/>";;
                 *mouse) echo "    <qemu:arg value='-object'/><qemu:arg value='input-linux,id=mouse1,evdev=$d'/>";; esac
done
echo
echo "Teste os hooks por SSH antes de ligar a VM:"
echo "  sudo /etc/libvirt/hooks/qemu.d/$VM/prepare/begin/start.sh && lspci -k -s ${GPU#0000:} | grep 'in use'"
echo "  sudo /etc/libvirt/hooks/qemu.d/$VM/release/end/stop.sh"
