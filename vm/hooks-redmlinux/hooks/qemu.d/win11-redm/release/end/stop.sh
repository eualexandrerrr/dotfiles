#!/usr/bin/env bash
# Depois que a VM desliga: a 3090 volta pro vfio-pci (nao pro host) e a sessao nunca
# parou, entao so ha a trava de suspensao pra soltar.
exec >>/var/log/libvirt/hooks-win11-redm.log 2>&1
echo "== stop $(date -Is)"

# ANTES do filtro de perfil: o UEFI e o vTPM mudam nos dois perfis, e este e o unico
# momento em que o estado acabou de ser gravado. Sem isto o backup so existiria se alguem
# lembrasse de rodar na mao antes de formatar -- e nao existiria.
DONO=@USERNAME@ bash "/home/@USERNAME@/.dotfiles/vm/firmware-estado.sh" salvar || true

XML=""; [[ -t 0 ]] || XML="$(cat)"
if [[ -n $XML ]] && ! grep -q "<hostdev mode='subsystem' type='pci'" <<<"$XML"; then
    echo "sem hostdev PCI no XML: perfil janela, nada a fazer"; exit 0
fi
set -x

systemctl stop "libvirt-nosleep@$1.service" || true
# A maquina fica em desempenho maximo o tempo todo, dentro e fora da VM.
for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > "$g" || true; done
for e in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo performance > "$e" || true; done
echo "== stop ok"
