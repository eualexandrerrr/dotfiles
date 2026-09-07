#!/usr/bin/env bash
# Lista grupos IOMMU e destaca a RTX 3090 (10de:2204) e o audio HDMI dela (10de:1aef).
shopt -s nullglob
for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
    echo "IOMMU Group ${g##*/}:"
    for d in "$g"/devices/*; do
        line="$(lspci -nns "${d##*/}")"
        case "$line" in
            *10de:2204*|*10de:1aef*) printf '\t\e[1;32m%s\e[0m  <-- 3090\n' "$line" ;;
            *) printf '\t%s\n' "$line" ;;
        esac
    done
done
echo
echo "Endereços pra libvirt (virsh nodedev-detach pci_0000_XX_00_0):"
lspci -Dnn | grep -E '10de:(2204|1aef)' | awk '{print "  " $1}'
