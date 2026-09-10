#!/usr/bin/env bash
# Restaura as credenciais do repo privado. Chamado pelo install.sh; nunca derruba a
# instalacao: sem pendrive, sem repo ou sem rede, avisa e sai com 0.
#
#   ~/.dotfiles/segredos/restaurar.sh
set -uo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
PRIVADO="${PRIVADO:-$HOME/.secret-keys}"
REPO_PRIVADO="${REPO_PRIVADO:-git@github.com:eualexandrerrr/secret-keys.git}"
source "$DOTFILES_DIR/segredos/comum.sh"

command -v age >/dev/null 2>&1 || { aviso "age nao instalado, credenciais nao restauradas"; exit 0; }

if [[ ! -d $PRIVADO/.git ]]; then
    git clone --quiet "$REPO_PRIVADO" "$PRIVADO" 2>/dev/null \
        || { aviso "nao consegui clonar $REPO_PRIVADO; credenciais ficam pra depois"; exit 0; }
    ok "secret-keys clonado"
else
    git -C "$PRIVADO" pull --quiet --ff-only 2>/dev/null || true
fi

cifrado="$PRIVADO/segredos.tar.age"
[[ -f $cifrado ]] || { aviso "$cifrado nao existe, nada a restaurar"; exit 0; }

chave_usada=""
if montar_pendrive && [[ -f $CHAVE ]]; then
    chave_usada="$CHAVE"
    ok "chave lida do pendrive $ROTULO_PENDRIVE"
elif [[ -f $PRIVADO/chave.txt.age ]]; then
    aviso "pendrive $ROTULO_PENDRIVE nao encontrado, caindo na recuperacao por senha"
    chave_usada="$(mktemp)"
    chmod 600 "$chave_usada"
    if ! age -d -o "$chave_usada" "$PRIVADO/chave.txt.age"; then
        rm -f "$chave_usada"
        aviso "senha recusada, credenciais nao restauradas"
        exit 0
    fi
    trap 'rm -f "$chave_usada"' EXIT
else
    aviso "sem chave no pendrive e sem chave.txt.age, credenciais nao restauradas"
    exit 0
fi

tmp="$(mktemp -d)"
pacote="$tmp/segredos.tar.gz"
if ! age -d -i "$chave_usada" -o "$pacote" "$cifrado" 2>/dev/null; then
    rm -rf "$tmp"
    aviso "nao consegui decifrar $cifrado (chave errada?)"
    exit 0
fi

# Extrai POR ARQUIVO, direto no $HOME. Nunca mover o primeiro nivel do tar pra ca: a lista
# tem caminhos aninhados (.config/gh/hosts.yml), entao "mover .config" trocaria a ~/.config
# inteira -- com o perfil do Chrome, do Discord e do resto -- por uma pasta com um arquivo so.
entradas=()
while IFS= read -r linha; do
    [[ -z $linha || $linha == */ ]] && continue
    if [[ $linha == /* || $linha == *..* ]]; then
        rm -rf "$tmp"
        aviso "o pacote tem caminho suspeito ($linha), nada restaurado"
        exit 0
    fi
    entradas+=("$linha")
done < <(tar tzf "$pacote" 2>/dev/null)

if (( ${#entradas[@]} == 0 )); then
    rm -rf "$tmp"
    aviso "pacote vazio, nada a restaurar"
    exit 0
fi

# O que ja existe no $HOME VENCE o pacote. A /home sobrevive ao format (particao Files), entao
# o caso normal e reinstalar com as credenciais atuais no lugar -- restaurar por cima
# trocaria elas por uma foto velha e deslogaria tudo. So entra o que esta faltando, que e o
# caso que importa de verdade: home nova depois de perder o disco.
# FORCAR=1 inverte, pra quando o pacote e que esta certo.
existentes=(); faltando=()
for rel in "${entradas[@]}"; do
    if [[ -e "$HOME/$rel" && ${FORCAR:-0} != 1 ]]; then existentes+=("$rel"); else faltando+=("$rel"); fi
done

if (( ${#existentes[@]} )); then
    ok "${#existentes[@]} ja existiam no HOME e foram mantidos (FORCAR=1 sobrescreve)"
fi

if (( ${#faltando[@]} == 0 )); then
    rm -rf "$tmp"
    ok "nada faltando, credenciais atuais preservadas"
    exit 0
fi

if (( ${#existentes[@]} )); then
    anteriores="$HOME/.local/state/dotfiles"
    mkdir -p "$anteriores"
    guardado="$anteriores/segredos-anteriores-$(date +%Y%m%d%H%M%S).tar.gz"
    tar czf "$guardado" -C "$HOME" "${existentes[@]}" 2>/dev/null \
        && ok "$(basename "$guardado") guarda o que ja estava no HOME"
fi

if ! tar xzf "$pacote" -C "$HOME" "${faltando[@]}" 2>/dev/null; then
    rm -rf "$tmp"
    aviso "a extracao falhou, credenciais nao restauradas"
    exit 0
fi
n=${#faltando[@]}
rm -rf "$tmp"

chmod 700 "$HOME/.ssh" 2>/dev/null || true
find "$HOME/.ssh" -maxdepth 1 -type f -exec chmod 600 {} + 2>/dev/null || true
chmod 700 "$HOME/.claude" 2>/dev/null || true
chmod 600 "$HOME/.claude/.credentials.json" "$HOME/.npmrc" 2>/dev/null || true
chmod 700 "$HOME/.config/gh" 2>/dev/null || true
chmod 600 "$HOME/.config/gh/hosts.yml" 2>/dev/null || true

ok "$n itens restaurados"
