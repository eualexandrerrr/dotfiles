#!/usr/bin/env bash
# Launch RedM or FiveM inside the VM, already connected to a server, wiping its cache first.
#
# The cache has to go on every launch. The client dies with
# "Failed to allocate memory for Vulkan. VkResult: VK_ERROR_OUT_OF_DEVICE_MEMORY" whenever
# that folder is stale, which reads like a passthrough failure and is not one: the Cfx.re
# forum is full of the same report on bare metal. Deleting it is cheap, the client rebuilds
# what it needs on the way in.
#
# The address is the host seen from inside the VM. It is NOT localhost: the guest reaches
# the Linux side through the gateway of the libvirt `default` network.
#
# Both clients refuse to run elevated, so the scheduled task uses LogonType Interactive with
# RunLevel Limited. With Highest it dies on "does not support running under elevated
# privileges".
#
#   vm/guest-game.sh redm [server]
#   vm/guest-game.sh fivem [server]
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
source "$HERE/guest.sh"

GAME="${1:-redm}"
SERVER="${2:-${GAME_CONNECT:-192.168.122.1:30120}}"

case "$GAME" in
    redm)
        EXE="${REDM_EXE:-D:\\Jogos\\RedM\\RedM.exe}"
        CACHE="${REDM_CACHE:-D:\\Jogos\\RedM\\RedM.app\\data\\cache}"
        SCHEME=redm
        ;;
    fivem)
        EXE="${FIVEM_EXE:-D:\\Jogos\\FiveM\\FiveM.exe}"
        CACHE="${FIVEM_CACHE:-D:\\Jogos\\FiveM\\FiveM.app\\data\\cache}"
        SCHEME=fivem
        ;;
    *)
        echo "guest-game: use 'redm' or 'fivem', got '$GAME'" >&2
        exit 1
        ;;
esac

guest_ready 60 || { echo "guest-game: the Windows agent did not answer" >&2; exit 1; }

# Fail loudly instead of registering a task that points at nothing: without this the task is
# created, starts, and dies silently -- the window simply never shows up.
if ! guest_exec "if (Test-Path '$EXE') { 'yes' } else { 'no' }" 2>/dev/null | grep -q yes; then
    echo "guest-game: $EXE nao existe dentro da VM -- instale o $GAME ou aponte outro caminho em ${GAME^^}_EXE" >&2
    exit 1
fi

echo "  connecting $GAME to $SERVER"

guest_exec "
Get-Process -Name '${GAME^}*' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5
Remove-Item '$CACHE' -Recurse -Force -ErrorAction SilentlyContinue
if (Test-Path '$CACHE') { 'cache still there' } else { 'cache cleared' }
\$action = New-ScheduledTaskAction -Execute '$EXE' -Argument '$SCHEME://connect/$SERVER'
\$who = New-ScheduledTaskPrincipal -UserId '${GUEST_USER:-Alexandre}' -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName 'dotfiles-$GAME' -Action \$action -Principal \$who -Force | Out-Null
Start-ScheduledTask -TaskName 'dotfiles-$GAME'
'launched'
"
