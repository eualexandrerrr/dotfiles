#!/usr/bin/env bash
# Mede os resolvedores de DNS e poe os dois mais rapidos na conexao do NetworkManager.
#
#   dns-rapido.sh              mede e aplica
#   dns-rapido.sh --medir      so mede, nao muda nada
#   dns-rapido.sh --restaurar  devolve o DNS do DHCP (o roteador)
#
# A medicao usa subdominio aleatorio de proposito. Perguntar "google.com" pro roteador
# responde em 6 ms porque esta em cache; o que interessa e o tempo quando NAO esta, que e
# quando ele precisa sair pra rede. Medido aqui: roteador 195 ms, Cloudflare 25 ms.
set -uo pipefail

RODADAS="${RODADAS:-3}"
DOMINIO_BASE="${DOMINIO_BASE:-wikipedia.org}"
TIMEOUT="${TIMEOUT:-2}"

CANDIDATOS=(
    "1.1.1.1|Cloudflare"
    "1.0.0.1|Cloudflare 2"
    "8.8.8.8|Google"
    "8.8.4.4|Google 2"
    "9.9.9.9|Quad9"
    "149.112.112.112|Quad9 2"
    "94.140.14.14|AdGuard"
    "208.67.222.222|OpenDNS"
)

acao=aplicar
case "${1:-}" in
    --medir|-m)     acao=medir ;;
    --restaurar|-r) acao=restaurar ;;
    -h|--help)      sed -n '2,10p' "${BASH_SOURCE[0]}"; exit 0 ;;
    "")             ;;
    *)              printf 'opcao desconhecida: %s\n' "$1" >&2; exit 1 ;;
esac

command -v nmcli >/dev/null 2>&1 || { printf 'dns: nmcli ausente\n' >&2; exit 1; }

conexao="$(nmcli -t -f NAME,TYPE con show --active 2>/dev/null | grep -vE ':(loopback|bridge)$' | head -1 | cut -d: -f1)"
[[ -n $conexao ]] || { printf 'dns: nenhuma conexao ativa\n' >&2; exit 1; }

if [[ $acao == restaurar ]]; then
    sudo nmcli con mod "$conexao" ipv4.ignore-auto-dns no ipv4.dns "" \
                                  ipv6.ignore-auto-dns no ipv6.dns "" 2>/dev/null \
        && sudo nmcli con up "$conexao" >/dev/null 2>&1 \
        && { printf 'dns: %s voltou pro DNS do DHCP\n' "$conexao"; exit 0; }
    printf 'dns: nao consegui restaurar\n' >&2; exit 1
fi

command -v drill >/dev/null 2>&1 || { printf 'dns: drill ausente (pacote ldns)\n' >&2; exit 1; }

gateway="$(ip route | awk '/^default/ {print $3; exit}')"
[[ -n ${gateway:-} ]] && CANDIDATOS+=("$gateway|Roteador")

medir() {
    local ip="$1" total=0 ok=0 i ini fim d
    for ((i=1; i<=RODADAS; i++)); do
        d="dns$RANDOM$i.$DOMINIO_BASE"
        ini=$(date +%s%N)
        if timeout "$TIMEOUT" drill -Q @"$ip" "$d" A >/dev/null 2>&1; then
            fim=$(date +%s%N)
            total=$(( total + (fim - ini) / 1000000 ))
            ok=$((ok+1))
        fi
    done
    (( ok >= 2 )) || return 1
    printf '%d' $(( total / ok ))
}

printf 'dns: medindo %d resolvedores, %d consultas sem cache cada\n\n' "${#CANDIDATOS[@]}" "$RODADAS"
resultados=()
for c in "${CANDIDATOS[@]}"; do
    ip="${c%%|*}"; nome="${c#*|}"
    if ms="$(medir "$ip")"; then
        resultados+=("$ms|$ip|$nome")
        printf '  %-16s %-12s %5d ms\n' "$ip" "$nome" "$ms"
    else
        printf '  %-16s %-12s   falhou\n' "$ip" "$nome"
    fi
done

(( ${#resultados[@]} >= 1 )) || { printf '\ndns: nenhum resolvedor respondeu\n' >&2; exit 1; }

mapfile -t ordenados < <(printf '%s\n' "${resultados[@]}" | sort -t'|' -k1,1n)

# Dois de operadores diferentes: se um cair, o outro nao cai junto.
primeiro="${ordenados[0]}"
op1="$(cut -d'|' -f3 <<<"$primeiro" | awk '{print $1}')"
segundo=""
for r in "${ordenados[@]:1}"; do
    [[ "$(cut -d'|' -f3 <<<"$r" | awk '{print $1}')" != "$op1" ]] && { segundo="$r"; break; }
done
[[ -z $segundo && ${#ordenados[@]} -gt 1 ]] && segundo="${ordenados[1]}"

ip1="$(cut -d'|' -f2 <<<"$primeiro")"; ms1="$(cut -d'|' -f1 <<<"$primeiro")"; n1="$(cut -d'|' -f3 <<<"$primeiro")"
lista="$ip1"
resumo="$n1 ($ms1 ms)"
if [[ -n $segundo ]]; then
    ip2="$(cut -d'|' -f2 <<<"$segundo")"; ms2="$(cut -d'|' -f1 <<<"$segundo")"; n2="$(cut -d'|' -f3 <<<"$segundo")"
    lista="$ip1,$ip2"
    resumo="$resumo + $n2 ($ms2 ms)"
fi

printf '\ndns: mais rapido -> %s\n' "$resumo"

if [[ $acao == medir ]]; then
    printf 'dns: (--medir) nada foi alterado\n'
    exit 0
fi

atual="$(nmcli -g ipv4.dns con show "$conexao" 2>/dev/null)"
if [[ $atual == "$lista" ]]; then
    printf 'dns: %s ja usa %s, nada a fazer\n' "$conexao" "$lista"
    exit 0
fi

if sudo nmcli con mod "$conexao" ipv4.dns "$lista" ipv4.ignore-auto-dns yes \
                              ipv6.dns "" ipv6.ignore-auto-dns yes 2>/dev/null \
   && sudo nmcli con up "$conexao" >/dev/null 2>&1; then
    printf 'dns: %s agora usa %s\n' "$conexao" "$lista"
else
    printf 'dns: nao consegui aplicar (precisa de sudo)\n' >&2
    exit 1
fi
