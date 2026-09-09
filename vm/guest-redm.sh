#!/usr/bin/env bash
# Launch RedM inside the VM already connected to a server, and wipe its cache first.
#
# The cache has to go on every launch. RedM dies with
# "Failed to allocate memory for Vulkan. VkResult: VK_ERROR_OUT_OF_DEVICE_MEMORY" whenever
# that folder is stale, which reads like a passthrough failure and is not one: the Cfx.re
# forum is full of the same report on bare metal. Deleting it is cheap, the client rebuilds
# what it needs on the way in.
#
# The address is the host seen from inside the VM. It is NOT localhost: the guest reaches
# the Linux side through the gateway of the libvirt `default` network.
#
# RedM refuses to run elevated, so the scheduled task uses LogonType Interactive with
# RunLevel Limited. With Highest it dies on "RedM does not support running under elevated
# privileges".
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
source "$HERE/guest.sh"

SERVER="${REDM_CONNECT:-192.168.122.1:30120}"
REDM_EXE="${REDM_EXE:-D:\\Jogos\\RedM\\RedM.exe}"
REDM_CACHE="${REDM_CACHE:-D:\\Jogos\\RedM\\RedM.app\\data\\cache}"

guest_ready 60 || { echo "guest-redm: the Windows agent did not answer" >&2; exit 1; }

echo "  connecting RedM to $SERVER"

guest_exec "
Get-Process -Name 'RedM*' -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 5
Remove-Item '$REDM_CACHE' -Recurse -Force -ErrorAction SilentlyContinue
if (Test-Path '$REDM_CACHE') { 'cache still there' } else { 'cache cleared' }
\$action = New-ScheduledTaskAction -Execute '$REDM_EXE' -Argument 'redm://connect/$SERVER'
\$who = New-ScheduledTaskPrincipal -UserId '${GUEST_USER:-Alexandre}' -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName 'dotfiles-redm' -Action \$action -Principal \$who -Force | Out-Null
Start-ScheduledTask -TaskName 'dotfiles-redm'
'launched'
"
