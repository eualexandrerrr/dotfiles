#!/usr/bin/env bash
# Abre os apps fixos do logon e confere se cada um chegou a criar janela.
#
#   ~/.dotfiles/bin/apps-logon.sh
#
# Existe porque exec-once nao tem repescagem: se o app morre nos primeiros segundos do
# login (disco ocupado, GPU ainda subindo, sandbox do Electron), ninguem o traz de volta.
# Cada app tem o padrao da classe de janela que as regras do hypr usam, para nao abrir
# duplicado quando ja subiu.
set -uo pipefail

ESPERA_ENTRE="${ESPERA_ENTRE:-2}"
ESPERA_REPESCAGEM="${ESPERA_REPESCAGEM:-25}"

APPS=(
    "[Gg]oogle-chrome|uwsm app -- google-chrome-stable"
    "[Dd]iscord|uwsm app -- discord"
    "[Rr][Cc]ode|uwsm app -- rcode"
    "[Ss]potify|uwsm app -- spotify-launcher"
)

command -v hyprctl >/dev/null 2>&1 || exit 0

tem_janela() {
    hyprctl clients 2>/dev/null | awk -F": " '/^\tclass: /{print $2}' | grep -qE "$1"
}

abrir_faltantes() {
    local entrada padrao cmd
    for entrada in "${APPS[@]}"; do
        padrao="${entrada%%|*}"
        cmd="${entrada#*|}"
        tem_janela "$padrao" && continue
        setsid bash -c "$cmd" >/dev/null 2>&1 &
        sleep "$ESPERA_ENTRE"
    done
}

abrir_faltantes
sleep "$ESPERA_REPESCAGEM"
abrir_faltantes
