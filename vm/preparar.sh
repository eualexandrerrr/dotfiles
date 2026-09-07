#!/usr/bin/env bash
# Deixa o host pronto pra VM w11: libvirtd, rede default, disco em ~/vms (sobrevive ao format),
# acesso do libvirt-qemu a ~/vms e os hooks do RedMLinux. Idempotente. Nao mexe no vfio:
# isso e o vfio-ativar.sh, so depois da segunda GPU.
set -uo pipefail
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"; VMS="$HOME/vms"
ok(){ printf '  ok   %s\n' "$*"; }
sudo systemctl enable --now libvirtd >/dev/null 2>&1 && ok "libvirtd"
virsh -c qemu:///system net-autostart default >/dev/null 2>&1; virsh -c qemu:///system net-start default >/dev/null 2>&1; ok "rede default"
mkdir -p "$VMS"
[[ -f $VMS/win.raw ]] || { qemu-img create -f raw -o preallocation=falloc "$VMS/win.raw" 200G >/dev/null && ok "win.raw 200G"; }
sudo setfacl -m u:libvirt-qemu:x "$HOME"; sudo setfacl -R -m u:libvirt-qemu:rwx "$VMS"; sudo setfacl -R -d -m u:libvirt-qemu:rwx "$VMS"; ok "acl do libvirt-qemu em ~/vms"
sudo bash "$DOTFILES_DIR/vm/hooks-redmlinux/install-hooks.sh" w11 "$USER" >/dev/null 2>&1 && ok "hooks em /etc/libvirt/hooks/qemu.d/w11"
sudo install -Dm644 "$DOTFILES_DIR/vm/looking-glass.tmpfiles" /etc/tmpfiles.d/10-looking-glass.conf && sudo systemd-tmpfiles --create /etc/tmpfiles.d/10-looking-glass.conf && ok "shmem do Looking Glass"
bash "$DOTFILES_DIR/vm/autounattend-vm.sh"
[[ -f $VMS/virtio-win.iso ]] || curl -sSL -o "$VMS/virtio-win.iso" https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso && ok "virtio-win.iso"
