#!/usr/bin/env bash
# Instala o CTRL+ALT+Home dentro do Windows: roda uma vez (a tarefa agendada "AtLogOn" cobre os
# proximos boots sozinha). RegisterHotKey precisa de sessao interativa com loop de mensagens
# -- por isso vira tarefa agendada com LogonType Interactive, ligada tambem agora, pra nao
# esperar o proximo login.
set -euo pipefail
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
source "$HERE/guest.sh"

GUEST_USER="${GUEST_USER:-Alexandre}"

guest_ready 30 || { echo "modo-jogo: o agente da VM nao respondeu" >&2; exit 1; }

cat >/tmp/modo-jogo-hotkey.ps1 <<'PS1'
$src = @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class HotkeyForm : Form {
  [DllImport("user32.dll")] static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);
  protected override void OnLoad(EventArgs e) {
    this.Visible = false;
    this.ShowInTaskbar = false;
    RegisterHotKey(this.Handle, 1, 0x0003, 0x24); // CTRL + ALT + Home
  }
  protected override void WndProc(ref Message m) {
    if (m.Msg == 0x0312 && m.WParam.ToInt32() == 1) {
      try { new System.Net.WebClient().DownloadString("http://192.168.122.1:8765/voltar"); } catch {}
    }
    base.WndProc(ref m);
  }
}
"@
Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition $src -ReferencedAssemblies System.Windows.Forms
[System.Windows.Forms.Application]::Run((New-Object HotkeyForm))
PS1
guest_put /tmp/modo-jogo-hotkey.ps1 'C:/Windows/Temp/modo-jogo-hotkey.ps1'
rm -f /tmp/modo-jogo-hotkey.ps1

guest_exec "
\$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File C:\Windows\Temp\modo-jogo-hotkey.ps1'
\$trigger = New-ScheduledTaskTrigger -AtLogOn -User '$GUEST_USER'
\$who = New-ScheduledTaskPrincipal -UserId '$GUEST_USER' -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName 'dotfiles-modo-jogo-hotkey' -Action \$action -Trigger \$trigger -Principal \$who -Force | Out-Null
Start-ScheduledTask -TaskName 'dotfiles-modo-jogo-hotkey'
"
echo "  CTRL+ALT+Home instalado -- ativo agora e em todo login futuro"
