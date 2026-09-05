#!/usr/bin/env bash
# Le a configuracao viva do KDE em ~/.config e regrava scripts/kde-settings.conf.
#
# Rode isso depois de mexer nas Configuracoes do Sistema: o que voce ajustou na GUI
# entra no repo e volta identico em qualquer maquina via scripts/kde-apply.sh.
#
#   ~/.dotfiles/scripts/kde-capture.sh && git -C ~/.dotfiles diff
#
# Nao versiona o ~/.config do KDE inteiro de proposito. O Plasma grava estado junto da
# configuracao (posicao de janela, hash de tema, UUID de desktop virtual, cache de icone)
# e commitar isso vira ruido que conflita a cada login. A lista GRUPOS abaixo e a
# curadoria: so grupo que e decisao sua, nunca estado.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
OUT="$DOTFILES_DIR/scripts/kde-settings.conf"

# arquivo:grupo (o grupo aceita * no fim, pra casar os [Libinput][...] por dispositivo)
GRUPOS=(
    "kcminputrc:Keyboard"
    "kcminputrc:Mouse"
    "kcminputrc:Libinput*"
    "kxkbrc:Layout"
    "kdeglobals:General"
    "kdeglobals:Icons"
    "kdeglobals:KDE"
    "kwinrc:Windows"
    "kwinrc:org.kde.kdecoration2"
    "kwinrc:Xwayland"
    "plasmarc:Theme"
    "kscreenlockerrc:Daemon"
    "powermanagementprofilesrc:AC*"
    "dolphinrc:General"
    "kdeglobals:KFileDialog Settings"
)

# Chaves que sao estado ou derivadas, nunca entram no repo.
IGNORAR_CHAVE='^(ColorSchemeHash|Id_[0-9]+|Number|Rows|State|Timestamp|.*Cache.*)$'

casa_grupo() {
    local grupo="$1" arquivo="$2" alvo padrao
    for alvo in "${GRUPOS[@]}"; do
        [[ ${alvo%%:*} == "$arquivo" ]] || continue
        padrao="${alvo#*:}"
        # shellcheck disable=SC2053  -- glob proposital, o * no fim do padrao
        [[ $grupo == $padrao ]] && return 0
    done
    return 1
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

{
    printf '# Gerado por scripts/kde-capture.sh em %s. Nao edite na mao:\n' "$(date '+%d/%m/%Y %H:%M')"
    printf '# mexa nas Configuracoes do Sistema e rode o capture de novo.\n'
    printf '#\n'
    printf '# Formato: arquivo|grupo[|subgrupo...]|chave|valor\n'
    printf '# Aplicado por scripts/kde-apply.sh (kwriteconfig6, um --group por nivel).\n'
} > "$tmp"

arquivos=()
for alvo in "${GRUPOS[@]}"; do arquivos+=("${alvo%%:*}"); done
mapfile -t arquivos < <(printf '%s\n' "${arquivos[@]}" | sort -u)

total=0
for arquivo in "${arquivos[@]}"; do
    [[ -f "$CFG/$arquivo" ]] || continue
    n=0
    while IFS='|' read -r grupo_bruto chave valor; do
        [[ -n $grupo_bruto ]] || continue
        [[ $chave =~ $IGNORAR_CHAVE ]] && continue
        casa_grupo "${grupo_bruto%%|*}" "$arquivo" || \
            casa_grupo "$(printf '%s' "$grupo_bruto" | tr '|' '\n' | head -1)" "$arquivo" || continue
        printf '%s|%s|%s|%s\n' "$arquivo" "$grupo_bruto" "$chave" "$valor" >> "$tmp"
        n=$((n+1))
    done < <(awk -F= '
        /^[[:space:]]*[#;]/ { next }
        /^[[:space:]]*\[/ {
            linha = $0
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", linha)
            grupo = ""
            # [A][B][C] -> A|B|C
            while (match(linha, /^\[[^]]*\]/)) {
                pedaco = substr(linha, RSTART + 1, RLENGTH - 2)
                grupo = (grupo == "" ? pedaco : grupo "|" pedaco)
                linha = substr(linha, RSTART + RLENGTH)
            }
            next
        }
        /=/ {
            if (grupo == "") next
            chave = $1
            sub(/[[:space:]]+$/, "", chave)
            valor = substr($0, index($0, "=") + 1)
            if (chave == "") next
            print grupo "|" chave "|" valor
        }
    ' "$CFG/$arquivo")
    (( n )) && printf '  %-28s %d chaves\n' "$arquivo" "$n" >&2
    total=$((total + n))
done

mv "$tmp" "$OUT"
trap - EXIT
printf '\n%d chaves gravadas em %s\n' "$total" "${OUT/#$HOME/\~}" >&2
