#!/usr/bin/env bash
# Player do Spotify na waybar: texto e os tres botoes, tudo por playerctl na linha de comando.
#
# O modulo mpris nativo da waybar foi descartado: ele derrubou a barra inteira (SIGSEGV dentro
# de libplayerctl.so.2) quando o Spotify saiu e voltou. Chamando o playerctl por fora, um erro
# dele no maximo apaga o modulo, nao mata a barra.
#
# Uso: "texto", "estado", "anterior", "alternar", "proximo".
set -uo pipefail

PLAYER=spotify
LIMITE=34

ANTERIOR=$'\U000f04ae'
PROXIMO=$'\U000f04ad'
TOCAR=$'\U000f040a'
PAUSAR=$'\U000f03e4'
NOTA=$'\U000f075a'

status() { playerctl --player="$PLAYER" status 2>/dev/null; }

# Sem player nenhum o modulo tem de sumir, e nao mostrar "No player".
tocando_ou_pausado() {
    local s; s="$(status)"
    [[ $s == Playing || $s == Paused ]]
}

json() { printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$1" "$2" "$3"; }

escapar() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

case "${1:-texto}" in
    texto)
        tocando_ou_pausado || { json "" "" "vazio"; exit 0; }
        titulo="$(playerctl --player="$PLAYER" metadata title 2>/dev/null)"
        artista="$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)"
        [[ -n $titulo ]] || { json "" "" "vazio"; exit 0; }
        if [[ -n $artista ]]; then linha="$artista — $titulo"; else linha="$titulo"; fi
        curto="$linha"
        (( ${#curto} > LIMITE )) && curto="${curto:0:LIMITE}…"
        album="$(playerctl --player="$PLAYER" metadata album 2>/dev/null)"
        # \n aqui fica literal de proposito: quebra de linha crua invalidaria o JSON
        dica="$(printf '%s' "$titulo" | escapar)"
        [[ -n $artista ]] && dica="$dica\\n$(printf '%s' "$artista" | escapar)"
        [[ -n $album ]] && dica="$dica\\n$(printf '%s' "$album" | escapar)"
        json "$NOTA $(printf '%s' "$curto" | escapar)" "$dica" "$(status)"
        ;;
    estado)
        tocando_ou_pausado || { json "" "" "vazio"; exit 0; }
        if [[ "$(status)" == Playing ]]; then json "$PAUSAR" "Pausar" "tocando"
        else json "$TOCAR" "Tocar" "pausado"; fi
        ;;
    anterior|proximo)
        tocando_ou_pausado || { json "" "" "vazio"; exit 0; }
        [[ $1 == anterior ]] && json "$ANTERIOR" "Faixa anterior" "botao" || json "$PROXIMO" "Proxima faixa" "botao"
        ;;
    voltar)   playerctl --player="$PLAYER" previous 2>/dev/null ;;
    alternar) playerctl --player="$PLAYER" play-pause 2>/dev/null ;;
    avancar)  playerctl --player="$PLAYER" next 2>/dev/null ;;
esac
