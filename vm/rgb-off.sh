#!/usr/bin/env bash
# Apaga o RGB da 3090 e deixa apagado em todo logon do Windows.
#
# O host nao alcanca esse RGB: a placa esta em vfio-pci, sem driver aqui, e nao expoe
# barramento I2C nenhum (`i2cdetect -l` so mostra AMDGPU e o SMBus do chipset). Quem fala com
# o controlador da placa e o Windows da VM, pelo I2C da propria 3090 via driver NVIDIA.
#
# Roda uma vez; a tarefa "AtLogOn" cobre os boots seguintes. Idempotente: so baixa o OpenRGB
# se ele nao estiver la.
set -euo pipefail
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
source "$HERE/guest.sh"

GUEST_USER="${GUEST_USER:-Alexandre}"
OPENRGB_DIR='C:\Tools\OpenRGB\OpenRGB Windows 64-bit'

guest_ready 30 || { echo "rgb-off: o agente da VM nao respondeu" >&2; exit 1; }

# URL oficial do openrgb.org: artefato de CI do proprio projeto, nao um mirror.
guest_exec "
\$ErrorActionPreference = 'Stop'
\$exe = '$OPENRGB_DIR\\OpenRGB.exe'
if (-not (Test-Path \$exe)) {
    \$url = 'https://gitlab.com/CalcProgrammer1/OpenRGB/-/jobs/artifacts/master/download?job=Windows%2064'
    \$zip = 'C:\Windows\Temp\openrgb.zip'
    Invoke-WebRequest -Uri \$url -OutFile \$zip -UseBasicParsing
    New-Item -ItemType Directory -Path 'C:\Tools\OpenRGB' -Force | Out-Null
    Expand-Archive -Path \$zip -DestinationPath 'C:\Tools\OpenRGB' -Force
}
Test-Path \$exe
" >/dev/null

guest_exec "
\$action = New-ScheduledTaskAction -Execute '$OPENRGB_DIR\\OpenRGB.exe' -Argument '--color 000000'
\$trigger = New-ScheduledTaskTrigger -AtLogOn -User '$GUEST_USER'
\$who = New-ScheduledTaskPrincipal -UserId '$GUEST_USER' -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName 'dotfiles-rgb-off' -Action \$action -Trigger \$trigger -Principal \$who -Force | Out-Null
Start-ScheduledTask -TaskName 'dotfiles-rgb-off'
" >/dev/null

echo "  RGB da 3090 apagado -- e apaga sozinho em todo logon do Windows"
