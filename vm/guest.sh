#!/usr/bin/env bash
# Funcoes para falar com o Windows da VM pelo qemu-guest-agent, sem tela e sem RDP.
# Carregue com `source`; nao roda sozinho.
#
# guest_exec '<powershell>'   roda o script no guest e devolve stdout+stderr
# guest_put  <local> <destino>  copia um arquivo do host para o guest
#
# O script vai por arquivo, nao por linha de comando: `guest-exec` tem limite de tamanho e
# um Add-Type inteiro nao cabe. Os caminhos do guest usam barra normal porque o JSON do
# agente engasga com a barra invertida.
VM="${VM:-w11}"

_qga() { virsh -c qemu:///system qemu-agent-command "$VM" "$@"; }

guest_put() {
    local origem="$1" destino="${2//\\//}" b64 h
    b64=$(base64 -w0 < "$origem")
    h=$(_qga "{\"execute\":\"guest-file-open\",\"arguments\":{\"path\":\"$destino\",\"mode\":\"wb\"}}" \
        | python3 -c 'import sys,json;print(json.load(sys.stdin)["return"])')
    _qga "{\"execute\":\"guest-file-write\",\"arguments\":{\"handle\":$h,\"buf-b64\":\"$b64\"}}" >/dev/null
    _qga "{\"execute\":\"guest-file-close\",\"arguments\":{\"handle\":$h}}" >/dev/null
}

guest_exec() {
    local tmp pid out fim
    tmp=$(mktemp); printf '%s\n' "$1" > "$tmp"
    guest_put "$tmp" 'C:/Windows/Temp/dotfiles-guest.ps1'
    rm -f "$tmp"
    pid=$(_qga '{"execute":"guest-exec","arguments":{"path":"powershell.exe","arg":["-NoProfile","-ExecutionPolicy","Bypass","-File","C:\\Windows\\Temp\\dotfiles-guest.ps1"],"capture-output":true}}' \
        | python3 -c 'import sys,json;print(json.load(sys.stdin)["return"]["pid"])')
    for _ in $(seq 1 180); do
        out=$(_qga "{\"execute\":\"guest-exec-status\",\"arguments\":{\"pid\":$pid}}")
        fim=$(printf '%s' "$out" | python3 -c 'import sys,json;print(json.load(sys.stdin)["return"]["exited"])')
        [[ $fim == True ]] && break
        sleep 1
    done
    printf '%s' "$out" | python3 -c '
import sys, json, base64
r = json.load(sys.stdin)["return"]
for k in ("out-data", "err-data"):
    if r.get(k):
        sys.stdout.write(base64.b64decode(r[k]).decode("utf-8", "replace").split("#< CLIXML")[0])
'
}

guest_pronto() {
    local i
    for i in $(seq 1 "${1:-60}"); do
        _qga '{"execute":"guest-ping"}' >/dev/null 2>&1 && return 0
        sleep 2
    done
    return 1
}
