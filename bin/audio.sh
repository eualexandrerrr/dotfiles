#!/usr/bin/env bash
# Padroes de audio: saida analogica como principal a 80%, HDMI a 50%, microfone a 80%.
#
#   ~/.dotfiles/bin/audio.sh
#
# Casa por nome de dispositivo do PipeWire (alsa_output.pci-...analog-stereo), nao por id:
# o id muda a cada boot e a cada monitor que entra ou sai.
set -uo pipefail

ANALOGICO="${ANALOGICO:-analog-stereo}"
HDMI="${HDMI:-hdmi-stereo}"
VOL_PRINCIPAL="${VOL_PRINCIPAL:-0.80}"
VOL_HDMI="${VOL_HDMI:-0.50}"
VOL_MIC="${VOL_MIC:-0.80}"

command -v wpctl  >/dev/null 2>&1 || { printf 'audio: wpctl ausente (pipewire)\n' >&2; exit 1; }
command -v pactl  >/dev/null 2>&1 || { printf 'audio: pactl ausente (libpulse)\n' >&2; exit 1; }

ok() { printf '  ok   %s\n' "$*"; }

saida_por_nome() { pactl list short sinks   2>/dev/null | awk -v p="$1" '$2 ~ p {print $1; exit}'; }
fonte_por_nome() { pactl list short sources 2>/dev/null | awk -v p="$1" '$2 ~ p && $2 !~ /monitor/ {print $1; exit}'; }
nome_da_saida()  { pactl list short sinks   2>/dev/null | awk -v i="$1" '$1 == i {print $2; exit}'; }

principal="$(saida_por_nome "$ANALOGICO")"
if [[ -n ${principal:-} ]]; then
    pactl set-default-sink "$(nome_da_saida "$principal")" 2>/dev/null
    wpctl set-volume "$principal" "$VOL_PRINCIPAL" 2>/dev/null
    wpctl set-mute   "$principal" 0 2>/dev/null
    ok "saida analogica em $(awk -v v="$VOL_PRINCIPAL" 'BEGIN{printf "%d%%", v*100}'), como padrao"
else
    printf '  !!   nao achei saida %s\n' "$ANALOGICO" >&2
fi

hdmi="$(saida_por_nome "$HDMI")"
if [[ -n ${hdmi:-} ]]; then
    wpctl set-volume "$hdmi" "$VOL_HDMI" 2>/dev/null
    ok "HDMI em $(awk -v v="$VOL_HDMI" 'BEGIN{printf "%d%%", v*100}')"
fi

mic="$(fonte_por_nome "$ANALOGICO")"
if [[ -n ${mic:-} ]]; then
    pactl set-default-source "$(pactl list short sources | awk -v i="$mic" '$1==i{print $2;exit}')" 2>/dev/null
    wpctl set-volume "$mic" "$VOL_MIC" 2>/dev/null
    wpctl set-mute   "$mic" 0 2>/dev/null
    ok "microfone em $(awk -v v="$VOL_MIC" 'BEGIN{printf "%d%%", v*100}')"
fi
