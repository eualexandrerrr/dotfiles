#!/usr/bin/env bash
# Talk to the VM's Windows through the qemu-guest-agent, with no screen and no RDP.
# Source it; it does nothing on its own.
#
# guest_exec '<powershell>'      run the script in the guest, return stdout and stderr
# guest_put  <local> <remote>    copy a file from the host into the guest
# guest_ready [tries]            wait until the agent answers
#
# The script travels as a file, not as a command line: guest-exec has a length limit and a
# whole Add-Type does not fit. Guest paths use forward slashes because the agent's JSON
# chokes on the backslash.
VM="${VM:-w11}"

_qga() { virsh -c qemu:///system qemu-agent-command "$VM" "$@"; }

guest_put() {
    local source="$1" target="${2//\\//}" b64 h
    b64=$(base64 -w0 < "$source")
    h=$(_qga "{\"execute\":\"guest-file-open\",\"arguments\":{\"path\":\"$target\",\"mode\":\"wb\"}}" \
        | python3 -c 'import sys,json;print(json.load(sys.stdin)["return"])')
    _qga "{\"execute\":\"guest-file-write\",\"arguments\":{\"handle\":$h,\"buf-b64\":\"$b64\"}}" >/dev/null
    _qga "{\"execute\":\"guest-file-close\",\"arguments\":{\"handle\":$h}}" >/dev/null
}

guest_exec() {
    local tmp pid out done_
    tmp=$(mktemp); printf '%s\n' "$1" > "$tmp"
    guest_put "$tmp" 'C:/Windows/Temp/dotfiles-guest.ps1'
    rm -f "$tmp"
    pid=$(_qga '{"execute":"guest-exec","arguments":{"path":"powershell.exe","arg":["-NoProfile","-ExecutionPolicy","Bypass","-File","C:\\Windows\\Temp\\dotfiles-guest.ps1"],"capture-output":true}}' \
        | python3 -c 'import sys,json;print(json.load(sys.stdin)["return"]["pid"])')
    for _ in $(seq 1 180); do
        out=$(_qga "{\"execute\":\"guest-exec-status\",\"arguments\":{\"pid\":$pid}}")
        done_=$(printf '%s' "$out" | python3 -c 'import sys,json;print(json.load(sys.stdin)["return"]["exited"])')
        [[ $done_ == True ]] && break
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

guest_ready() {
    local i
    for i in $(seq 1 "${1:-60}"); do
        _qga '{"execute":"guest-ping"}' >/dev/null 2>&1 && return 0
        sleep 2
    done
    return 1
}
