#!/usr/bin/env bash
set -uo pipefail

CRED="${RDP_CRED:-$HOME/.config/rdp/michigan.env}"

erro() { printf '  ERRO %s\n' "$*" >&2; }

[[ -f $CRED ]] || { erro "$CRED nao existe; crie com RDP_HOST, RDP_PORT, RDP_USER e RDP_PASS"; exit 1; }
[[ $(stat -c %a "$CRED") == 600 ]] || chmod 600 "$CRED"

RDP_HOST=""; RDP_PORT=""; RDP_USER=""; RDP_PASS=""
source "$CRED"
RDP_PORT="${RDP_PORT:-3389}"
[[ -n $RDP_HOST && -n $RDP_USER && -n $RDP_PASS ]] || { erro "$CRED incompleto"; exit 1; }

CLIENTE="${RDP_CLIENTE:-}"
if [[ -z $CLIENTE ]]; then
    for c in sdl-freerdp3 xfreerdp3 wlfreerdp3 xfreerdp; do
        command -v "$c" >/dev/null 2>&1 && { CLIENTE="$c"; break; }
    done
fi
[[ -n $CLIENTE ]] || { erro "nenhum cliente FreeRDP encontrado (pacote freerdp)"; exit 1; }

args=(
    "/v:${RDP_HOST}:${RDP_PORT}"
    "/u:${RDP_USER}"
    /from-stdin
    /cert:tofu
    +dynamic-resolution
    +clipboard
    /sound:sys:pulse
    /sec:nla
    /network:auto
    /compression
    /timeout:15000
    /log-level:WARN
)

modo="${1:-}"
case "$modo" in
    --tela-cheia|-f) shift; args+=(/f) ;;
    --editar|-e)     exec "${EDITOR:-nano}" "$CRED" ;;
    --ajuda|-h)      printf 'rdp.sh [--tela-cheia|--editar] [args extras do FreeRDP]\n'; exit 0 ;;
    "")              : ;;
    -*)              : ;;
esac
(( $# )) && args+=("$@")

printf '%s\n' "$RDP_PASS" | "$CLIENTE" "${args[@]}"
saida=$?
unset RDP_PASS
exit "$saida"
