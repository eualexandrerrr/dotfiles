#!/usr/bin/env bash
# Reabre os apps que estavam abertos antes de a VM w11 levar a RTX 3090.
#
# Por que existe: com uma GPU so, o hook do libvirt precisa derrubar a sessao do KDE
# (loginctl terminate-user) pra soltar a placa -- os apps morrem, nao ha como o host
# continuar desenhando sem placa. O restore nativo do Plasma nao serve: em Wayland o
# ksmserver salva zero clientes (testado no 6.7.4, saveCurrentSession grava count=0),
# porque nao existe protocolo de gerenciamento de sessao como havia no X11.
#
# Entao a lista e feita na mao pelo `vm/w11` antes de ligar a VM, a partir dos scopes
# do systemd (app-<desktop-id>-<pid>.scope), que e como o Plasma lanca cada aplicativo.
#
# Roda no login pelo links/config/autostart/w11-reabrir-apps.desktop. Consome a lista:
# so dispara na volta da VM, num boot normal o arquivo nao existe e ele sai calado.
set -uo pipefail

lista="${XDG_STATE_HOME:-$HOME/.local/state}/w11-apps"
[[ -f $lista ]] || exit 0

# Move antes de usar: se algo abaixo falhar, ninguem reabre em loop no proximo login.
usado="$lista.usado"
mv -f "$lista" "$usado"

while read -r id; do
    [[ -n $id ]] || continue
    kstart --application "$id" >/dev/null 2>&1 || true
    # Os apps pesados (Chrome, VS Code) restauram abas/janelas sozinhos; abrir em
    # rajada faz os tres brigarem por disco no primeiro segundo do login.
    sleep 1
done < "$usado"
