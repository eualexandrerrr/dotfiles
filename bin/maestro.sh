#!/usr/bin/env bash
# Baixa o Maestro CLI do release oficial e instala em ~/.local/share/maestro.
# O zip tem ~300 MB: o download retoma de onde parou e valida o arquivo antes de extrair.
#
#   ~/.dotfiles/bin/maestro.sh            instala se faltar
#   ~/.dotfiles/bin/maestro.sh --forcar   reinstala mesmo se ja existir

set -uo pipefail

URL="https://github.com/mobile-dev-inc/maestro/releases/latest/download/maestro.zip"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
ZIP="$CACHE/maestro.zip"
DESTINO="$HOME/.local/share/maestro"

GRN=$'\e[32m'; YEL=$'\e[33m'; END=$'\e[0m'
ok()    { printf '%s  ok%s %s\n' "$GRN" "$END" "$*"; }
falha() { printf '%s  !!%s %s\n' "$YEL" "$END" "$*" >&2; }

if command -v bsdtar >/dev/null 2>&1; then
    EXTRATOR=bsdtar
elif command -v unzip >/dev/null 2>&1; then
    EXTRATOR=unzip
else
    falha "nem bsdtar nem unzip instalados, nao da pra abrir o zip"
    exit 1
fi

zip_valido() {
    case $EXTRATOR in
        bsdtar) bsdtar -tf "$ZIP" >/dev/null 2>&1 ;;
        unzip)  unzip -tq "$ZIP" >/dev/null 2>&1 ;;
    esac
}

extrair() {
    case $EXTRATOR in
        bsdtar) bsdtar -xf "$ZIP" -C "$1" ;;
        unzip)  unzip -q "$ZIP" -d "$1" ;;
    esac
}

if [[ ${1:-} != --forcar ]] && command -v maestro >/dev/null 2>&1; then
    ok "maestro ja presente: $(command -v maestro)"
    exit 0
fi

command -v java >/dev/null 2>&1 || falha "java nao encontrado, o maestro precisa dele (jdk17-openjdk)"

mkdir -p "$CACHE" "$HOME/.local/bin" "$HOME/.local/share"

for tentativa in 1 2 3; do
    printf 'baixando o maestro (~300 MB), tentativa %d de 3\n' "$tentativa"
    if curl -fL --progress-bar --connect-timeout 20 --retry 5 --retry-delay 5 \
        --retry-all-errors --continue-at - -o "$ZIP" "$URL"; then
        zip_valido && break
        falha "arquivo veio corrompido, recomecando do zero"
        rm -f "$ZIP"
    else
        falha "download interrompido, retomando de onde parou"
        sleep 3
    fi
done

if ! zip_valido; then
    rm -f "$ZIP"
    falha "maestro nao baixou"
    exit 1
fi

TMP="$(mktemp -d)"
if ! extrair "$TMP"; then
    rm -rf "$TMP"
    falha "falha ao extrair"
    exit 1
fi

rm -rf "$DESTINO"
mv "$TMP/maestro" "$DESTINO"
rm -rf "$TMP" "$ZIP"
chmod +x "$DESTINO/bin/maestro"
ln -sfn "$DESTINO/bin/maestro" "$HOME/.local/bin/maestro"
ok "maestro em $DESTINO, link em ~/.local/bin/maestro"
