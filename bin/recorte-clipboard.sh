#!/usr/bin/env bash
# Recorta uma regiao da tela e deixa a IMAGEM na area de transferencia.
# Chamado pelo Shift+Print, via local/share/applications/spectacle-regiao-clipboard.desktop
#
# Por que nao basta "spectacle --region --background --copy-image":
# no Wayland o conteudo do clipboard pertence ao processo que copiou. O spectacle em modo
# background sai assim que copia, e nada assume a posse da imagem -- o Klipper nao assume
# nem com IgnoreImages=false (testado). Medido com wl-paste --list-types: enquanto o
# spectacle vive o clipboard tem image/png e mais 30 tipos; depois que ele sai sobra so
# application/x-kde-onlyReplaceEmpty, e ai o "xclip -t TARGETS | grep image/" do Claude
# Code nao acha nada pra colar. O wl-copy bifurca e continua servindo o clipboard depois
# que este script termina, entao a imagem sobrevive.

set -euo pipefail

command -v wl-copy >/dev/null 2>&1 || {
    notify-send "Recorte" "wl-clipboard nao esta instalado" 2>/dev/null
    exit 1
}

tmp="$(mktemp --tmpdir recorte-XXXXXXXX.png)"
trap 'rm -f "$tmp"' EXIT

# Sem --copy-image: quem poe no clipboard e o wl-copy. O --output faz o spectacle gravar
# no arquivo temporario em vez de na pasta de capturas.
spectacle --region --background --nonotify --output "$tmp"

# Selecao cancelada (Esc): o spectacle sai com 0 e nao grava nada. Nao mexe no clipboard.
[[ -s $tmp ]] || exit 0

# O wl-copy le o arquivo inteiro pra memoria antes de bifurcar, entao o rm do trap e seguro.
wl-copy --type image/png < "$tmp"
