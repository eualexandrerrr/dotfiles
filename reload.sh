#!/usr/bin/env bash
# Recarrega o que ja esta rodando na sessao, sem reinstalar nem reconfigurar nada.
# Para quando algo saiu do lugar no meio do trabalho -- tela na taxa errada, painel travado,
# volume fora do ajuste. Nao mexe em disco, nao pede rede e nao derruba a sessao.
#
#   ~/.dotfiles/reload.sh
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
export DOTFILES_DIR

GRN=$'\e[32m'; YEL=$'\e[33m'; BLU=$'\e[34m'; END=$'\e[0m'
FALHAS=()

log()   { printf '\n%s==>%s %s\n' "$BLU" "$END" "$*"; }
ok()    { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
falha() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*" >&2; FALHAS+=("$*"); }

# Fora da sessao grafica (tty, ssh, hook do libvirt) o systemctl --user e o qdbus nao acham
# o barramento; sem isto tudo aqui falha com "Failed to connect to bus".
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

log "telas"
if [[ -x $DOTFILES_DIR/bin/apply-screens.sh ]]; then
    bash "$DOTFILES_DIR/bin/apply-screens.sh" \
        && ok "taxa, rotacao e posicao reaplicadas" \
        || falha "apply-screens.sh"
else
    falha "bin/apply-screens.sh ausente"
fi

log "audio"
bash "$DOTFILES_DIR/bin/audio.sh" >/dev/null 2>&1 \
    && ok "volumes de saida e microfone no ajuste" \
    || falha "audio.sh"

log "painel do Plasma"
if /usr/bin/systemctl --user restart plasma-plasmashell.service 2>/dev/null; then
    ok "plasmashell reiniciado"
else
    falha "plasmashell nao reiniciou"
fi

log "KWin"
# reconfigure so rele a config: nao reinicia o compositor, entao a sessao nao pisca.
if qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1; then
    ok "config do KWin relida"
else
    falha "KWin nao respondeu no dbus"
fi

if (( ${#FALHAS[@]} )); then
    printf '\n%s%d aviso(s):%s\n' "$YEL" "${#FALHAS[@]}" "$END"
    printf '  - %s\n' "${FALHAS[@]}"
    exit 1
fi
printf '\n%ssessao recarregada.%s\n' "$GRN" "$END"
