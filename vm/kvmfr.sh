#!/usr/bin/env bash
# Install and load kvmfr, the Looking Glass shared memory device.
#
# It replaces the file in /dev/shm with a /dev/kvmfr0 the client imports straight into the
# GPU, without the CPU copy the plain file forces. Idempotent.
#
# The module is built from the same source as the dev client in ~/vms/lg-dev, so host and
# client stay on one version, and dkms rebuilds it for every new kernel.
set -uo pipefail
MB="${KVMFR_MB:-128}"
ok(){ printf '  ok   %s\n' "$*"; }
warn(){ printf '  !!   %s\n' "$*" >&2; }

source_dir="$(find "$HOME/vms/lg-dev" -maxdepth 2 -type d -name module -print -quit 2>/dev/null)"

if ! modinfo kvmfr >/dev/null 2>&1; then
    [[ -n $source_dir ]] || { warn "kvmfr source not found under ~/vms/lg-dev"; exit 0; }
    ( cd "$source_dir" && sudo dkms install "." ) >/dev/null 2>&1 || { warn "dkms refused kvmfr"; exit 0; }
    ok "kvmfr built by dkms"
fi

printf 'options kvmfr static_size_mb=%s\n' "$MB" | sudo tee /etc/modprobe.d/kvmfr.conf >/dev/null
printf '# KVMFR Looking Glass module\nkvmfr\n' | sudo tee /etc/modules-load.d/kvmfr.conf >/dev/null
printf 'SUBSYSTEM=="kvmfr", GROUP="kvm", MODE="0660", TAG+="uaccess"\n' | sudo tee /etc/udev/rules.d/70-kvmfr.rules >/dev/null
sudo udevadm control --reload-rules >/dev/null 2>&1

[[ -c /dev/kvmfr0 ]] || sudo modprobe kvmfr
[[ -c /dev/kvmfr0 ]] && ok "/dev/kvmfr0 (${MB}M)" || warn "kvmfr did not load"

# QEMU runs confined by cgroup and only opens the devices listed in qemu.conf.
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
    ok "cgroup_device_acl with /dev/kvmfr0"
fi
