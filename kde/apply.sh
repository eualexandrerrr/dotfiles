#!/usr/bin/env bash
# Aplica kde/settings.conf no KDE via kwriteconfig6 e recarrega o kwin.
# Idempotente. Chamado pelo install.sh e pelo kde-layout-once.sh (primeiro login).
#
#   ~/.dotfiles/kde/apply.sh

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CONF="${1:-$DOTFILES_DIR/kde/settings.conf}"

[[ -f $CONF ]] || { printf 'kde-apply: %s nao existe\n' "$CONF" >&2; exit 1; }
command -v kwriteconfig6 >/dev/null 2>&1 || { printf 'kde-apply: kwriteconfig6 nao encontrado, pulando\n' >&2; exit 0; }

n=0
espelhados=0
while IFS= read -r linha; do
    [[ -z $linha || $linha == '#'* ]] && continue

    # arquivo|grupo[|subgrupo...]|chave|valor  -> o valor e o ultimo campo, a chave o penultimo
    IFS='|' read -r -a campos <<< "$linha"
    (( ${#campos[@]} >= 4 )) || { printf 'kde-apply: linha ignorada (poucos campos): %s\n' "$linha" >&2; continue; }

    arquivo="${campos[0]}"
    valor="${campos[-1]}"
    # O kglobalshortcutsrc separa atalhos alternativos com \t. O capture le o arquivo
    # cru, entao a barra chega aqui literal; sem virar tab de verdade o kwriteconfig6
    # escapa a barra (\\t no arquivo) e o KDE le a sequencia inteira como um atalho so.
    valor="${valor//\\t/$'\t'}"
    chave="${campos[-2]}"
    grupos=("${campos[@]:1:${#campos[@]}-3}")

    # Nome simples e ~/.config/<nome>; caminho com / e relativo ao $HOME (o KDE guarda
    # coisa fora do ~/.config, como as view properties do Dolphin em ~/.local/share).
    case "$arquivo" in
        */*) alvo="$HOME/$arquivo"; mkdir -p "$(dirname "$alvo")" ;;
        *)   alvo="$arquivo" ;;
    esac

    # Arquivo espelhado (symlink pra dentro do repo) ja E a fonte da verdade: o que o
    # KDE grava cai direto no links/config. Escrever o settings.conf por cima desfaria
    # qualquer ajuste feito na GUI que ainda nao tenha passado pelo capture.
    destino="$alvo"
    [[ $destino != /* ]] && destino="${XDG_CONFIG_HOME:-$HOME/.config}/$alvo"
    if [[ -L $destino && "$(readlink -f "$destino")" == "$(readlink -f "$DOTFILES_DIR")"/* ]]; then
        espelhados=$((espelhados+1))
        continue
    fi

    args=(--file "$alvo")
    for g in "${grupos[@]}"; do args+=(--group "$g"); done
    # O -- fecha as opcoes: sem ele, valor negativo (PointerAcceleration=-0.400)
    # vira flag e o kwriteconfig6 morre com "Unknown options: 0, ., 4, 0, 0".
    args+=(--key "$chave" -- "$valor")

    kwriteconfig6 "${args[@]}" && n=$((n+1)) || printf 'kde-apply: falhou em %s\n' "$linha" >&2
done < "$CONF"

printf 'kde-apply: %d chaves aplicadas de %s' "$n" "${CONF/#$HOME/\~}"
(( espelhados )) && printf ', %d puladas por ja estarem espelhadas' "$espelhados"
printf '\n'

# Recarrega sem precisar deslogar: kwin le teclado, bordas e decoracao do disco.
qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true
