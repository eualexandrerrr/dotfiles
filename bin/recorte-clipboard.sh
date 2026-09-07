#!/usr/bin/env bash
# Recorta uma regiao da tela e deixa a IMAGEM na area de transferencia.
# Chamado pelo Shift+Print e pelo Meta+Shift+S (hypr/atalhos.conf).
#
# O wl-copy e quem poe a imagem no clipboard, e nao o programa de captura: no Wayland o
# conteudo pertence ao processo que copiou, e quem captura sai logo depois. O wl-copy
# bifurca e continua servindo o clipboard depois que este script termina, entao a imagem
# sobrevive -- e o "xclip -t TARGETS | grep image/" do Claude Code acha o que colar.
set -euo pipefail

for p in grim slurp wl-copy; do
    command -v "$p" >/dev/null 2>&1 || {
        notify-send "Recorte" "$p nao esta instalado" 2>/dev/null
        exit 1
    }
done

# Selecao cancelada (Esc): o slurp sai diferente de 0 e nada e capturado.
area="$(slurp -d)" || exit 0

grim -g "$area" - | wl-copy --type image/png
