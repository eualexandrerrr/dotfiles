#!/usr/bin/env bash
# Diz qual GPU desenha o desktop, em KEY=VALUE pra ser lido por outro script:
#
#   GPU_DRIVER=amdgpu
#   GPU_PCI=0000:04:00.0
#   GPU_CARD=/dev/dri/by-path/pci-0000:04:00.0-card
#   GPU_OUTRAS=0000:07:00.0            (as demais GPUs com nó DRM, separadas por espaço)
#
# Quem tem monitor ligado ganha. O empate acontece de verdade nesta maquina: os dummy plugs
# da 3090 clonam EDID e aparecem como `connected` igual aos monitores reais, entao a NVIDIA
# so vale como ultimo recurso -- se ela fosse a unica placa, ai sim e ela que desenha.
set -uo pipefail

candidato_drv=""; candidato_pci=""
nvidia_drv=""; nvidia_pci=""
outras=()

for card in /sys/class/drm/card[0-9]*; do
    [[ -e $card/device/driver ]] || continue
    [[ $(basename "$card") == *-* ]] && continue

    drv="$(basename "$(readlink -f "$card/device/driver")")"
    pci="$(basename "$(readlink -f "$card/device")")"

    ligado=""
    for st in "$card"-*/status; do
        [[ -e $st ]] || continue
        [[ $(<"$st") == connected ]] && { ligado=1; break; }
    done

    if [[ -z $ligado ]]; then
        outras+=("$pci")
    elif [[ $drv == nvidia ]]; then
        [[ -z $nvidia_drv ]] && { nvidia_drv="$drv"; nvidia_pci="$pci"; } || outras+=("$pci")
    elif [[ -z $candidato_drv ]]; then
        candidato_drv="$drv"; candidato_pci="$pci"
    else
        outras+=("$pci")
    fi
done

if [[ -z $candidato_drv ]]; then
    candidato_drv="$nvidia_drv"; candidato_pci="$nvidia_pci"
elif [[ -n $nvidia_pci ]]; then
    outras+=("$nvidia_pci")
fi

[[ -n $candidato_drv ]] || exit 1

printf 'GPU_DRIVER=%s\n' "$candidato_drv"
printf 'GPU_PCI=%s\n' "$candidato_pci"
printf 'GPU_CARD=/dev/dri/by-path/pci-%s-card\n' "$candidato_pci"
printf 'GPU_OUTRAS=%s\n' "${outras[*]-}"
