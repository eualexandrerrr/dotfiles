#!/usr/bin/env bash
# Duas GPUs: RX 550 desenha o host, RTX 3090 vai inteira pra VM. A 3090 ja esta presa no
# vfio-pci desde o boot (vm/vfio-ativar.sh), e o hostdev do XML e managed="yes", entao o
# libvirt cuida do bind sozinho. Aqui nao se derruba sessao, nem display manager, nem
# nvidia: isso era do tempo de uma GPU so.
# Placeholders preenchidos por install-hooks.sh: @GPU_V@ @AUD_V@ @USERNAME@
exec >>/var/log/libvirt/hooks-win11-redm.log 2>&1
echo "== start $(date -Is)"

# Perfil "janela" (dotfiles vm/w11-janela.xml): sem hostdev PCI, a 3090 fica no host e nao ha o que fazer.
# O XML vem no stdin via dispatcher. Rodando na mao (stdin e terminal) assume perfil 3090.
XML=""; [[ -t 0 ]] || XML="$(cat)"
if [[ -n $XML ]] && ! grep -q "<hostdev mode='subsystem' type='pci'" <<<"$XML"; then
    echo "sem hostdev PCI no XML: perfil janela, nada a fazer"; exit 0
fi

GPU_V="@GPU_V@"; AUD_V="@AUD_V@"

# A unica guarda que importa: sem a RX 550 desenhando o host, entregar a 3090 pra VM deixa
# o PC sem tela e sem como voltar. Mesma logica do vm/vfio-ativar.sh.
if ! grep -qs amdgpu /sys/class/drm/card*/device/uevent; then
    echo "amdgpu nao esta em uso: sem a RX 550 o host fica sem tela. Abortado."
    exit 1
fi

set -x
systemctl start "libvirt-nosleep@$1.service" || true
lspci -k -s "${GPU_V#pci_}" 2>/dev/null || true
echo "== start ok"
