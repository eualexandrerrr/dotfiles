#!/usr/bin/env bash
# Put the Looking Glass virtual display on the SAME refresh rate as the physical monitor.
#
# The IDD is created at 2560x1440@60 and Windows keeps the rate it used last, so the game
# runs at 60 fps no matter how fast the 3090 is. An approximate rate is not enough either:
# the Looking Glass manual asks for the exact value, otherwise the two free-running clocks
# beat against each other and frames arrive late. That is why the rate comes from
# kscreen-doctor, with its decimals, instead of being rounded to 60/120/144.
#
# The user32 display APIs do not exist in session 0, where the guest agent runs. The change
# goes through a scheduled task with LogonType Interactive, which lands in the console
# session.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
source "$HERE/guest.sh"

BRAND="${BRAND:-ASUSTek COMPUTER INC XG27ACS}"
GUEST_USER="${GUEST_USER:-Alexandre}"

# O conector sai do bin/monitor.sh (que le o EDID e nao depende de sessao); a taxa de verdade
# sai de quem manda nas telas na sessao de agora -- kscreen-doctor no Plasma, cosmic-randr no
# COSMIC, hyprctl no Hyprland. Com o desktop errado o JSON vem vazio e a tela virtual fica nos
# 60 Hz de nascenca, o que prende o jogo em 60 fps (visto no COSMIC em 12/09/2026).
read_monitor() {
    local conector
    conector="$("${DOTFILES_DIR:-$HOME/.dotfiles}/bin/monitor.sh" principal 2>/dev/null)"
    [[ -n $conector ]] || return 1

    if command -v kscreen-doctor >/dev/null 2>&1; then
        kscreen-doctor -j 2>/dev/null | CONECTOR="$conector" python3 -c "
import sys, json, os
alvo = os.environ['CONECTOR']
try:
    dados = json.load(sys.stdin)
except ValueError:
    sys.exit(1)
for o in dados.get('outputs', []):
    if o.get('name') != alvo:
        continue
    atual = o.get('currentModeId')
    for m in o.get('modes', []):
        if m.get('id') == atual:
            t = m['size']
            print(t['width'], t['height'], round(m['refreshRate'], 3))
            sys.exit(0)
sys.exit(1)
" && return 0
    fi

    if command -v cosmic-randr >/dev/null 2>&1; then
        cosmic-randr list 2>/dev/null | CONECTOR="$conector" python3 -c "
import os, re, sys
alvo = os.environ['CONECTOR']
dentro = False
for linha in sys.stdin:
    linha = re.sub(r'\x1b\[[0-9;]*m', '', linha)
    cabeca = re.match(r'^(\S+) \(', linha)
    if cabeca:
        dentro = cabeca.group(1) == alvo
        continue
    if dentro and '(current)' in linha:
        m = re.search(r'(\d+)x(\d+) @ *([0-9.]+) Hz', linha)
        if m:
            print(m.group(1), m.group(2), round(float(m.group(3)), 3))
            sys.exit(0)
sys.exit(1)
" && return 0
    fi

    if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && command -v hyprctl >/dev/null 2>&1; then
        hyprctl -j monitors 2>/dev/null | CONECTOR="$conector" python3 -c "
import sys, json, os
alvo = os.environ['CONECTOR']
try:
    dados = json.load(sys.stdin)
except ValueError:
    sys.exit(1)
for m in dados:
    if m.get('name') == alvo:
        print(m['width'], m['height'], round(m['refreshRate'], 3))
        sys.exit(0)
sys.exit(1)
" && return 0
    fi

    return 1
}

read -r WIDTH HEIGHT HZ <<<"$(read_monitor)"
[[ -n ${HZ:-} ]] || { echo "guest-display: could not read the mode of monitor '$BRAND'" >&2; exit 1; }
HZ_INT=$(python3 -c "print(round($HZ))")
echo "  target ${WIDTH}x${HEIGHT}@${HZ}"

guest_ready 60 || { echo "guest-display: the Windows agent did not answer" >&2; exit 1; }

# Leave early when it is already right: recreating the IDD blanks the screen for a moment
# and there is no reason to do that before every match.
current=$(guest_exec "
\$v = Get-CimInstance Win32_VideoController | Where-Object { \$_.Name -like '*Indirect*' }
\"\$(\$v.CurrentHorizontalResolution)x\$(\$v.CurrentVerticalResolution)@\$(\$v.CurrentRefreshRate)\"
" | tr -d '\r\n ')

# WMI truncates the real rate (119.998 reads as 119) and DEVMODE reports the nominal one
# (120), so the comparison accepts one hertz of difference.
for hz in $HZ_INT $((HZ_INT - 1)); do
    if [[ $current == "${WIDTH}x${HEIGHT}@${hz}" ]]; then
        echo "  already at $current"
        exit 0
    fi
done
echo "  currently at ${current:-?}"

guest_exec "
Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\LookingGlass\\IDD' -Name ExtraMode -Value '${WIDTH}x${HEIGHT}@${HZ}*'
Get-ItemProperty 'HKLM:\\SOFTWARE\\LookingGlass\\IDD' | Select-Object -ExpandProperty ExtraMode
Disable-PnpDevice -InstanceId 'ROOT\\DISPLAY\\0000' -Confirm:\$false
Start-Sleep -Seconds 3
Enable-PnpDevice -InstanceId 'ROOT\\DISPLAY\\0000' -Confirm:\$false
Start-Sleep -Seconds 5
"

cat > /tmp/guest-display.ps1 <<PS1
\$log = 'C:\Windows\Temp\guest-display.log'
"target ${WIDTH}x${HEIGHT}@${HZ_INT}" | Out-File \$log -Encoding utf8
function L(\$m) { \$m | Out-File \$log -Append -Encoding utf8 }
\$src = @"
using System;
using System.Runtime.InteropServices;
public class Screen {
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
  public struct DEVMODE {
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmDeviceName;
    public short dmSpecVersion; public short dmDriverVersion; public short dmSize; public short dmDriverExtra;
    public int dmFields;
    public int dmPositionX; public int dmPositionY; public int dmDisplayOrientation; public int dmDisplayFixedOutput;
    public short dmColor; public short dmDuplex; public short dmYResolution; public short dmTTOption; public short dmCollate;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string dmFormName;
    public short dmLogPixels;
    public int dmBitsPerPel; public int dmPelsWidth; public int dmPelsHeight; public int dmDisplayFlags; public int dmDisplayFrequency;
    public int dmICMMethod; public int dmICMIntent; public int dmMediaType; public int dmDitherType; public int dmReserved1; public int dmReserved2;
    public int dmPanningWidth; public int dmPanningHeight;
  }
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern bool EnumDisplaySettingsW(string dev, int mode, ref DEVMODE dm);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern int ChangeDisplaySettingsW(ref DEVMODE dm, int flags);
}
"@
Add-Type -TypeDefinition \$src
\$size = [Runtime.InteropServices.Marshal]::SizeOf([type]([Screen+DEVMODE]))

# \$null in a P/Invoke string parameter reaches Win32 as an empty string, not as NULL, and
# every call fails in silence. [NullString]::Value is what asks for the default device.
\$now = New-Object Screen+DEVMODE
\$now.dmSize = \$size
[void][Screen]::EnumDisplaySettingsW([NullString]::Value, -1, [ref]\$now)
L "current \$(\$now.dmPelsWidth)x\$(\$now.dmPelsHeight)@\$(\$now.dmDisplayFrequency)"

\$target = \$null
for (\$m = 0; \$m -lt 400; \$m++) {
  \$dm = New-Object Screen+DEVMODE
  \$dm.dmSize = \$size
  if (-not [Screen]::EnumDisplaySettingsW([NullString]::Value, \$m, [ref]\$dm)) { break }
  if (\$dm.dmPelsWidth -eq $WIDTH -and \$dm.dmPelsHeight -eq $HEIGHT -and \$dm.dmBitsPerPel -eq 32) {
    if (\$dm.dmDisplayFrequency -eq $HZ_INT) { \$target = \$dm; break }
  }
}
if (\$target -eq \$null) { L "${WIDTH}x${HEIGHT}@${HZ_INT} is not in the IDD mode list"; exit 2 }

\$target.dmFields = 0x00080000 -bor 0x00100000 -bor 0x00400000 -bor 0x00040000
L "change = \$([Screen]::ChangeDisplaySettingsW([ref]\$target, 1))"

Start-Sleep -Seconds 3
\$after = New-Object Screen+DEVMODE
\$after.dmSize = \$size
[void][Screen]::EnumDisplaySettingsW([NullString]::Value, -1, [ref]\$after)
L "final \$(\$after.dmPelsWidth)x\$(\$after.dmPelsHeight)@\$(\$after.dmDisplayFrequency)"
PS1

guest_put /tmp/guest-display.ps1 'C:/Windows/Temp/guest-display.ps1'
rm -f /tmp/guest-display.ps1

guest_exec "
\$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\guest-display.ps1'
\$who = New-ScheduledTaskPrincipal -UserId '$GUEST_USER' -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName 'dotfiles-display' -Action \$action -Principal \$who -Force | Out-Null
Start-ScheduledTask -TaskName 'dotfiles-display'
Start-Sleep -Seconds 20
Get-Content C:\Windows\Temp\guest-display.log
"
