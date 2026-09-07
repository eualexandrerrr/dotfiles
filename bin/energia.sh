#!/usr/bin/env bash
# Garante que o PC nunca durma: nem suspender, nem hibernar, nem desligar por inatividade.
# A unica coisa que a inatividade faz e apagar os monitores, em 5 minutos -- e isso quem
# faz e o hypridle (hypr/hypridle.conf), nao este script.
#
#   ~/.dotfiles/bin/energia.sh
set -uo pipefail

ok()    { printf '  ok   %s\n' "$*"; }
aviso() { printf '  !!   %s\n' "$*" >&2; }

ALVOS=(sleep.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target)

faltam=()
for alvo in "${ALVOS[@]}"; do
    if [[ "$(/usr/bin/systemctl is-enabled "$alvo" 2>/dev/null)" != masked ]]; then
        faltam+=("$alvo")
    fi
done

if (( ${#faltam[@]} )); then
    if sudo -n true 2>/dev/null || [[ -t 0 ]]; then
        if sudo /usr/bin/systemctl mask "${faltam[@]}" >/dev/null 2>&1; then
            ok "systemd: ${#faltam[@]} alvo(s) de sono mascarado(s)"
        else
            aviso "nao consegui mascarar: ${faltam[*]}"
        fi
    else
        aviso "sem sudo agora; rode a mao: sudo systemctl mask ${faltam[*]}"
    fi
else
    ok "systemd: sono ja estava mascarado"
fi

CONF=/etc/systemd/logind.conf.d/99-nunca-dormir.conf
desejado='[Login]
IdleAction=ignore
IdleActionSec=0
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
'
if [[ -f $CONF ]] && [[ "$(cat "$CONF" 2>/dev/null)" == "$desejado" ]]; then
    ok "logind ja configurado"
elif sudo -n true 2>/dev/null || [[ -t 0 ]]; then
    if sudo install -Dm644 /dev/stdin "$CONF" <<<"$desejado" 2>/dev/null; then
        ok "logind: IdleAction=ignore"
        sudo /usr/bin/systemctl kill -s HUP systemd-logind 2>/dev/null || true
    else
        aviso "nao consegui escrever $CONF"
    fi
else
    aviso "sem sudo agora; $CONF nao foi escrito"
fi

if pidof hypridle >/dev/null 2>&1; then
    pkill -x hypridle 2>/dev/null || true
    if command -v uwsm >/dev/null 2>&1 && [[ -n ${WAYLAND_DISPLAY:-} ]]; then
        uwsm app -- hypridle >/dev/null 2>&1 &
    else
        hypridle >/dev/null 2>&1 &
    fi
    ok "hypridle reiniciado"
fi
