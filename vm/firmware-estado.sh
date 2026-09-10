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
#
# O `salvar` NAO depende de o Alexandre lembrar: o hook release/end do libvirt chama sozinho
# toda vez que a VM desliga, que e exatamente quando esse estado acabou de mudar. Rodando de
# la ja se esta como root e sem HOME do usuario, dai o DONO/VMS_DIR.
set -uo pipefail

DONO="${DONO:-$USER}"
VMS="${VMS_DIR:-$(getent passwd "$DONO" | cut -d: -f6)/vms}"
GUARDA="$VMS/firmware"
NVRAM=/var/lib/libvirt/qemu/nvram
SWTPM=/var/lib/libvirt/swtpm

ok(){ printf '  ok   %s\n' "$*"; }
aviso(){ printf '  !!   %s\n' "$*" >&2; }

# Chamado tanto pela mao (usuario) quanto pelo hook do libvirt (root). sudo dentro do hook
# nao existe no PATH minimo dele, entao so usa quando realmente falta privilegio.
priv(){ if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

salvar() {
    mkdir -p "$GUARDA" 2>/dev/null || priv mkdir -p "$GUARDA"
    local par
    for par in "nvram:$NVRAM" "swtpm:$SWTPM"; do
        local nome="${par%%:*}" origem="${par#*:}"
        priv test -d "$origem" || continue
        # Escreve em .novo e so troca no fim: hook interrompido no meio nao deixa um tar
        # truncado no lugar do backup bom.
        if priv tar -C "$(dirname "$origem")" -cf "$GUARDA/$nome.tar.novo" "$(basename "$origem")"; then
            priv mv -f "$GUARDA/$nome.tar.novo" "$GUARDA/$nome.tar"
            priv chown "$DONO:$DONO" "$GUARDA/$nome.tar"
            ok "$nome salvo"
        else
            priv rm -f "$GUARDA/$nome.tar.novo"
            aviso "nao consegui salvar $nome"
        fi
    done
    priv chown "$DONO:$DONO" "$GUARDA" 2>/dev/null || true
}

# Nunca sobrescreve: se o arquivo ja existe na /, quem manda e a maquina, nao o backup. Isso
# faz a etapa poder rodar em todo install.sh sem risco de voltar um estado velho por cima.
restaurar() {
    local t
    for t in nvram swtpm; do
        local tar="$GUARDA/$t.tar" destino
        [[ -f $tar ]] || continue
        destino=$([[ $t == nvram ]] && echo "$NVRAM" || echo "$SWTPM")
        if [[ -n "$(priv ls -A "$destino" 2>/dev/null)" ]]; then
            ok "$t ja tem conteudo, nao mexo"
            continue
        fi
        priv mkdir -p "$(dirname "$destino")"
        priv tar -C "$(dirname "$destino")" -xf "$tar" && ok "$t restaurado de $tar" \
            || aviso "nao consegui restaurar $t"
    done
}

case "${1:-}" in
    salvar)    salvar ;;
    restaurar) restaurar ;;
    *) echo "uso: firmware-estado.sh salvar|restaurar" >&2; exit 1 ;;
esac
