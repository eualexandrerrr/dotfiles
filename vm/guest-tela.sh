#!/usr/bin/env bash
# Poe a tela virtual do Looking Glass na MESMA taxa do monitor fisico do Hyprland.
#
# O IDD nasce com 2560x1440@60 e o Windows guarda a taxa que usou da ultima vez, entao o
# jogo roda a 60 fps por mais rapida que seja a 3090. E taxa aproximada nao serve: o proprio
# manual do Looking Glass manda casar o valor exato, senao o "Hold" bate e o frame chega
# atrasado. Por isso a taxa vem do hyprctl, com as tres casas.
#
# As APIs de video do user32 nao existem na sessao 0, onde o guest-agent roda. A troca vai
# por uma tarefa agendada com LogonType Interactive, que cai na sessao do console.
set -uo pipefail
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
source "$HERE/guest.sh"

MARCA="${MARCA:-ASUSTek COMPUTER INC XG27ACS}"

leia_monitor() {
    hyprctl monitors -j | python3 -c "
import sys, json
for m in json.load(sys.stdin):
    if m['description'].startswith('''$MARCA'''):
        print(m['width'], m['height'], round(m['refreshRate'], 3))
        break
"
}

read -r LARG ALT HZ <<<"$(leia_monitor)"
[[ -n ${HZ:-} ]] || { echo "guest-tela: monitor '$MARCA' nao esta ligado" >&2; exit 1; }
HZ_INT=$(python3 -c "print(round($HZ))")
echo "  alvo ${LARG}x${ALT}@${HZ}"

guest_pronto 60 || { echo "guest-tela: o agente do Windows nao respondeu" >&2; exit 1; }

# Sai cedo quando ja esta certo: recriar o IDD apaga a tela por um instante e nao ha motivo
# de fazer isso a cada partida.
atual=$(guest_exec "
\$v = Get-CimInstance Win32_VideoController | Where-Object { \$_.Name -like '*Indirect*' }
\"\$(\$v.CurrentHorizontalResolution)x\$(\$v.CurrentVerticalResolution)@\$(\$v.CurrentRefreshRate)\"
" | tr -d '\r\n ')
# O WMI trunca a taxa real (119,998 vira 119) e o DEVMODE devolve a nominal (120), entao a
# comparacao aceita um hertz de diferenca.
for hz in $HZ_INT $((HZ_INT - 1)); do
    if [[ $atual == "${LARG}x${ALT}@${hz}" ]]; then
        echo "  ja esta em $atual"
        exit 0
    fi
done
echo "  hoje esta em ${atual:-?}"

guest_exec "
Set-ItemProperty -Path 'HKLM:\\SOFTWARE\\LookingGlass\\IDD' -Name ExtraMode -Value '${LARG}x${ALT}@${HZ}*'
Get-ItemProperty 'HKLM:\\SOFTWARE\\LookingGlass\\IDD' | Select-Object -ExpandProperty ExtraMode
Disable-PnpDevice -InstanceId 'ROOT\\DISPLAY\\0000' -Confirm:\$false
Start-Sleep -Seconds 3
Enable-PnpDevice -InstanceId 'ROOT\\DISPLAY\\0000' -Confirm:\$false
Start-Sleep -Seconds 5
"

cat > /tmp/guest-tela.ps1 <<PS1
\$log = 'C:\Windows\Temp\guest-tela.log'
"alvo ${LARG}x${ALT}@${HZ_INT}" | Out-File \$log -Encoding utf8
function L(\$m) { \$m | Out-File \$log -Append -Encoding utf8 }
\$src = @"
using System;
using System.Runtime.InteropServices;
public class Tela {
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
\$sz = [Runtime.InteropServices.Marshal]::SizeOf([type]([Tela+DEVMODE]))

\$atual = New-Object Tela+DEVMODE
\$atual.dmSize = \$sz
[void][Tela]::EnumDisplaySettingsW([NullString]::Value, -1, [ref]\$atual)
L "atual \$(\$atual.dmPelsWidth)x\$(\$atual.dmPelsHeight)@\$(\$atual.dmDisplayFrequency)"

\$alvo = \$null
for (\$m = 0; \$m -lt 400; \$m++) {
  \$dm = New-Object Tela+DEVMODE
  \$dm.dmSize = \$sz
  if (-not [Tela]::EnumDisplaySettingsW([NullString]::Value, \$m, [ref]\$dm)) { break }
  if (\$dm.dmPelsWidth -eq $LARG -and \$dm.dmPelsHeight -eq $ALT -and \$dm.dmBitsPerPel -eq 32) {
    if (\$dm.dmDisplayFrequency -eq $HZ_INT) { \$alvo = \$dm; break }
  }
}
if (\$alvo -eq \$null) { L "modo ${LARG}x${ALT}@${HZ_INT} nao esta na lista do IDD"; exit 2 }

\$alvo.dmFields = 0x00080000 -bor 0x00100000 -bor 0x00400000 -bor 0x00040000
L "troca = \$([Tela]::ChangeDisplaySettingsW([ref]\$alvo, 1))"

Start-Sleep -Seconds 3
\$fim = New-Object Tela+DEVMODE
\$fim.dmSize = \$sz
[void][Tela]::EnumDisplaySettingsW([NullString]::Value, -1, [ref]\$fim)
L "final \$(\$fim.dmPelsWidth)x\$(\$fim.dmPelsHeight)@\$(\$fim.dmDisplayFrequency)"
PS1

guest_put /tmp/guest-tela.ps1 'C:/Windows/Temp/guest-tela.ps1'
rm -f /tmp/guest-tela.ps1

guest_exec "
\$acao = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\guest-tela.ps1'
\$quem = New-ScheduledTaskPrincipal -UserId 'Alexandre' -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName 'dotfiles-tela' -Action \$acao -Principal \$quem -Force | Out-Null
Start-ScheduledTask -TaskName 'dotfiles-tela'
Start-Sleep -Seconds 20
Get-Content C:\Windows\Temp\guest-tela.log
"
