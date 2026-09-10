#!/usr/bin/env bash
# Garante que os parametros citados estejam na linha de comando do kernel, em qualquer um
# dos tres bootloaders que esta maquina ja usou. Idempotente: parametro que ja esta la nao
# entra de novo. Usado pelo install.sh (driver NVIDIA) e pelo setup.sh (IOMMU da VM).
#
#   ~/.dotfiles/bin/kernel-params.sh amd_iommu=on iommu=pt
set -uo pipefail

(( $# )) || { echo "uso: kernel-params.sh <param> [param...]" >&2; exit 1; }
params=("$@")
aplicado=0

if sudo test -d /boot/loader/entries && command -v bootctl >/dev/null 2>&1; then
    while IFS= read -r entry; do
        sudo grep -qE '^options ' "$entry" || continue
        for p in "${params[@]}"; do
            sudo grep -qF -- "$p" "$entry" || sudo sed -i "s|^options .*|& $p|" "$entry"
        done
        aplicado=1
        printf '  ok   systemd-boot: %s com os parametros\n' "$(basename "$entry")"
    done < <(sudo find /boot/loader/entries -maxdepth 1 -name '*.conf' 2>/dev/null)
fi

if sudo test -f /etc/kernel/cmdline; then
    for p in "${params[@]}"; do
        sudo grep -qF -- "$p" /etc/kernel/cmdline \
            || printf ' %s' "$p" | sudo tee -a /etc/kernel/cmdline >/dev/null
    done
    aplicado=1
    printf '  ok   /etc/kernel/cmdline atualizado\n'
fi

# So mexe no GRUB se ele puder ser regerado: editar o /etc/default/grub sem rodar o
# grub-mkconfig deixa o arquivo divergindo do grub.cfg que o boot realmente le.
if [[ -f /etc/default/grub ]] && command -v grub-mkconfig >/dev/null 2>&1 && [[ -d /boot/grub ]]; then
    for p in "${params[@]}"; do
        grep -qF -- "$p" /etc/default/grub \
            || sudo sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\)\"|\1 $p\"|" /etc/default/grub
    done
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    aplicado=1
    printf '  ok   GRUB regerado\n'
fi

if (( aplicado )); then
    exit 0
else
    printf '  !!   nenhum bootloader reconhecido, adicione na mao: %s\n' "${params[*]}" >&2
    exit 1
fi
