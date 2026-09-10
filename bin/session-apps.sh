#!/usr/bin/env bash
# Guarda quais aplicativos estavam abertos e reabre na volta, pra desligar e ligar o PC
# cair no mesmo lugar. O Plasma lanca cada app num scope do systemd chamado
# app-<desktop-id>-<pid>.scope -- e dai que sai a lista, ja com o id do .desktop.
#
# O restore nativo do Plasma nao cobre isto sozinho: no Wayland ele depende de o app falar
# o protocolo de gerenciamento de sessao, e Chrome, Discord e Electron em geral nao falam.
#
#   ~/.dotfiles/bin/session-apps.sh salvar     # tira a foto (roda ao encerrar a sessao)
#   ~/.dotfiles/bin/session-apps.sh restaurar  # reabre (roda ao entrar)
set -uo pipefail

LISTA="${XDG_STATE_HOME:-$HOME/.local/state}/session-apps"
# Lista da VM: quando ela leva a GPU e derruba a sessao, quem escreve e o `vm/w11`.
LISTA_VM="${XDG_STATE_HOME:-$HOME/.local/state}/w11-apps"

# Apps que nao devem voltar sozinhos: o terminal porque o Alexandre abre quando quer, e o
# instalador porque reabrir no login e pedido de tela de update em cima do trabalho.
IGNORAR='^(org\.kde\.konsole|org\.kde\.discover)$'

salvar() {
    mkdir -p "$(dirname "$LISTA")"
    local tmp; tmp="$(mktemp)"
    systemctl --user list-units --type=scope --no-legend 'app-*.scope' 2>/dev/null \
        | awk '{print $1}' \
        | sed -n 's/^app-\(.*\)-[0-9]\+\.scope$/\1/p' \
        | while read -r id; do systemd-escape -u -- "$id"; done \
        | grep -vE "$IGNORAR" \
        | sort -u > "$tmp"
    # Foto vazia nao substitui a anterior: no shutdown os scopes as vezes ja morreram, e
    # gravar vazio ali apagaria a lista boa que o timer tinha guardado.
    if [[ -s $tmp ]]; then
        mv -f "$tmp" "$LISTA"
        printf '%d app(s) guardado(s)\n' "$(wc -l < "$LISTA")"
    else
        rm -f "$tmp"
        printf 'nenhum app aberto, lista anterior mantida\n'
    fi
}

restaurar() {
    local origem=""
    [[ -f $LISTA_VM ]] && origem="$LISTA_VM"
    [[ -z $origem && -f $LISTA ]] && origem="$LISTA"
    [[ -n $origem ]] || { printf 'sem lista, nada a reabrir\n'; return 0; }

    # Move antes de usar: se algo abaixo travar, ninguem reabre em loop no proximo login.
    local usado="$origem.usado"
    mv -f "$origem" "$usado"

    local n=0 id
    while read -r id; do
        [[ -n $id ]] || continue
        kstart "$id" >/dev/null 2>&1 && n=$((n+1))
        # Chrome e Electron restauram as abas sozinhos; abrir em rajada faz os tres
        # brigarem por disco no primeiro segundo do login.
        sleep 1
    done < "$usado"
    printf '%d app(s) reaberto(s)\n' "$n"
}

case "${1:-}" in
    salvar)    salvar ;;
    restaurar) restaurar ;;
    *) printf 'uso: %s salvar|restaurar\n' "$(basename "$0")" >&2; exit 1 ;;
esac
