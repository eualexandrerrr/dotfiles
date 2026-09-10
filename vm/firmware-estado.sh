#!/usr/bin/env bash
# Salva e restaura o estado de firmware da VM w11, que mora na / e MORRE no format:
#
#   /var/lib/libvirt/qemu/nvram/win11-redm_VARS.fd   variaveis UEFI
#   /var/lib/libvirt/swtpm/<uuid>/                   estado do vTPM
#
# O disco (~/vms/win.raw) e a definicao (vm/w11-*.xml) sobrevivem sozinhos -- estes dois nao,
# e sem eles a VM nao volta como estava:
#
#   - o VARS.fd guarda a entrada de boot do Windows Boot Manager e as chaves de Secure Boot
#     (o XML pede secure='yes'). Sem ele a VM cai no shell da UEFI, "no bootable device".
#   - o swtpm e o TPM 2.0 que o Windows 11 exige. Perder equivale a trocar de TPM: BitLocker
#     pede a chave de recuperacao, o PIN do Hello some e o Windows pode pedir reativacao.
#
#   vm/firmware-estado.sh salvar      copia pra ~/vms/firmware (na /home, sobrevive)
#   vm/firmware-estado.sh restaurar   devolve pra / depois do format, se estiver faltando
set -uo pipefail

VMS="$HOME/vms"
GUARDA="$VMS/firmware"
NVRAM=/var/lib/libvirt/qemu/nvram
SWTPM=/var/lib/libvirt/swtpm

ok(){ printf '  ok   %s\n' "$*"; }
aviso(){ printf '  !!   %s\n' "$*" >&2; }

salvar() {
    mkdir -p "$GUARDA"
    if sudo test -d "$NVRAM"; then
        sudo tar -C "$(dirname "$NVRAM")" -cf "$GUARDA/nvram.tar" "$(basename "$NVRAM")" \
            && sudo chown "$USER:$USER" "$GUARDA/nvram.tar" && ok "nvram salvo"
    fi
    if sudo test -d "$SWTPM"; then
        sudo tar -C "$(dirname "$SWTPM")" -cf "$GUARDA/swtpm.tar" "$(basename "$SWTPM")" \
            && sudo chown "$USER:$USER" "$GUARDA/swtpm.tar" && ok "swtpm salvo"
    fi
}

# Nunca sobrescreve: se o arquivo ja existe na /, quem manda e a maquina, nao o backup. Isso
# faz a etapa poder rodar em todo install.sh sem risco de voltar um estado velho por cima.
restaurar() {
    local t
    for t in nvram swtpm; do
        local tar="$GUARDA/$t.tar" destino
        [[ -f $tar ]] || continue
        destino=$([[ $t == nvram ]] && echo "$NVRAM" || echo "$SWTPM")
        if sudo test -n "$(sudo ls -A "$destino" 2>/dev/null)"; then
            ok "$t ja tem conteudo, nao mexo"
            continue
        fi
        sudo mkdir -p "$(dirname "$destino")"
        sudo tar -C "$(dirname "$destino")" -xf "$tar" && ok "$t restaurado de $tar" \
            || aviso "nao consegui restaurar $t"
    done
}

case "${1:-}" in
    salvar)    salvar ;;
    restaurar) restaurar ;;
    *) echo "uso: firmware-estado.sh salvar|restaurar" >&2; exit 1 ;;
esac
