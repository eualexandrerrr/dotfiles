#!/usr/bin/env bash
# Olhos e maos dentro do Windows da VM, sem tela nem teclado: print da sessao do usuario e
# clique/teclado injetados nela. Source it; depende do vm/guest.sh.
#
# guest_screenshot <local.png>     print da tela do usuario logado (todos os monitores)
# guest_click <x> <y> [right|double]
# guest_type '<texto>'             digita texto literal (SendKeys, caracteres especiais escapados)
# guest_keys '<SendKeys>'          sequencia SendKeys crua: '%{TAB}', '{ENTER}', '^v'
# guest_windows                    lista janelas visiveis: pid, titulo, retangulo
# guest_focus <titulo>             traz a janela pra frente (AppActivate)
#
# O guest-agent roda na sessao 0, onde nao ha tela nem input: tudo aqui vai por uma tarefa
# agendada `dotfiles-ui` com LogonType Interactive, na sessao do usuario, e espera ela acabar.
# Print volta pelo guest-file-read em pedacos (o buffer do agente e limitado).
[[ -n ${VM:-} ]] || VM=w11
GUEST_USER="${GUEST_USER:-Alexandre}"
# shellcheck source=guest.sh
source "${DOTFILES_DIR:-$HOME/.dotfiles}/vm/guest.sh"

_ui_run() {
    local tmp
    tmp=$(mktemp)
    printf '%s\n' "$1" >"$tmp"
    guest_put "$tmp" 'C:/Windows/Temp/dotfiles-ui.ps1'
    rm -f "$tmp"
    guest_exec "
Remove-Item C:\\Windows\\Temp\\dotfiles-ui.done -ErrorAction SilentlyContinue
\$acao = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\\Windows\\Temp\\dotfiles-ui.ps1'
\$who  = New-ScheduledTaskPrincipal -UserId '$GUEST_USER' -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName 'dotfiles-ui' -Action \$acao -Principal \$who -Force | Out-Null
Start-ScheduledTask -TaskName 'dotfiles-ui'
for (\$i = 0; \$i -lt 120; \$i++) {
    if (Test-Path C:\\Windows\\Temp\\dotfiles-ui.done) { break }
    Start-Sleep -Milliseconds 500
}
if (Test-Path C:\\Windows\\Temp\\dotfiles-ui.out) { Get-Content C:\\Windows\\Temp\\dotfiles-ui.out -Raw }
" 2>/dev/null
}

# Tudo que roda na sessao do usuario termina marcando .done; a saida vai em .out.
_ui_wrap() {
    cat <<FIM
\$ErrorActionPreference = 'Continue'
\$out = 'C:\\Windows\\Temp\\dotfiles-ui.out'
Remove-Item \$out -ErrorAction SilentlyContinue
try {
$1
} catch { \$_ | Out-String | Add-Content \$out }
New-Item -ItemType File -Path 'C:\\Windows\\Temp\\dotfiles-ui.done' -Force | Out-Null
FIM
}

guest_get() {
    local remoto="${1//\\//}" local_="$2" h out
    h=$(_qga "{\"execute\":\"guest-file-open\",\"arguments\":{\"path\":\"$remoto\",\"mode\":\"rb\"}}" \
        | python3 -c 'import sys,json;print(json.load(sys.stdin)["return"])') || return 1
    : >"$local_"
    while :; do
        out=$(_qga "{\"execute\":\"guest-file-read\",\"arguments\":{\"handle\":$h,\"count\":1048576}}")
        printf '%s' "$out" | python3 -c '
import sys, json, base64
r = json.load(sys.stdin)["return"]
sys.stdout.buffer.write(base64.b64decode(r["buf-b64"]))
sys.exit(0 if r["eof"] else 3)' >>"$local_"
        [[ $? == 3 ]] || break
    done
    _qga "{\"execute\":\"guest-file-close\",\"arguments\":{\"handle\":$h}}" >/dev/null
}

guest_screenshot() {
    local destino="$1"
    _ui_run "$(_ui_wrap '
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$b = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bmp = New-Object System.Drawing.Bitmap $b.Width, $b.Height
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($b.Left, $b.Top, 0, 0, $bmp.Size)
$bmp.Save("C:\Windows\Temp\dotfiles-tela.png", [System.Drawing.Imaging.ImageFormat]::Png)
"$($b.Width)x$($b.Height)" | Add-Content $out
')" | tr -d '\r'
    guest_get 'C:/Windows/Temp/dotfiles-tela.png' "$destino"
}

guest_click() {
    local x="$1" y="$2" modo="${3:-left}" seq
    case "$modo" in
        right)  seq='0x0008; 0x0010' ;;
        double) seq='0x0002; 0x0004; 0x0002; 0x0004' ;;
        *)      seq='0x0002; 0x0004' ;;
    esac
    _ui_run "$(_ui_wrap "
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class M {
  [DllImport(\"user32.dll\")] public static extern bool SetCursorPos(int x, int y);
  [DllImport(\"user32.dll\")] public static extern void mouse_event(uint f, uint dx, uint dy, uint d, UIntPtr e);
}
'@
[M]::SetCursorPos($x, $y); Start-Sleep -Milliseconds 80
foreach (\$f in @($seq)) { [M]::mouse_event(\$f, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 60 }
'clicou $x,$y' | Add-Content \$out
")" | tr -d '\r'
}

guest_keys() {
    local teclas="${1//\'/\'\'}"
    _ui_run "$(_ui_wrap "
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait('$teclas')
'teclou' | Add-Content \$out
")" | tr -d '\r'
}

guest_type() {
    # Escapa o que o SendKeys trata como comando: + ^ % ~ ( ) { } [ ]
    local texto
    texto=$(printf '%s' "$1" | sed 's/[]+^%~(){}[]/{&}/g')
    guest_keys "$texto"
}

guest_windows() {
    _ui_run "$(_ui_wrap '
Add-Type @"
using System; using System.Text; using System.Runtime.InteropServices; using System.Collections.Generic;
public static class W {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p, IntPtr l);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out R r);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [StructLayout(LayoutKind.Sequential)] public struct R { public int L, T, Rt, B; }
  public static List<string> List() {
    var o = new List<string>();
    EnumWindows((h, l) => {
      if (!IsWindowVisible(h)) return true;
      var sb = new StringBuilder(256); GetWindowText(h, sb, 256);
      if (sb.Length == 0) return true;
      R r; GetWindowRect(h, out r); uint pid; GetWindowThreadProcessId(h, out pid);
      o.Add(pid + "\t" + sb + "\t" + r.L + "," + r.T + "-" + r.Rt + "," + r.B);
      return true; }, IntPtr.Zero);
    return o; }
}
"@
[W]::List() | Add-Content $out
')" | tr -d '\r'
}

guest_focus() {
    local titulo="${1//\'/\'\'}"
    _ui_run "$(_ui_wrap "
\$sh = New-Object -ComObject WScript.Shell
\$ok = \$sh.AppActivate('$titulo')
Start-Sleep -Milliseconds 300
\"foco '$titulo': \$ok\" | Add-Content \$out
")" | tr -d '\r'
}

# Controles filhos de uma janela (classe, texto, retangulo, indice), pra achar campo e botao.
guest_children() {
    local titulo="${1//\'/\'\'}"
    _ui_run "$(_ui_wrap "
Add-Type @'
using System; using System.Text; using System.Runtime.InteropServices; using System.Collections.Generic;
public static class C {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern IntPtr FindWindow(string c, string t);
  [DllImport(\"user32.dll\")] public static extern bool EnumChildWindows(IntPtr p, EnumProc f, IntPtr l);
  [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport(\"user32.dll\")] public static extern bool GetWindowRect(IntPtr h, out R r);
  [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, string l);
  [DllImport(\"user32.dll\")] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  [StructLayout(LayoutKind.Sequential)] public struct R { public int L, T, Rt, B; }
  public static List<IntPtr> Handles(string title) {
    var o = new List<IntPtr>(); var p = FindWindow(null, title); if (p == IntPtr.Zero) return o;
    EnumChildWindows(p, (h, l) => { o.Add(h); return true; }, IntPtr.Zero); return o; }
  public static string Describe(IntPtr h) {
    var c = new StringBuilder(64); GetClassName(h, c, 64); var t = new StringBuilder(512); GetWindowText(h, t, 512);
    R r; GetWindowRect(h, out r); return c + \"\t\" + r.L + \",\" + r.T + \"-\" + r.Rt + \",\" + r.B + \"\t\" + t; }
  public static void SetText(IntPtr h, string s) { SendMessage(h, 0x000C, IntPtr.Zero, s); }
  public static void Click(IntPtr h) { SendMessage(h, 0x00F5, IntPtr.Zero, IntPtr.Zero); }
}
'@
\$i = 0
foreach (\$h in [C]::Handles('$titulo')) { \"\$i\`t\$([C]::Describe(\$h))\" | Add-Content \$out; \$i++ }
")" | tr -d '\r'
}

# Escreve texto num controle pelo indice de guest_children (WM_SETTEXT: nao depende de foco).
guest_settext() {
    local titulo="${1//\'/\'\'}" indice="$2" texto="${3//\'/\'\'}"
    _ui_run "$(_ui_wrap "
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Collections.Generic;
public static class S {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern IntPtr FindWindow(string c, string t);
  [DllImport(\"user32.dll\")] public static extern bool EnumChildWindows(IntPtr p, EnumProc f, IntPtr l);
  [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, string l);
  [DllImport(\"user32.dll\")] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  public static List<IntPtr> Handles(string title) {
    var o = new List<IntPtr>(); var p = FindWindow(null, title); if (p == IntPtr.Zero) return o;
    EnumChildWindows(p, (h, l) => { o.Add(h); return true; }, IntPtr.Zero); return o; }
  public static void SetText(IntPtr h, string s) { SendMessage(h, 0x000C, IntPtr.Zero, s); }
  public static void Click(IntPtr h) { SendMessage(h, 0x00F5, IntPtr.Zero, IntPtr.Zero); }
}
'@
\$hs = [S]::Handles('$titulo')
if (\$hs.Count -gt $indice) { [S]::SetText(\$hs[$indice], '$texto'); 'escrito' | Add-Content \$out } else { 'controle nao achado' | Add-Content \$out }
")" | tr -d '\r'
}

# Aperta um botao pelo indice de guest_children (BM_CLICK).
guest_press() {
    local titulo="${1//\'/\'\'}" indice="$2"
    _ui_run "$(_ui_wrap "
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Collections.Generic;
public static class P {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport(\"user32.dll\", CharSet=CharSet.Unicode)] public static extern IntPtr FindWindow(string c, string t);
  [DllImport(\"user32.dll\")] public static extern bool EnumChildWindows(IntPtr p, EnumProc f, IntPtr l);
  [DllImport(\"user32.dll\")] public static extern IntPtr SendMessage(IntPtr h, uint m, IntPtr w, IntPtr l);
  public static List<IntPtr> Handles(string title) {
    var o = new List<IntPtr>(); var p = FindWindow(null, title); if (p == IntPtr.Zero) return o;
    EnumChildWindows(p, (h, l) => { o.Add(h); return true; }, IntPtr.Zero); return o; }
  public static void Click(IntPtr h) { SendMessage(h, 0x00F5, IntPtr.Zero, IntPtr.Zero); }
}
'@
\$hs = [P]::Handles('$titulo')
if (\$hs.Count -gt $indice) { [P]::Click(\$hs[$indice]); 'apertado' | Add-Content \$out } else { 'controle nao achado' | Add-Content \$out }
")" | tr -d '\r'
}
