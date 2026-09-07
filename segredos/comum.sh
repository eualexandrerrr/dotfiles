# Compartilhado pelo guardar.sh e pelo restaurar.sh. Nao roda sozinho.

ROTULO_PENDRIVE="${ROTULO_PENDRIVE:-Ventoy}"
DIR_NO_PENDRIVE="${DIR_NO_PENDRIVE:-dotfiles}"
MONTAGEM=""
CHAVE=""

ok()     { printf '  ok   %s\n' "$*"; }
aviso()  { printf '  !!   %s\n' "$*" >&2; }
erro()   { printf '  ERRO %s\n' "$*" >&2; }

desmontar_pendrive() {
    [[ -n ${MONTOU_AQUI:-} && -n $MONTAGEM ]] || return 0
    umount "$MONTAGEM" 2>/dev/null || sudo umount "$MONTAGEM" 2>/dev/null || true
    rmdir "$MONTAGEM" 2>/dev/null || sudo rmdir "$MONTAGEM" 2>/dev/null || true
    MONTOU_AQUI=""
}

montar_pendrive() {
    local dev
    dev="$(blkid -L "$ROTULO_PENDRIVE" 2>/dev/null || true)"
    [[ -b ${dev:-} ]] || return 1

    MONTAGEM="$(findmnt -n -o TARGET --source "$dev" 2>/dev/null | head -1)"
    if [[ -z $MONTAGEM ]]; then
        MONTAGEM="$(mktemp -d)"
        if ! mount -o uid=$(id -u),gid=$(id -g) "$dev" "$MONTAGEM" 2>/dev/null \
           && ! sudo mount -o uid=$(id -u),gid=$(id -g) "$dev" "$MONTAGEM" 2>/dev/null; then
            rmdir "$MONTAGEM" 2>/dev/null || true
            MONTAGEM=""
            return 1
        fi
        MONTOU_AQUI=1
        trap desmontar_pendrive EXIT
    fi
    CHAVE="$MONTAGEM/$DIR_NO_PENDRIVE/chave.txt"
    return 0
}
