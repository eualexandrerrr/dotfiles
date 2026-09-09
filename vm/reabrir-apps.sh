#!/usr/bin/env bash
# Reabre os apps que estavam abertos antes de a VM w11 levar a RTX 3090.
#
# Por que existe: com uma GPU so, o hook do libvirt precisa derrubar a sessao
# (loginctl terminate-user) pra soltar a placa -- os apps morrem, nao ha como o host
# continuar desenhando sem placa. Com a RX 550 no host a sessao nao cai mais, entao a
# lista so aparece se a VM levar a unica placa de video.
#
# Entao a lista e feita na mao pelo `vm/w11` antes de ligar a VM, a partir dos scopes
# do systemd (app-<desktop-id>-<pid>.scope), que e como o uwsm lanca cada aplicativo.
#
# Roda no login pelo autostart do hypr (hyprland.lua). Consome a lista:
# so dispara na volta da VM, num boot normal o arquivo nao existe e ele sai calado.
set -uo pipefail

lista="${XDG_STATE_HOME:-$HOME/.local/state}/w11-apps"
[[ -f $lista ]] || exit 0

# Move antes de usar: se algo abaixo falhar, ninguem reabre em loop no proximo login.
usado="$lista.usado"
mv -f "$lista" "$usado"

while read -r id; do
    [[ -n $id ]] || continue
    uwsm app -- "$id" >/dev/null 2>&1 || true
    # Os apps pesados (Chrome, VS Code) restauram abas/janelas sozinhos; abrir em
    # rajada faz os tres brigarem por disco no primeiro segundo do login.
    sleep 1
done < "$usado"
