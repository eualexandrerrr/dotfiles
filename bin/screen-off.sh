#!/usr/bin/env bash
# Painel de desligamento: fixa no topo do console o que ainda segura a maquina e deixa as
# mensagens finais do systemd-shutdown rolarem embaixo, no rodape. E a unica janela que
# sobra depois que o journald morre -- se a tela travar, o culpado esta listado aqui.
#
#   /usr/local/bin/tela-desligar          instalado pelo setup.sh, chamado por systemd
#   tela-desligar --ultimo                mostra o que estava vivo no desligamento passado
#   TELA_TTY=/dev/tty3 screen-off.sh   forca um console pra testar com a sessao aberta
set -u

REGISTRO=/var/log/tela-desligar.log

if [[ ${1:-} == --ultimo ]]; then
    [[ -r $REGISTRO ]] || { printf 'sem registro em %s ainda\n' "$REGISTRO" >&2; exit 1; }
    awk '/^== /{bloco=""} {bloco = bloco $0 "\n"} END{printf "%s", bloco}' "$REGISTRO"
    exit 0
fi

TTY="${TELA_TTY:-/dev/console}"
[[ -w $TTY ]] || TTY=/dev/tty1
[[ -w $TTY ]] || exit 0
exec >"$TTY" 2>/dev/null

E=$'\e'
R="${E}[0m"; B="${E}[1m"
DIM="${E}[90m"; TXT="${E}[97m"; AZ="${E}[94m"
VD="${E}[92m"; AM="${E}[93m"; VM="${E}[91m"; RX="${E}[95m"

LINHAS=25; COLUNAS=80
if leitura="$(stty -F "$TTY" size 2>/dev/null)"; then
    set -- $leitura
    [[ ${1:-0} -gt 10 ]] && LINHAS=$1
    [[ ${2:-0} -gt 40 ]] && COLUNAS=$2
fi
L=$(( COLUNAS - 6 )); (( L > 74 )) && L=74
RODAPE_MIN=5

BUF=()
add()     { BUF+=("$1"); }
repetir() { local i s=''; for ((i = 0; i < $2; i++)); do s+="$1"; done; printf '%s' "$s"; }
regua()   { add "$(printf '   %s%s%s' "$DIM" "$(repetir '─' "$L")" "$R")"; }
titulo()  { add ''; add "$(printf '   %s%s%s %s%s%s' "$B$RX" "$1" "$R" "$DIM" "$(repetir '─' $(( L - ${#1} - 1 )))" "$R")"; }
campo()   { add "$(printf '     %s%-29s%s %s%s%s' "$DIM" "$1" "$R" "${3:-$TXT}" "$2" "$R")"; }
lista()   {
    local cor="$1"; shift
    local v total=$#
    for v in "${@:1:$MAX}"; do add "$(printf '       %s·  %s%s' "$cor" "$v" "$R")"; done
    (( MAX && total > MAX )) && add "$(printf '       %s   e mais %d%s' "$DIM" $(( total - MAX )) "$R")"
    return 0
}

alvo() {
    local j
    j="$(timeout 2 /usr/bin/systemctl list-jobs --no-legend 2>/dev/null)"
    case $j in
        *poweroff.target*) printf 'DESLIGANDO' ;;
        *reboot.target*)   printf 'REINICIANDO' ;;
        *halt.target*)     printf 'PARANDO' ;;
        *)                 printf 'ENCERRANDO' ;;
    esac
}

ligada_ha() {
    local s h m
    read -r s _ < /proc/uptime 2>/dev/null
    s=${s%%.*}; h=$(( s / 3600 )); m=$(( (s % 3600) / 60 ))
    (( h )) && printf '%dh %dmin' "$h" "$m" || printf '%dmin' "$m"
}

travados() {
    local d nome estado k v
    for d in /proc/[0-9]*; do
        [[ -s $d/cmdline ]] || continue
        [[ -r $d/status ]]  || continue
        nome=''; estado=''
        while IFS=$'\t' read -r k v; do
            case $k in
                Name:)  nome=$v ;;
                State:) estado=${v%% *}; break ;;
            esac
        done < "$d/status" 2>/dev/null
        [[ $estado == D ]] && printf '%s  %s\n' "${d#/proc/}" "$nome"
    done
}

montagens() {
    local dev ponto tipo resto
    while read -r dev ponto tipo resto; do
        case $tipo in
            ext4|xfs|btrfs|vfat|exfat|ntfs3|f2fs|nfs|nfs4|cifs|fuseblk) ;;
            *) continue ;;
        esac
        printf '%-32s %s\n' "$ponto" "$tipo"
    done < /proc/self/mounts
}

swaps()    { sed -n '2,$p' /proc/swaps 2>/dev/null | awk '{print $1}'; }
unidades() { timeout 3 /usr/bin/systemctl list-units --type=service --state=running --no-legend --plain 2>/dev/null | awk '{sub(/\.service$/,"",$1); print $1}'; }

ALVO="$(alvo)"
HOST="$(< /proc/sys/kernel/hostname)"
KERNEL="$(< /proc/sys/kernel/osrelease)"
LIGADA="$(ligada_ha)"

mapfile -t TRAVADOS  < <(travados)
mapfile -t MONTAGENS < <(montagens)
mapfile -t SWAPS     < <(swaps)
mapfile -t UNIDADES  < <(unidades)

montar() {
    BUF=()
    add ''
    add "$(printf '   %s%s██%s  %s%s%s' "$B" "$RX" "$R" "$B$TXT" "$ALVO" "$R")"
    add "$(printf '   %s%s██%s  %s%s · %s · ligada ha %s%s' "$B" "$RX" "$R" "$DIM" \
        "$HOST" "$KERNEL" "$LIGADA" "$R")"
    add ''
    regua

    titulo 'o que ainda respira'

    if (( ${#TRAVADOS[@]} )); then
        campo 'processos presos em disco' "${#TRAVADOS[@]}  nao morrem nem com SIGKILL" "$VM"
        lista "$VM" "${TRAVADOS[@]}"
    else
        campo 'processos presos em disco' 'nenhum' "$VD"
    fi

    if (( ${#MONTAGENS[@]} )); then
        campo 'sistemas de arquivos montados' "${#MONTAGENS[@]}" "$AM"
        lista "$AM" "${MONTAGENS[@]}"
    else
        campo 'sistemas de arquivos montados' 'nenhum' "$VD"
    fi

    if (( ${#SWAPS[@]} )); then
        campo 'swap ainda ativo' "${SWAPS[*]}" "$AM"
    else
        campo 'swap ainda ativo' 'nao' "$VD"
    fi

    if (( ${#UNIDADES[@]} )); then
        campo 'servicos ainda rodando' "${#UNIDADES[@]}" "$AM"
        lista "$AM" "${UNIDADES[@]}"
    else
        campo 'servicos ainda rodando' 'nenhum' "$VD"
    fi

    titulo 'daqui pra frente nada mais vai pro journal'
    add "$(printf '     %sSIGTERM   SIGKILL   desmontar   remontar ro   cortar energia%s' "$AZ" "$R")"
    add "$(printf '     %sse a tela congelar agora, o culpado esta na lista acima%s' "$DIM" "$R")"
    add ''
    regua
}

for MAX in 8 6 4 3 2 1 0; do
    montar
    (( ${#BUF[@]} + RODAPE_MIN <= LINHAS )) && break
done

printf '%s[r%s[2J%s[H' "$E" "$E" "$E"
printf '%s\n' "${BUF[@]}"

RODAPE=$(( ${#BUF[@]} + 1 ))
if (( LINHAS > RODAPE )); then
    printf '%s[%d;%dr%s[%d;1H' "$E" "$RODAPE" "$LINHAS" "$E" "$RODAPE"
fi

{
    printf '== %s  %s  %s\n' "$(date '+%d/%m/%Y %H:%M:%S' 2>/dev/null)" "$ALVO" "$HOST"
    printf '%s\n' "${BUF[@]}" | sed 's/\x1b\[[0-9;]*m//g'
} >>"$REGISTRO" 2>/dev/null

if [[ -w $REGISTRO ]]; then
    tail -n 240 "$REGISTRO" >"$REGISTRO.tmp" 2>/dev/null \
        && mv -f "$REGISTRO.tmp" "$REGISTRO" 2>/dev/null
fi
sync 2>/dev/null

sleep "${TELA_PAUSA:-1.5}"
exit 0
