#!/usr/bin/env bash
# Instala e carrega o kvmfr, o dispositivo de memoria compartilhada do Looking Glass.
# Ele troca o arquivo em /dev/shm por um /dev/kvmfr0 que o cliente importa direto na GPU,
# sem a copia intermediaria em CPU. Idempotente.
#
# O modulo vem do mesmo fonte do cliente dev em ~/vms/lg-dev -- a mesma versao do host e do
# cliente, e o dkms recompila a cada kernel novo.
set -uo pipefail
MB="${KVMFR_MB:-128}"
ok(){ printf '  ok   %s\n' "$*"; }
aviso(){ printf '  !!   %s\n' "$*" >&2; }

fonte="$(find "$HOME/vms/lg-dev" -maxdepth 2 -type d -name module -print -quit 2>/dev/null)"

if ! modinfo kvmfr >/dev/null 2>&1; then
    [[ -n $fonte ]] || { aviso "fonte do kvmfr nao encontrada em ~/vms/lg-dev"; exit 0; }
    ( cd "$fonte" && sudo dkms install "." ) >/dev/null 2>&1 || { aviso "dkms recusou o kvmfr"; exit 0; }
    ok "kvmfr compilado pelo dkms"
fi

printf 'options kvmfr static_size_mb=%s\n' "$MB" | sudo tee /etc/modprobe.d/kvmfr.conf >/dev/null
printf '# KVMFR Looking Glass module\nkvmfr\n' | sudo tee /etc/modules-load.d/kvmfr.conf >/dev/null
printf 'SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"\n' | sudo tee /etc/udev/rules.d/70-kvmfr.rules >/dev/null
sudo udevadm control --reload-rules >/dev/null 2>&1

[[ -c /dev/kvmfr0 ]] || sudo modprobe kvmfr
[[ -c /dev/kvmfr0 ]] && ok "/dev/kvmfr0 (${MB}M)" || aviso "kvmfr nao carregou"

# O QEMU roda confinado por cgroup e so abre os dispositivos da lista do qemu.conf.
if ! sudo grep -q '^cgroup_device_acl' /etc/libvirt/qemu.conf; then
    sudo tee -a /etc/libvirt/qemu.conf >/dev/null <<'CONF'

cgroup_device_acl = [
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm", "/dev/userfaultfd",
    "/dev/kvmfr0"
]
CONF
    sudo systemctl restart libvirtd >/dev/null 2>&1
    ok "cgroup_device_acl com /dev/kvmfr0"
fi
