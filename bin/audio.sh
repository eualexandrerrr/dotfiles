#!/usr/bin/env bash
# Padroes de audio: saida analogica como principal a 80%, HDMI a 50%, microfone a 80%.
#
#   ~/.dotfiles/bin/audio.sh
#
# Casa por nome de dispositivo do PipeWire (alsa_output.pci-...analog-stereo), nao por id:
# o id muda a cada boot e a cada monitor que entra ou sai. O id do pactl tambem nao e o
# mesmo id do wpctl, entao aqui tudo passa pelo pactl, pelo nome.
set -uo pipefail

ANALOGICO="${ANALOGICO:-analog-stereo}"
HDMI="${HDMI:-hdmi-stereo}"
VOL_PRINCIPAL="${VOL_PRINCIPAL:-80}"
VOL_HDMI="${VOL_HDMI:-50}"
VOL_MIC="${VOL_MIC:-80}"

command -v pactl >/dev/null 2>&1 || { printf 'audio: pactl ausente (libpulse)\n' >&2; exit 1; }

ok() { printf '  ok   %s\n' "$*"; }

saida_por_nome() { pactl list short sinks   2>/dev/null | awk -v p="$1" '$2 ~ p {print $2; exit}'; }
fonte_por_nome() { pactl list short sources 2>/dev/null | awk -v p="$1" '$2 ~ p && $2 !~ /monitor/ {print $2; exit}'; }

principal=""
for _ in $(seq 1 20); do
    principal="$(saida_por_nome "$ANALOGICO")"
    [[ -n $principal ]] && break
    sleep 0.5
done

if [[ -n ${principal:-} ]]; then
    pactl set-default-sink   "$principal" 2>/dev/null
    pactl set-sink-volume    "$principal" "${VOL_PRINCIPAL}%" 2>/dev/null
    pactl set-sink-mute      "$principal" 0 2>/dev/null
    ok "saida analogica em ${VOL_PRINCIPAL}%, como padrao"
else
    printf '  !!   nao achei saida %s\n' "$ANALOGICO" >&2
fi

hdmi="$(saida_por_nome "$HDMI")"
if [[ -n ${hdmi:-} ]]; then
    pactl set-sink-volume "$hdmi" "${VOL_HDMI}%" 2>/dev/null
    ok "HDMI em ${VOL_HDMI}%"
fi

mic="$(fonte_por_nome "$ANALOGICO")"
if [[ -n ${mic:-} ]]; then
    pactl set-default-source "$mic" 2>/dev/null
    pactl set-source-volume  "$mic" "${VOL_MIC}%" 2>/dev/null
    pactl set-source-mute    "$mic" 0 2>/dev/null
    ok "microfone em ${VOL_MIC}%"
fi
