#!/usr/bin/env bash
# Disposicao dos monitores, aplicada por kscreen-doctor a partir de kde/monitores.conf.
#
# Por que nao versionar ~/.local/share/kscreen/: o kscreen grava um arquivo por COMBINACAO
# de monitores, com nome derivado do hash dos EDIDs conectados. Trocar de porta, de cabo ou
# de placa muda o hash e o arquivo antigo deixa de valer. Aqui versionamos a decisao, nao o
# estado, e casamos por conector -- resolucao nao separa dois monitores iguais.
#
# Formato do monitores.conf, um monitor por linha:
#   chave|resolucao|rotacao|posicao|escala|primario
#   DP-1|2560x1440|normal|1440,0|1|sim
# chave: nome do conector (DP-1, HDMI-A-1) ou * pra "a proxima saida livre com essa
#        resolucao nativa". Nome vale quando os monitores sao iguais e a resolucao nao
#        separa; * vale quando trocar de placa e os nomes mudarem.
# rotacao: normal, left, right, inverted
# posicao: x,y em pixels do canto superior esquerdo do desktop
# primario: sim ou nao
set -uo pipefail

aqui="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$aqui/monitores.conf"
capturar=0

while (( $# )); do
    case "$1" in
        --capturar|-c) capturar=1 ;;
        *)             CONF="$1" ;;
    esac
    shift
done

for bin in kscreen-doctor jq; do
    command -v "$bin" >/dev/null 2>&1 || { printf 'monitores: %s ausente\n' "$bin" >&2; exit 1; }
done

json="$(kscreen-doctor -j 2>/dev/null)" || { printf 'monitores: kscreen-doctor nao respondeu\n' >&2; exit 1; }

if (( capturar )); then
    novo="$(jq -r '
        [.outputs[] | select(.connected and .enabled)] | sort_by(.pos.x, .pos.y)[]
        | . as $o
        | ($o.modes[] | select(.id == $o.currentModeId)) as $m
        | ({"1":"normal","2":"left","4":"inverted","8":"right"}[$o.rotation|tostring] // "normal") as $rot
        | (if ($o.scale|floor) == $o.scale then ($o.scale|floor|tostring) else ($o.scale|tostring) end) as $esc
        | (if $o.priority == 1 then "sim" else "nao" end) as $pri
        | "\($o.name)|\($m.size.width)x\($m.size.height)|\($rot)|\($o.pos.x),\($o.pos.y)|\($esc)|\($pri)"
    ' <<<"$json")"
    [[ -n $novo ]] || { printf 'monitores: nada a capturar\n' >&2; exit 1; }
    printf '%s\n' "$novo" > "$CONF"
    printf 'monitores: disposicao atual gravada em %s\n' "${CONF/#$HOME/\~}"
    sed 's/^/  /' "$CONF"
    exit 0
fi

[[ -f $CONF ]] || { printf 'monitores: %s nao encontrado\n' "$CONF" >&2; exit 1; }

usados=()
pos_esperada=()
rot_esperada=()

ja_usado() {
    local n
    for n in "${usados[@]}"; do [[ $n == "$1" ]] && return 0; done
    return 1
}

saida_por_nome() {
    jq -r --arg n "$1" '.outputs[] | select(.connected and .name == $n) | .name' <<<"$json" | head -1
}

saida_livre_por_resolucao_nativa() {
    local largura="${1%x*}" altura="${1#*x}" n
    while IFS= read -r n; do
        [[ -z $n ]] && continue
        ja_usado "$n" || { printf '%s' "$n"; return 0; }
    done < <(jq -r --argjson w "$largura" --argjson h "$altura" '
        .outputs[]
        | select(.connected)
        | . as $o
        | ($o.preferredModes[0] // $o.currentModeId) as $pid
        | ($o.modes[] | select(.id == $pid)) as $m
        | select($m.size.width == $w and $m.size.height == $h)
        | $o.name
    ' <<<"$json" | sort)
    return 1
}

modo_por_resolucao() {
    local nome="$1" largura="${2%x*}" altura="${2#*x}"
    jq -r --arg n "$nome" --argjson w "$largura" --argjson h "$altura" '
        [.outputs[] | select(.name == $n) | .modes[]
         | select(.size.width == $w and .size.height == $h)]
        | sort_by(.refreshRate) | reverse | .[0].name // empty
    ' <<<"$json"
}

args=()
achados=0
faltando=()

while IFS='|' read -r chave resolucao rotacao posicao escala primario; do
    [[ -z ${chave// } || $chave == \#* ]] && continue
    if [[ $chave == '*' ]]; then
        nome="$(saida_livre_por_resolucao_nativa "$resolucao")"
    else
        nome="$(saida_por_nome "$chave")"
        if [[ -n $nome ]] && ja_usado "$nome"; then
            printf 'monitores: %s aparece duas vezes no conf, ignorando a segunda\n' "$nome" >&2
            continue
        fi
    fi
    if [[ -z $nome ]]; then
        faltando+=("$chave $resolucao")
        continue
    fi
    usados+=("$nome")
    pos_esperada+=("$posicao")
    rot_esperada+=("$rotacao")
    modo="$(modo_por_resolucao "$nome" "$resolucao")"
    args+=("output.$nome.enable")
    [[ -n $modo ]] && args+=("output.$nome.mode.$modo")
    args+=("output.$nome.rotation.$rotacao")
    args+=("output.$nome.position.$posicao")
    args+=("output.$nome.scale.$escala")
    [[ $primario == sim ]] && args+=("output.$nome.primary")
    achados=$((achados+1))
    printf 'monitores: %s -> %s %s %s em %s\n' "$chave" "$nome" "$resolucao" "$rotacao" "$posicao"
done < "$CONF"

if (( ${#faltando[@]} )); then
    printf 'monitores: sem saida conectada para: %s\n' "${faltando[*]}" >&2
fi
if (( achados == 0 )); then
    printf 'monitores: nenhum monitor do conf esta conectado, nada a fazer\n' >&2
    exit 1
fi

saida="$(kscreen-doctor "${args[@]}" 2>&1)"

sleep 1
json="$(kscreen-doctor -j 2>/dev/null)" || { printf 'monitores: kscreen-doctor nao respondeu na conferencia\n' >&2; exit 1; }

divergentes=0
for i in "${!usados[@]}"; do
    nome="${usados[$i]}"
    esperado_pos="${pos_esperada[$i]}"
    esperado_rot="${rot_esperada[$i]}"
    atual="$(jq -r --arg n "$nome" '.outputs[] | select(.name == $n)
        | "\(.pos.x),\(.pos.y)|\(.rotation)"' <<<"$json")"
    atual_pos="${atual%%|*}"
    case "${atual##*|}" in
        1) atual_rot=normal ;; 2) atual_rot=left ;; 4) atual_rot=inverted ;; 8) atual_rot=right ;;
        *) atual_rot=desconhecida ;;
    esac
    if [[ $atual_pos != "$esperado_pos" || $atual_rot != "$esperado_rot" ]]; then
        printf 'monitores: %s ficou %s %s, esperado %s %s\n' \
            "$nome" "$atual_rot" "$atual_pos" "$esperado_rot" "$esperado_pos" >&2
        divergentes=$((divergentes+1))
    fi
done

if (( divergentes )); then
    printf 'monitores: %d de %d fora do lugar\n' "$divergentes" "$achados" >&2
    [[ -n $saida ]] && printf 'monitores: kscreen-doctor disse -> %s\n' "$saida" >&2
    printf 'monitores: comando -> kscreen-doctor %s\n' "${args[*]}" >&2
    exit 1
fi
printf 'monitores: %d aplicados e conferidos\n' "$achados"
exit 0
