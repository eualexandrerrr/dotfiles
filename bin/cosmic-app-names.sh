#!/usr/bin/env bash
# Renomeia os apps do COSMIC na interface, sem tocar no pacote da distro.
#
# Dois incomodos: os apps da System76 vem com "COSMIC" no fim do nome ("COSMIC Files"), e a
# traducao pt de Portugal vaza na barra e no lancador ("Ficheiros COSMIC", "Definicoes").
# Vaza porque nem todo .desktop tem `Name[pt_BR]`, e `LANGUAGE=pt_BR:pt` manda cair no pt.
#
# A correcao e um .desktop nosso em ~/.local/share/applications com o mesmo nome de arquivo:
# ele ganha do /usr/share/applications inteiro. O arquivo e uma copia do original com as tres
# chaves de nome reescritas -- `Name`, `Name[pt]` e `Name[pt_BR]` com o mesmo texto, pra nao
# depender de qual idioma o app escolher.
set -uo pipefail

DESTINO="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
ORIGEM=/usr/share/applications
mkdir -p "$DESTINO"

# arquivo .desktop | nome que queremos
NOMES=(
    "com.system76.CosmicFiles.desktop|Arquivos"
    "com.system76.CosmicTerm.desktop|Terminal"
    "com.system76.CosmicEdit.desktop|Editor de Texto"
    "com.system76.CosmicSettings.desktop|Configuracoes"
    "com.system76.CosmicStore.desktop|Loja"
    "com.system76.CosmicPlayer.desktop|Reprodutor de Midia"
    "com.system76.CosmicScreenshot.desktop|Captura de Tela"
    "com.system76.CosmicMonitor.desktop|Monitor do Sistema"
    "com.system76.CosmicAppLibrary.desktop|Aplicativos"
)
# Acento nao passa em array de shell sem dor de cabeca com locale; vai em tabela separada.
declare -A ACENTO=(
    ["Configuracoes"]="Configurações"
    ["Reprodutor de Midia"]="Reprodutor de Mídia"
)

feitos=0
for entrada in "${NOMES[@]}"; do
    IFS='|' read -r arquivo nome <<<"$entrada"
    nome="${ACENTO[$nome]:-$nome}"
    [[ -f $ORIGEM/$arquivo ]] || continue

    tmp="$DESTINO/.$arquivo.tmp"
    # Reescreve as tres chaves de nome na secao [Desktop Entry]; as acoes (secoes
    # [Desktop Action ...]) ficam como estao, que sao "Nova janela" e afins.
    awk -v nome="$nome" '
        /^\[/ { secao = $0 }
        secao == "[Desktop Entry]" && /^Name=/        { print "Name=" nome; next }
        secao == "[Desktop Entry]" && /^Name\[pt\]=/  { print "Name[pt]=" nome; next }
        secao == "[Desktop Entry]" && /^Name\[pt_BR\]=/ { print "Name[pt_BR]=" nome; next }
        { print }
    ' "$ORIGEM/$arquivo" >"$tmp"
    grep -q "^Name\[pt_BR\]=" "$tmp" ||
        sed -i "0,/^Name=/s//Name=$nome\nName[pt]=$nome\nName[pt_BR]=$nome/" "$tmp"

    if cmp -s "$tmp" "$DESTINO/$arquivo"; then
        rm -f "$tmp"
    else
        mv "$tmp" "$DESTINO/$arquivo"
        feitos=$((feitos + 1))
    fi
done

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$DESTINO" 2>/dev/null
printf '  ok %s nome(s) de app reescrito(s) em %s\n' "$feitos" "$DESTINO"
