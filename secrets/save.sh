#!/usr/bin/env bash
# Coleta as credenciais do $HOME, cifra com age e grava no repo privado.
#
#   ~/.dotfiles/secrets/save.sh
#
# A chave privada mora no pendrive do Ventoy, nunca no repo. O repo guarda so o
# segredos.tar.age e uma copia da propria chave cifrada por senha (chave.txt.age), que e o
# unico jeito de voltar se o pendrive sumir.
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
PRIVADO="${PRIVADO:-$HOME/.secret-keys}"
LISTA="$DOTFILES_DIR/secrets/list.txt"
source "$DOTFILES_DIR/secrets/common.sh"

command -v age >/dev/null 2>&1 || { erro "age nao instalado (esta no packages.txt)"; exit 1; }
[[ -f $LISTA ]] || { erro "$LISTA nao existe"; exit 1; }
[[ -d $PRIVADO ]] || { erro "$PRIVADO nao existe; clone o secret-keys primeiro"; exit 1; }

montar_pendrive || { erro "pendrive $ROTULO_PENDRIVE nao encontrado; espeta ele e roda de novo"; exit 1; }

if [[ ! -f $CHAVE ]]; then
    aviso "sem chave em $CHAVE, gerando uma nova"
    mkdir -p "$(dirname "$CHAVE")"
    age-keygen -o "$CHAVE" 2>/dev/null
    ok "chave criada no pendrive"
fi
destinatario="$(age-keygen -y "$CHAVE")"

itens=()
faltando=()
while IFS= read -r alvo; do
    [[ -z ${alvo// } || $alvo == \#* ]] && continue
    if [[ -e "$HOME/$alvo" ]]; then itens+=("$alvo"); else faltando+=("$alvo"); fi
done < "$LISTA"

(( ${#itens[@]} )) || { erro "nenhum item da lista existe no \$HOME, nada a guardar"; exit 1; }

printf 'guardando %d itens:\n' "${#itens[@]}"
printf '  %s\n' "${itens[@]}"
(( ${#faltando[@]} )) && printf 'ausentes (ignorados): %s\n' "${faltando[*]}"

# Perfil de navegador nao e credencial: automacao (MCP) cria um dentro do Claude/.secrets e
# ele sozinho tem ~94 MB, o que levava o pacote de 23 KB pra 39 MB -- e o git guarda TODA
# versao, entao o repo privado incharia sem volta. O perfil vive na /home, que sobrevive.
EXCLUIR=(--exclude=perfil-navegador --exclude=Cache --exclude=node_modules --exclude='*.log')
tar czf - -C "$HOME" "${EXCLUIR[@]}" "${itens[@]}" | age -r "$destinatario" -o "$PRIVADO/segredos.tar.age"
ok "segredos.tar.age gravado ($(du -h "$PRIVADO/segredos.tar.age" | cut -f1))"

if [[ ! -f $PRIVADO/chave.txt.age ]]; then
    printf '\nAgora uma senha para a copia de recuperacao da chave.\n'
    printf 'E o que te salva se o pendrive sumir. Guarde no gerenciador de senhas.\n'
    age -p -o "$PRIVADO/chave.txt.age" < "$CHAVE"
    ok "chave.txt.age gravado (recuperacao por senha)"
fi

# O repo privado ja tem .gitignore proprio (os .env reais ficam de fora). Nao
# sobrescreve: so garante que o pacote cifrado nao caia numa regra ampla.
if [[ -f $PRIVADO/.gitignore ]] && ! grep -qF '!*.age' "$PRIVADO/.gitignore"; then
    printf '\n!*.age\n' >> "$PRIVADO/.gitignore"
fi

printf '\nfalta commitar:\n  git -C %s add -A && git -C %s commit -m "segredos: atualiza" && git -C %s push\n' \
    "$PRIVADO" "$PRIVADO" "$PRIVADO"
