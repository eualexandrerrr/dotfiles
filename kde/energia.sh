#!/usr/bin/env bash
# Garante que o PC nunca durma: nem suspender, nem hibernar, nem desligar por inatividade.
# A unica coisa que a inatividade faz e apagar os monitores, em 5 minutos.
#
#   ~/.dotfiles/kde/energia.sh
#
set -uo pipefail

ok()    { printf '  ok   %s\n' "$*"; }
aviso() { printf '  !!   %s\n' "$*" >&2; }

ALVOS=(sleep.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target)

mascarados=0
faltam=()
for alvo in "${ALVOS[@]}"; do
    if [[ "$(systemctl is-enabled "$alvo" 2>/dev/null)" == masked ]]; then
        mascarados=$((mascarados+1))
    else
        faltam+=("$alvo")
    fi
done

if (( ${#faltam[@]} )); then
    if sudo -n true 2>/dev/null || [[ -t 0 ]]; then
        if sudo systemctl mask "${faltam[@]}" >/dev/null 2>&1; then
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
        sudo systemctl kill -s HUP systemd-logind 2>/dev/null || true
    else
        aviso "nao consegui escrever $CONF"
    fi
else
    aviso "sem sudo agora; $CONF nao foi escrito"
fi

if [[ ! -L $HOME/.config/powerdevilrc ]] && command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file powerdevilrc --group AC --key autoSuspendAction 0
    kwriteconfig6 --file powerdevilrc --group AC --key turnOffDisplayWhenIdle true
    kwriteconfig6 --file powerdevilrc --group AC --key turnOffDisplayIdleTimeoutSec 300
    kwriteconfig6 --file powerdevilrc --group AC --key dimDisplayWhenIdle false
    ok "powerdevilrc escrito (nao estava linkado pelo stow)"
fi

if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement refreshStatus >/dev/null 2>&1 \
        && ok "powerdevil recarregado" \
        || systemctl --user restart plasma-powerdevil.service 2>/dev/null && ok "powerdevil reiniciado"
fi
