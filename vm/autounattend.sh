#!/usr/bin/env bash
# Gera ~/vms/autounattend-usb.img: o autounattend.xml do MyWinISO adaptado a VM.
# Tres injecoes, todas por causa do que o Ventoy faz e um pendrive comum nao:
#   1. MYWINISO_PERFIL=vm-jogo no primeiro logon (o perfil nao e automatico)
#   2. copia do autounattend.xml da midia pra X:\ (o Ventoy injeta no boot.wim)
#   3. HKLM\System\Setup\UnattendFile apontando pra ele (o instala.vbs le so a chave)
set -euo pipefail
VMS="$HOME/vms"; mkdir -p "$VMS"; cd "$VMS"
curl -fsSL -o autounattend.orig.xml https://raw.githubusercontent.com/eualexandrerrr/MyWinISO/main/autounattend.xml
python3 - <<'PY'
import re,pathlib,xml.etree.ElementTree as ET
s=pathlib.Path('autounattend.orig.xml').read_text(encoding='utf-8')
a="$env:MYWINISO_SENHA = $Senha\n"; assert s.count(a)==1
s=s.replace(a,a+"$env:MYWINISO_PERFIL = 'vm-jogo'\n",1)
i=s.index('<settings pass="windowsPE">'); j=s.index('</settings>',i); pe=s[i:j]
pe=re.sub(r'<Order>(\d+)</Order>',lambda m:f'<Order>{int(m.group(1))+2 if int(m.group(1))>=6 else int(m.group(1))}</Order>',pe)
novo='''        <RunSynchronousCommand wcm:action="add">
          <Order>6</Order>
          <Description>VM: copia o autounattend.xml da midia pra X:\\, como o Ventoy faria</Description>
          <Path>cmd.exe /c for %d in (C D E F G H I J) do if exist %d:\\autounattend.xml copy /y %d:\\autounattend.xml X:\\autounattend.xml</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>7</Order>
          <Description>VM: registra o arquivo de resposta como o Ventoy faz</Description>
          <Path>reg.exe add HKLM\\System\\Setup /v UnattendFile /t REG_SZ /d X:\\autounattend.xml /f</Path>
        </RunSynchronousCommand>
'''
k=pe.index('<RunSynchronousCommand wcm:action="add">\n          <Order>8</Order>')
pe=pe[:k]+novo+pe[k:]; s=s[:i]+pe+s[j:]
pathlib.Path('autounattend.xml').write_text(s,encoding='utf-8'); ET.parse('autounattend.xml')
PY
rm -f autounattend-usb.img; truncate -s 64M autounattend-usb.img
mformat -i autounattend-usb.img -F -v AUTOUNATT :: && mcopy -i autounattend-usb.img autounattend.xml ::/
echo "  ok   autounattend-usb.img (perfil vm-jogo)"
