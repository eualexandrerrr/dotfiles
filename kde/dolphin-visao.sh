#!/usr/bin/env bash
# Modo de visao padrao do Dolphin: detalhes em toda pasta que o usuario nao tenha
# customizado. Pasta customizada guarda a dela e continua valendo -- e o que
# GlobalViewProps=false faz.
#
#   kde/dolphin-visao.sh
#
# Por que xattr e nao arquivo: desde a v4 o Dolphin grava as propriedades de visao no
# extended attribute `user.kde.fm.viewproperties#1` do diretorio e APAGA o `.directory`
# depois de salvar (ViewProperties::save -> cleanDotDirectoryFile, em
# dolphin/src/views/viewproperties.cpp). Versionar o `.directory` nao adianta: ele some no
# primeiro save. Como xattr nao entra no git, o valor e reaplicado por este script.
#
# O default global fica no xattr de ~/.local/share/dolphin/view_properties/global, lido por
# ViewProperties::defaultProperties() quando a pasta nao tem propriedades proprias.
# ViewMode: 0 icones, 1 detalhes, 2 compacto.
set -uo pipefail

GLOBAL="${XDG_DATA_HOME:-$HOME/.local/share}/dolphin/view_properties/global"
CHAVE='user.kde.fm.viewproperties#1'

command -v setfattr >/dev/null 2>&1 || { printf 'dolphin-visao: setfattr ausente (pacote attr)\n' >&2; exit 1; }

mkdir -p "$GLOBAL"

# O `.directory` tem precedencia sobre o xattr na leitura (ViewProperties::loadProperties),
# entao um resto de esquema antigo aqui anularia este script.
rm -f "$GLOBAL/.directory"

VALOR=$(printf '%s\n' \
    '[Dolphin]' \
    'HeaderColumnWidths=490,142,79,77' \
    'HiddenFilesShown=false' \
    'PreviewsShown=true' \
    'SortFoldersFirst=true' \
    'SortHiddenLast=true' \
    'SortOrder=0' \
    'SortRole=text' \
    "Timestamp=$(date '+%Y,%-m,%-d,%-H,%-M,%-S')" \
    'Version=4' \
    'ViewMode=1' \
    'VisibleRoles=Details_text,Details_modificationtime,Details_type,Details_size')

setfattr -n "$CHAVE" -v "$VALOR" "$GLOBAL" || { printf 'dolphin-visao: setfattr falhou em %s\n' "$GLOBAL" >&2; exit 1; }

kwriteconfig6 --file dolphinrc --group General --key GlobalViewProps false

printf '  ok   dolphin-visao: detalhes como padrao (xattr), excecao por pasta preservada\n'
