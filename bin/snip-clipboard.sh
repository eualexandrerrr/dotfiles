#!/usr/bin/env bash
# Recorta uma regiao da tela e deixa a IMAGEM na area de transferencia.
# Chamado pelo Shift+Print e pelo Meta+Shift+S (hypr/atalhos.conf).
#
# O wl-copy e quem poe a imagem no clipboard, e nao o programa de captura: no Wayland o
# conteudo pertence ao processo que copiou, e quem captura sai logo depois. O wl-copy
# bifurca e continua servindo o clipboard depois que este script termina, entao a imagem
# sobrevive -- e o "xclip -t TARGETS | grep image/" do Claude Code acha o que colar.
set -uo pipefail

aviso() { command -v notify-send >/dev/null 2>&1 && notify-send "Recorte" "$1" || printf '%s\n' "$1"; }

for p in grim slurp wl-copy; do
    command -v "$p" >/dev/null 2>&1 || { aviso "$p nao esta instalado"; exit 1; }
done

# Selecao cancelada (Esc): o slurp sai diferente de 0 e nada e capturado.
area="$(slurp -d)" || exit 0
[[ -n $area ]] || exit 0

imagem="$(mktemp -t recorte-XXXXXX.png)"
trap 'rm -f "$imagem"' EXIT

if ! grim -g "$area" "$imagem" 2>/dev/null || [[ ! -s $imagem ]]; then
    aviso "nao consegui capturar essa regiao"
    exit 1
fi

wl-copy --type image/png < "$imagem" || { aviso "wl-copy falhou, imagem nao foi pro clipboard"; exit 1; }
