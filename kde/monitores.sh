#!/usr/bin/env bash
# Disposicao dos monitores, aplicada por kscreen-doctor a partir de kde/monitores.conf.
#
# Por que nao versionar ~/.local/share/kscreen/: o kscreen grava um arquivo por COMBINACAO
# de monitores, com nome derivado do hash dos EDIDs conectados. Trocar de porta, de cabo ou
# de placa muda o hash e o arquivo antigo deixa de valer. Aqui versionamos a decisao, nao o
# estado, e casamos por resolucao -- que sobrevive a troca de placa-mae.
#
# Formato do monitores.conf, um monitor por linha:
#   resolucao|rotacao|posicao|escala|primario
#   2560x1440|normal|1080,0|1|sim
# rotacao: normal, left, right, inverted
# posicao: x,y em pixels do canto superior esquerdo do desktop
# primario: sim ou nao
set -uo pipefail

aqui="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="${1:-$aqui/monitores.conf}"

for bin in kscreen-doctor jq; do
    command -v "$bin" >/dev/null 2>&1 || { printf 'monitores: %s ausente\n' "$bin" >&2; exit 1; }
done
[[ -f $CONF ]] || { printf 'monitores: %s nao encontrado\n' "$CONF" >&2; exit 1; }

json="$(kscreen-doctor -j 2>/dev/null)" || { printf 'monitores: kscreen-doctor nao respondeu\n' >&2; exit 1; }

nome_por_resolucao() {
    local largura="${1%x*}" altura="${1#*x}"
    jq -r --argjson w "$largura" --argjson h "$altura" '
        .outputs[]
        | select(.connected)
        | select([.modes[] | select(.size.width == $w and .size.height == $h)] | length > 0)
        | .name
    ' <<<"$json" | head -1
}

modo_por_resolucao() {
    local nome="$1" largura="${2%x*}" altura="${2#*x}"
    jq -r --arg n "$nome" --argjson w "$largura" --argjson h "$altura" '
        .outputs[] | select(.name == $n) | .modes[]
        | select(.size.width == $w and .size.height == $h)
        | "\(.size.width)x\(.size.height)@\(.refreshRate | floor)"
    ' <<<"$json" | sort -t@ -k2 -rn | head -1
}

args=()
achados=0
faltando=()

while IFS='|' read -r resolucao rotacao posicao escala primario; do
    [[ -z ${resolucao// } || $resolucao == \#* ]] && continue
    nome="$(nome_por_resolucao "$resolucao")"
    if [[ -z $nome ]]; then
        faltando+=("$resolucao")
        continue
    fi
    modo="$(modo_por_resolucao "$nome" "$resolucao")"
    args+=("output.$nome.enable")
    [[ -n $modo ]] && args+=("output.$nome.mode.$modo")
    args+=("output.$nome.rotation.$rotacao")
    args+=("output.$nome.position.$posicao")
    args+=("output.$nome.scale.$escala")
    [[ $primario == sim ]] && args+=("output.$nome.primary")
    achados=$((achados+1))
    printf 'monitores: %s -> %s %s em %s\n' "$resolucao" "$nome" "$rotacao" "$posicao"
done < "$CONF"

if (( ${#faltando[@]} )); then
    printf 'monitores: sem saida conectada para: %s\n' "${faltando[*]}" >&2
fi
if (( achados == 0 )); then
    printf 'monitores: nenhum monitor do conf esta conectado, nada a fazer\n' >&2
    exit 1
fi

if kscreen-doctor "${args[@]}" >/dev/null 2>&1; then
    printf 'monitores: %d aplicados\n' "$achados"
    exit 0
fi
printf 'monitores: kscreen-doctor recusou a configuracao\n' >&2
exit 1
