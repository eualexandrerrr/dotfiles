#!/usr/bin/env bash
# Pastas amarelas em todos os tamanhos.
#
#   ~/.dotfiles/kde/icones.sh
#
# O Tela-yellow-dark so recoloriu parte do tema: os icones de 16, 22 e 24px continuam com
# o azul do Tela padrao (#5294e2), e e justamente o de 22px que o Dolphin usa na lista.
# Aqui recolorimos as pastas em ~/.local/share/icons, que tem precedencia sobre /usr/share
# e sobrevive a update do pacote.
set -uo pipefail

TEMA="${TEMA:-Tela-yellow-dark}"
AZUL="${AZUL:-#5294e2}"
AMBAR="${AMBAR:-#ffca28}"
ORIGEM="/usr/share/icons/$TEMA"
DESTINO="$HOME/.local/share/icons/$TEMA"

[[ -d $ORIGEM ]] || { printf 'icones: %s nao instalado\n' "$TEMA" >&2; exit 1; }

n=0
while IFS= read -r svg; do
    rel="${svg#"$ORIGEM"/}"
    alvo="$DESTINO/$rel"
    mkdir -p "$(dirname "$alvo")"
    if [[ -L $svg ]]; then
        cp -a "$svg" "$alvo" 2>/dev/null && n=$((n+1))
    else
        sed "s/$AZUL/$AMBAR/g" "$svg" > "$alvo" && n=$((n+1))
    fi
done < <(find "$ORIGEM" -path '*/places/*.svg' \( -type f -o -type l \) 2>/dev/null)

[[ -f $ORIGEM/index.theme ]] && cp -a "$ORIGEM/index.theme" "$DESTINO/index.theme" 2>/dev/null

command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -f -t "$DESTINO" >/dev/null 2>&1
printf 'icones: %d icone(s) de pasta em ambar (%s)\n' "$n" "$TEMA"
